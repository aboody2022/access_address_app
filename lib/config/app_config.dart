// lib/config/app_config.dart
class AppConfig {
  // اسم التطبيق بالعربية (للعرض)
  static const String appNameArabic = "عنوان الوصول";

  // اسم التطبيق بالإنجليزية (للـ Deep Links)
  static const String appNameEnglish = "accessaddress";

  // Deep Link Scheme
  static const String deepLinkScheme = "accessaddress";

  // URLs
  static const String resetPasswordUrl = "accessaddress://reset-password";
  static const String mainUrl = "accessaddress://";

  // معلومات Supabase
  static const String supabaseUrl = "https://sipdyolcorgpqocgydik.supabase.co";
  static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpcGR5b2xjb3JncHFvY2d5ZGlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU3Nzk2OTEsImV4cCI6MjA2MTM1NTY5MX0.JwtkGwtp9qGGdNv7QscyIuxsKNVeSf46nqc5giZXNgg";
}