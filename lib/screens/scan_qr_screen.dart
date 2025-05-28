import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cobic/services/point_service.dart';
import 'package:cobic/utils/error_utils.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/profile_provider.dart';

class ScanQrScreen extends StatefulWidget {
  final String? targetRoute;
  const ScanQrScreen({Key? key, this.targetRoute}) : super(key: key);

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  bool _isPopped = false;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    ctrl.scannedDataStream.listen((scanData) async {
      if (_isProcessing || _isPopped) return;
      setState(() => _isProcessing = true);
      print('Đã quét: \\${scanData.code}');
      try {
        await controller?.pauseCamera();
        final res = await PointService.scanQrAndCollectPoint(scanData.code ?? '').timeout(const Duration(seconds: 10));
        print('API trả về: \\${res}');
        if (mounted && !_isPopped) {
          _isPopped = true;
          ErrorUtils.showSuccessToast(context, res['message'] ?? 'Tích điểm thành công!');
          await Future.delayed(const Duration(milliseconds: 1200));
          if (!mounted) return;
          // Gọi lại API lấy profile để cập nhật số dư
          try {
            await Provider.of<ProfileProvider>(context, listen: false).fetchUserInfo();
          } catch (e) {
            if (mounted) {
              ErrorUtils.showErrorToast(context, ErrorUtils.parseApiError(e));
            }
          }
          Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        print('Lỗi khi quét QR: \\${e}');
        if (mounted && !_isPopped) {
          _isPopped = true;
          ErrorUtils.showErrorToast(context, ErrorUtils.parseApiError(e));
          await Future.delayed(const Duration(milliseconds: 1200));
          if (!mounted) return;
          Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét QR tích điểm')),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.deepPurple,
              borderRadius: 12,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 250,
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
} 