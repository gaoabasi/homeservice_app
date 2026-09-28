<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\ProviderDocument;
use App\Models\Review;
use App\Models\ServiceProvider;
use App\Models\ServiceRequest;
use App\Services\FileUploadService;
use App\Services\LocationPrivacyService;
use App\Services\RequestDispatchService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CustomerController extends Controller
{
    protected RequestDispatchService $dispatchService;
    protected FileUploadService $fileUploadService;

    public function __construct(RequestDispatchService $dispatchService, FileUploadService $fileUploadService)
    {
        $this->dispatchService = $dispatchService;
        $this->fileUploadService = $fileUploadService;
    }

    public function createServiceRequest(Request $request)
    {
        $customer = $request->user()->customer;

        if (!$customer) {
            return response()->json(['message' => 'User is not a registered customer.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'service_id' => 'required|exists:services,id',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'address_text' => 'required|string',
            'problem_description' => 'required|string',
            'urgency' => 'nullable|in:normal,urgent,emergency',
            'photos_json' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $serviceRequest = ServiceRequest::create([
            'customer_id' => $customer->id,
            'service_id' => $request->service_id,
            'urgency' => $request->urgency ?? 'normal',
            'status' => 'pending',
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'address_text' => $request->address_text,
            'problem_description' => $request->problem_description,
            'photos_json' => $request->photos_json ?? [],
        ]);

        // Trigger dispatching pipeline
        $dispatchResult = $this->dispatchService->dispatchRequest($serviceRequest);

        return response()->json([
            'message' => 'Service request created successfully',
            'request' => $serviceRequest->fresh(['service', 'assignedProvider.user']),
            'dispatch_status' => $dispatchResult,
        ], 201);
    }

    public function applyProvider(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'national_id' => 'required|string',
            'bio' => 'nullable|string',
            'experience_years' => 'required|integer|min:0',
            'service_ids' => 'required|array|min:1',
            'service_ids.*' => 'exists:services,id',
            'document' => 'nullable|file',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $provider = ServiceProvider::updateOrCreate(
            ['user_id' => $user->id],
            [
                'national_id' => $request->national_id,
                'bio' => $request->bio,
                'experience_years' => $request->experience_years,
                'verification_status' => 'pending', // Queued for admin inspection
                'is_online' => false,
                'is_available' => true,
            ]
        );

        $provider->services()->sync($request->service_ids);

        // Upload verification document if provided
        if ($request->hasFile('document')) {
            try {
                $uploadData = $this->fileUploadService->uploadFile($request->file('document'), 'provider_documents');

                ProviderDocument::create([
                    'service_provider_id' => $provider->id,
                    'document_type' => 'national_id_certificate',
                    'file_path' => $uploadData['file_path'],
                    'mime_type' => $uploadData['mime_type'],
                    'verification_status' => 'pending',
                ]);
            } catch (\Exception $e) {
                // Document upload optional error catch
            }
        }

        return response()->json([
            'message' => 'Your application to become a Service Provider has been submitted successfully and is queued for Admin inspection and approval.',
            'provider' => $provider->load(['user', 'services', 'documents']),
        ], 201);
    }

    public function myRequests(Request $request)
    {
        $customer = $request->user()->customer;

        $requests = ServiceRequest::where('customer_id', $customer->id)
            ->with(['service', 'assignedProvider.user', 'booking'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json(['requests' => $requests]);
    }

    public function requestDetails(Request $request, $id)
    {
        $customer = $request->user()->customer;

        $serviceRequest = ServiceRequest::where('customer_id', $customer->id)
            ->with(['service', 'assignedProvider.user', 'booking.payment', 'booking.review'])
            ->findOrFail($id);

        return response()->json(['request' => $serviceRequest]);
    }

    public function rateProvider(Request $request, $bookingId)
    {
        $customer = $request->user()->customer;

        $booking = Booking::where('customer_id', $customer->id)
            ->where('status', 'completed')
            ->findOrFail($bookingId);

        $validator = Validator::make($request->all(), [
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $review = Review::create([
            'booking_id' => $booking->id,
            'customer_id' => $customer->id,
            'service_provider_id' => $booking->service_provider_id,
            'rating' => $request->rating,
            'comment' => $request->comment,
        ]);

        // Recalculate provider cache rating
        $provider = $booking->serviceProvider;
        $avgRating = Review::where('service_provider_id', $provider->id)->avg('rating');
        $provider->update(['rating_cache' => round($avgRating, 2)]);

        return response()->json([
            'message' => 'Review submitted successfully',
            'review' => $review,
        ]);
    }
}
