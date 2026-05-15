import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EmailService {
  static const String _serviceId = 'service_9evk6dn';
  static const String _templateId = 'template_1sp6k1s';
  static const String _publicKey = 'qsY2zacERIeSxPLgJ';

  static Future<bool> kirimFeedback({
    required String nama,
    required String pesan,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _publicKey,
          'template_params': {
            'from_name': nama,
            'message': pesan,
            'to_email': 'zizybaik@gmail.com',
            'reply_to': 'zizybaik@gmail.com',
          },
        }),
      );

      if (kDebugMode) {
        print('EmailJS Result: ${response.statusCode}');
        print('EmailJS Body: ${response.body}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('EmailJS Error: $e');
      }
      return false;
    }
  }
}