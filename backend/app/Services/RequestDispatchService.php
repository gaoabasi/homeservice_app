<?php

namespace App\Services;

use App\Models\Booking;
use App\Models\RequestAssignment;
use App\Models\ServiceRequest;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class RequestDispatchService
{
    protected MatchingEngineService $matchingEngine;

    public function __construct(MatchingEngineService $matchingEngine)
    {
        $this->matchingEngine = $matchingEngine;
    }

    /**
     * Initiate dispatch process for a service request.
     */
    public function dispatchRequest(ServiceRequest $request): array
    {
        $candidates = $this->matchingEngine->findEligibleProviders($request, config('app.search_radius_km', 5.0));

        if ($candidates->isEmpty()) {
            $request->update(['status' => 'pending']);
            return [
                'success' => false,
                'message' => 'No verified online service providers found in your area at the moment.',
                'candidates_count' => 0,
            ];
        }

        $request->update(['status' => 'matching']);

        // Offer to the nearest candidate (#0)
        $firstCandidate = $candidates->first();
        $assignment = $this->offerToProvider($request, $firstCandidate['provider'], $firstCandidate['distance_km']);

        return [
            'success' => true,
            'message' => 'Service request dispatched to nearest provider.',
            'candidates_count' => $candidates->count(),
            'offered_provider_id' => $firstCandidate['provider']->id,
            'assignment_id' => $assignment->id,
        ];
    }

    /**
     * Create assignment offer for a specific provider.
     */
    public function offerToProvider(ServiceRequest $request, $provider, float $distanceKm): RequestAssignment
    {
        $assignment = RequestAssignment::create([
            'service_request_id' => $request->id,
            'service_provider_id' => $provider->id,
            'status' => 'offered',
            'distance_km' => $distanceKm,
            'offered_at' => Carbon::now(),
        ]);

        $request->update(['status' => 'sent_to_provider']);

        return $assignment;
    }

    /**
     * Handle provider acceptance of a request.
     */
    public function acceptOffer(RequestAssignment $assignment): Booking
    {
        return DB::transaction(function () use ($assignment) {
            $assignment->update([
                'status' => 'accepted',
                'responded_at' => Carbon::now(),
            ]);

            $request = $assignment->serviceRequest;
            $provider = $assignment->serviceProvider;

            $request->update([
                'status' => 'accepted',
                'assigned_provider_id' => $provider->id,
            ]);

            // Mark provider as busy during active job
            $provider->update(['is_available' => false]);

            // Create initial booking
            $booking = Booking::create([
                'service_request_id' => $request->id,
                'customer_id' => $request->customer_id,
                'service_provider_id' => $provider->id,
                'final_amount' => $request->service->base_price ?? 0.00,
                'status' => 'active',
            ]);

            return $booking;
        });
    }

    /**
     * Handle provider rejection or timeout and dispatch to next nearest provider.
     */
    public function handleRejectOrTimeout(RequestAssignment $assignment, string $reason = 'rejected'): ?RequestAssignment
    {
        return DB::transaction(function () use ($assignment, $reason) {
            $assignment->update([
                'status' => $reason === 'timeout' ? 'timeout' : 'rejected',
                'responded_at' => Carbon::now(),
            ]);

            $request = $assignment->serviceRequest;

            // Find next eligible provider not previously assigned
            $assignedProviderIds = RequestAssignment::where('service_request_id', $request->id)
                ->pluck('service_provider_id')
                ->toArray();

            $candidates = $this->matchingEngine->findEligibleProviders($request, 10.0);
            $nextCandidate = $candidates->first(function ($c) use ($assignedProviderIds) {
                return !in_array($c['provider']->id, $assignedProviderIds);
            });

            if ($nextCandidate) {
                return $this->offerToProvider($request, $nextCandidate['provider'], $nextCandidate['distance_km']);
            }

            // If no more candidates, set request to pending/unmatched
            $request->update(['status' => 'pending']);
            return null;
        });
    }
}
