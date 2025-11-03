import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_model.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'VNPayPaymentScreen.dart'; // WebView
import 'UrlVNPay.dart'; // createVNPayUrlInApp

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

  // Thông tin VNPAY sandbox (điền theo mail VNPAY cấp)
  final String vnpUrl = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
  final String vnpTmnCode = "L2H6NDO9";
  final String vnpHashSecret ="YH409Q4WOS4IPVM0KPTKCGVTXRM0VELO";
  final String vnpReturnUrl = "https://sandbox.vnpayment.vn/paymentv2/ReturnMock";


  @override
  void initState() {
    super.initState();
    _total = widget.itemsToBuy.fold(
      0,
      (sum, item) => sum + (item.book.price * item.quantity),
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    if (currentUser != null) {
      _nameController.text = currentUser.name;
      _phoneController.text = currentUser.phone;
      _addressController.text = currentUser.address;
    }
  }

  // Thanh toán trực tiếp
  Future<void> _placeOrderDirectly() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final actualUserId = authProvider.currentUser!.id;

    try {
      await orderProvider.addOrder(
        userId: actualUserId,
        totalAmount: _total,
        items: widget.itemsToBuy,
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
      );

      if (widget.source == CheckoutSource.cart) cartProvider.clearCart();

      setState(() => _isProcessing = false);

      final formattedTotal = cartProvider.formatPrice(_total);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt hàng thành công! Đơn hàng trị giá $formattedTotal'),
          backgroundColor: AppColors.successGreen,
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt hàng thất bại: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Thanh toán qua VNPAY
  Future<void> _payWithVNPay() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isProcessing = true);

  final orderId = DateTime.now().millisecondsSinceEpoch.toString();

  final paymentUrl = await createVNPayUrlInApp(
    vnpUrl: vnpUrl,
    vnpTmnCode: vnpTmnCode,
    vnpHashSecret: vnpHashSecret,
    returnUrl: vnpReturnUrl,
    amount: _total.round(),
    orderId: orderId,
    orderInfo: "Thanh toán đơn hàng ${orderId}"
  );

  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => VNPayPaymentScreen(paymentUrl: paymentUrl),
    ),
  );

  setState(() => _isProcessing = false);

  if (result == true) {
    _placeOrderDirectly();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanh toán VNPAY thất bại hoặc bị huỷ')),
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
          padding: const EdgeInsets.all(20),
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
                  decoration: const InputDecoration(labelText: 'Tên người nhận'),
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
                  decoration: const InputDecoration(labelText: 'Địa chỉ giao hàng'),
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                ),
                const SizedBox(height: 40),

                // Nút thanh toán trực tiếp
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _placeOrderDirectly,
                  icon: _isProcessing
                      ? CircularProgressIndicator(color: colorScheme.onPrimary)
                      : const Icon(Icons.check_circle_outline),
                  label: const Text('Thanh toán trực tiếp'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 15),

                // Nút thanh toán VNPAY
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _payWithVNPay,
                  icon: _isProcessing
                      ? CircularProgressIndicator(color: colorScheme.onPrimary)
                      : const Icon(Icons.payment),
                  label: const Text('Thanh toán qua VNPAY'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.orange,
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
