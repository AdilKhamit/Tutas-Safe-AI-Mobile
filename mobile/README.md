# Tutas Ai Mobile Application

Flutter mobile application with offline-first architecture for pipeline monitoring.

## Architecture

### Offline-First Design

- **Local-First**: All data is saved to local SQLite database first
- **Background Sync**: Synchronization happens in background when online
- **Conflict Resolution**: Manual resolution UI for server conflicts

### Data Flow

1. **Save Defect**: `DefectRepository.saveDefect()` → Saved to local DB with `syncStatus = Pending`
2. **Sync**: `DefectRepository.syncPendingDefects()` → Syncs all pending defects
3. **Conflict Handling**: On 409 Conflict, server version saved to `serverVersionJson` field

## Structure

```
lib/
├── data/
│   ├── local/
│   │   └── database.dart      # Drift database schema
│   ├── models/
│   │   └── defect_dto.dart    # DTO and mappers
│   └── api/
│       └── api_client.dart    # HTTP client with conflict handling
├── repositories/
│   └── defect_repository.dart # Business logic and sync
└── main.dart
```

## Sync Status

- `0` (Pending): Waiting to be synced
- `1` (Synced): Successfully synced with server
- `2` (Failed): Sync failed (retry later)
- `3` (Conflict): Server version conflicts with local

## Usage

### Save Defect (Offline)

```dart
final repository = ref.read(defectRepositoryProvider);
await repository.saveDefect(DefectDto(
  pipeId: 'pipe-uuid',
  defectType: 'corrosion',
  severity: 3,
  photos: ['/path/to/photo.jpg'],
));
```

### Sync Pending Defects

```dart
final result = await repository.syncPendingDefects();
print('Synced: ${result.synced}, Failed: ${result.failed}, Conflicts: ${result.conflicts}');
```

### Resolve Conflict

```dart
// Accept server version
await repository.acceptServerVersion(defectId);

// Or keep local version (retry sync)
await repository.keepLocalVersion(defectId);
```

## Code Generation

After adding dependencies, run:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `database.g.dart` - Drift database code
- `defect_dto.g.dart` - JSON serialization code

## Dependencies

- **Drift**: Local SQLite database
- **Riverpod**: Dependency injection and state management
- **Dio**: HTTP client for API calls
- **json_annotation**: JSON serialization
