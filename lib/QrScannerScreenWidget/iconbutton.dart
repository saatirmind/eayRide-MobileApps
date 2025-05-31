import 'package:easymotorbike/AppColors.dart/EasyrideAppColors.dart';
import 'package:easymotorbike/DrawerWidget/healp.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class IconButtonWidget extends StatefulWidget {
  final QRViewController? controller;
  final bool isFlashOn;
  final Function(bool) onFlashToggle;

  const IconButtonWidget({
    super.key,
    this.controller,
    required this.isFlashOn,
    required this.onFlashToggle,
  });

  @override
  State<IconButtonWidget> createState() => _IconButtonWidgetState();
}

class _IconButtonWidgetState extends State<IconButtonWidget> {
  late bool isFlashOn;

  @override
  void initState() {
    super.initState();
    isFlashOn = widget.isFlashOn;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(Icons.flash_on),
        _buildIconButton(Icons.headset_mic),
      ],
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      decoration: const BoxDecoration(
        color: EasyrideColors.buttonColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: EasyrideColors.buttontextColor,
        iconSize: 40,
        onPressed: () {
          if (icon == Icons.flash_on) {
            toggleFlash();
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpScreen()),
            );
          }
        },
      ),
    );
  }

  void toggleFlash() async {
    if (widget.controller != null) {
      await widget.controller?.toggleFlash();
      _showSnackbar(isFlashOn ? 'Flash OFF' : 'Flash ON');
    }
    setState(() {
      isFlashOn = !isFlashOn;
      widget.onFlashToggle(isFlashOn);
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
