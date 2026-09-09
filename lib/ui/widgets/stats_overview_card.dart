import 'package:flutter/material.dart';

/// Pure helper function to build individual stat counter item
Widget buildStatItem(String label, String value, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 16, color: Colors.white.withOpacity(0.9)),
      const SizedBox(width: 6),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Pure builder function that creates the dashboard statistics header
Widget buildStatsOverviewCard({
  required String userName,
  required int total,
  required int completed,
  required int pending,
  required double percentage,
}) {
  final percentInt = (percentage * 100).toInt();

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF4F46E5).withOpacity(0.35),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName 👋',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  total == 0
                      ? 'Ready to plan your day?'
                      : (pending == 0
                          ? 'All tasks completed! 🎉'
                          : '$pending tasks remaining today'),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            // Circular progress ring
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 5,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Text(
                  '$percentInt%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Counters Row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildStatItem('Total', total.toString(), Icons.format_list_bulleted),
              Container(height: 24, width: 1, color: Colors.white.withOpacity(0.3)),
              buildStatItem('Pending', pending.toString(), Icons.hourglass_top_rounded),
              Container(height: 24, width: 1, color: Colors.white.withOpacity(0.3)),
              buildStatItem('Done', completed.toString(), Icons.check_circle_outline_rounded),
            ],
          ),
        ),
      ],
    ),
  );
}

/// StatsOverviewCard widget adapter
class StatsOverviewCard extends StatelessWidget {
  final String userName;
  final int total;
  final int completed;
  final int pending;
  final double percentage;

  const StatsOverviewCard({
    super.key,
    required this.userName,
    required this.total,
    required this.completed,
    required this.pending,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) => buildStatsOverviewCard(
        userName: userName,
        total: total,
        completed: completed,
        pending: pending,
        percentage: percentage,
      );
}
