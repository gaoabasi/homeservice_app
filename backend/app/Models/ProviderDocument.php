<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProviderDocument extends Model
{
    use HasFactory;

    protected $fillable = [
        'service_provider_id',
        'document_type',
        'file_path',
        'mime_type',
        'verification_status',
    ];

    public function serviceProvider()
    {
        return $this->belongsTo(ServiceProvider::class);
    }
}
