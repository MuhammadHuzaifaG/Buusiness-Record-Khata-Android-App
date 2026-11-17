import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/customer.dart';
import '../models/transaction.dart';

class GoogleSheetsService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/spreadsheets'],
  );

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  // Sign in with Google option
  Future<bool> signInWithGoogle() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser != null;
    } catch (e) {
      return false;
    }
  }

  // Sign out option (Support for without-signin / local-only mode)
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  // Auto-sync local records to Google Sheet when online
  Future<bool> syncDataToCloud({
    required List<Customer> customers,
    required List<KhataTransaction> transactions,
    required String spreadsheetId,
  }) async {
    if (_currentUser == null) return false; // Offline or signed out mode

    try {
      final authHeaders = await _currentUser!.authHeaders;
      final url = Uri.parse('https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/Sheet1!A1:append?valueInputOption=USER_ENTERED');

      List<List<dynamic>> rows = customers.map((c) => [
        c.id, c.name, c.phone, c.note, c.balance, c.lastTransactionDate.toIso8601String()
      ]).toList();

      final response = await http.post(
        url,
        headers: {
          'Authorization': '${authHeaders['Authorization']}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'values': rows,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      // Keep working offline if sync fails due to network drop
      return false;
    }
  }
}