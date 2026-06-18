class AdminStatsModel {
  final int totalUsers;
  final int totalHalls;
  final int totalBookings;
  final double totalRevenue;

  AdminStatsModel({
    required this.totalUsers,
    required this.totalHalls,
    required this.totalBookings,
    required this.totalRevenue,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['totalUsers'] ?? 0,
      totalHalls: json['totalHalls'] ?? 0,
      totalBookings: json['totalBookings'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}
