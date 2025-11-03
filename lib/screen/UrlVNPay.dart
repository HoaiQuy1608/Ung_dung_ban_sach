import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';

String hmacSha512(String key, String data) {
  final hmac = Hmac(sha512, utf8.encode(key));
  final digest = hmac.convert(utf8.encode(data));
  return digest.toString();
}

String buildQuery(Map<String, String> params) {
  final queryParts = params.entries.map((e) =>
      '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}'
  ).toList();
  return queryParts.join('&');
}

Future<String> createVNPayUrlInApp({
  required String vnpUrl,
  required String vnpTmnCode,
  required String vnpHashSecret,
  required String returnUrl,
  required int amount,
  required String orderId,
  String orderInfo = 'Thanh toán đơn hàng',
  String orderType = 'other',
  String locale = 'vn',
}) async {
  final now = DateTime.now();
  final formatter = DateFormat('yyyyMMddHHmmss');
  final vnpCreateDate = formatter.format(now);

  final Map<String, String> vnpParams = {
  'vnp_Version': '2.1.0',
  'vnp_Command': 'pay',
  'vnp_TmnCode': vnpTmnCode,
  'vnp_Amount': (amount * 100).toString(),
  'vnp_CurrCode': 'VND',
  'vnp_TxnRef': orderId,
  'vnp_OrderInfo': orderInfo,
  'vnp_OrderType': orderType,
  'vnp_ReturnUrl': returnUrl,
  'vnp_CreateDate': vnpCreateDate,
  'vnp_Locale': locale,
  'vnp_IpAddr': '127.0.0.1',
};

// Sort và tạo checksum
final sortedKeys = vnpParams.keys.toList()..sort();
final signData = sortedKeys.map((k) => '$k=${vnpParams[k]}').join('&');
final vnpSecureHash = hmacSha512(vnpHashSecret, signData);

// Thêm hash vào params cuối cùng
vnpParams['vnp_SecureHash'] = vnpSecureHash;

// Build URL
final query = buildQuery(Map.fromEntries(
  vnpParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
));

final paymentUrl = '$vnpUrl?$query';
print('VNP_URL = $vnpUrl');
print('TMN_CODE = $vnpTmnCode');
print('HASH_SECRET = $vnpHashSecret');

  print('DEBUG: VNPAY URL = $paymentUrl');

  return paymentUrl;
}
