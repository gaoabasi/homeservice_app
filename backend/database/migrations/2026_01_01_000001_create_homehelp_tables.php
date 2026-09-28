<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('phone')->unique();
            $table->timestamp('phone_verified_at')->nullable();
            $table->string('password');
            $table->enum('role', ['customer', 'provider', 'admin'])->default('customer');
            $table->enum('status', ['active', 'suspended', 'inactive'])->default('active');
            $table->rememberToken();
            $table->timestamps();
        });

        Schema::create('customers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('default_address')->nullable();
            $table->string('emergency_contact')->nullable();
            $table->string('profile_photo')->nullable();
            $table->timestamps();
        });

        Schema::create('service_providers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('national_id')->unique();
            $table->text('bio')->nullable();
            $table->integer('experience_years')->default(1);
            $table->enum('verification_status', ['pending', 'under_review', 'verified', 'rejected', 'suspended'])->default('pending');
            $table->boolean('is_online')->default(false);
            $table->boolean('is_available')->default(true);
            $table->double('current_latitude', 10, 7)->nullable();
            $table->double('current_longitude', 10, 7)->nullable();
            $table->timestamp('last_location_update')->nullable();
            $table->double('rating_cache', 3, 2)->default(5.00);
            $table->integer('total_completed_jobs')->default(0);
            $table->timestamps();
        });

        Schema::create('provider_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_provider_id')->constrained()->onDelete('cascade');
            $table->string('document_type'); // e.g., national_id, certificate, license
            $table->string('file_path');
            $table->string('mime_type');
            $table->enum('verification_status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->timestamps();
        });

        Schema::create('services', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->text('description');
            $table->string('icon_name');
            $table->decimal('base_price', 10, 2)->default(0.00);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('provider_services', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_provider_id')->constrained()->onDelete('cascade');
            $table->foreignId('service_id')->constrained()->onDelete('cascade');
            $table->decimal('custom_rate', 10, 2)->nullable();
            $table->timestamps();
            $table->unique(['service_provider_id', 'service_id']);
        });

        Schema::create('service_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('customer_id')->constrained()->onDelete('cascade');
            $table->foreignId('service_id')->constrained()->onDelete('cascade');
            $table->enum('urgency', ['normal', 'urgent', 'emergency'])->default('normal');
            $table->enum('status', [
                'pending',
                'matching',
                'sent_to_provider',
                'accepted',
                'provider_on_the_way',
                'arrived',
                'in_progress',
                'completed',
                'cancelled',
                'expired'
            ])->default('pending');
            $table->double('latitude', 10, 7);
            $table->double('longitude', 10, 7);
            $table->text('address_text');
            $table->text('problem_description');
            $table->json('photos_json')->nullable();
            $table->foreignId('assigned_provider_id')->nullable()->constrained('service_providers')->onDelete('set null');
            $table->string('cancelled_by')->nullable(); // customer, provider, admin
            $table->text('cancellation_reason')->nullable();
            $table->timestamps();
        });

        Schema::create('request_assignments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_request_id')->constrained()->onDelete('cascade');
            $table->foreignId('service_provider_id')->constrained()->onDelete('cascade');
            $table->enum('status', ['offered', 'accepted', 'rejected', 'expired', 'timeout'])->default('offered');
            $table->double('distance_km', 8, 2)->default(0);
            $table->timestamp('offered_at');
            $table->timestamp('responded_at')->nullable();
            $table->timestamps();
        });

        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('service_request_id')->constrained()->onDelete('cascade');
            $table->foreignId('customer_id')->constrained()->onDelete('cascade');
            $table->foreignId('service_provider_id')->constrained()->onDelete('cascade');
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->decimal('final_amount', 10, 2)->default(0.00);
            $table->enum('status', ['active', 'completed', 'cancelled'])->default('active');
            $table->timestamps();
        });

        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('booking_id')->constrained()->onDelete('cascade');
            $table->enum('payment_method', ['cash', 'mpesa', 'airtel_money', 'card'])->default('cash');
            $table->enum('payment_status', ['pending', 'paid', 'failed', 'refunded'])->default('pending');
            $table->decimal('amount', 10, 2);
            $table->string('transaction_ref')->nullable();
            $table->timestamps();
        });

        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('booking_id')->constrained()->onDelete('cascade');
            $table->foreignId('customer_id')->constrained()->onDelete('cascade');
            $table->foreignId('service_provider_id')->constrained()->onDelete('cascade');
            $table->unsignedTinyInteger('rating'); // 1-5
            $table->text('comment')->nullable();
            $table->timestamps();
            $table->unique('booking_id');
        });

        Schema::create('complaints', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('booking_id')->nullable()->constrained()->onDelete('set null');
            $table->string('subject');
            $table->text('details');
            $table->enum('status', ['open', 'under_investigation', 'resolved', 'closed'])->default('open');
            $table->timestamps();
        });

        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('set null');
            $table->string('action');
            $table->string('ip_address')->nullable();
            $table->text('user_agent')->nullable();
            $table->json('payload_json')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
        Schema::dropIfExists('complaints');
        Schema::dropIfExists('reviews');
        Schema::dropIfExists('payments');
        Schema::dropIfExists('bookings');
        Schema::dropIfExists('request_assignments');
        Schema::dropIfExists('service_requests');
        Schema::dropIfExists('provider_services');
        Schema::dropIfExists('services');
        Schema::dropIfExists('provider_documents');
        Schema::dropIfExists('service_providers');
        Schema::dropIfExists('customers');
        Schema::dropIfExists('users');
    }
};
