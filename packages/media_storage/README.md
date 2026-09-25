# media_storage

Reusable Image Compression, Supabase Storage adapter, and timestamp pathing for Constellation media apps (Quire and Dream Journal).

## Features

- **Standardized Client Compression**: WebP output, 1:1 and 4:5 cropping ratios, maximum dimensions (1440px moments, 400px avatars), 80–85% quality presets.
- **Supabase Storage Adapter**: Decoupled interface for upload, delete, batch cleanup, and signed/public URL generation.
- **Timestamped Paths**: Pattern `avatars/{user_id}/avatar_{timestamp}.webp` prevents CDN and browser cache lockups.
- **Garbage Collection**: `cleanupPreviousAvatars()` purges obsolete avatar files to conserve storage space.
- **The Void Invariant Guard**: Throws `TheVoidPersistenceViolationException` if any attempt is made to route data from After Midnight's The Void into storage.

## Architecture & SOLID Principles

- **SRP**: `ImageCompressor` handles pixel transforms; `StoragePathGenerator` formats URI paths; `MediaStorageAdapter` manages network storage; `TheVoidStorageGuard` verifies compliance.
- **OCP**: Compression backends (native vs web) and storage providers (Supabase, local mock) can be added without altering caller logic.
- **LSP**: `SupabaseMediaStorageAdapter` implements `MediaStorageAdapter` and is fully substitutable by mock implementations in tests.
- **ISP**: Small, cohesive interfaces for listing, uploading, and deleting.
- **DIP**: Features depend on `MediaStorageAdapter` and `ImageCompressor` abstractions, never direct SDK globals.
