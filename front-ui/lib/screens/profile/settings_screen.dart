// ========== IMPORTS ========== //
// Flutter
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Themes
import 'package:Spark/themes/dark_theme.dart';
import 'package:Spark/themes/light_theme.dart';
import 'package:Spark/provider/theme_provider.dart';

// Screens
import 'blockeduser_screen.dart';

// ========== SETTINGS PAGE ========== //
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'Lobster',
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20), // Espacement
          SettingsListItem(
            title: 'Switch Theme Mode',
            icon: CupertinoIcons.moon_stars,
            isSwitchItem: true,
            initialSwitchState: Provider.of<ThemeProvider>(context).themeData == DarkTheme.data,
            onSwitchChanged: (value) {
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              final newTheme = value ? DarkTheme.data : LightTheme.data;
              themeProvider.setTheme(newTheme);
            },
          ),
          SettingsListItem(
            title: 'Blocked Users',
            icon: CupertinoIcons.person,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const BlockedUsersPage()));
            },
          ),

        ],
      ),
    );
  }
}

// ========== SETTINGS LIST ITEM ========== //
class SettingsListItem extends StatefulWidget {
  final String title;
  final IconData? icon;
  final bool isSwitchItem;
  final bool initialSwitchState;
  final Function()? onPressed;
  final Function(bool)? onSwitchChanged;

  const SettingsListItem({
    required this.title,
    this.icon,
    this.isSwitchItem = false,
    this.initialSwitchState = false,
    this.onPressed,
    this.onSwitchChanged,
    super.key,
  });

  @override
  _SettingsListItemState createState() => _SettingsListItemState();
}

class _SettingsListItemState extends State<SettingsListItem> {
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
              const Icon(Icons.arrow_forward_ios),
            ],
          ],
        ),
      ),
    );
  }
}
