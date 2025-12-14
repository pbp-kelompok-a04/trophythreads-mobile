import 'package:flutter/material.dart';
import '../models/cart_entry.dart';

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

  // sizing constants
  static const double _imageSize = 110;
  static const double _checkboxSize = 42;

  @override
  void initState() {
    super.initState();
    _quantity = widget.cartItem.fields.quantity;
    _isSelected = widget.cartItem.fields.selected;
  }

  @override
  void didUpdateWidget(covariant CartItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // sync local state if model changed externally
    if (oldWidget.cartItem.pk != widget.cartItem.pk ||
        oldWidget.cartItem.fields.quantity != widget.cartItem.fields.quantity) {
      _quantity = widget.cartItem.fields.quantity;
    }
    if (oldWidget.cartItem.fields.selected != widget.cartItem.fields.selected) {
      _isSelected = widget.cartItem.fields.selected;
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      widget.onQuantityChanged(_quantity);
    }
  }

  void _incrementQuantity() {
    final stock = (widget.cartItem.fields.productStock ?? 0) as int;
    if (_quantity < stock) {
      setState(() {
        _quantity++;
      });
      widget.onQuantityChanged(_quantity);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok tidak mencukupi'),
          duration: Duration(seconds: 2),
        ),
      );
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
    final fields = widget.cartItem.fields;
    final productName = (fields.productName ?? 'Unknown Product') as String;
    final productPrice = (fields.productPrice ?? 0) as int;
    final productThumbnail = (fields.productThumbnail ?? '') as String;
    final productStock = (fields.productStock ?? 0) as int;

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
                                  onTap: _decrementQuantity,
                                  borderRadius: BorderRadius.circular(6),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      size: 16,
                                      color: Color(0xFFE93C49),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    '$_quantity',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: _incrementQuantity,
                                  borderRadius: BorderRadius.circular(6),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 16,
                                      color: Color(0xFFE93C49),
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
