# version_gate

Production-ready Version Gating, SemVer Precedence Comparison, and Anti-Stale Cache manager for Constellation apps (Quire, Dream Journal, Astraea, After Midnight).

## Features

- **Standard SemVer 2.0.0 Comparator**: Zero external dependencies, supports precedence `<, <=, ==, >=, >`, pre-release, and build metadata.
- **Supabase Config Fetcher**: Clean Architecture repository contract querying `app_system_configs`.
- **App Lifecycle Hooks**: Evaluates version status on cold boot (`onAppBoot`) and resume (`onAppResume`).
- **Sync Lock Coordination**: Automatically locks local sync engines upon `ForceUpdate` or `EmergencyMaintenance` to prevent database schema corruption.
- **Calm UX ForceUpdateScreen Contract**: Unskippable single-CTA gate for forced updates; dismissible notification for soft updates.
- **Web/PWA Anti-Stale Cache**: Cache-Control headers for Caddy/Nginx and ServiceWorker `controllerchange` hook.

## Architecture & SOLID Principles

- **SRP**: `SemVer` compares; `SystemConfigRepository` fetches; `VersionGateManager` coordinates; `ForceUpdateDelegate` renders.
- **OCP**: Platforms and storage adapters can be extended without modifying the core state machine.
- **LSP**: Subclasses of `SystemConfigRepository` or `ForceUpdateDelegate` substitute cleanly.
- **ISP**: `SyncLockListener` is separated from `ForceUpdateDelegate`.
- **DIP**: High-level gating depends on `SystemConfigRepository` abstraction, not concrete network clients.
