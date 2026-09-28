<?php

namespace Tests\Feature;

use App\Models\Customer;
use App\Models\Service;
use App\Models\ServiceProvider;
use App\Models\ServiceRequest;
use App\Models\User;
use App\Services\MatchingEngineService;
use App\Services\RequestDispatchService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MatchingEngineTest extends TestCase
{
    use RefreshDatabase;

    public function test_haversine_distance_calculation()
    {
        // Distance between Dar es Salaam City Center (-6.8160, 39.2804) and Mwenge (-6.7621, 39.2223)
        $dist = MatchingEngineService::haversineDistance(-6.8160, 39.2804, -6.7621, 39.2223);

        $this->assertGreaterThan(7.0, $dist);
        $this->assertLessThan(10.0, $dist);
    }

    public function test_matching_engine_filters_only_verified_and_online_providers()
    {
        $service = Service::create([
            'name' => 'Electrical Services',
            'slug' => 'electrical-services',
            'description' => 'Electrical work',
            'icon_name' => 'flash_on',
            'base_price' => 30000,
        ]);

        $custUser = User::create([
            'name' => 'Test Customer',
            'email' => 'cust@test.com',
            'phone' => '+255700000001',
            'password' => bcrypt('password'),
            'role' => 'customer',
        ]);
        $customer = Customer::create(['user_id' => $custUser->id]);

        // Provider A: Verified + Online (Near - 1 KM away)
        $provUserA = User::create(['name' => 'Provider A', 'email' => 'a@test.com', 'phone' => '+255700000002', 'password' => bcrypt('password'), 'role' => 'provider']);
        $provA = ServiceProvider::create([
            'user_id' => $provUserA->id,
            'national_id' => '11111111',
            'verification_status' => 'verified',
            'is_online' => true,
            'is_available' => true,
            'current_latitude' => -6.8000,
            'current_longitude' => 39.2100,
        ]);
        $provA->services()->attach($service->id);

        // Provider B: Pending + Online (Should be excluded)
        $provUserB = User::create(['name' => 'Provider B', 'email' => 'b@test.com', 'phone' => '+255700000003', 'password' => bcrypt('password'), 'role' => 'provider']);
        $provB = ServiceProvider::create([
            'user_id' => $provUserB->id,
            'national_id' => '22222222',
            'verification_status' => 'pending',
            'is_online' => true,
            'is_available' => true,
            'current_latitude' => -6.8001,
            'current_longitude' => 39.2101,
        ]);
        $provB->services()->attach($service->id);

        $request = ServiceRequest::create([
            'customer_id' => $customer->id,
            'service_id' => $service->id,
            'latitude' => -6.7924,
            'longitude' => 39.2083,
            'address_text' => 'Kinondoni',
            'problem_description' => 'Socket broken',
            'urgency' => 'normal',
            'status' => 'pending',
        ]);

        $engine = new MatchingEngineService();
        $candidates = $engine->findEligibleProviders($request, 5.0);

        $this->assertCount(1, $candidates);
        $this->assertEquals($provA->id, $candidates[0]['provider']->id);
    }
}
