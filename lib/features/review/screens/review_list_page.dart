import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/review_entry.dart';
import '../services/review_service.dart';
import '../widgets/review_card.dart';
import '../widgets/review_stats.dart';
import 'add_review_page.dart';

class ReviewListPage extends StatefulWidget {
  final String productId;
  final String productName;

  const ReviewListPage({
    Key? key,
    required this.productId,
    required this.productName,
  }) : super(key: key);

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  late ReviewService _reviewService;
  String _currentFilter = 'all';
  bool _isLoading = true;
  ReviewEntry? _reviewData;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      _reviewService = ReviewService(request);
      _fetchReviews();
    });
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _reviewService.fetchReviews(
        productId: widget.productId,
        stars: _currentFilter,
      );

      setState(() {
        _reviewData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAddReview() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewPage(
          productId: widget.productId,
          productName: widget.productName,
        ),
      ),
    );

    if (result == true) {
      _fetchReviews();
    }
  }

  Future<void> _handleEditReview(Review review) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewPage(
          productId: widget.productId,
          productName: widget.productName,
          existingReview: review,
        ),
      ),
    );

    if (result == true) {
      _fetchReviews();
    }
  }

  Future<void> _handleDeleteReview(Review review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Review',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah kamu yakin ingin menghapus review ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await _reviewService.deleteReview(review.id);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Review berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchReviews();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Gagal menghapus review'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _getCurrentUsername() {
    final request = context.read<CookieRequest>();
    return request.jsonData['username'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF45959), Color(0xFFFFA4A4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Penilaian dan ulasan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.productName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _fetchReviews,
                  child: _buildContent(),
                ),
      floatingActionButton: _reviewData?.canReview == true
          ? FloatingActionButton.extended(
              onPressed: _handleAddReview,
              backgroundColor: const Color(0xFFE93C49),
              icon: const Icon(Icons.rate_review),
              label: const Text('Tulis Review'),
            )
          : null,
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchReviews,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final reviews = _reviewData?.reviews ?? [];
    final currentUsername = _getCurrentUsername();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ReviewStats(
          counts: _reviewData?.counts ?? {},
          total: _reviewData?.total ?? 0,
          currentFilter: _currentFilter,
          onFilterChanged: (filter) {
            setState(() => _currentFilter = filter);
            _fetchReviews();
          },
        ),
        const SizedBox(height: 24),
        if (reviews.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentFilter == 'all'
                        ? 'Belum ada review'
                        : 'Belum ada review dengan $_currentFilter bintang',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${reviews.length} Review',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE93C49),
                ),
              ),
              const SizedBox(height: 12),
              ...reviews.map(
                (review) => ReviewCard(
                  review: review,
                  isOwnReview: review.user == currentUsername,
                  onEdit: review.user == currentUsername
                      ? () => _handleEditReview(review)
                      : null,
                  onDelete: review.user == currentUsername
                      ? () => _handleDeleteReview(review)
                      : null,
                ),
              ),
            ],
          ),
        const SizedBox(height: 80),
      ],
    );
  }
}