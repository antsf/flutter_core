/// Path utility methods for building URLs and replacing parameters.
class PathUtils {
  static String buildUrl(String base, String endpoint) {
    return '$base$endpoint';
  }

  static String replaceParams(String path, Map<String, dynamic> params) {
    var result = path;
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value.toString());
      result = result.replaceAll('{$key}', value.toString());
    });
    return result;
  }
}
