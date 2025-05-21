/// Options for configuring API requests
class RequestOptions {
  /// Whether to retry the request on failure
  final bool retry;
  
  /// Maximum number of retry attempts
  final int maxRetries;
  
  /// Timeout for the request in milliseconds
  final int timeoutMs;
  
  /// Whether to cache the response
  final bool cache;
  
  /// Time to live for the cache in milliseconds
  final int cacheTtlMs;
  
  /// Whether to use authentication for the request
  final bool useAuth;

  /// Creates new request options
  const RequestOptions({
    this.retry = false,
    this.maxRetries = 3,
    this.timeoutMs = 30000,
    this.cache = false,
    this.cacheTtlMs = 300000, // 5 minutes
    this.useAuth = true,
  });
  
  /// Creates a copy of this options with the given fields replaced
  RequestOptions copyWith({
    bool? retry,
    int? maxRetries,
    int? timeoutMs,
    bool? cache,
    int? cacheTtlMs,
    bool? useAuth,
  }) {
    return RequestOptions(
      retry: retry ?? this.retry,
      maxRetries: maxRetries ?? this.maxRetries,
      timeoutMs: timeoutMs ?? this.timeoutMs,
      cache: cache ?? this.cache,
      cacheTtlMs: cacheTtlMs ?? this.cacheTtlMs,
      useAuth: useAuth ?? this.useAuth,
    );
  }
}
