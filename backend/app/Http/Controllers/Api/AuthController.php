<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\ServiceProvider;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function registerCustomer(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|unique:users',
            'phone' => 'required|string|unique:users',
            'password' => 'required|string|min:6',
            'default_address' => 'nullable|string',
            'emergency_contact' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
            'role' => 'customer',
            'status' => 'active',
            'phone_verified_at' => now(),
        ]);

        $customer = Customer::create([
            'user_id' => $user->id,
            'default_address' => $request->default_address,
            'emergency_contact' => $request->emergency_contact,
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Customer registered successfully',
            'user' => $user->load('customer'),
            'token' => $token,
        ], 201);
    }

    public function registerProvider(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|unique:users',
            'phone' => 'required|string|unique:users',
            'password' => 'required|string|min:6',
            'national_id' => 'required|string|unique:service_providers',
            'bio' => 'nullable|string',
            'experience_years' => 'integer|min:0',
            'service_ids' => 'required|array|min:1',
            'service_ids.*' => 'exists:services,id',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
            'role' => 'provider',
            'status' => 'active',
        ]);

        $provider = ServiceProvider::create([
            'user_id' => $user->id,
            'national_id' => $request->national_id,
            'bio' => $request->bio,
            'experience_years' => $request->experience_years ?? 1,
            'verification_status' => 'pending', // Must be verified by admin
        ]);

        $provider->services()->attach($request->service_ids);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Provider registered successfully. Account pending admin verification.',
            'user' => $user->load('serviceProvider.services'),
            'token' => $token,
        ], 201);
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone_or_email' => 'required|string',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $field = filter_var($request->phone_or_email, FILTER_VALIDATE_EMAIL) ? 'email' : 'phone';

        $user = User::where($field, $request->phone_or_email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        if ($user->status === 'suspended') {
            return response()->json(['message' => 'Account is suspended. Contact admin.'], 403);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'user' => $user->load(['customer', 'serviceProvider.services']),
            'token' => $token,
        ]);
    }

    public function me(Request $request)
    {
        return response()->json([
            'user' => $request->user()->load(['customer', 'serviceProvider.services']),
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out successfully']);
    }
}
