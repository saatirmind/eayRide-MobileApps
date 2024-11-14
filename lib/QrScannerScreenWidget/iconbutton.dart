import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class IconButtonWidget extends StatefulWidget {
  final QRViewController? controller;
  final bool isFlashOn;
  final Function(bool) onFlashToggle;

  const IconButtonWidget({
    Key? key,
    this.controller,
    required this.isFlashOn,
    required this.onFlashToggle,
  }) : super(key: key);

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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIconButton(Icons.flash_on),
        SizedBox(width: 20),
        _buildIconButton(Icons.headset_mic),
        SizedBox(width: 20),
        _buildIconButton(Icons.motorcycle),
      ],
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.black,
        iconSize: 40,
        onPressed: () {
          if (icon == Icons.flash_on) {
            toggleFlash();
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
        duration: Duration(seconds: 2),
      ),
    );
  }
}
