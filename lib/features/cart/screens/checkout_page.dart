import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/cart_service.dart';
import 'after_checkout.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late CartService _cartService;

  bool _isLoading = true;
  bool _isProcessing = false;

  List<dynamic> _items = [];
  int _totalBeforeFee = 0;
  int _shippingFee = 0;
  int _serviceFee = 0;
  int _grandTotal = 0;
  bool _isBuyNow = false;

  final TextEditingController _addressController = TextEditingController();

  // Payment method selections
  String _paymentCategory = 'ewallet'; // ewallet, bca, bri
  String _paymentMethod = 'gopay'; // gopay, ovo, flip

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      _cartService = CartService(request);
      _fetchCheckoutItems();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchCheckoutItems() async {
    setState(() => _isLoading = true);

    try {
      final result = await _cartService.getCheckoutItems();

      if (result['success'] == true) {
        setState(() {
          _items = result['items'] ?? [];
          _totalBeforeFee = result['total_before_fee'] ?? 0;
          _shippingFee = result['shipping_fee'] ?? 0;
          _serviceFee = result['service_fee'] ?? 0;
          _grandTotal = result['grand_total'] ?? 0;
          _isBuyNow = result['is_buy_now'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'Gagal memuat item checkout'),
              backgroundColor: const Color(0xFFE93C49),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFE93C49),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _processCheckout() async {
    final address = _addressController.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat harus diisi'),
          backgroundColor: Color(0xFFE93C49),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final result = await _cartService.processCheckout(
        address: address,
        paymentMethod: _paymentMethod,
      );

      setState(() => _isProcessing = false);

      if (result['success'] == true) {
        if (mounted) {
          // Navigate to success page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AfterCheckoutPage(
                orderToken: result['order_token'] ?? '',
                grandTotal: result['grand_total'] ?? 0,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Checkout gagal'),
              backgroundColor: const Color(0xFFE93C49),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFE93C49),
          ),
        );
      }
    }
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  onTap: () => Navigator.of(context).pop(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_back, color: Color(0xFFE36B6B)),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Checkout',
                    style: TextStyle(
                      color: Color(0xFFE36B6B),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address Section with #FFCECE background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCECE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildAddressSection(),
                  ),
                  const SizedBox(height: 12),

                  // Items List with #FFCECE background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCECE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: _items
                          .map((item) => _buildItemCard(item))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Total Products with #FFCECE background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCECE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildTotalProductsCard(),
                  ),
                  const SizedBox(height: 12),

                  // Payment Method
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCECE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildPaymentMethodCard(),
                  ),
                  const SizedBox(height: 12),

                  // Payment Summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCECE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildPaymentSummaryCard(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCECE), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFFE93C49), size: 20),
              SizedBox(width: 8),
              Text(
                'Burhan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE93C49),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            maxLines: 2,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText:
                  'Alamat: Jl. ABCDEF No. 123 RT/RW 01/003, Universitas Indonesia, DEPOK',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE93C49)),
              ),
              contentPadding: const EdgeInsets.all(12),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    final productName = item['product_name'] ?? 'Unknown';
    final productPrice = item['product_price'] ?? 0;
    final quantity = item['quantity'] ?? 0;
    final thumbnail = item['product_thumbnail'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCECE), width: 2),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: const Color(0xFFFFF8F8),
              child: thumbnail.isNotEmpty
                  ? Image.network(
                      thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported,
                        color: Color(0xFFFFCECE),
                      ),
                    )
                  : const Icon(
                      Icons.shopping_bag,
                      color: Color(0xFFFFCECE),
                      size: 40,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${_formatPrice(productPrice)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE93C49),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jumlah: $quantity',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalProductsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCECE), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total ${_items.length} Produk',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(
            'Rp ${_formatPrice(_totalBeforeFee)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCECE), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Payment Category Buttons
          Row(
            children: [
              _buildPaymentCategoryButton('Ewallet', 'ewallet'),
              const SizedBox(width: 8),
              _buildPaymentCategoryButton('BCA OneKlik', 'bca'),
              const SizedBox(width: 8),
              _buildPaymentCategoryButton('BRI OneKlik', 'bri'),
            ],
          ),

          // Show ewallet options only if ewallet is selected
          if (_paymentCategory == 'ewallet') ...[
            const SizedBox(height: 16),
            _buildPaymentOption('Gopay', 'gopay'),
            _buildPaymentOption('Ovo', 'ovo'),
            _buildPaymentOption('Flip', 'flip'),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentCategoryButton(String label, String value) {
    final isSelected = _paymentCategory == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _paymentCategory = value;
            if (value != 'ewallet') {
              _paymentMethod = value;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFE5E5) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFE93C49)
                  : const Color(0xFFE0E0E0),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFFE93C49) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      value: value,
      groupValue: _paymentMethod,
      onChanged: (newValue) {
        setState(() => _paymentMethod = newValue ?? 'gopay');
      },
      activeColor: const Color(0xFFE93C49),
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCECE), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Pembayaran',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal Pesanan', _totalBeforeFee),
          const SizedBox(height: 8),
          _buildSummaryRow('Subtotal Pengiriman', _shippingFee),
          const SizedBox(height: 8),
          _buildSummaryRow('Biaya Layanan', _serviceFee),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE93C49),
                ),
              ),
              Text(
                'Rp ${_formatPrice(_grandTotal)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE93C49),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Text(
          'Rp ${_formatPrice(amount)}',
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
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
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rp ${_formatPrice(_grandTotal)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Termasuk biaya layanan & pengiriman',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ],
                ),
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
                  onPressed: _isProcessing ? null : _processCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: const Color(0xFFFF6B6B),
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFF6B6B),
                          ),
                        )
                      : const Text(
                          'Buat Pesanan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
