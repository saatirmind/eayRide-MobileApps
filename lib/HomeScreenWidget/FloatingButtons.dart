import 'package:easyride/settings/setting.dart';
import 'package:flutter/material.dart';

class FloatingButtons extends StatefulWidget {
  final VoidCallback onMyLocationPressed;

  const FloatingButtons({Key? key, required this.onMyLocationPressed})
      : super(key: key);

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
            SizedBox(height: 10),
            _buildFloatingButton(
              Icons.settings,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 10),
            _buildFloatingButton(Icons.headset_mic),
            SizedBox(height: 10),
            _buildFloatingButton(Icons.my_location,
                onPressed: onMyLocationPressed),
            SizedBox(height: 10),
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
      child: Icon(icon),
      backgroundColor: Colors.yellow,
      mini: true,
    );
  }
}
