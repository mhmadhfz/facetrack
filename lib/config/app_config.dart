class AppConfig {
  // 🔥 Backend API
  static const String baseUrl =
      "http://192.168.0.105/facetrack_backend/public/api";

  // 🔥 Base backend root (without /api)
  static const String backendRoot =
      "http://192.168.0.105/facetrack_backend/public";

  // 🔥 Storage URL
  static String storageUrl(String path) {
    return "$backendRoot/storage/$path";
  }
}
