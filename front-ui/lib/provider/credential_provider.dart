// ========== IMPORTS ========== //
// Flutter
import 'package:flutter/foundation.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

// ========== CREDENTIAL PROVIDER ========== //
class CredentialProvider with ChangeNotifier {
  Credentials? _credentials;

  Credentials? get credentials => _credentials;
  bool get isAuthenticated => _credentials != null;

  void setCredentials(Credentials credentials) {
    _credentials = credentials;
    notifyListeners();
  }

  void clearCredentials() {
    _credentials = null;
    notifyListeners();
  }

  void logout() {}
}
