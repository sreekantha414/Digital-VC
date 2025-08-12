import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRService {
  /// Call this inside the QRView's onQRViewCreated:
  void onQRViewCreated(QRViewController controller, void Function(String) onScanned) {
    controller.scannedDataStream.listen((scanData) {
      onScanned(scanData.code ?? '');
      controller.pauseCamera();
    });
  }
}
