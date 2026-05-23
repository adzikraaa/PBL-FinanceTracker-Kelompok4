import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../viewmodels/premium_viewmodel.dart';
import '../../data/config/midtrans_config.dart';
import 'payment_success_view.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  late WebViewController _webController;
  bool _isPageLoading = true;
  bool _isConfirming = false;
  bool _showSuccessButton = false;
  Timer? _successCheckTimer;

  @override
  void initState() {
    super.initState();
    final vm = context.read<PremiumViewModel>();
    _initWebView(vm);
    _startSuccessCheckTimer();
  }

  @override
  void dispose() {
    _successCheckTimer?.cancel();
    super.dispose();
  }

  void _startSuccessCheckTimer() {
    _successCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !_isPageLoading && !_isConfirming) {
        _checkPageContent();
      }
    });
  }

  Future<void> _checkPageContent() async {
    if (!mounted) return;
    try {
      final currentUrl = await _webController.currentUrl();
      if (currentUrl == null) return;

      // Detect finish URL redirect
      if (currentUrl.startsWith(MidtransConfig.finishUrl)) {
        if (!_showSuccessButton) {
          setState(() {
            _showSuccessButton = true;
          });
        }
        return;
      }

      // Check if page contains payment success indicators
      final result = await _webController.runJavaScriptReturningResult(
        "document.body.innerText.indexOf('Transaction is successful') !== -1 || document.body.innerText.indexOf('PAID') !== -1"
      );
      final resultStr = result.toString().toLowerCase();
      if (resultStr == 'true' || resultStr == '1' || resultStr.contains('true')) {
        if (!_showSuccessButton) {
          setState(() {
            _showSuccessButton = true;
          });
        }
      }
    } catch (e) {
      // Ignore javascript execution errors before page is fully loaded
    }
  }

  void _initWebView(PremiumViewModel vm) {
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0D1117))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isPageLoading = true),
          onPageFinished: (_) {
            setState(() => _isPageLoading = false);
            _checkPageContent();
          },
          onWebResourceError: (_) => setState(() => _isPageLoading = false),
          onNavigationRequest: (NavigationRequest req) {
            return _handleNavigation(req.url, vm);
          },
        ),
      )
      ..loadRequest(Uri.parse(vm.snapUrl!));
  }

  NavigationDecision _handleNavigation(String url, PremiumViewModel vm) {
    final uri = Uri.tryParse(url);
    if (uri == null) return NavigationDecision.navigate;

    // Deteksi callback URL dari Midtrans
    final isFinish = url.startsWith(MidtransConfig.finishUrl);
    final isError = url.startsWith(MidtransConfig.errorUrl);
    final isPending = url.startsWith(MidtransConfig.pendingUrl);

    if (isFinish || isError || isPending) {
      final status = uri.queryParameters['transaction_status'] ?? '';
      final orderId = uri.queryParameters['order_id'];

      if (status == 'settlement' || status == 'capture') {
        _onPaymentSuccess(vm, orderId: orderId);
      } else if (isPending || status == 'pending') {
        vm.setPendingPayment(orderId: orderId);
        _showPendingDialog(orderId);
      } else {
        _onPaymentFailed(status);
      }
      return NavigationDecision.prevent;
    }

    // Izinkan URL Midtrans lainnya
    return NavigationDecision.navigate;
  }

  Future<void> _onPaymentSuccess(PremiumViewModel vm,
      {String? orderId}) async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);

    final ok = await vm.confirmPayment(orderId: orderId);
    if (!mounted) return;

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: vm,
            child: const PaymentSuccessView(),
          ),
        ),
      );
    } else {
      _showErrorSnack('Gagal memverifikasi pembayaran. Hubungi support.');
      setState(() => _isConfirming = false);
    }
  }

  void _onPaymentFailed(String status) {
    _showErrorSnack('Pembayaran gagal (status: $status). Silakan coba lagi.');
  }

  void _showPendingDialog(String? orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.access_time_rounded,
                color: Color(0xFFFFD700), size: 22),
            SizedBox(width: 8),
            Text('Menunggu Pembayaran',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pembayaran kamu sedang diproses.',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 13),
            ),
            const SizedBox(height: 10),
            if (orderId != null) ...[
              Text('Order ID:',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(orderId,
                    style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 12,
                        fontFamily: 'monospace')),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              'Premium akan aktif otomatis setelah transfer dikonfirmasi.',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // tutup dialog
              Navigator.pop(context); // kembali ke premium view
            },
            child: const Text('OK',
                style: TextStyle(color: Color(0xFFFFD700))),
          ),
        ],
      ),
    );
  }

  void _showErrorSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 15),
          ),
        ),
        title: const Text(
          'Pembayaran Premium',
          style: TextStyle(
              color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.white.withOpacity(0.06)),
        ),
      ),
      body: Stack(
        children: [
          // WebView Midtrans Snap
          if (_isConfirming)
            _buildConfirming()
          else
            WebViewWidget(controller: _webController),

          // Loading overlay saat halaman sedang dimuat
          if (_isPageLoading && !_isConfirming)
            Container(
              color: const Color(0xFF0D1117),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFFFD700),
                      strokeWidth: 2.5,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Memuat halaman pembayaran...',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

          // Tombol "Pembayaran Selesai" hanya muncul setelah transaksi sukses (PAID)
          if (_showSuccessButton && !_isConfirming)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () => _onPaymentSuccess(context.read<PremiumViewModel>()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  'Pembayaran Selesai',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfirming() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFD700).withOpacity(0.1),
              border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.3), width: 2),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFD700),
                strokeWidth: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Mengaktifkan Premium...',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Harap tunggu sebentar',
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
