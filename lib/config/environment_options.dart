import 'package:flutter/foundation.dart';

class EnvironmentOptions {
  static const String _environmentParameter =
      String.fromEnvironment("ENVIRONMENT");
  static const DulnoEnvironment environment =
      kIsWeb && _environmentParameter == "STAGING"
          ? DulnoEnvironment.staging
          : DulnoEnvironment.production;
}

enum DulnoEnvironment {
  production("dulno.com", "api.dulno.com"),
  staging("dulno.dev", "api.dulno.dev");

  const DulnoEnvironment(this._domain, this._endpoint);

  final String _domain;
  final String _endpoint;

  String get domain => _domain;

  String get endpoint => _endpoint;
}
