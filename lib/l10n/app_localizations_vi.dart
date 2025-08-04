// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Cobic';

  @override
  String get welcome => 'Chào mừng đến với Cobic';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get dontHaveAccount => 'Bạn chưa có tài khoản?';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản? Đăng nhập';

  @override
  String get scanQR => 'Quét QR';

  @override
  String get wallet => 'Ví';

  @override
  String get balance => 'Số dư';

  @override
  String get tasks => 'Nhiệm vụ';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get settings => 'Cài đặt';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get submit => 'Gửi';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get delete => 'Xóa';

  @override
  String get edit => 'Sửa';

  @override
  String get loading => 'Đang tải...';

  @override
  String get error => 'Lỗi';

  @override
  String get success => 'Thành công';

  @override
  String get tryAgain => 'Thử lại';

  @override
  String get noInternet => 'Không có kết nối Internet';

  @override
  String get serverError => 'Lỗi máy chủ';

  @override
  String get unknownError => 'Lỗi không xác định';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get referralCode => 'Mã giới thiệu';

  @override
  String get kycStatus => 'Trạng thái KYC';

  @override
  String get dob => 'Ngày sinh';

  @override
  String get notUpdated => 'Chưa cập nhật';

  @override
  String get pending => 'Đang chờ duyệt';

  @override
  String get approved => 'Đã xác thực';

  @override
  String get rejected => 'Từ chối';

  @override
  String get reasonKycRejected => 'Lý do từ chối KYC';

  @override
  String get nonTransferableBalance => 'Số dư không chuyển được';

  @override
  String get miningRate => 'Tỷ lệ đào';

  @override
  String get sendKyc => 'Gửi KYC';

  @override
  String get updateProfile => 'Cập nhật hồ sơ';

  @override
  String get copyReferralCode => 'Đã copy mã giới thiệu!';

  @override
  String get shareReferral =>
      'Chia sẻ mã này để mời người khác và nhận thưởng tăng tỉ lệ đào!';

  @override
  String get enterReferral => 'Nhập mã giới thiệu';

  @override
  String get taskContent => 'Nội dung nhiệm vụ';

  @override
  String get execute => 'Thực hiện';

  @override
  String get previousPage => 'Trang trước';

  @override
  String get searchCountry => 'Tìm kiếm quốc gia';

  @override
  String get account => 'Tài khoản';

  @override
  String get close => 'Đóng';

  @override
  String get missingEmail => 'Chưa cập nhật email';

  @override
  String cobicPerDay(Object amount) {
    return '$amount COBIC/ngày';
  }

  @override
  String get all => 'Tất cả';

  @override
  String get notSubmitted => 'Chưa nộp';

  @override
  String get pendingTask => 'Đang chờ duyệt';

  @override
  String get approvedTask => 'Đã được duyệt';

  @override
  String get rejectedTask => 'Bị từ chối';

  @override
  String get mining => 'Khai thác';

  @override
  String get mine => 'Bắt đầu khai thác ngay';

  @override
  String get nextMining => 'Đào tiếp theo';

  @override
  String get readyToMine => 'Sẵn sàng đào!';

  @override
  String get countingDown => 'Đang đếm ngược...';

  @override
  String get scanVietQR => 'Quét VietQR';

  @override
  String get scanVietQRDesc =>
      'Quét mã VietQR để nhận Cobic Points\nTích điểm Cobic Points với tỷ lệ 250 VND = 1 Cobic Point.';

  @override
  String get scanNow => 'Quét Ngay';

  @override
  String get currentBalance => 'Số dư hiện tại';

  @override
  String get receiverName => 'Tên người nhận';

  @override
  String get amountCobic => 'Số lượng (Cobic)';

  @override
  String get send => 'Gửi';

  @override
  String get transactionHistory => 'Lịch sử giao dịch';

  @override
  String get transactionType => 'Loại giao dịch';

  @override
  String get noTransaction => 'Chưa có giao dịch nào';

  @override
  String get nextPage => 'Trang sau';

  @override
  String get transactionTypeMining => 'Khai thác';

  @override
  String get transactionTypeDailyCheckIn => 'Điểm danh';

  @override
  String get transactionTypeTransfer => 'Chuyển tiền';

  @override
  String get transactionTypeQrScan => 'Quét QR';

  @override
  String get transactionTypeBounty => 'Thưởng nhiệm vụ';

  @override
  String transferDescription(String receiver) {
    return 'Chuyển tiền cho $receiver';
  }

  @override
  String miningDescription(String amount) {
    return 'Khai thác $amount COBIC';
  }

  @override
  String bountyDescription(String taskName) {
    return 'Thưởng nhiệm vụ $taskName';
  }

  @override
  String dailyCheckInDescription(String amount) {
    return 'Điểm danh nhận $amount COBIC';
  }

  @override
  String qrScanDescription(String amount) {
    return 'Quét QR nhận $amount COBIC';
  }

  @override
  String get referralStats => 'Thống kê giới thiệu';

  @override
  String get invitedUsers => 'Người đã mời';

  @override
  String get remainingInvites => 'Lượt mời còn lại';

  @override
  String get invitedByYou => 'Người dùng bạn đã mời';

  @override
  String get noInvitedUsers => 'Chưa có ai được mời';

  @override
  String get invitedBy => 'Người đã mời bạn';

  @override
  String get noReferrer => 'Chưa có ai mời bạn';

  @override
  String get securityCircle => 'Vòng tròn bảo mật';

  @override
  String get noSecurityCircle => 'Bạn chưa có vòng tròn bảo mật';

  @override
  String get securityCircleDesc =>
      'Vòng tròn bảo mật được tạo ra khi hai người dùng cùng giới thiệu lẫn nhau. Hãy tìm người bạn tin tưởng và tạo vòng tròn bảo mật để được +0.1 vào tỉ lệ đào.';

  @override
  String get yourReferralCode => 'Mã giới thiệu của bạn';

  @override
  String get enterReferralCode => 'Nhập mã giới thiệu';

  @override
  String get referralCodeHint => 'Nhập mã';

  @override
  String get apply => 'Áp dụng';

  @override
  String get alreadyEnteredCode =>
      'Bạn đã nhập mã giới thiệu, chỉ được nhập 1 lần duy nhất!';

  @override
  String get enterCodeSuccess => 'Nhập mã giới thiệu thành công!';

  @override
  String get pleaseEnterCode => 'Vui lòng nhập mã giới thiệu!';

  @override
  String joinedAt(String date) {
    return 'Tham gia $date';
  }

  @override
  String referralCodeLabel(String code) {
    return 'Mã giới thiệu: $code';
  }

  @override
  String get updateProfileTitle => 'Cập nhật hồ sơ';

  @override
  String get username => 'Tên đăng nhập';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get country => 'Quốc gia';

  @override
  String get chooseCountry => 'Chọn quốc gia';

  @override
  String get pleaseChooseCountry => 'Vui lòng chọn quốc gia';

  @override
  String get phone => 'Số điện thoại';

  @override
  String get address => 'Địa chỉ';

  @override
  String get bio => 'Giới thiệu';

  @override
  String get chooseDob => 'Chọn ngày sinh';

  @override
  String get pleaseChooseDob => 'Vui lòng chọn ngày sinh';

  @override
  String get dob18plus => 'Bạn phải đủ 18 tuổi trở lên';

  @override
  String get cannotChangeDob =>
      'Không thể thay đổi ngày sinh sau khi KYC thành công';

  @override
  String get update => 'Cập nhật';

  @override
  String get usernameRequired => 'Vui lòng nhập tên đăng nhập';

  @override
  String get usernameLength => 'Tên đăng nhập từ 4-32 ký tự';

  @override
  String get usernamePattern => 'Chỉ cho phép chữ, số, dấu gạch dưới';

  @override
  String get usernameExists => 'Tên đăng nhập đã tồn tại';

  @override
  String get fullNameRequired => 'Vui lòng nhập họ và tên';

  @override
  String get fullNameLength => 'Họ và tên tối thiểu 2 ký tự';

  @override
  String get emailRequired => 'Vui lòng nhập email';

  @override
  String get emailInvalid => 'Email không hợp lệ';

  @override
  String get emailExists => 'Email đã tồn tại';

  @override
  String get phoneRequired => 'Vui lòng nhập số điện thoại';

  @override
  String get phoneInvalid => 'Số điện thoại không hợp lệ';

  @override
  String get updateProfileSuccess => 'Cập nhật hồ sơ thành công!';

  @override
  String get updateProfileError => 'Có lỗi xảy ra khi cập nhật hồ sơ';

  @override
  String get changePasswordTitle => 'Đổi mật khẩu';

  @override
  String get currentPassword => 'Mật khẩu hiện tại';

  @override
  String get newPassword => 'Mật khẩu mới';

  @override
  String get confirmNewPassword => 'Xác nhận mật khẩu mới';

  @override
  String get currentPasswordRequired => 'Vui lòng nhập mật khẩu hiện tại';

  @override
  String get newPasswordRequired => 'Vui lòng nhập mật khẩu mới';

  @override
  String get newPasswordLength => 'Mật khẩu phải có ít nhất 8 ký tự';

  @override
  String get newPasswordUpper =>
      'Mật khẩu phải có ít nhất một chữ cái viết hoa';

  @override
  String get confirmPasswordRequired => 'Vui lòng xác nhận mật khẩu mới';

  @override
  String get confirmPasswordNotMatch => 'Mật khẩu không khớp';

  @override
  String get changePasswordSuccess => 'Đổi mật khẩu thành công!';

  @override
  String get changePasswordError => 'Có lỗi xảy ra khi đổi mật khẩu';

  @override
  String get loginTokenNotFound => 'Không tìm thấy token đăng nhập';

  @override
  String get kycSubmitTitle => 'Gửi KYC';

  @override
  String get kycApprovedMsg => 'Bạn đã xác thực KYC thành công!';

  @override
  String get kycPendingMsg =>
      'Hồ sơ KYC của bạn đang được duyệt. Vui lòng chờ kết quả.';

  @override
  String get kycTakePhoto => 'Chụp ảnh';

  @override
  String get kycChooseFromGallery => 'Chọn từ thư viện';

  @override
  String get kycSubmitSuccess => 'Nộp hồ sơ KYC thành công!';

  @override
  String get kycSelectCountry => 'Vui lòng chọn quốc gia.';

  @override
  String get kycSelectAllImages => 'Vui lòng chọn đủ 3 ảnh.';

  @override
  String get kycFullName => 'Họ và tên';

  @override
  String get kycDob => 'Ngày sinh';

  @override
  String get kycAddress => 'Địa chỉ';

  @override
  String get kycIdentityNumber => 'Số giấy tờ tùy thân';

  @override
  String get kycDocumentType => 'Loại giấy tờ';

  @override
  String get kycNationalId => 'CMND/CCCD';

  @override
  String get kycPassport => 'Hộ chiếu';

  @override
  String get kycDriversLicense => 'Bằng lái xe';

  @override
  String get kycFrontImage => 'Ảnh mặt trước giấy tờ';

  @override
  String get kycBackImage => 'Ảnh mặt sau giấy tờ';

  @override
  String get kycSelfieImage => 'Ảnh selfie với giấy tờ';

  @override
  String get kycSubmit => 'Gửi KYC';

  @override
  String get kycRequired => 'Bắt buộc';

  @override
  String get kycDobFormat => 'Ngày sinh (YYYY-MM-DD)';

  @override
  String get kycAddressOptional => 'Địa chỉ (tùy chọn)';

  @override
  String get kycIdType => 'Loại giấy tờ tùy thân';

  @override
  String get kycFrontImageTitle => 'Ảnh mặt trước giấy tờ tùy thân:';

  @override
  String get kycBackImageTitle => 'Ảnh mặt sau giấy tờ tùy thân:';

  @override
  String get kycSelfieImageTitle => 'Ảnh chân dung cầm giấy tờ tùy thân:';

  @override
  String get kycSelectOrTakePhoto => 'Chọn/chụp ảnh';

  @override
  String get kycSearchCountry => 'Tìm kiếm quốc gia';

  @override
  String get referral => 'Giới thiệu';

  @override
  String get logoutSuccess => 'Đăng xuất thành công!';

  @override
  String get or => 'Hoặc';

  @override
  String get loginGuest => 'Đăng nhập nhanh (khách)';

  @override
  String get registerNewAccount => 'Đăng ký tài khoản mới';

  @override
  String get loginSuccess => 'Đăng nhập thành công!';

  @override
  String get loginFailed => 'Đăng nhập thất bại!';

  @override
  String get wrongCredentials => 'Sai tài khoản hoặc mật khẩu!';

  @override
  String get guestLoginFailed => 'Đăng nhập nhanh thất bại!';

  @override
  String get passwordRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get passwordMinLength => 'Mật khẩu tối thiểu 6 ký tự';

  @override
  String get passwordPattern => 'Mật khẩu phải có ít nhất 1 chữ cái và 1 số';

  @override
  String get registerTitle => 'Đăng ký tài khoản';

  @override
  String get registerSuccess => 'Đăng ký thành công!';

  @override
  String get registerFailed => 'Đăng ký thất bại!';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get forgotPasswordTitle => 'Quên mật khẩu';

  @override
  String get forgotPasswordDesc =>
      'Nhập email đã đăng ký để nhận hướng dẫn đặt lại mật khẩu.';

  @override
  String get sendResetLink => 'Gửi hướng dẫn đặt lại mật khẩu';

  @override
  String get resetLinkSent =>
      'Đã gửi hướng dẫn đặt lại mật khẩu! Vui lòng kiểm tra email.';

  @override
  String get resetLinkFailed => 'Gửi hướng dẫn thất bại!';

  @override
  String get logoutConfirmTitle => 'Xác nhận đăng xuất';

  @override
  String get logoutConfirmContent => 'Bạn có chắc chắn muốn đăng xuất không?';

  @override
  String get referent => 'Người giới thiệu';

  @override
  String get guestAccountTitle => 'Tài khoản khách';

  @override
  String get guestUsername => 'Tên đăng nhập:';

  @override
  String get guestPassword => 'Mật khẩu:';

  @override
  String get guestSaveInfoNote => 'Lưu lại thông tin này để đăng nhập về sau!';

  @override
  String get guestSavedToGallery => 'Đã lưu thông tin vào thư viện ảnh!';

  @override
  String get appTitle => 'Cobic';

  @override
  String get theme => 'Giao diện';

  @override
  String get systemTheme => 'Hệ thống';

  @override
  String get lightTheme => 'Sáng';

  @override
  String get darkTheme => 'Tối';

  @override
  String get cannotTransferToYourself => 'Không thể chuyển cho chính mình';

  @override
  String get recipientNotFound => 'Không tìm thấy người nhận';

  @override
  String get invalidAmount => 'Vui lòng nhập số lượng hợp lệ!';
}
