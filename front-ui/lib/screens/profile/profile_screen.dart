import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Spark/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Spark/services/profile_service.dart';
import 'editprofile_screen.dart';
import 'settings_screen.dart';
import 'package:Spark/login_screen.dart';
import 'package:Spark/widgets/lazy_loading_page.dart';

class ProfilePage extends StatefulWidget with LazyLoadingPage {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();

  @override
  Future<void> loadData() async {
    // Custom method to load data for this page
    await _ProfilePageState()._loadUserData();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileServiceAPI apiService = ProfileServiceAPI();
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? userData;
  UserProfile? userProfile;
  bool isLoading = true;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserProfile() async {
    _loadingTimer = Timer(const Duration(seconds: 30), () {
      if (isLoading) {
        _showTimeoutDialog();
      }
    });

    try {
      final response = await apiService.getUser();
      if (response.statusCode == 200) {
        final profile = jsonDecode(response.body);
        setState(() {
          userProfile = UserProfile.fromJson(profile);
          isLoading = false;
        });
      } else {
        // handle error
      }
    } catch (e) {
      // handle error
    } finally {
      _loadingTimer?.cancel();
    }
  }

  Future<void> _loadUserData() async {
    _loadingTimer = Timer(const Duration(seconds: 30), () {
      if (isLoading) {
        _showTimeoutDialog();
      }
    });

    try {
      final response = await apiService.getUser();
      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        // handle error
      }
    } catch (e) {
      // handle error
    } finally {
      _loadingTimer?.cancel();
    }
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Timeout"),
          content: const Text("Loading user data is taking longer than expected. Do you want to log out?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Log Out"),
              onPressed: () async {
                Navigator.of(context).pop();
                await apiService.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      try {
        final imageUrl = await apiService.uploadImageProfileToCloudinary(file);
        final response = await apiService.updateImageProfile(userData!, imageUrl);
        if (response.statusCode == 204) {
          _loadUserData();
        } else {
          // handle error
        }
      } catch (e) {
        // handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 5), // Ajout de l'espacement
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 75,
                      backgroundImage: userData?['profilePic'] != null
                        ? NetworkImage(userData?['profilePic']) as ImageProvider<Object>?
                        : const AssetImage('assets/profile_picture.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LineIcons.camera),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  userData!['fullname'] ?? '', // Utilisation de ?? pour gérer le cas où fullname est null
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20), // Ajout de l'espacement
                ProfileListItem(
                  title: 'Edit Profile',
                  icon: LineIcons.user,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(userData: userData!),
                      ),
                    ).then((value) {
                      if (value == true) {
                        _loadUserData();
                      }
                    });
                  },
                ),
                ProfileListItem(
                  title: 'Match Profile',
                  icon: LineIcons.userFriends,
                  isSwitchItem: true,
                  initialSwitchState: userData!['match'] ?? false, // Utilisation de ?? pour gérer le cas où match est null
                  onSwitchChanged: (bool newValue) {
                    ProfileServiceAPI().updateMatchProfile(userData!, newValue);
                  },
                ),
                ProfileListItem(
                  title: 'Settings',
                  icon: Icons.settings,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                ProfileListItem(
                  title: 'Help & Support',
                  icon: Icons.help,
                  onPressed: () {
                    // handle help & support
                  },
                ),
                ProfileListItem(
                  title: 'Log Out',
                  icon: LineIcons.powerOff,
                  onPressed: () async {
                    await apiService.logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class ProfileListItem extends StatefulWidget {
  final String title;
  final IconData? icon;
  final bool isSwitchItem;
  final bool initialSwitchState;
  final Function()? onPressed;
  final Function(bool)? onSwitchChanged;

  const ProfileListItem({
    required this.title,
    this.icon,
    this.isSwitchItem = false,
    this.initialSwitchState = false,
    this.onPressed,
    this.onSwitchChanged,
    super.key,
  });

  @override
  _ProfileListItemState createState() => _ProfileListItemState();
}

class _ProfileListItemState extends State<ProfileListItem> {
  late bool switchState;

  @override
  void initState() {
    super.initState();
    switchState = widget.initialSwitchState;
  }

  void _handleSwitchChanged(bool value) {
    setState(() {
      switchState = value;
    });
    if (widget.onSwitchChanged != null) {
      widget.onSwitchChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: widget.isSwitchItem ? null : widget.onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            if (widget.isSwitchItem) ...[
              Switch(
                value: switchState,
                onChanged: _handleSwitchChanged,
              ),
            ] else ...[
              Icon(Icons.arrow_forward_ios, color: iconColor),
            ],
          ],
        ),
      ),
    );
  }
}