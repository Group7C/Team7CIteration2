import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Settings", style: Theme.of(context).textTheme.headlineSmall),
                ListTile(
                  title: const Text("Select Theme"),
                  subtitle: Text(themeProvider.themeType.toString().split('.').last.toUpperCase()),
                ),
                RadioListTile<ThemeType>(
                  title: const Text("Light Theme"),
                  value: ThemeType.light,
                  groupValue: themeProvider.themeType,
                  onChanged: (ThemeType? value) {
                    if (value != null) themeProvider.setTheme(value);
                  },
                ),
                RadioListTile<ThemeType>(
                  title: const Text("Dark Theme"),
                  value: ThemeType.dark,
                  groupValue: themeProvider.themeType,
                  onChanged: (ThemeType? value) {
                    if (value != null) themeProvider.setTheme(value);
                  },
                ),
                RadioListTile<ThemeType>(
                  title: const Text("Custom Theme"),
                  value: ThemeType.custom,
                  groupValue: themeProvider.themeType,
                  onChanged: (ThemeType? value) {
                    if (value != null) themeProvider.setTheme(value);
                  },
                ),
                if (themeProvider.themeType == ThemeType.custom) ...[
                  const SizedBox(height: 16.0),
                  ListTile(
                    title: const Text('Surface Color'),
                    trailing: CircleAvatar(backgroundColor: themeProvider.currentTheme.colorScheme.surface),
                    onTap: () async {
                      final Color? newColor = await _showColorPicker(context, themeProvider.currentTheme.colorScheme.surface);
                      if (newColor != null) {
                        themeProvider.setCustomTheme(surfaceColor: newColor, onSurfaceColor: themeProvider.currentTheme.colorScheme.onSurface);
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Text Color'),
                    trailing: CircleAvatar(backgroundColor:  themeProvider.currentTheme.colorScheme.onSurface),
                    onTap: () async {
                      final Color? newColor = await _showColorPicker(context,  themeProvider.currentTheme.colorScheme.onSurface);
                      if (newColor != null) {
                        themeProvider.setCustomTheme(surfaceColor: themeProvider.currentTheme.colorScheme.surface, onSurfaceColor: newColor);
                      }
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Color?> _showColorPicker(BuildContext context, Color currentColor) async {
    Color selectedColor = currentColor;
    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (Color color) {
              selectedColor = color;
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(selectedColor), child: const Text('OK')),
        ],
      ),
    );
  }
}
