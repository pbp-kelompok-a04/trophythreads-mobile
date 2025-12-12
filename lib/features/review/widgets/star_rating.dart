import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final bool showRating;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 20,
    this.color = Colors.orange,
    this.showRating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < fullStars) {
            return Icon(Icons.star, size: size, color: color);
          } else if (index == fullStars && hasHalfStar) {
            return Icon(Icons.star_half, size: size, color: color);
          } else {
            return Icon(Icons.star_border, size: size, color: color);
          }
        }),
        if (showRating) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.7,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ],
    );
  }
}

class InteractiveStarRating extends StatefulWidget {
  final int rating;
  final Function(int) onRatingChanged;
  final double size;

  const InteractiveStarRating({
    Key? key,
    required this.rating,
    required this.onRatingChanged,
    this.size = 36,
  }) : super(key: key);

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  int _hoveredStar = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        int starValue = index + 1;
        bool isFilled = starValue <= (widget.rating);
        bool isHovered = starValue <= _hoveredStar;

        return GestureDetector(
          onTap: () => widget.onRatingChanged(starValue),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoveredStar = starValue),
            onExit: (_) => setState(() => _hoveredStar = 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                isFilled || isHovered ? Icons.star : Icons.star_border,
                size: widget.size,
                color: isFilled || isHovered
                    ? const Color(0xFFFFA726)
                    : Colors.grey[400],
              ),
            ),
          ),
        );
      }),
    );
  }
}