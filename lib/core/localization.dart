class AppLocalizations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Digital Khata',
      'customers': 'Customers',
      'products': 'Products',
      'analytics': 'Analytics',
      'settings': 'Settings',
      'add_customer': 'Add Customer',
      'add_product': 'Add Product',
      'customer_has_to_pay': 'Customer Has To Pay',
      'we_have_to_pay': 'We Have To Pay',
      'late_payment_alert': 'Payment Delayed (>7 Days)',
      'generate_invoice': 'Generate Invoice',
      'total_sales': 'Overall Sales',
      'top_products': 'Top Products',
      'top_customers': 'Top Customers',
      'sync_now': 'Sync with Google Sheet',
      'offline_mode': 'Offline Mode (Saved Locally)',
      'online_synced': 'Synced with Google Drive',
      'privacy_policy': '100% Secure: Your data stays on your device and your personal Google Drive. We never send data to any external server.',
      'user_guide': '1. Add products in Products tab.\n2. Tap + to add customers & select products.\n3. Red rows indicate payments delayed over 7 days.\n4. Connect Google account in Settings for auto-backup.',
    },
    'ur': {
      'app_title': 'ڈیجیٹل کھاتہ',
      'customers': 'گاہک',
      'products': 'مصنوعات',
      'analytics': 'تجزیات',
      'settings': 'ترتیبات',
      'add_customer': 'نیا گاہک شامل کریں',
      'add_product': 'نئی پروڈکٹ شامل کریں',
      'customer_has_to_pay': 'گاہک نے ادا کرنے ہیں',
      'we_have_to_pay': 'ہم نے ادا کرنے ہیں',
      'late_payment_alert': 'ادائیگی میں تاخیر (7 دن سے زائد)',
      'generate_invoice': 'انوائس بنائیں',
      'total_sales': 'مجموعی فروخت',
      'top_products': 'بہترین مصنوعات',
      'top_customers': 'بہترین گاہک',
      'sync_now': 'گوگل شیٹ کے ساتھ سنک کریں',
      'offline_mode': 'آف لائن موڈ (مقامی طور پر محفوظ)',
      'online_synced': 'گوگل ڈرائیو کے ساتھ محفوظ ہے',
      'privacy_policy': 'مکمل محفوظ: آپ کا ڈیٹا صرف آپ کے فون اور آپ کی ذاتی گوگل ڈرائیو میں محفوظ رہتا ہے۔ ہم کوئی ڈیٹا اپنے سرور پر نہیں بھیجتے۔',
      'user_guide': '1. مصنوعات کے ٹیب میں اپنی اشیاء شامل کریں۔\n2. نیا گاہک شامل کرنے کے لیے + دبائیں۔\n3. سرخ رنگ 7 دن سے زیادہ تاخیر والی ادائیگی کو ظاہر کرتا ہے۔\n4. آٹو بیک اپ کے لیے ترتیبات میں گوگل اکاؤنٹ جوڑیں۔',
    },
  };

  static String getText(String langCode, String key) {
    return _localizedValues[langCode]?[key] ?? _localizedValues['en']![key]!;
  }
}