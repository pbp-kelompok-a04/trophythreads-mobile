import 'package:flutter/material.dart';
import 'package:trophythreads_mobile/features/merchandise/screens/merchandise_list.dart';

class AfterCheckoutPage extends StatelessWidget {
  final String orderToken;
  final int grandTotal;

  const AfterCheckoutPage({
    Key? key,
    required this.orderToken,
    required this.grandTotal,
  }) : super(key: key);

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
                  onTap: () {
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => MerchandiseEntryListPage(),
                    //   ),
                    // );
                    // Navigate back to home or main page
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_back, color: Color(0xFFE36B6B)),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Kembali ke Home',
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Card
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCECE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success Title
                      const Text(
                        'PEMBAYARAN',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE93C49),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Text(
                        'BERHASIL',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFCECE),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Happy Emoticon
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9F89), Color(0xFFFD5140)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'ദി(˵ •̀ ᴗ - ˵ ) ✧',
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Thank you message
                      const Text(
                        'Terima kasih!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE93C49),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Pesanan kamu akan diproses.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFE93C49),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
