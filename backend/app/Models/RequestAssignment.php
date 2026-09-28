<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RequestAssignment extends Model
{
    use HasFactory;

    protected $fillable = [
        'service_request_id',
        'service_provider_id',
        'status',
        'distance_km',
        'offered_at',
        'responded_at',
    ];

    protected $casts = [
        'distance_km' => 'double',
        'offered_at' => 'datetime',
        'responded_at' => 'datetime',
    ];

    public function serviceRequest()
    {
        return $this->belongsTo(ServiceRequest::class);
    }

    public function serviceProvider()
    {
        return $this->belongsTo(ServiceProvider::class);
    }
}
