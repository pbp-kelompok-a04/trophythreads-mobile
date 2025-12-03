import 'package:flutter/material.dart';
import '../models/merchandise_entry.dart';
import 'package:trophythreads_mobile/features/review/screens/review_list_page.dart';


class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({Key? key, required merchandise}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final List<String> images = [
    'https://picsum.photos/800/800?image=1',
    'https://picsum.photos/800/800?image=2',
    'https://picsum.photos/800/800?image=3',
  ];

  int _currentImage = 0;
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
      body: SafeArea(
        child: ListView(
          children: [
            _buildImageCarousel(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleAndPrice(),
                  const SizedBox(height: 8),
                  _buildRatingAndStock(),
                  const SizedBox(height: 12),
                  _buildQuantity(),
                  const SizedBox(height: 16),
                  _buildDescription(),
                  const SizedBox(height: 16),
                  _buildReviews(),
                  const SizedBox(height: 80), // leave space for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            onPageChanged: (index) => setState(() => _currentImage = index),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Hero(
                tag: 'product-image-$index',
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stack) => const Center(child: Icon(Icons.broken_image, size: 48)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _buildImageIndicators(),
      ],
    );
  }

  Widget _buildImageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(images.length, (index) {
        bool active = index == _currentImage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: active ? Colors.blueAccent : Colors.grey.shade400,
          ),
        );
      }),
    );
  }

  Widget _buildTitleAndPrice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Stylish Casual Shirt',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Brand: FashionCo', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text('\$79.99', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('\$129.99', style: TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough)),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingAndStock() {
    return Row(
      children: [
        _buildStarRating(4.5),
        const SizedBox(width: 8),
        const Text('(120 reviews)', style: TextStyle(color: Colors.grey)),
        const Spacer(),
        const Text('In stock', style: TextStyle(color: Colors.green)),
      ],
    );
  }

  Widget _buildStarRating(double rating) {
    int full = rating.floor();
    bool half = (rating - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full) return const Icon(Icons.star, size: 18, color: Colors.orange);
        if (i == full && half) return const Icon(Icons.star_half, size: 18, color: Colors.orange);
        return const Icon(Icons.star_border, size: 18, color: Colors.orange);
      }),
    );
  }

  Widget _buildQuantity() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _quantity = (_quantity > 1) ? _quantity - 1 : 1),
                icon: const Icon(Icons.remove),
              ),
              Text('$_quantity', style: const TextStyle(fontSize: 16)),
              IconButton(
                onPressed: () => setState(() => _quantity++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Text(
          'A high-quality casual shirt made from breathable fabric. Perfect for everyday wear or semi-formal events. Machine washable and available in several colors and sizes.',
          style: TextStyle(height: 1.4),
        ),
      ],
    );
  }

  Widget _buildReviews() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Customer Reviews', style: TextStyle(fontWeight: FontWeight.w600)),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReviewListPage(
                    productId: 'product-123', // Dummy ID
                    productName: 'Stylish Casual Shirt', // Nama product
                  ),
                ),
              );
            },
            child: const Text('See All Reviews →'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      _buildSingleReview('Alice', 5, 'Great shirt — fits well and looks premium.'),
      const SizedBox(height: 8),
      _buildSingleReview('Bob', 4, 'Good quality, color was slightly different than photos.'),
    ],
  );
}

  Widget _buildSingleReview(String author, int rating, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(child: Text(author[0])),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(author, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Row(children: List.generate(rating, (_) => const Icon(Icons.star, size: 14, color: Colors.orange))),
                ],
              ),
              const SizedBox(height: 4),
              Text(text),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                // quick support/chat action
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // add to cart logic
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                },
                child: const Text('Add to cart'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                // buy now logic
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proceed to buy')));
              },
              child: const Text('Buy now'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
