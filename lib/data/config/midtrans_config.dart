/// Konfigurasi Midtrans Payment Gateway
/// ⚠️ Untuk PRODUKSI: pindahkan serverKey ke Firebase Cloud Functions
/// Jangan expose serverKey di client-side untuk production
class MidtransConfig {
  // ── Ganti dengan key Midtrans kamu ─────────────────────────────────────
  // Dashboard Sandbox : https://dashboard.sandbox.midtrans.com
  // Dashboard Produksi: https://dashboard.midtrans.com
  static const String serverKey = 'Mid-server-XeNrvdn9CtzCFBJ-Ec_8mJ34';
  static const String clientKey = 'Mid-client-fjEeyLRTTCSvXty6';

  // ── Mode: true = Sandbox (testing), false = Production (uang asli) ─────
  static const bool isSandbox = true;

  static String get snapApiUrl => isSandbox
      ? 'https://app.sandbox.midtrans.com/snap/v1/transactions'
      : 'https://app.midtrans.com/snap/v1/transactions';

  // ── URL yang dideteksi WebView sebagai hasil pembayaran ────────────────
  // Set URL ini di Midtrans Dashboard > Settings > Snap Preferences
  static const String finishUrl = 'https://bizprice.app/payment/finish';
  static const String errorUrl = 'https://bizprice.app/payment/error';
  static const String pendingUrl = 'https://bizprice.app/payment/pending';

  // ── Harga Premium Lifetime ─────────────────────────────────────────────
  static const int premiumPrice = 100000; // Rp 100.000
}
