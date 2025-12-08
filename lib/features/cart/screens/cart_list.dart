import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/cart_entry.dart';
import '../widgets/cart_item_card.dart';
import '../services/cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];
  bool _isLoading = true;
  bool _selectAll = false;
  int _cartSubtotal = 0;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    setState(() => _isLoading = true);

    final request = context.read<CookieRequest>();

    try {
      final response = await CartService.getCartPage(request);

      if (response['items'] != null) {
        setState(() {
          // Parse items dari format custom response
          cartItems = (response['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList();
          _cartSubtotal = response['cart_subtotal'] ?? 0;
          _totalItems = response['total_items'] ?? 0;
          _selectAll =
              cartItems.isNotEmpty && cartItems.every((item) => item.selected);
          _isLoading = false;
        });
      } else {
        setState(() {
          cartItems = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading cart: $e'),
            backgroundColor: const Color(0xFFE93C49),
          ),
        );
      }
    }
  }

  Future<void> _toggleSelectAll(bool? value) async {
    final request = context.read<CookieRequest>();
    final selected = value ?? false;

    try {
      final response = await CartService.toggleSelectAll(request, selected);

      if (response['success'] == true) {
        setState(() {
          _selectAll = selected;
          for (var item in cartItems) {
            item.selected = _selectAll;
          }
          _cartSubtotal = response['cart_subtotal'] ?? 0;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? 'Failed to toggle all'),
              backgroundColor: const Color(0xFFE93C49),
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
          ),
        );
      }
    }
  }

  Future<void> _deleteItem(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Konfirmasi Hapus',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Apakah kamu yakin mau menghapus item ini dari keranjang (づ •. •)??',
                  style: TextStyle(fontSize: 16, height: 1.3),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          'Batalkan',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _performDelete(index);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE93C49),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Text(
                          'Hapus',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performDelete(int index) async {
    final request = context.read<CookieRequest>();
    final itemId = cartItems[index].id;

    try {
      final response = await CartService.deleteItem(request, itemId);

      if (response['success'] == true) {
        setState(() {
          cartItems.removeAt(index);
          _cartSubtotal = response['cart_subtotal'] ?? 0;
          _totalItems = response['total_items'] ?? 0;
          _selectAll =
              cartItems.isNotEmpty && cartItems.every((i) => i.selected);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item berhasil dihapus')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? 'Failed to delete item'),
              backgroundColor: const Color(0xFFE93C49),
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
          ),
        );
      }
    }
  }

  int _getSelectedItemsCount() {
    return cartItems.where((item) => item.selected).length;
  }

  int _getTotalPrice() {
    int total = 0;
    for (var item in cartItems) {
      if (item.selected) {
        total += item.lineTotal;
      }
    }
    return total;
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _proceedToCheckout() async {
    final selectedItems = cartItems.where((item) => item.selected).toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 item untuk checkout'),
          backgroundColor: Color(0xFFE93C49),
        ),
      );
      return;
    }

    // Navigate to checkout page or show checkout dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checkout ${selectedItems.length} item')),
    );

    // TODO: Implement navigation to checkout page
    // Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage()));
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _getSelectedItemsCount();
    final totalPrice = _getTotalPrice();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF1F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF45959), Color(0xFFFFA4A4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        centerTitle: false,
        title: SizedBox(
          width: MediaQuery.of(context).size.width - 16,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_back, color: Color(0xFFE36B6B)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Keranjang (${cartItems.length})',
                    style: const TextStyle(
                      color: Color(0xFFE36B6B),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _fetchCartItems,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.refresh,
                      color: Color(0xFFE93C49),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        toolbarHeight: 92,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? _buildEmptyCart()
          : RefreshIndicator(
              onRefresh: _fetchCartItems,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFCECE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    itemCount: cartItems.length,
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return CartItemCard(
                        cartItem: cartItems[index],
                        onDelete: () => _deleteItem(index),
                        onSelectedChanged: (value) async {
                          final request = context.read<CookieRequest>();
                          final response = await CartService.toggleSelection(
                            request,
                            cartItems[index].id,
                          );

                          if (response['success'] == true) {
                            setState(() {
                              cartItems[index].selected =
                                  response['selected'] ?? false;
                              _selectAll =
                                  cartItems.isNotEmpty &&
                                  cartItems.every((item) => item.selected);
                              _cartSubtotal = response['cart_subtotal'] ?? 0;
                            });
                          }
                        },
                        onQuantityChanged: (newQuantity) async {
                          final request = context.read<CookieRequest>();
                          final response = await CartService.updateQuantity(
                            request,
                            cartItems[index].id,
                            'set',
                            quantity: newQuantity,
                          );

                          if (response['success'] == true) {
                            setState(() {
                              if (response['quantity'] == 0) {
                                cartItems.removeAt(index);
                              } else {
                                cartItems[index].quantity =
                                    response['quantity'];
                                cartItems[index].lineTotal =
                                    response['line_total'];
                              }
                              _cartSubtotal = response['cart_subtotal'] ?? 0;
                              _totalItems = response['total_items'] ?? 0;
                            });
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response['error'] ??
                                        'Failed to update quantity',
                                  ),
                                  backgroundColor: const Color(0xFFE93C49),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomBar(selectedCount, totalPrice),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 100,
                color: Color(0xFFFFCECE),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum ada produk di Keranjang (ã€‚Â´ï¸¶`ã€‚)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8A8A1),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Silahkan tambahkan produk terlebih dahulu...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFE36B6B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(int selectedCount, int totalPrice) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFD9B9B), Color(0xFFFF6B6B), Color(0xFFEC414E)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Checkbox(
                value: _selectAll,
                onChanged: _toggleSelectAll,
                activeColor: Colors.white,
                checkColor: const Color(0xFFE93C49),
                side: const BorderSide(color: Colors.white, width: 2),
              ),
              const Text(
                'Semua',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  Text(
                    'Rp ${_formatPrice(totalPrice)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFFEEFEF),
                      Color(0xFFFFD4D4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: _proceedToCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFFFF6B6B),
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    fixedSize: const Size(160, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Checkout ($selectedCount)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
}
