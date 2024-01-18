import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/widgets/theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Color currentPrimaryColor;
  late Color currentAccentColor;
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    final theme = Provider.of<ThemeNotifier>(context, listen: false).getTheme();
    currentPrimaryColor = theme.primaryColor;
    currentAccentColor = theme.colorScheme.secondary;
    isDarkMode = theme.brightness == Brightness.dark;
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
    return MaterialColor(color.value, swatch);
  }

  void pickColor(
      BuildContext screenContext, ValueChanged<Color> onColorSelected) {
    // Use a temporary variable to hold the color value
    Color pickerColor = currentPrimaryColor;
    showDialog(
      context: screenContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                // Update the temporary variable when color changes
                pickerColor = color;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it'),
              onPressed: () {
                // Use the onColorSelected callback with the picked color
                onColorSelected(pickerColor);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final isDarkMode = themeNotifier.getTheme().brightness == Brightness.dark;

    return Scaffold(
      body: ListView(
        children: [
          _buildDarkModeSwitch(isDarkMode, themeNotifier),
          _buildColorOption(
            'Primary Color',
            currentPrimaryColor,
            (color) => _updatePrimaryColor(context, color, themeNotifier),
          ),
          _buildColorOption(
            'Accent Color',
            currentAccentColor,
            (color) => _updateAccentColor(context, color, themeNotifier),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeSwitch(bool isDarkMode, ThemeNotifier themeNotifier) {
    return SwitchListTile(
      title: const Text('Dark Mode'),
      value: isDarkMode,
      onChanged: (value) {
        // Create a ColorScheme for dark mode
        var darkColorScheme = ColorScheme.dark().copyWith(
          primary: currentPrimaryColor,
          secondary: currentAccentColor,
        );

        // Create a ColorScheme for light mode
        var lightColorScheme = ColorScheme.light().copyWith(
          primary: currentPrimaryColor,
          secondary: currentAccentColor,
        );

        // Now set the theme based on the value of the switch
        ThemeData theme = value
            ? ThemeData.dark().copyWith(colorScheme: darkColorScheme)
            : ThemeData.light().copyWith(colorScheme: lightColorScheme);
        // Don't forget to set the value for isDarkMode to update the switch's position
        setState(() {
          isDarkMode = value;
          themeNotifier.setTheme(theme);
        });
      },
    );
  }

  Widget _buildColorOption(String title, Color color, Function(Color) onTap) {
    return ListTile(
      title: Text(title),
      trailing: GestureDetector(
        onTap: () => pickColor(context, onTap),
        child: CircleAvatar(
          backgroundColor: color,
        ),
      ),
    );
  }

  void _updatePrimaryColor(
      BuildContext context, Color newColor, ThemeNotifier themeNotifier) {
    setState(() {
      currentPrimaryColor = newColor;
    });
    themeNotifier.setTheme(
      ThemeData(
        primaryColor: newColor,
        colorScheme: themeNotifier.getTheme().colorScheme.copyWith(
              primary: newColor,
              secondary: currentAccentColor,
            ),
        brightness: themeNotifier.getTheme().brightness,
      ),
    );
  }

  void _updateAccentColor(
      BuildContext context, Color newColor, ThemeNotifier themeNotifier) {
    setState(() {
      currentAccentColor = newColor;
    });
    themeNotifier.setTheme(
      ThemeData(
        primaryColor: currentPrimaryColor,
        colorScheme: themeNotifier.getTheme().colorScheme.copyWith(
              secondary: newColor,
            ),
        brightness: themeNotifier.getTheme().brightness,
      ),
    );
  }
}
