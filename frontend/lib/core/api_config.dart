import 'package:fitflow/core/api_config_stub.dart'
    if (dart.library.io) 'package:fitflow/core/api_config_io.dart';

/// Core service base URL. Override with `--dart-define=CORE_API_URL=...`.
String coreApiBaseUrl() {
  const override = String.fromEnvironment('CORE_API_URL');
  if (override.isNotEmpty) return override;
  return platformCoreApiBaseUrl();
}
