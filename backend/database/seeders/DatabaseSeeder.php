<?php

namespace Database\Seeders;

use App\Models\Customer;
use App\Models\Service;
use App\Models\ServiceProvider;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Seed Services
        $services = [
            ['name' => 'Electrical Services', 'slug' => 'electrical-services', 'icon_name' => 'flash_on', 'base_price' => 35000.00, 'description' => 'Home wiring, socket repair, lighting & electrical fault fixing.'],
            ['name' => 'Plumbing', 'slug' => 'plumbing', 'icon_name' => 'water_drop', 'base_price' => 30000.00, 'description' => 'Pipe leak repair, tap installation, drainage & water tank setups.'],
            ['name' => 'Cleaning Services', 'slug' => 'cleaning', 'icon_name' => 'cleaning_services', 'base_price' => 25000.00, 'description' => 'Deep home cleaning, sofa washing & office space sanitation.'],
            ['name' => 'Carpentry', 'slug' => 'carpenter', 'icon_name' => 'build', 'base_price' => 40000.00, 'description' => 'Furniture assembly, door lock fixing & custom woodwork.'],
            ['name' => 'Painting', 'slug' => 'painting', 'icon_name' => 'format_paint', 'base_price' => 50000.00, 'description' => 'Interior and exterior house painting and wall touch-ups.'],
            ['name' => 'AC Repair & Service', 'slug' => 'ac-repair', 'icon_name' => 'ac_unit', 'base_price' => 45000.00, 'description' => 'AC refilling, filter cleaning, cooling diagnostics & install.'],
            ['name' => 'Appliance Repair', 'slug' => 'appliance-repair', 'icon_name' => 'home_max', 'base_price' => 30000.00, 'description' => 'Washing machine, fridge, microwave & television repair.'],
            ['name' => 'Gardening & Landscaping', 'slug' => 'gardening', 'icon_name' => 'grass', 'base_price' => 20000.00, 'description' => 'Lawn mowing, tree trimming, hedge cutting & garden care.'],
            ['name' => 'Laundry Services', 'slug' => 'laundry', 'icon_name' => 'local_laundry_service', 'base_price' => 20000.00, 'description' => 'Clothes washing, dry cleaning, ironing & doorstep pickup.'],
            ['name' => 'Pest Control', 'slug' => 'pest-control', 'icon_name' => 'bug_report', 'base_price' => 60000.00, 'description' => 'Fumigation for termites, cockroaches, rodents & bedbugs.'],
            ['name' => 'Moving Services', 'slug' => 'moving-services', 'icon_name' => 'local_shipping', 'base_price' => 120000.00, 'description' => 'House moving, furniture packing, loading & transport.'],
            ['name' => 'Water Delivery', 'slug' => 'water-delivery', 'icon_name' => 'water', 'base_price' => 45000.00, 'description' => 'Clean domestic water bowser delivery (5000L - 10000L).'],
            ['name' => 'Gas Delivery', 'slug' => 'gas-delivery', 'icon_name' => 'propane', 'base_price' => 55000.00, 'description' => 'Cooking gas cylinder refill and safe home installation.'],
            ['name' => 'Car Wash at Home', 'slug' => 'car-wash', 'icon_name' => 'directions_car', 'base_price' => 15000.00, 'description' => 'Mobile doorstep car pressure wash, vacuuming & wax.'],
            ['name' => 'Other Home Services', 'slug' => 'other-services', 'icon_name' => 'handyman', 'base_price' => 25000.00, 'description' => 'General handyman tasks and customized home assistance.'],
        ];

        foreach ($services as $srv) {
            Service::create($srv);
        }

        // 2. Seed Admin User
        User::create([
            'name' => 'HOMEHELP System Admin',
            'email' => 'admin@homehelp.co.tz',
            'phone' => '+255700000000',
            'password' => Hash::make('secretpass'),
            'role' => 'admin',
            'status' => 'active',
            'phone_verified_at' => now(),
        ]);

        // 3. Seed Sample Customer
        $custUser = User::create([
            'name' => 'Juma Jux',
            'email' => 'customer@homehelp.co.tz',
            'phone' => '+255712345678',
            'password' => Hash::make('password123'),
            'role' => 'customer',
            'status' => 'active',
            'phone_verified_at' => now(),
        ]);

        Customer::create([
            'user_id' => $custUser->id,
            'default_address' => 'Kinondoni, Dar es Salaam',
            'emergency_contact' => '+255799999999',
        ]);

        // 4. Seed Verified Electrician (0.8 KM away from Dar city center)
        $elecUser = User::create([
            'name' => 'Fundi Hassan (Electrician A)',
            'email' => 'hassan@electric.tz',
            'phone' => '+255788111222',
            'password' => Hash::make('password123'),
            'role' => 'provider',
            'status' => 'active',
            'phone_verified_at' => now(),
        ]);

        $elecProvider = ServiceProvider::create([
            'user_id' => $elecUser->id,
            'national_id' => '19900101-12345-00001-10',
            'bio' => 'Certified high-voltage electrician with 8 years experience.',
            'experience_years' => 8,
            'verification_status' => 'verified',
            'is_online' => true,
            'is_available' => true,
            'current_latitude' => -6.7924,
            'current_longitude' => 39.2083,
            'rating_cache' => 4.9,
            'total_completed_jobs' => 42,
        ]);

        $elecService = Service::where('slug', 'electrical-services')->first();
        $elecProvider->services()->attach($elecService->id);

        // 5. Seed Verified Plumber (1.5 KM away)
        $plumbUser = User::create([
            'name' => 'Fundi Moses (Plumber B)',
            'email' => 'moses@plumb.tz',
            'phone' => '+255788333444',
            'password' => Hash::make('password123'),
            'role' => 'provider',
            'status' => 'active',
            'phone_verified_at' => now(),
        ]);

        $plumbProvider = ServiceProvider::create([
            'user_id' => $plumbUser->id,
            'national_id' => '19920202-54321-00002-20',
            'bio' => 'Expert pipe fitter and water heater technician.',
            'experience_years' => 5,
            'verification_status' => 'verified',
            'is_online' => true,
            'is_available' => true,
            'current_latitude' => -6.8000,
            'current_longitude' => 39.2150,
            'rating_cache' => 4.8,
            'total_completed_jobs' => 29,
        ]);

        $plumbService = Service::where('slug', 'plumbing')->first();
        $plumbProvider->services()->attach($plumbService->id);
    }
}
