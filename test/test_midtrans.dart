import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final serverKey = 'Mid-server-XeNrvdn9CtzCFBJ-Ec_8mJ34';
  final credentials = base64.encode(utf8.encode('$serverKey:'));
  final snapApiUrl = 'https://app.sandbox.midtrans.com/snap/v1/transactions';
  
  print('Sending request to Midtrans Snap API...');
  try {
    final response = await http.post(
      Uri.parse(snapApiUrl),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'transaction_details': {
          'order_id': 'TEST-${DateTime.now().millisecondsSinceEpoch}',
          'gross_amount': 100000,
        },
        'credit_card': {'secure': true},
        'customer_details': {
          'first_name': 'Test User',
          'email': 'test@gmail.com',
        },
        'item_details': [
          {
            'id': 'BIZPRICE_PREMIUM_LIFETIME',
            'price': 100000,
            'quantity': 1,
            'name': 'BizPrice Premium Seumur Hidup',
          }
        ],
      }),
    );
    
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
