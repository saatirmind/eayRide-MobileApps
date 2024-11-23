import 'package:easyride/QrScannerScreenWidget/buildBottomcontainer.dart';
import 'package:easyride/QrScannerScreenWidget/cameraframe.dart';
import 'package:easyride/QrScannerScreenWidget/iconbutton.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  QRScannerScreenState createState() => QRScannerScreenState();
}

class QRScannerScreenState extends State<QRScannerScreen> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String qrText = '';
  bool isCameraAvailable = true;
  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        isCameraAvailable = true;
      });
    } else {
      setState(() {
        isCameraAvailable = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera permission is required for QR scanning.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRScan(String result) {
    setState(() {
      qrText = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'SCAN QR',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isCameraAvailable ? _buildQRView() : _buildPermissionDenied(),
    );
  }

  Widget _buildQRView() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: QRView(
            key: qrKey,
            onQRViewCreated: (QRViewController qrController) {
              controller = qrController;
              controller?.scannedDataStream.listen(
                (scanData) {
                  if (scanData.code != null) {
                    _onQRScan(scanData.code!);
                  }
                },
              );
            },
          ),
        ),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1),
              child: SizedBox(
                height: 200,
                width: 200,
                child: Cameraframe(),
              ),
            ),
            SizedBox(height: 8),
            IconButtonWidget(
              controller: controller,
              isFlashOn: isFlashOn,
              onFlashToggle: (bool flashState) {
                setState(() {
                  isFlashOn = flashState;
                });
              },
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: BuildBottomContainer(
            qrText: qrText,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Text(
        'Camera permission denied.\nPlease enable it in settings to scan QR codes.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
    );
  }
}
