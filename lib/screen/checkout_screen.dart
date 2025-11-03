import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_model.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

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
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Tính tổng tiền
    _total = widget.itemsToBuy.fold(
      0,
      (sum, item) => sum + (item.book.price * item.quantity),
    );
    
    // ⭐️ [THÊM MỚI] Logic tự động điền thông tin
    // Lấy thông tin user từ AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser != null) {
      _nameController.text = currentUser.name;
      _phoneController.text = currentUser.phone;
      _addressController.text = currentUser.address;
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final String actualUserId = authProvider.currentUser!.id;

    await Future.delayed(const Duration(seconds: 2));

    try {
      await orderProvider.addOrder(
        userId: actualUserId,
        totalAmount: _total,
        items: widget.itemsToBuy,
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
      );
      if (widget.source == CheckoutSource.cart) {
        cartProvider.clearCart();
      }

      setState(() {
        _isProcessing = false;
      });

      final fomattedTotal = cartProvider.formatPrice(_total);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt hàng thành công! Đơn hàng trị giá $fomattedTotal'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt hàng thất bại: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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
    final colorScheme = Theme.of(context).colorScheme;

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
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.tertiary,
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
                  onPressed: _isProcessing ? null : _placeOrder,
                  icon: _isProcessing
                      ? CircularProgressIndicator(color: colorScheme.onPrimary)
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _isProcessing
                        ? 'Đang xử lý...'
                        : 'Xác nhận đặt hàng $formattedTotal',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
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
