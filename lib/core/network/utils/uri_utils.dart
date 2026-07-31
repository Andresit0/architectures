class UriUtils {
  static Uri replacePathParams(Uri uri, Map<String, String>? pathParams) {
    if (pathParams == null) return uri;
    pathParams.forEach((key, value) {
      uri = uri.replace(path: uri.path.replaceAll(':$key', value));
    });
    return uri;
  }
}
