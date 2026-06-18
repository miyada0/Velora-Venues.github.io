import 'api_service.dart';

class ProfileService {
  final api = ApiService();

  Future updateProfile(Map data) async {
    final response = await api.dio.put(
      "/auth/update-profile",
      data: data,
    );

    return response.data;
  }
}
