<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ServiceRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'service_id',
        'urgency',
        'status',
        'latitude',
        'longitude',
        'address_text',
        'problem_description',
        'photos_json',
        'assigned_provider_id',
        'cancelled_by',
        'cancellation_reason',
    ];

    protected $casts = [
        'latitude' => 'double',
        'longitude' => 'double',
        'photos_json' => 'array',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function service()
    {
        return $this->belongsTo(Service::class);
    }

    public function assignedProvider()
    {
        return $this->belongsTo(ServiceProvider::class, 'assigned_provider_id');
    }

    public function assignments()
    {
        return $this->hasMany(RequestAssignment::class);
    }

    public function booking()
    {
        return $this->hasOne(Booking::class);
    }
}
