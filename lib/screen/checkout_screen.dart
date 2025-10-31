import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_model.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';

enum CheckoutSource { cart, quickBuy }

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> itemsToBuy;
  final CheckoutSource source;

  const CheckoutScreen({
    super.key,
    required this.itemsToBuy,
    required this.source,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  double _total = 0;

  @override
  void initState() {
    super.initState();
    _total = widget.itemsToBuy.fold(
      0,
      (sum, item) => sum + (item.book.price * item.quantity),
    );
  }

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final double total = widget.itemsToBuy.fold(
      0,
      (sum, item) => sum + (item.book.price * item.quantity),
    );
    final String formattedTotal = cartProvider.formatPrice(_total);
    final String actualUserId = authProvider.currentUser!.email;

    orderProvider.addOrder(
      userId: actualUserId,
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      totalAmount: total,
      items: widget.itemsToBuy,
    );

    if (widget.source == CheckoutSource.cart) {
      cartProvider.clearCart();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đặt hàng thành công! Đơn hàng trị giá $formattedTotal đã được giao đến ${_addressController.text}.',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedTotal = Provider.of<CartProvider>(
      context,
      listen: false,
    ).formatPrice(_total);

    return Scaffold(
      appBar: AppBar(title: const Text('Xác Nhận Đơn Hàng')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20), // <-- Đã sửa lỗi padding
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng tiền: $formattedTotal',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Thông tin giao hàng:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Divider(),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên người nhận',
                  ),
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập SĐT' : null,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ giao hàng',
                  ),
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                ),
                const SizedBox(height: 40),

                ElevatedButton.icon(
                  onPressed: _placeOrder,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text('Xác nhận đặt hàng $formattedTotal'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
