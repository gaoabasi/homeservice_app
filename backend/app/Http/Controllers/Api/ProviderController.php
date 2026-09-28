<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProviderDocument;
use App\Models\RequestAssignment;
use App\Models\ServiceRequest;
use App\Services\FileUploadService;
use App\Services\LocationPrivacyService;
use App\Services\RequestDispatchService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ProviderController extends Controller
{
    protected RequestDispatchService $dispatchService;
    protected FileUploadService $fileUploadService;

    public function __construct(RequestDispatchService $dispatchService, FileUploadService $fileUploadService)
    {
        $this->dispatchService = $dispatchService;
        $this->fileUploadService = $fileUploadService;
    }

    public function toggleOnlineStatus(Request $request)
    {
        $provider = $request->user()->serviceProvider;

        if ($provider->verification_status !== 'verified') {
            return response()->json([
                'message' => 'Your account must be verified by admin before going online.',
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'is_online' => 'required|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $provider->update([
            'is_online' => $request->is_online,
        ]);

        return response()->json([
            'message' => 'Online status updated',
            'is_online' => $provider->is_online,
        ]);
    }

    public function updateLocation(Request $request)
    {
        $provider = $request->user()->serviceProvider;

        $validator = Validator::make($request->all(), [
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $provider->update([
            'current_latitude' => $request->latitude,
            'current_longitude' => $request->longitude,
            'last_location_update' => now(),
        ]);

        return response()->json(['message' => 'Location updated successfully']);
    }

    public function pendingOffers(Request $request)
    {
        $provider = $request->user()->serviceProvider;

        $offers = RequestAssignment::where('service_provider_id', $provider->id)
            ->where('status', 'offered')
            ->with(['serviceRequest.service', 'serviceRequest.customer.user'])
            ->get()
            ->map(function ($assignment) use ($request) {
                $sr = $assignment->serviceRequest;
                $locationPayload = LocationPrivacyService::formatRequestLocation($sr, $request->user(), $assignment->distance_km);

                return [
                    'assignment_id' => $assignment->id,
                    'request_id' => $sr->id,
                    'service_name' => $sr->service->name,
                    'urgency' => $sr->urgency,
                    'problem_description' => $sr->problem_description,
                    'location' => $locationPayload,
                    'offered_at' => $assignment->offered_at,
                ];
            });

        return response()->json(['pending_offers' => $offers]);
    }

    public function acceptOffer(Request $request, $assignmentId)
    {
        $provider = $request->user()->serviceProvider;

        $assignment = RequestAssignment::where('service_provider_id', $provider->id)
            ->where('status', 'offered')
            ->findOrFail($assignmentId);

        $booking = $this->dispatchService->acceptOffer($assignment);

        return response()->json([
            'message' => 'Service request accepted successfully!',
            'booking' => $booking->load(['customer.user', 'serviceRequest.service']),
        ]);
    }

    public function rejectOffer(Request $request, $assignmentId)
    {
        $provider = $request->user()->serviceProvider;

        $assignment = RequestAssignment::where('service_provider_id', $provider->id)
            ->where('status', 'offered')
            ->findOrFail($assignmentId);

        $nextAssignment = $this->dispatchService->handleRejectOrTimeout($assignment, 'rejected');

        return response()->json([
            'message' => 'Request rejected.',
            'next_assignment_dispatched' => (bool)$nextAssignment,
        ]);
    }

    public function updateJobStatus(Request $request, $requestId)
    {
        $provider = $request->user()->serviceProvider;

        $serviceRequest = ServiceRequest::where('assigned_provider_id', $provider->id)
            ->findOrFail($requestId);

        $validator = Validator::make($request->all(), [
            'status' => 'required|in:provider_on_the_way,arrived,in_progress,completed,cancelled',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $newStatus = $request->status;
        $serviceRequest->update(['status' => $newStatus]);

        if ($newStatus === 'completed') {
            $provider->increment('total_completed_jobs');
            $provider->update(['is_available' => true]);

            if ($serviceRequest->booking) {
                $serviceRequest->booking->update(['completed_at' => now(), 'status' => 'completed']);
            }
        } elseif ($newStatus === 'cancelled') {
            $provider->update(['is_available' => true]);
        }

        return response()->json([
            'message' => "Job status updated to {$newStatus}",
            'status' => $newStatus,
        ]);
    }

    public function uploadDocument(Request $request)
    {
        $provider = $request->user()->serviceProvider;

        $validator = Validator::make($request->all(), [
            'document_type' => 'required|string',
            'file' => 'required|file',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        try {
            $uploadData = $this->fileUploadService->uploadFile($request->file('file'), 'provider_documents');

            $doc = ProviderDocument::create([
                'service_provider_id' => $provider->id,
                'document_type' => $request->document_type,
                'file_path' => $uploadData['file_path'],
                'mime_type' => $uploadData['mime_type'],
                'verification_status' => 'pending',
            ]);

            return response()->json([
                'message' => 'Document uploaded successfully',
                'document' => $doc,
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }
    }
}
