// 📊 Admin Analytics Dashboard
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wedding_hall_booking_app/providers/analyticsProvider.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() =>
      _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // Load admin analytics on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsProvider.notifier).loadAdminAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProvider);
    final notifier = ref.read(analyticsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("📊 Admin Analytics"),
        backgroundColor: const Color(0xFF8B4789),
        elevation: 0,
      ),
      body: analyticsState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF8B4789)),
              ),
            )
          : analyticsState.errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(height: 20),
                      Text("Error: ${analyticsState.errorMessage}"),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(analyticsProvider.notifier)
                              .loadAdminAnalytics();
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // ✅ 1. SUMMARY CARDS
                      _buildSummaryCards(analyticsState, notifier),
                      const SizedBox(height: 20),

                      // ✅ 2. BOOKINGS TREND CHART
                      _buildBookingsTrendChart(analyticsState, notifier),
                      const SizedBox(height: 20),

                      // ✅ 3. REVENUE TREND CHART
                      _buildRevenueTrendChart(analyticsState, notifier),
                      const SizedBox(height: 20),

                      // ✅ 4. TOP HALLS
                      _buildTopHallsList(analyticsState, notifier),
                      const SizedBox(height: 20),

                      // ✅ 5. TOP RATINGS
                      _buildTopRatingsList(analyticsState, notifier),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  // 📦 Summary Cards
  Widget _buildSummaryCards(AnalyticsState state, AnalyticsNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  title: "Total Bookings",
                  value: "${state.summary['totalBookings'] ?? 0}",
                  icon: Icons.book,
                  bgColor: const Color(0xFFE8F5E9),
                  textColor: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  title: "Total Revenue",
                  value: notifier.formatCurrency(state.summary['totalRevenue']),
                  icon: Icons.attach_money,
                  bgColor: const Color(0xFFFFF3E0),
                  textColor: const Color(0xFFF57C00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  title: "Total Halls",
                  value: "${state.summary['totalHalls'] ?? 0}",
                  icon: Icons.home,
                  bgColor: const Color(0xFFE3F2FD),
                  textColor: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  title: "Total Users",
                  value: "${state.summary['totalUsers'] ?? 0}",
                  icon: Icons.people,
                  bgColor: const Color(0xFFF3E5F5),
                  textColor: const Color(0xFF6A1B9A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📊 Bookings Trend Chart
  Widget _buildBookingsTrendChart(
      AnalyticsState state, AnalyticsNotifier notifier) {
    if (state.bookingsTrend.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No booking data available"),
        ),
      );
    }

    final trendData = notifier.getTrendChartData();
    final bookings = trendData['bookings'] as List<double>;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "📈 Bookings Trend (Last 30 Days)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4789),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text("Day ${value.toInt()}");
                            }),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          bookings.length,
                          (index) => FlSpot(index.toDouble(), bookings[index]),
                        ),
                        isCurved: true,
                        color: const Color(0xFF8B4789),
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 💰 Revenue Trend Chart
  Widget _buildRevenueTrendChart(
      AnalyticsState state, AnalyticsNotifier notifier) {
    if (state.revenueTrend.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No revenue data available"),
        ),
      );
    }

    final revenueData = notifier.getRevenueTrendChartData();
    final revenues = revenueData['revenues'] as List<double>;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "💰 Revenue Trend (Last 12 Months)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4789),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text("M${value.toInt()}");
                            }),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    barGroups: List.generate(
                      revenues.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: revenues[index],
                            color: const Color(0xFF8B4789),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🏆 Top Halls List
  Widget _buildTopHallsList(AnalyticsState state, AnalyticsNotifier notifier) {
    if (state.topHalls.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No halls data available"),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "🏆 Top Halls",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4789),
                ),
              ),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.topHalls.length,
                itemBuilder: (context, index) {
                  final hall = state.topHalls[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF8B4789),
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        hall['hallName'] ?? 'Unknown Hall',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Bookings: ${hall['bookingCount']} | Revenue: ${notifier.formatCurrency(hall['totalRevenue'])}",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ⭐ Top Ratings List
  Widget _buildTopRatingsList(
      AnalyticsState state, AnalyticsNotifier notifier) {
    if (state.ratings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("No ratings data available"),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "⭐ Top Rated Halls",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4789),
                ),
              ),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.ratings.length,
                itemBuilder: (context, index) {
                  final rating = state.ratings[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFC107),
                        child: Text(
                          "⭐",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      title: Text(
                        rating['hallName'] ?? 'Unknown Hall',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Rating: ${rating['averageRating']} | Reviews: ${rating['reviewCount']}",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: Summary Card Widget
  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
