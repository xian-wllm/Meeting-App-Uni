// ========== IMPORTS ========== //
// Flutter
import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Widgets
import '../widgets/navigation_bottom_widget.dart';

// Services
import '../services/profile_service.dart';

// ========== LOGIN PAGE ========== //
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final storage = const FlutterSecureStorage();
  late Auth0 auth0;

  @override
  void initState() {
    super.initState();
    auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
  }

  Future<void> checkAndCreateUserProfile() async {
    final apiService = ProfileServiceAPI();
    final response = await apiService.getUser();
    print("User response: ${response.statusCode}");
    if (response.statusCode == 204) {
      // User does not exist, create the user
      final userName = await storage.read(key: 'userName');
      final userId = await storage.read(key: 'userId');
      final email = await storage.read(key: 'email');
      final payload = {
        'id': userId,
        'fullname': userName,
        'email': email,
        'match': true
      };
      await apiService.createUser(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: theme.colorScheme.primary,
          onPrimary: theme.colorScheme.onPrimary,
        ),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // Background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/login_background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Centered logo and login form
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Logo
                    SvgPicture.asset(
                      'assets/logo_Spark.svg', // Make sure the logo image is in your assets folder
                      height: 100, // Adjust the height as needed
                    ),
                    const SizedBox(height: 20), // Space between logo and text
                    const Text(
                      'Welcome to Spark!',
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Lobster',
                      ),
                    ),
                    const SizedBox(height: 10), // Space between welcome text and description
                    const Text(
                      'Light the Spark.',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Lobster',
                      ),
                      textAlign: TextAlign.center, // Center align the description text
                    ),
                    const SizedBox(height: 20), // Space between description and button
                    ElevatedButton(
                      onPressed: () async {
                        final credentials = await auth0.webAuthentication().login();

                        if (credentials != null) {
                          await storage.write(key: 'accessToken', value: credentials.accessToken);
                          await storage.write(key: 'userId', value: credentials.user.sub);
                          await storage.write(key: 'userName', value: credentials.user.name);
                          await storage.write(key: 'email', value: credentials.user.email);

                          await checkAndCreateUserProfile();

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const NavigationBottom()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onPrimary,
                        backgroundColor: theme.colorScheme.primary,
                      ),
                      child: Text(
                        'Login / Register',
                        style: TextStyle(color: theme.colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
