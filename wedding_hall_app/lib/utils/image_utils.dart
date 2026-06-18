/// Image URL Utility for handling hall and booking images
class ImageUtils {
  /// Backend base URL
  static const String baseUrl = "http://10.99.227.20:5000";

  /// Convert relative image path to full URL
  static String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) {
      return getPlaceholderUrl();
    }

    // If already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // If it's a relative path, construct full URL
    if (!imagePath.startsWith('/')) {
      imagePath = '/$imagePath';
    }

    return '$baseUrl/uploads$imagePath';
  }

  /// Get placeholder image URL
  static String getPlaceholderUrl() {
    return '$baseUrl/uploads/placeholder.jpg';
  }

  /// Check if image URL is valid
  static bool isValidImageUrl(String url) {
    return url.isNotEmpty &&
        (url.startsWith('http://') ||
            url.startsWith('https://') ||
            url.startsWith('/'));
  }

  /// Get multiple image URLs from a list of paths
  static List<String> getImageUrls(List<String> imagePaths) {
    return imagePaths.map((path) => getImageUrl(path)).toList();
  }
}
