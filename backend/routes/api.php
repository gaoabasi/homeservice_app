<?php

use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CustomerController;
use App\Http\Controllers\Api\ProviderController;
use App\Http\Controllers\Api\ServiceController;
use App\Http\Middleware\EnsureRole;
use Illuminate\Support\Facades\Route;

// Public Routes
Route::post('/auth/register/customer', [AuthController::class, 'registerCustomer']);
Route::post('/auth/register/provider', [AuthController::class, 'registerProvider']);
Route::post('/auth/login', [AuthController::class, 'login']);

Route::get('/services', [ServiceController::class, 'index']);

// Protected Routes (Requires Sanctum Token)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // Customer Endpoints
    Route::middleware(EnsureRole::class . ':customer,provider')->prefix('customer')->group(function () {
        Route::post('/requests', [CustomerController::class, 'createServiceRequest']);
        Route::get('/requests', [CustomerController::class, 'myRequests']);
        Route::get('/requests/{id}', [CustomerController::class, 'requestDetails']);
        Route::post('/bookings/{id}/rate', [CustomerController::class, 'rateProvider']);
        Route::post('/apply-provider', [CustomerController::class, 'applyProvider']);
    });

    // Provider Endpoints
    Route::middleware(EnsureRole::class . ':provider')->prefix('provider')->group(function () {
        Route::post('/status/online', [ProviderController::class, 'toggleOnlineStatus']);
        Route::post('/location', [ProviderController::class, 'updateLocation']);
        Route::get('/offers/pending', [ProviderController::class, 'pendingOffers']);
        Route::post('/offers/{id}/accept', [ProviderController::class, 'acceptOffer']);
        Route::post('/offers/{id}/reject', [ProviderController::class, 'rejectOffer']);
        Route::post('/requests/{id}/status', [ProviderController::class, 'updateJobStatus']);
        Route::post('/documents/upload', [ProviderController::class, 'uploadDocument']);
    });

    // Admin Endpoints
    Route::middleware(EnsureRole::class . ':admin')->prefix('admin')->group(function () {
        Route::get('/stats', [AdminController::class, 'dashboardStats']);
        Route::get('/providers/pending', [AdminController::class, 'pendingProviders']);
        Route::post('/providers/{id}/verify', [AdminController::class, 'verifyProvider']);
        Route::get('/requests', [AdminController::class, 'allRequests']);
    });
});
