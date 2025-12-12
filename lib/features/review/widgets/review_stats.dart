import 'package:flutter/material.dart';
import 'star_rating.dart';

class ReviewStats extends StatelessWidget {
  final Map<String, int> counts;
  final int total;
  final String currentFilter;
  final Function(String) onFilterChanged;

  const ReviewStats({
    Key? key,
    required this.counts,
    required this.total,
    required this.currentFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  double get averageRating {
    if (total == 0) return 0;
    int sum = 0;
    counts.forEach((star, count) {
      sum += int.parse(star) * count;
    });
    return sum / total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD4D4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE93C49),
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StarRating(rating: averageRating, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    '$total ulasan',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    for (int i = 5; i >= 1; i--)
                      _buildRatingBar(
                        context,
                        i,
                        counts[i.toString()] ?? 0,
                        total,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('all', 'Semua'),
              for (int i = 5; i >= 1; i--)
                _buildFilterChip(
                  i.toString(),
                  '$i ⭐',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(
    BuildContext context,
    int star,
    int count,
    int total,
  ) {
    double percentage = total > 0 ? (count / total) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '$star ⭐',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA726),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 35,
            child: Text(
              count.toString(),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    bool isSelected = currentFilter == value;

    return GestureDetector(
      onTap: () => onFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE93C49) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFE93C49) : const Color(0xFFFFD4D4),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFFE93C49),
          ),
        ),
      ),
    );
  }
}