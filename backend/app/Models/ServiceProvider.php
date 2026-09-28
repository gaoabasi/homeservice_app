<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ServiceProvider extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'national_id',
        'bio',
        'experience_years',
        'verification_status',
        'is_online',
        'is_available',
        'current_latitude',
        'current_longitude',
        'last_location_update',
        'rating_cache',
        'total_completed_jobs',
    ];

    protected $casts = [
        'is_online' => 'boolean',
        'is_available' => 'boolean',
        'current_latitude' => 'double',
        'current_longitude' => 'double',
        'last_location_update' => 'datetime',
        'rating_cache' => 'double',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function documents()
    {
        return $this->hasMany(ProviderDocument::class);
    }

    public function services()
    {
        return $this->belongsToMany(Service::class, 'provider_services')->withPivot('custom_rate');
    }

    public function assignments()
    {
        return $this->hasMany(RequestAssignment::class);
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function isEligibleForJobs(): bool
    {
        return $this->verification_status === 'verified' &&
               $this->is_online &&
               $this->is_available;
    }
}
