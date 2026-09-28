<?php

namespace App\Services;

use App\Models\ServiceProvider;
use App\Models\ServiceRequest;
use Illuminate\Support\Collection;

class MatchingEngineService
{
    /**
     * Calculate Haversine distance in kilometers between two GPS points.
     */
    public static function haversineDistance(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadiusKm = 6371.0;

        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat / 2) * sin($dLat / 2) +
             cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
             sin($dLon / 2) * sin($dLon / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return round($earthRadiusKm * $c, 2);
    }

    /**
     * Find nearest verified, online, and available providers offering the given service.
     */
    public function findEligibleProviders(ServiceRequest $request, float $maxRadiusKm = 5.0): Collection
    {
        $serviceId = $request->service_id;
        $custLat = $request->latitude;
        $custLon = $request->longitude;

        // Fetch verified, online, and available providers offering the requested service
        $providers = ServiceProvider::with('user', 'services')
            ->where('verification_status', 'verified')
            ->where('is_online', true)
            ->where('is_available', true)
            ->whereHas('services', function ($q) use ($serviceId) {
                $q->where('services.id', $serviceId);
            })
            ->whereNotNull('current_latitude')
            ->whereNotNull('current_longitude')
            ->get();

        $candidates = collect();

        foreach ($providers as $provider) {
            $distance = self::haversineDistance(
                $custLat,
                $custLon,
                $provider->current_latitude,
                $provider->current_longitude
            );

            if ($distance <= $maxRadiusKm) {
                $candidates->push([
                    'provider' => $provider,
                    'distance_km' => $distance,
                ]);
            }
        }

        // Sort candidates primarily by distance ascending, then by highest rating
        return $candidates->sortBy([
            ['distance_km', 'asc'],
            [function ($a, $b) {
                return $b['provider']->rating_cache <=> $a['provider']->rating_cache;
            }],
        ])->values();
    }
}
