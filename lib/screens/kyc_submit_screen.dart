import 'package:flutter/material.dart';
import 'package:cobic/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:cobic/services/profile_service.dart';
import 'package:cobic/utils/error_utils.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:country_picker/country_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:cobic/providers/profile_provider.dart';
import 'package:cobic/screens/main_tab_screen.dart';
import 'package:image/image.dart' as img;

class KycSubmitScreen extends StatefulWidget {
  const KycSubmitScreen({Key? key}) : super(key: key);

  @override
  State<KycSubmitScreen> createState() => _KycSubmitScreenState();
}

class _KycSubmitScreenState extends State<KycSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _identityNumberController = TextEditingController();
  XFile? _idCardFrontFile;
  XFile? _idCardBackFile;
  XFile? _selfieWithIdCardFile;
  String _documentType = 'national_id';
  String _country = 'VN';
  Country? _selectedCountry;

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _identityNumberController.dispose();
    super.dispose();
  }

  String getMimeType(String path) {
    final ext = path.toLowerCase();
    if (ext.endsWith('.png')) return 'png';
    if (ext.endsWith('.webp')) return 'webp';
    return 'jpeg'; // default
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCountry == null || _country.isEmpty) {
      ErrorUtils.showErrorToast(context, 'Vui lòng chọn quốc gia.');
      return;
    }
    if (_idCardFrontFile == null || _idCardBackFile == null || _selfieWithIdCardFile == null) {
      ErrorUtils.showErrorToast(context, 'Vui lòng chọn đủ 3 ảnh.');
      return;
    }
    try {
      final frontBytes = await _idCardFrontFile!.readAsBytes();
      final backBytes = await _idCardBackFile!.readAsBytes();
      final selfieBytes = await _selfieWithIdCardFile!.readAsBytes();

      final frontImage = img.decodeImage(frontBytes);
      final backImage = img.decodeImage(backBytes);
      final selfieImage = img.decodeImage(selfieBytes);

      if (frontImage == null || backImage == null || selfieImage == null) {
        throw Exception('Không thể xử lý ảnh');
      }

      final compressedFront = img.encodeJpg(frontImage, quality: 60);
      final compressedBack = img.encodeJpg(backImage, quality: 60);
      final compressedSelfie = img.encodeJpg(selfieImage, quality: 60);

      final formData = FormData.fromMap({
        "fullName": _fullNameController.text,
        "dateOfBirth": _dobController.text,
        "country": _country,
        "address": _addressController.text,
        "documentType": _documentType,
        "documentFront": MultipartFile.fromBytes(
          compressedFront,
          filename: "front.jpg",
          contentType: MediaType('image', 'jpeg'),
        ),
        "documentBack": MultipartFile.fromBytes(
          compressedBack,
          filename: "back.jpg",
          contentType: MediaType('image', 'jpeg'),
        ),
        "selfieWithDocument": MultipartFile.fromBytes(
          compressedSelfie,
          filename: "selfie.jpg",
          contentType: MediaType('image', 'jpeg'),
        ),
      });
      await ProfileService.submitKyc(formData);
      ErrorUtils.showSuccessToast(context, 'Nộp hồ sơ KYC thành công!');
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        try {
          await Provider.of<ProfileProvider>(context, listen: false).fetchUserInfo();
        } catch (_) {}
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainTabScreen(initialTab: 0)),
          (route) => false,
        );
      }
    } catch (e) {
      ErrorUtils.showErrorToast(context, ErrorUtils.parseApiError(e));
    }
  }

  Future<void> _pickImage(Function(XFile) onPicked) async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppTheme.lightTheme.primaryColor),
                title: Text('Chụp ảnh', style: TextStyle(color: AppTheme.lightTheme.textTheme.bodyLarge?.color ?? Colors.white)),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                  if (pickedFile != null) {
                    onPicked(pickedFile);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppTheme.lightTheme.primaryColor),
                title: Text('Chọn từ thư viện', style: TextStyle(color: AppTheme.lightTheme.textTheme.bodyLarge?.color ?? Colors.white)),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                  if (pickedFile != null) {
                    onPicked(pickedFile);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userInfo = profileProvider.userInfo;
    final kycStatus = userInfo?['kycStatus']?.toString().toLowerCase();

    String? kycMessage;
    if (kycStatus == 'approved') {
      kycMessage = 'Bạn đã xác thực KYC thành công!';
    } else if (kycStatus == 'pending') {
      kycMessage = 'Hồ sơ KYC của bạn đang được duyệt. Vui lòng chờ kết quả.';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gửi KYC'),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: kycMessage != null
          ? Center(
              child: Card(
                color: AppTheme.lightTheme.cardTheme.color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user, color: AppTheme.lightTheme.primaryColor, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        kycMessage,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên đầy đủ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppTheme.lightTheme.primaryColor,
                                  onPrimary: Colors.white,
                                  surface: AppTheme.lightTheme.cardTheme.color!,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          _dobController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                        }
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          controller: _dobController,
                          decoration: const InputDecoration(
                            labelText: 'Ngày sinh (YYYY-MM-DD)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.cake_outlined),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: false,
                          countryListTheme: CountryListThemeData(
                            backgroundColor: AppTheme.lightTheme.cardTheme.color ?? Colors.white,
                            textStyle: TextStyle(color: AppTheme.lightTheme.textTheme.bodyLarge?.color ?? Colors.white),
                            inputDecoration: InputDecoration(
                              labelText: 'Tìm kiếm quốc gia',
                              labelStyle: TextStyle(color: AppTheme.lightTheme.primaryColor),
                              prefixIcon: Icon(Icons.search, color: AppTheme.lightTheme.primaryColor),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: AppTheme.lightTheme.primaryColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: AppTheme.lightTheme.primaryColor, width: 2),
                              ),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                            searchTextStyle: TextStyle(color: AppTheme.lightTheme.primaryColor),
                            flagSize: 24,
                            bottomSheetHeight: 600,
                          ),
                          onSelect: (Country country) {
                            setState(() {
                              _selectedCountry = country;
                              _country = country.countryCode;
                            });
                          },
                        );
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Quốc gia',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedCountry?.name ?? 'Chọn quốc gia',
                              style: TextStyle(color: AppTheme.lightTheme.textTheme.bodyLarge?.color ?? Colors.white)),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ (tùy chọn)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _documentType,
                      decoration: const InputDecoration(
                        labelText: 'Loại giấy tờ tùy thân',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'national_id',
                          child: Text('CMND/CCCD', style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: 'passport',
                          child: Text('Hộ chiếu', style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: 'drivers_license',
                          child: Text('Bằng lái xe', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      dropdownColor: AppTheme.lightTheme.cardTheme.color,
                      style: TextStyle(color: AppTheme.lightTheme.textTheme.bodyLarge?.color ?? Colors.white),
                      onChanged: (v) => setState(() => _documentType = v ?? 'national_id'),
                      validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                    ),
                    const SizedBox(height: 16),
                    Text('Ảnh mặt trước giấy tờ tùy thân:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _pickImage((img) => setState(() => _idCardFrontFile = img)),
                          child: const Text('Chọn ảnh'),
                        ),
                        if (_idCardFrontFile != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Image.file(
                              File(_idCardFrontFile!.path),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Ảnh mặt sau giấy tờ tùy thân:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _pickImage((img) => setState(() => _idCardBackFile = img)),
                          child: const Text('Chọn ảnh'),
                        ),
                        if (_idCardBackFile != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Image.file(
                              File(_idCardBackFile!.path),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Ảnh chân dung cầm giấy tờ tùy thân:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _pickImage((img) => setState(() => _selfieWithIdCardFile = img)),
                          child: const Text('Chọn ảnh'),
                        ),
                        if (_selfieWithIdCardFile != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Image.file(
                              File(_selfieWithIdCardFile!.path),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitKyc,
                        child: const Text('Gửi KYC'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 