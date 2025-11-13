
class Injector {
  final _map = <Type, dynamic>{};

  void register<T>(T i) => _map[T] = i;

  void registerLazy<T>(T Function() f) => _map[T] = f;

  T get<T>() {
    final value = _map[T];
    if (value is Function) {
      final i = value();
      _map[T] = i;
      return i;
    }
    return value;
  }
}