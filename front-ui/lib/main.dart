// ========== IMPORTS ========== //
// Flutter
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Screens
import 'package:Spark/login_screen.dart';

// Providers
import 'package:Spark/provider/theme_provider.dart';
import 'package:Spark/provider/event_provider.dart';

// Widgets
import 'package:Spark/widgets/navigation_bottom_widget.dart';

// ========== MAIN ========== //
void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CredentialProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => EventProvider()),
      ],
      child: const Spark(),
    ),
  );
}

class CredentialProvider extends ChangeNotifier {
  final storage = const FlutterSecureStorage();
  bool isAuthenticated = false;

  CredentialProvider() {
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final accessToken = await storage.read(key: 'accessToken');
    if (accessToken != null) {
      isAuthenticated = true;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await storage.delete(key: 'accessToken');
    isAuthenticated = false;
    notifyListeners();
  }
}

class Spark extends StatelessWidget {
  const Spark({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Spark',
          theme: themeProvider.themeData,
          home: Consumer<CredentialProvider>(
            builder: (context, credentials, child) {
              return credentials.isAuthenticated
                  ? const NavigationBottom()
                  : const LoginPage();
            },
          ),
        );
      },
    );
  }
}