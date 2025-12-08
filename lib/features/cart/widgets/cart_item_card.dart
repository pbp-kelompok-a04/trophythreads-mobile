import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/cart_entry.dart';
import '../services/cart_service.dart';

class CartItemCard extends StatefulWidget {
  final CartItem cartItem;
  final VoidCallback onDelete;
  final Function(bool?) onSelectedChanged;
  final Function(int) onQuantityChanged;

  const CartItemCard({
    Key? key,
    required this.cartItem,
    required this.onDelete,
    required this.onSelectedChanged,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late int _quantity;
  late bool _isSelected;
  bool _isUpdating = false;

  // sizing constants
  static const double _imageSize = 110;
  static const double _checkboxSize = 42;

  @override
  void initState() {
    super.initState();
    _quantity = widget.cartItem.quantity;
    _isSelected = widget.cartItem.selected;
  }

  @override
  void didUpdateWidget(covariant CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // sync local state if model changed externally
    if (oldWidget.cartItem.id != widget.cartItem.id ||
        oldWidget.cartItem.quantity != widget.cartItem.quantity) {
      _quantity = widget.cartItem.quantity;
    }
    if (oldWidget.cartItem.selected != widget.cartItem.selected) {
      _isSelected = widget.cartItem.selected;
    }
  }

  Future<void> _decrementQuantity() async {
    if (_isUpdating || _quantity <= 0) return;

    setState(() => _isUpdating = true);

    final request = context.read<CookieRequest>();

    try {
      final response = await CartService.updateQuantity(
        request,
        widget.cartItem.id,
        'dec',
      );

      if (response['success'] == true) {
        if (response['quantity'] == 0) {
          // Item was deleted
          widget.onDelete();
        } else {
          setState(() => _quantity = response['quantity']);
          widget.onQuantityChanged(response['quantity']);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? 'Gagal mengupdate jumlah'),
              backgroundColor: const Color(0xFFE93C49),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFE93C49),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _incrementQuantity() async {
    if (_isUpdating) return;

    final stock = widget.cartItem.product.stock;
    if (_quantity >= stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok tidak mencukupi'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isUpdating = true);

    final request = context.read<CookieRequest>();

    try {
      final response = await CartService.updateQuantity(
        request,
        widget.cartItem.id,
        'inc',
      );

      if (response['success'] == true) {
        setState(() => _quantity = response['quantity']);
        widget.onQuantityChanged(response['quantity']);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? 'Gagal mengupdate jumlah'),
              backgroundColor: const Color(0xFFE93C49),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFE93C49),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  void _toggleSelect() {
    final newVal = !_isSelected;
    setState(() => _isSelected = newVal);
    widget.onSelectedChanged(newVal);
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.cartItem.product;
    final productName = product.name;
    final productPrice = product.price;
    final productThumbnail = product.thumbnail;
    final productStock = product.stock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, // tiap card putih
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: _imageSize,
              child: Center(
                child: GestureDetector(
                  onTap: _toggleSelect,
                  child: Container(
                    width: _checkboxSize,
                    height: _checkboxSize,
                    decoration: BoxDecoration(
                      color: _isSelected
                          ? const Color.fromARGB(255, 69, 137, 238)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isSelected
                            ? const Color.fromARGB(255, 69, 137, 238)
                            : const Color(0xFFE6E6E6),
                        width: 1.6,
                      ),
                      boxShadow: _isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: _isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // product image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: _imageSize,
                height: _imageSize,
                child: productThumbnail.isNotEmpty
                    ? Image.network(
                        productThumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFF7F7F7),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 36,
                              color: Color(0xFFFFCECE),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFF7F7F7),
                        child: const Center(
                          child: Icon(
                            Icons.shopping_bag,
                            size: 36,
                            color: Color(0xFFFFCECE),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // details + delete positioned
            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // product name
                      Text(
                        productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // price
                      Text(
                        'Rp ${_formatPrice(productPrice)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE93C49),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // stock
                      Text(
                        'Stok: $productStock',
                        style: TextStyle(
                          fontSize: 12,
                          color: productStock > 0
                              ? Colors.grey[600]
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // quantity selector
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFECECEC),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: _isUpdating
                                      ? null
                                      : _decrementQuantity,
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: 16,
                                      color: _isUpdating
                                          ? Colors.grey
                                          : const Color(0xFFE93C49),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: _isUpdating
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          '$_quantity',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                                InkWell(
                                  onTap: _isUpdating
                                      ? null
                                      : _incrementQuantity,
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 16,
                                      color: _isUpdating
                                          ? Colors.grey
                                          : const Color(0xFFE93C49),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Positioned(
                    right: 0,
                    top: 0,
                    child: TextButton(
                      onPressed: widget.onDelete,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Hapus',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
