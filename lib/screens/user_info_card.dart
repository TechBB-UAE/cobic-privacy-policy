import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserInfoCard extends StatefulWidget {
  final String username;
  final String password;
  const UserInfoCard({required this.username, required this.password});

  @override
  State<UserInfoCard> createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<UserInfoCard> {
  String? _message;
  Color _messageColor = Colors.green;
  final GlobalKey _infoKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      await _captureAndSaveInfo();
    });
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _message = AppLocalizations.of(context)!.copyReferralCode;
      _messageColor = Colors.blueAccent;
    });
  }

  Future<void> _captureAndSaveInfo() async {
    try {
      RenderRepaintBoundary boundary = _infoKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      var photosStatus = await Permission.photos.request();
      var storageStatus = await Permission.storage.request();

      if (photosStatus.isGranted || storageStatus.isGranted) {
        final result = await ImageGallerySaver.saveImage(
          pngBytes,
          quality: 100,
          name: "cobic_guest_info_${DateTime.now().millisecondsSinceEpoch}"
        );
        if ((result['isSuccess'] == true || result['isSuccess'] == 1) && mounted) {
          setState(() {
            _message = AppLocalizations.of(context)!.guestSavedToGallery;
            _messageColor = Colors.green;
          });
        } else {
          setState(() {
            _message = 'Lưu ảnh thất bại! (result: \\${result.toString()})';
            _messageColor = Colors.red;
          });
        }
      } else {
        setState(() {
          _message = 'Không có quyền lưu ảnh vào Photos!';
          _messageColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Lưu ảnh thất bại! ($e)';
        _messageColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                RepaintBoundary(
                  key: _infoKey,
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/logo.gif',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.guestAccountTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.black,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Tên đăng nhập + nút copy
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.guestUsername, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                              tooltip: l10n.copyReferralCode,
                              onPressed: () => _copyToClipboard(widget.username, l10n.guestUsername),
                            ),
                          ],
                        ),
                        Text(
                          widget.username,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Mật khẩu + nút copy
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.guestPassword, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18, color: Colors.grey),
                              tooltip: l10n.copyReferralCode,
                              onPressed: () => _copyToClipboard(widget.password, l10n.guestPassword),
                            ),
                          ],
                        ),
                        Text(
                          widget.password,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          l10n.guestSaveInfoNote,
                          style: const TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Thông báo
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _message!,
                      style: TextStyle(color: _messageColor, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.close),
                  ),
                ),
              ],
            ),
            // Nút đóng góc phải
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.grey[600]),
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 20,
                tooltip: l10n.close,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 