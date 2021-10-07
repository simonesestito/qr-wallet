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
