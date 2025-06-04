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
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  Future<List<int>> compressImage(String filePath) async {
    return await FlutterImageCompress.compressWithFile(
      filePath,
      minWidth: 1024,
      minHeight: 1024,
      quality: 70,
      format: CompressFormat.jpeg,
    ) ?? [];
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCountry == null || _country.isEmpty) {
      ErrorUtils.showErrorToast(context, AppLocalizations.of(context)!.kycSelectCountry);
      return;
    }
    if (_idCardFrontFile == null || _idCardBackFile == null || _selfieWithIdCardFile == null) {
      ErrorUtils.showErrorToast(context, AppLocalizations.of(context)!.kycSelectAllImages);
      return;
    }
    try {
      final compressedFront = await compressImage(_idCardFrontFile!.path);
      final compressedBack = await compressImage(_idCardBackFile!.path);
      final compressedSelfie = await compressImage(_selfieWithIdCardFile!.path);

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
      ErrorUtils.showSuccessToast(context, AppLocalizations.of(context)!.kycSubmitSuccess);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        try {
          await Provider.of<ProfileProvider>(context, listen: false).fetchUserInfo(context);
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
                title: Text(AppLocalizations.of(context)!.kycTakePhoto, style: TextStyle(color: AppTheme.lightTheme.textTheme.bodyLarge?.color ?? Colors.white)),
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
                title: Text(AppLocalizations.of(context)!.kycChooseFromGallery, style: TextStyle(color: AppTheme.lightTheme.textTheme.bodyLarge?.color ?? Colors.white)),
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
    final l10n = AppLocalizations.of(context)!;
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userInfo = profileProvider.userInfo;
    final kycStatus = userInfo?['kycStatus']?.toString().toLowerCase();

    String? kycMessage;
    if (kycStatus == 'approved') {
      kycMessage = AppLocalizations.of(context)!.kycApprovedMsg;
    } else if (kycStatus == 'pending') {
      kycMessage = AppLocalizations.of(context)!.kycPendingMsg;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(l10n.kycSubmitTitle, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                      decoration: InputDecoration(
                        labelText: l10n.kycFullName,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (v) => v == null || v.isEmpty ? l10n.kycRequired : null,
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
                                  surface: Colors.white,
                                  onSurface: Colors.black,
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
                          decoration: InputDecoration(
                            labelText: l10n.kycDobFormat,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.cake_outlined),
                          ),
                          style: const TextStyle(color: Colors.black),
                          validator: (v) => v == null || v.isEmpty ? l10n.kycRequired : null,
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
                              labelText: l10n.kycSearchCountry,
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
                        decoration: InputDecoration(
                          labelText: l10n.country,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.flag_outlined),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedCountry?.name ?? l10n.kycSelectCountry,
                              style: TextStyle(color: AppTheme.lightTheme.textTheme.bodyLarge?.color ?? Colors.white)),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: l10n.kycAddressOptional,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _documentType,
                      decoration: InputDecoration(
                        labelText: l10n.kycIdType,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.description_outlined),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'national_id',
                          child: Text(l10n.kycNationalId, style: const TextStyle(color: Colors.black)),
                        ),
                        DropdownMenuItem(
                          value: 'passport',
                          child: Text(l10n.kycPassport, style: const TextStyle(color: Colors.black)),
                        ),
                        DropdownMenuItem(
                          value: 'drivers_license',
                          child: Text(l10n.kycDriversLicense, style: const TextStyle(color: Colors.black)),
                        ),
                      ],
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black),
                      onChanged: (v) => setState(() => _documentType = v ?? 'national_id'),
                      validator: (v) => v == null || v.isEmpty ? l10n.kycRequired : null,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.kycFrontImageTitle, style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade300, width: 1.2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _idCardFrontFile == null
                                ? IconButton(
                                    icon: Icon(Icons.add_a_photo, color: AppTheme.lightTheme.primaryColor, size: 32),
                                    onPressed: () => _pickImage((img) => setState(() => _idCardFrontFile = img)),
                                    tooltip: l10n.kycSelectOrTakePhoto,
                                  )
                                : Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.file(
                                          File(_idCardFrontFile!.path),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: InkWell(
                                          onTap: () => setState(() => _idCardFrontFile = null),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white70,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, color: Colors.red, size: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.kycBackImageTitle, style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade300, width: 1.2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _idCardBackFile == null
                                ? IconButton(
                                    icon: Icon(Icons.add_a_photo, color: AppTheme.lightTheme.primaryColor, size: 32),
                                    onPressed: () => _pickImage((img) => setState(() => _idCardBackFile = img)),
                                    tooltip: l10n.kycSelectOrTakePhoto,
                                  )
                                : Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.file(
                                          File(_idCardBackFile!.path),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: InkWell(
                                          onTap: () => setState(() => _idCardBackFile = null),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white70,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, color: Colors.red, size: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.kycSelfieImageTitle, style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade300, width: 1.2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _selfieWithIdCardFile == null
                                ? IconButton(
                                    icon: Icon(Icons.add_a_photo, color: AppTheme.lightTheme.primaryColor, size: 32),
                                    onPressed: () => _pickImage((img) => setState(() => _selfieWithIdCardFile = img)),
                                    tooltip: l10n.kycSelectOrTakePhoto,
                                  )
                                : Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.file(
                                          File(_selfieWithIdCardFile!.path),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: InkWell(
                                          onTap: () => setState(() => _selfieWithIdCardFile = null),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white70,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close, color: Colors.red, size: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitKyc,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        child: Text(l10n.kycSubmit),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 