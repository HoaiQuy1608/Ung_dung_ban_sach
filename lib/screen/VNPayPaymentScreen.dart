import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VNPayPaymentScreen extends StatefulWidget {
  final String paymentUrl; // URL thanh toán từ VNPAY sandbox hoặc server
  final String successReturnFragment; // param kiểm tra thanh toán thành công

  const VNPayPaymentScreen({
    super.key,
    required this.paymentUrl,
    this.successReturnFragment = 'vnp_ResponseCode=00', // 00 = thành công
  });

  @override
  State<VNPayPaymentScreen> createState() => _VNPayPaymentScreenState();
}

class _VNPayPaymentScreenState extends State<VNPayPaymentScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;
            // Kiểm tra callback returnUrl chứa vnp_ResponseCode
            if (url.contains('vnp_ResponseCode')) {
              final uri = Uri.parse(url);
              final resp = uri.queryParameters['vnp_ResponseCode'];
              if (resp == '00') {
                Navigator.of(context).pop(true); // thanh toán thành công
              } else {
                Navigator.of(context).pop(false); // thất bại
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán VNPAY (Sandbox)'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
