import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../services/qr_service.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    QRService().onQRViewCreated(ctrl, (data) {
      controller?.pauseCamera();
      Navigator.pop(context, data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.deepPurple,
          borderRadius: 12,
          borderLength: 30,
          borderWidth: 10,
          overlayColor: Colors.black.withOpacity(0.6),
          cutOutSize: MediaQuery.of(context).size.width * 0.85,
        ),
      ),
    );
  }
}
