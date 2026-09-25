# local_sync

Reusable Local-First Offline Queue and Background Sync Dispatcher for Constellation apps.

## Features

- **Decoupled Offline Queue**: Stores pending tasks with `SyncQueueItem` metadata, payload, and retry state.
- **Pluggable Storage Ports**: `LocalStoreAdapter` interface with default `MemoryLocalStoreAdapter`, pluggable to SQLite/Drift or Hive.
- **Smart Background Dispatcher**: Connectivity-aware execution with exponential backoff and jitter.
- **Sync Lock Mechanism**: Coordinates with `version_gate` to immediately halt network sync when `ForceUpdate` or `EmergencyMaintenance` is triggered.
- **The Void Invariant Guard**: Throws `TheVoidSyncViolationException` if an attempt is made to enqueue or persist The Void thoughts.

## Architecture & SOLID Principles

- **SRP**: `SyncQueueItem` models state; `LocalStoreAdapter` abstracts storage; `SyncDispatcher` manages network scheduling; `TheVoidSyncGuard` enforces privacy.
- **OCP**: New domain action types register handlers dynamically via `registerHandler()` without modifying the queue engine.
- **LSP**: `LocalStoreAdapter` implementations are interchangeable across runtimes.
- **ISP**: Separate contracts for storage and network dispatch.
- **DIP**: Features push jobs to the abstract `LocalStoreAdapter` rather than writing directly to remote APIs.
