class EnvironmentOptions {
  static DulnoEnvironment environment = DulnoEnvironment.staging;
}

enum DulnoEnvironment {
  production("dulno.com", "api.dulno.com"),
  staging("dulno.dev", "pub.dulno.dev");

  const DulnoEnvironment(this._domain, this._endpoint);

  final String _domain;
  final String _endpoint;

  String get domain => _domain;

  String get endpoint => _endpoint;
}
