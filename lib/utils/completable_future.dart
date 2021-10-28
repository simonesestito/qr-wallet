class CompletableFuture<T> {
  late final Future<T> future;
  T? _cachedResult;

  bool get isCompleted => _cachedResult != null;

  T? get cachedResult => _cachedResult;

  CompletableFuture({required Future<T> future}) {
    this.future = future.then((result) {
      _cachedResult = result;
      return result;
    });
  }
}

typedef FutureSupplier<T> = Future<T> Function();

class LateFuture<T> {
  final FutureSupplier<T> futureBuilder;
  bool hasExecuted = false;

  LateFuture(this.futureBuilder);

  void execute() {
    if (hasExecuted) return;
    hasExecuted = true;
    futureBuilder.call().then((value) => print(value));
  }
}
