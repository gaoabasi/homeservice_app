<?php

namespace App\Services;

use App\Models\ServiceRequest;
use App\Models\User;

class LocationPrivacyService
{
    /**
     * Format location details based on user role and job status to enforce location privacy.
     */
    public static function formatRequestLocation(ServiceRequest $request, User $user, float $distanceKm = 0.0): array
    {
        $isAssignedProvider = $request->assigned_provider_id &&
                              $user->serviceProvider &&
                              $request->assigned_provider_id === $user->serviceProvider->id;

        $isCustomerOwner = $user->customer && $request->customer_id === $user->customer->id;
        $isAdmin = $user->isAdmin();

        // Exact coordinates unlocked for Admin, Customer Owner, or Accepted Provider
        if ($isAdmin || $isCustomerOwner || ($isAssignedProvider && in_array($request->status, ['accepted', 'provider_on_the_way', 'arrived', 'in_progress', 'completed']))) {
            return [
                'latitude' => $request->latitude,
                'longitude' => $request->longitude,
                'address_text' => $request->address_text,
                'is_exact' => true,
            ];
        }

        // Masked approximate location before job acceptance
        return [
            'approximate_area' => 'Approximate customer area (Within ' . ($distanceKm > 0 ? $distanceKm : 1.5) . ' KM)',
            'distance_km' => $distanceKm,
            'is_exact' => false,
        ];
    }
}
