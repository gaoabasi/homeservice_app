<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Str;
use InvalidArgumentException;

class FileUploadService
{
    protected array $allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
    protected array $allowedMimeTypes = ['image/jpeg', 'image/png', 'application/pdf'];
    protected int $maxSizeBytes = 5242880; // 5 MB

    /**
     * Safely validate and upload a file.
     */
    public function uploadFile(UploadedFile $file, string $directory = 'uploads'): array
    {
        $extension = strtolower($file->getClientOriginalExtension());
        $mimeType = $file->getMimeType();
        $size = $file->getSize();

        if (!in_array($extension, $this->allowedExtensions)) {
            throw new InvalidArgumentException("File extension .{$extension} is not allowed. Allowed: " . implode(', ', $this->allowedExtensions));
        }

        if (!in_array($mimeType, $this->allowedMimeTypes)) {
            throw new InvalidArgumentException("MIME type {$mimeType} is not permitted.");
        }

        if ($size > $this->maxSizeBytes) {
            throw new InvalidArgumentException("File size exceeds 5MB limit.");
        }

        $randomName = Str::uuid()->toString() . '.' . $extension;
        $path = $file->storeAs("public/{$directory}", $randomName);

        return [
            'file_path' => "/storage/{$directory}/{$randomName}",
            'mime_type' => $mimeType,
            'original_name' => $file->getClientOriginalName(),
            'size' => $size,
        ];
    }
}
