import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cobic/services/point_service.dart';
import 'package:cobic/utils/error_utils.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/profile_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class ScanQrScreen extends StatefulWidget {
  final String? targetRoute;
  const ScanQrScreen({Key? key, this.targetRoute}) : super(key: key);

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;
  bool _isPopped = false;
  final AudioPlayer player = AudioPlayer();
  String? _lastScannedValue; // Thêm biến để ngăn duplicate

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await player.setSource(AssetSource('sounds/ting.mp3'));
      await player.setVolume(1.0);
    } catch (e) {
      print('Lỗi khởi tạo âm thanh: $e');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    player.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _isPopped) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;
    
    // Ngăn chặn duplicate scan bằng cách kiểm tra giá trị đã quét
    if (_lastScannedValue == barcode.rawValue) return;
    _lastScannedValue = barcode.rawValue;
    
    setState(() => _isProcessing = true);
    print('Đã quét: ${barcode.rawValue}');
    try {
      controller.stop();
      final res = await PointService.scanQrAndCollectPoint(barcode.rawValue!).timeout(const Duration(seconds: 10));
      print('API trả về: $res');
      if (mounted && !_isPopped) {
        _isPopped = true;
        ErrorUtils.showSuccessToast(context, res['message'] ?? 'Tích điểm thành công!');
        try {
          await player.play(AssetSource('sounds/ting.mp3'));
          print('Đã phát âm thanh');
        } catch (e) {
          print('Lỗi phát âm thanh: $e');
        }
        await Future.delayed(const Duration(milliseconds: 1200));
        if (!mounted) return;
        try {
          await Provider.of<ProfileProvider>(context, listen: false).fetchUserInfo(context);
        } catch (e) {
          if (mounted) {
            ErrorUtils.showErrorToast(context, ErrorUtils.parseApiError(e));
          }
        }
        Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      print('Lỗi khi quét QR: $e');
      if (mounted && !_isPopped) {
        _isPopped = true;
        ErrorUtils.showErrorToast(context, ErrorUtils.parseApiError(e));
        await Future.delayed(const Duration(milliseconds: 1200));
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét QR tích điểm')),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
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