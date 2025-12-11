import 'package:flutter/material.dart';

class ReviewListPage extends StatefulWidget {
  final String productId;
  final String productName;
  
  const ReviewListPage({
    Key? key, 
    required this.productId,
    this.productName = 'Product',
  }) : super(key: key);
  
  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  String? _selectedFilter;
  
  // DUMMY DATA REVIEWS
  final List<Map<String, dynamic>> _allReviews = [
    {
      'id': '1',
      'user': 'Alice Johnson',
      'rating': 5,
      'body': 'Absolutely love this product! The quality is amazing and it fits perfectly. Highly recommend to everyone!',
      'date': '2024-01-15',
    },
    {
      'id': '2',
      'user': 'Bob Smith',
      'rating': 4,
      'body': 'Good quality product. The color was slightly different from the photo but overall satisfied with the purchase.',
      'date': '2024-01-10',
    },
    {
      'id': '3',
      'user': 'Charlie Brown',
      'rating': 5,
      'body': 'Best purchase ever! Fast delivery and excellent customer service. Will definitely buy again.',
      'date': '2024-01-08',
    },
    {
      'id': '4',
      'user': 'Diana Prince',
      'rating': 3,
      'body': 'It\'s okay. The product works as described but I expected better quality for the price.',
      'date': '2024-01-05',
    },
    {
      'id': '5',
      'user': 'Edward Norton',
      'rating': 4,
      'body': 'Pretty good! Delivery was quick and packaging was secure. Minor issues with sizing but manageable.',
      'date': '2024-01-03',
    },
    {
      'id': '6',
      'user': 'Fiona Apple',
      'rating': 5,
      'body': 'Exceeded my expectations! The material is high quality and the design is beautiful. Worth every penny.',
      'date': '2023-12-28',
    },
    {
      'id': '7',
      'user': 'George Martin',
      'rating': 2,
      'body': 'Not what I expected. The product arrived damaged and customer service was slow to respond.',
      'date': '2023-12-25',
    },
    {
      'id': '8',
      'user': 'Hannah Montana',
      'rating': 4,
      'body': 'Good value for money. Works well and looks nice. Only complaint is it took a while to arrive.',
      'date': '2023-12-20',
    },
  ];
  
  List<Map<String, dynamic>> get _filteredReviews {
    if (_selectedFilter == null) return _allReviews;
    int filterRating = int.parse(_selectedFilter!);
    return _allReviews.where((review) => review['rating'] == filterRating).toList();
  }
  
  Map<String, int> get _ratingCounts {
    Map<String, int> counts = {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};
    for (var review in _allReviews) {
      counts[review['rating'].toString()] = (counts[review['rating'].toString()] ?? 0) + 1;
    }
    return counts;
  }
  
  double get _averageRating {
    if (_allReviews.isEmpty) return 0.0;
    double sum = _allReviews.fold(0.0, (sum, review) => sum + review['rating']);
    return sum / _allReviews.length;
  }
  
  void _filterReviews(String? stars) {
    setState(() {
      _selectedFilter = stars;
    });
  }
  
  void _addNewReview(Map<String, dynamic> newReview) {
    setState(() {
      _allReviews.insert(0, newReview);
    });
  }
  
  void _editReview(int index, Map<String, dynamic> updatedReview) {
    setState(() {
      _allReviews[index] = updatedReview;
    });
  }
  
  void _deleteReview(int index) {
    setState(() {
      _allReviews.removeAt(index);
    });
  }
  
  // FUNCTION BUAT SHOW BOTTOM SHEET
  void _showReviewForm({bool isEdit = false, int? rating, String? body, int? reviewIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewFormBottomSheet(
        isEdit: isEdit,
        initialRating: rating,
        initialBody: body,
        onSubmit: (newRating, newBody) {
          if (isEdit && reviewIndex != null) {
            // Edit existing review
            _editReview(reviewIndex, {
              ..._allReviews[reviewIndex],
              'rating': newRating,
              'body': newBody,
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Review updated!')),
            );
          } else {
            // Add new review
            _addNewReview({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'user': 'You',
              'rating': newRating,
              'body': newBody,
              'date': DateTime.now().toString().split(' ')[0],
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Review added successfully!')),
            );
          }
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final reviews = _filteredReviews;
    final counts = _ratingCounts;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Reviews'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Product info & rating summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < _averageRating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 24,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Based on ${_allReviews.length} reviews',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                FilterChip(
                  label: Text('All (${_allReviews.length})'),
                  selected: _selectedFilter == null,
                  onSelected: (_) => _filterReviews(null),
                  selectedColor: Colors.blue.shade100,
                ),
                const SizedBox(width: 8),
                ...['5', '4', '3', '2', '1'].map((stars) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('$stars ⭐ (${counts[stars] ?? 0})'),
                      selected: _selectedFilter == stars,
                      onSelected: (_) => _filterReviews(stars),
                      selectedColor: Colors.blue.shade100,
                    ),
                  );
                }),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Reviews list
          Expanded(
            child: reviews.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No reviews for this filter',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: reviews.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      final actualIndex = _allReviews.indexOf(review);
                      
                      return Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.shade100,
                                    child: Text(
                                      review['user'][0],
                                      style: TextStyle(
                                        color: Colors.blue.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review['user'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          review['date'],
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Edit & Delete buttons
                                  PopupMenuButton(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 20, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete', style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        // SHOW BOTTOM SHEET BUAT EDIT
                                        _showReviewForm(
                                          isEdit: true,
                                          rating: review['rating'],
                                          body: review['body'],
                                          reviewIndex: actualIndex,
                                        );
                                      } else if (value == 'delete') {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Review'),
                                            content: const Text('Are you sure you want to delete this review?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        
                                        if (confirm == true) {
                                          _deleteReview(actualIndex);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Review deleted!')),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < review['rating'] ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  );
                                }),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                review['body'],
                                style: const TextStyle(height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // SHOW BOTTOM SHEET BUAT ADD REVIEW BARU
          _showReviewForm();
        },
        icon: const Icon(Icons.rate_review),
        label: const Text('Write Review'),
      ),
    );
  }
}

// WIDGET BOTTOM SHEET FORM
class ReviewFormBottomSheet extends StatefulWidget {
  final bool isEdit;
  final int? initialRating;
  final String? initialBody;
  final Function(int rating, String body) onSubmit;
  
  const ReviewFormBottomSheet({
    Key? key,
    this.isEdit = false,
    this.initialRating,
    this.initialBody,
    required this.onSubmit,
  }) : super(key: key);
  
  @override
  State<ReviewFormBottomSheet> createState() => _ReviewFormBottomSheetState();
}

class _ReviewFormBottomSheetState extends State<ReviewFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _bodyController = TextEditingController();
  late int _rating;
  
  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 5;
    _bodyController.text = widget.initialBody ?? '';
  }
  
  String _getRatingText(int rating) {
    switch (rating) {
      case 1: return 'Poor';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Very Good';
      case 5: return 'Excellent';
      default: return '';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  widget.isEdit ? 'Edit Review' : 'Write Review',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Rating
                Text(
                  'How would you rate this product?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        iconSize: 48,
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() => _rating = index + 1);
                        },
                      );
                    }),
                  ),
                ),
                Center(
                  child: Text(
                    _getRatingText(_rating),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Review text
                Text(
                  'Share your experience',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bodyController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Tell us what you think about this product...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please write your review';
                    }
                    if (value.trim().length < 10) {
                      return 'Review must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.onSubmit(_rating, _bodyController.text.trim());
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(widget.isEdit ? 'Update' : 'Submit'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }
}