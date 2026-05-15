import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/config/midtrans_config.dart';

// Status hasil pembayaran
enum PaymentStatus { idle, processing, success, pending, failed }

class PremiumViewModel extends ChangeNotifier {
  // ── State ────────────────────────────────────────────────────────────
  bool _isPremium = false;
  bool _isLoading = false;
  String? _errorMessage;
  PaymentStatus _paymentStatus = PaymentStatus.idle;
  String? _snapToken;
  String? _snapUrl;
  String? _currentOrderId;
  DateTime? _premiumPurchasedAt;

  // ── Getters ──────────────────────────────────────────────────────────
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PaymentStatus get paymentStatus => _paymentStatus;
  bool get paymentProcessing => _paymentStatus == PaymentStatus.processing;
  bool get paymentSuccess => _paymentStatus == PaymentStatus.success;
  bool get paymentPending => _paymentStatus == PaymentStatus.pending;
  String? get snapToken => _snapToken;
  String? get snapUrl => _snapUrl;
  String? get currentOrderId => _currentOrderId;
  DateTime? get premiumPurchasedAt => _premiumPurchasedAt;

  // Alias untuk backward-compat
  bool get isPremiumActive => _isPremium;

  // ── Benefits Premium (sesuai screenshot, tanpa Backup Cloud) ─────────
  static const List<Map<String, String>> benefits = [
    {
      'title': 'Ekspor Laporan PDF',
      'subtitle': 'Tanpa watermark, kualitas premium',
      'icon': 'pdf',
    },
    {
      'title': 'Analitik Bisnis Lengkap',
      'subtitle': 'Grafik profit, margin & BEP otomatis',
      'icon': 'analytics',
    },
    {
      'title': 'Akses Semua Fitur',
      'subtitle': 'Tanpa batasan, selamanya',
      'icon': 'unlock',
    },
  ];

  // ── Constructor ──────────────────────────────────────────────────────
  PremiumViewModel() {
    _loadPremiumStatus();
  }

  // ── Public Methods ───────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetPayment() {
    _paymentStatus = PaymentStatus.idle;
    _errorMessage = null;
    _snapToken = null;
    _snapUrl = null;
    _currentOrderId = null;
    notifyListeners();
  }

  /// Load status premium dari Firestore
  Future<void> _loadPremiumStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _isPremium = data['isPremium'] ?? false;
        final ts = data['premiumPurchasedAt'] as Timestamp?;
        _premiumPurchasedAt = ts?.toDate();
      }
    } catch (e) {
      debugPrint('Error loading premium status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Buat transaksi Midtrans Snap dan dapatkan URL pembayaran
  Future<bool> createMidtransTransaction() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'Sesi login tidak valid. Silakan login ulang.';
      notifyListeners();
      return false;
    }

    _paymentStatus = PaymentStatus.processing;
    _errorMessage = null;
    notifyListeners();

    try {
      // Order ID unik per user
      final uid = user.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final orderId =
          'BIZPRICE-${uid.substring(0, 6).toUpperCase()}-$timestamp';
      _currentOrderId = orderId;

      // Ambil nama user dari Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final userName =
          userDoc.data()?['name'] ?? user.displayName ?? 'Pengguna';
      final userEmail = user.email ?? 'user@bizprice.app';

      // Encode server key untuk Basic Auth
      final credentials =
          base64.encode(utf8.encode('${MidtransConfig.serverKey}:'));

      // POST ke Midtrans Snap API
      final response = await http.post(
        Uri.parse(MidtransConfig.snapApiUrl),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'transaction_details': {
            'order_id': orderId,
            'gross_amount': MidtransConfig.premiumPrice,
          },
          'credit_card': {'secure': true},
          'customer_details': {
            'first_name': userName,
            'email': userEmail,
          },
          'item_details': [
            {
              'id': 'BIZPRICE_PREMIUM_LIFETIME',
              'price': MidtransConfig.premiumPrice,
              'quantity': 1,
              'name': 'BizPrice Premium Seumur Hidup',
            }
          ],
          'callbacks': {
            'finish': MidtransConfig.finishUrl,
            'error': MidtransConfig.errorUrl,
            'pending': MidtransConfig.pendingUrl,
          },
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _snapToken = data['token'];
        _snapUrl = data['redirect_url'];
        _paymentStatus = PaymentStatus.idle;
        notifyListeners();
        return true;
      } else {
        final body = json.decode(response.body);
        final msgs = body['error_messages'];
        _errorMessage =
            msgs != null ? (msgs as List).join(', ') : 'Error ${response.statusCode}';
        _paymentStatus = PaymentStatus.failed;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Koneksi gagal. Periksa internet kamu.';
      _paymentStatus = PaymentStatus.failed;
      notifyListeners();
      return false;
    }
  }

  /// Konfirmasi pembayaran berhasil → simpan ke Firestore
  Future<bool> confirmPayment({String? orderId}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      final now = DateTime.now();
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'isPremium': true,
        'premiumType': 'lifetime',
        'premiumPurchasedAt': Timestamp.fromDate(now),
        'lastPayment': {
          'orderId': orderId ?? _currentOrderId ?? '',
          'amount': MidtransConfig.premiumPrice,
          'timestamp': FieldValue.serverTimestamp(),
          'type': 'lifetime',
        },
      }, SetOptions(merge: true));

      _isPremium = true;
      _premiumPurchasedAt = now;
      _paymentStatus = PaymentStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error confirming payment: $e');
      return false;
    }
  }

  /// Tandai pembayaran pending (misal: transfer bank belum selesai)
  void setPendingPayment({String? orderId}) {
    _currentOrderId = orderId ?? _currentOrderId;
    _paymentStatus = PaymentStatus.pending;
    notifyListeners();
  }

  /// Refresh status dari Firestore
  Future<void> refreshStatus() async {
    await _loadPremiumStatus();
  }
}
