import 'api_service.dart';

class ReviewService {
  final api = ApiService();

  /* ================= GET REVIEWS FOR A HALL ================= */

  Future<List<dynamic>> getHallReviews(String hallId) async {
    final res = await api.dio.get("/reviews/$hallId");
    return res.data;
  }

  /* ================= ADD REVIEW ================= */

  Future<String> addReview({
    required String hallId,
    required String bookingId,
    required double rating,
    required String comment,
  }) async {
    final res = await api.dio.post(
      "/reviews",
      data: {
        "hallId": hallId,
        "bookingId": bookingId,
        "rating": rating,
        "comment": comment,
      },
    );

    return res.data["message"];
  }
}
