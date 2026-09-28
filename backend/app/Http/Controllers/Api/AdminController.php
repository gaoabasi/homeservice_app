<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Customer;
use App\Models\Service;
use App\Models\ServiceProvider;
use App\Models\ServiceRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AdminController extends Controller
{
    public function dashboardStats()
    {
        return response()->json([
            'total_customers' => Customer::count(),
            'total_providers' => ServiceProvider::count(),
            'verified_providers' => ServiceProvider::where('verification_status', 'verified')->count(),
            'pending_providers' => ServiceProvider::where('verification_status', 'pending')->count(),
            'active_requests' => ServiceRequest::whereIn('status', ['pending', 'matching', 'sent_to_provider', 'accepted', 'provider_on_the_way', 'in_progress'])->count(),
            'completed_services' => Booking::where('status', 'completed')->count(),
            'emergency_requests' => ServiceRequest::where('urgency', 'emergency')->count(),
            'total_revenue' => Booking::where('status', 'completed')->sum('final_amount'),
        ]);
    }

    public function pendingProviders()
    {
        $providers = ServiceProvider::where('verification_status', 'pending')
            ->with(['user', 'documents', 'services'])
            ->get();

        return response()->json(['pending_providers' => $providers]);
    }

    public function verifyProvider(Request $request, $providerId)
    {
        $provider = ServiceProvider::findOrFail($providerId);

        $validator = Validator::make($request->all(), [
            'status' => 'required|in:verified,rejected,suspended',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $provider->update([
            'verification_status' => $request->status,
        ]);

        if ($request->status === 'verified' && $provider->user) {
            $provider->user->update(['role' => 'provider']);
        }

        return response()->json([
            'message' => "Provider verification status updated to {$request->status}",
            'provider' => $provider->fresh('user'),
        ]);
    }

    public function allRequests()
    {
        $requests = ServiceRequest::with(['customer.user', 'service', 'assignedProvider.user'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json($requests);
    }
}
