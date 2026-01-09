// =========== IMPORTS =========== //
// Flutter
import 'package:flutter/material.dart';

// ========== SWITCH BUTTON WIDGET ========== //
class SwitchButtonWidget extends StatefulWidget {
  const SwitchButtonWidget({super.key});

  @override
  _SwitchButtonWidgetState createState() => _SwitchButtonWidgetState();
}

class _SwitchButtonWidgetState extends State<SwitchButtonWidget> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = false; // Initialiser la valeur du commutateur à false
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      onChanged: (newValue) {
        setState(() {
          _value = newValue;
        });
        // Mettez ici le code pour changer le thème lorsque le commutateur est basculé
        if (newValue) {
          // Changer en mode sombre
          ThemeData newTheme = Theme.of(context).copyWith(brightness: Brightness.dark);
          Theme(data: newTheme, child: Container());
        } else {
          // Changer en mode clair
          ThemeData newTheme = Theme.of(context).copyWith(brightness: Brightness.light);
          Theme(data: newTheme, child: Container());
        }
      },
    );
  }
}
