<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminRegistrationController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\EvaluationSubmissionController;
use App\Http\Controllers\LaporanSubmissionController;
use App\Http\Controllers\RegionController;
use App\Http\Controllers\TemplateController;

Route::middleware('api')->group(function () {
    Route::get('/status', function () {
        return response()->json([
            'app' => 'GERMAS API',
            'status' => 'ok',
            'timestamp' => now()->toIso8601String(),
        ]);
    });

    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/register', [AdminRegistrationController::class, 'register']);
    Route::post('/registration/admin-code/validate', [AdminRegistrationController::class, 'validateCode']);

    Route::get('/templates/evaluasi', [TemplateController::class, 'evaluasi']);
    Route::get('/templates/laporan', [TemplateController::class, 'laporan']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/auth/me', [AuthController::class, 'me']);
        Route::post('/auth/logout', [AuthController::class, 'logout']);

        Route::get('/dashboard/metrics', [DashboardController::class, 'metrics']);

        Route::get('/regions', [RegionController::class, 'index']);
        Route::get('/regions/{regency}/districts', [RegionController::class, 'districts']);
        Route::get('/districts/{district}/villages', [RegionController::class, 'villages']);

        Route::post('/evaluasi/submissions', [EvaluationSubmissionController::class, 'store']);
        Route::get('/evaluasi/submissions', [EvaluationSubmissionController::class, 'index']);
        Route::get('/evaluasi/submissions/{submission}', [EvaluationSubmissionController::class, 'show']);
        Route::patch('/evaluasi/submissions/{submission}/status', [EvaluationSubmissionController::class, 'updateStatus']);
        Route::delete('/evaluasi/submissions/{submission}', [EvaluationSubmissionController::class, 'destroy']);

        Route::post('/laporan/submissions', [LaporanSubmissionController::class, 'store']);
        Route::get('/laporan/submissions', [LaporanSubmissionController::class, 'index']);
        Route::get('/laporan/submissions/{submission}', [LaporanSubmissionController::class, 'show']);
        Route::patch('/laporan/submissions/{submission}/status', [LaporanSubmissionController::class, 'updateStatus']);
        Route::delete('/laporan/submissions/{submission}', [LaporanSubmissionController::class, 'destroy']);
    });
});
