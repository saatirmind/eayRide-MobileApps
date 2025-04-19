// ignore_for_file: file_names
import 'package:easymotorbike/settings/setting.dart';
import 'package:flutter/material.dart';

class FloatingButtons extends StatefulWidget {
  final VoidCallback onMyLocationPressed;

  const FloatingButtons({super.key, required this.onMyLocationPressed});

  @override
  State<FloatingButtons> createState() => _FloatingButtonsState();
}

class _FloatingButtonsState extends State<FloatingButtons> {
  @override
  Widget build(BuildContext context) {
    return _buildFloatingButtons(widget.onMyLocationPressed);
  }

  Widget _buildFloatingButtons(VoidCallback onMyLocationPressed) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            _buildFloatingButton(Icons.location_pin),
            const SizedBox(height: 10),
            _buildFloatingButton(
              Icons.settings,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildFloatingButton(Icons.headset_mic),
            const SizedBox(height: 10),
            _buildFloatingButton(Icons.my_location,
                onPressed: onMyLocationPressed),
            const SizedBox(height: 10),
            _buildFloatingButton(Icons.loop),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, {VoidCallback? onPressed}) {
    return FloatingActionButton(
      heroTag: icon.toString(),
      onPressed: onPressed,
      backgroundColor: Colors.yellow,
      mini: true,
      child: Icon(icon),
    );
  }
}
