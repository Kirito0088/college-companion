/// App Metadata
///
/// Provides device/app-level context recorded on immutable ledger rows
/// (spec §11 — `device_timezone`, `app_version`). Kept dependency-free
/// (no `package_info_plus` / `timezone` package) for the Phase 4
/// foundation; `appVersion` mirrors `pubspec.yaml` and can be promoted
/// to a dynamic read later without changing call sites.
library;

/// The app version recorded on ledger rows (spec §11 metadata).
///
/// Mirrors `pubspec.yaml`'s `version: 1.0.0+1`. Update both together.
const String appVersion = '1.0.0+1';

/// Returns the recording device's timezone identifier (spec §11 metadata).
///
/// Uses the OS timezone abbreviation from [DateTime.timeZoneName].
String currentDeviceTimezone() {
  return DateTime.now().timeZoneName;
}
