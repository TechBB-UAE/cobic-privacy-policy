class ReferralStats {
  final int currentReferrals;
  final int maxReferrals;
  final int remainingReferrals;
  final List<ReferredUser> referredByMe;
  final Referrer? whoReferredMe;
  final List<SecurityCircleUser> securityCircles;

  ReferralStats({
    required this.currentReferrals,
    required this.maxReferrals,
    required this.remainingReferrals,
    required this.referredByMe,
    this.whoReferredMe,
    this.securityCircles = const [],
  });

  static int parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    // whoReferredMe: API trả về [] nếu không có, trả về mảng có 1 object nếu có
    Referrer? referrer;
    if (json['whoReferredMe'] is List && (json['whoReferredMe'] as List).isNotEmpty) {
      referrer = Referrer.fromJson((json['whoReferredMe'] as List).first);
    } else {
      referrer = null;
    }
    return ReferralStats(
      currentReferrals: parseInt(json['currentReferrals']),
      maxReferrals: parseInt(json['maxReferrals']),
      remainingReferrals: parseInt(json['remainingReferrals']),
      referredByMe: (json['referredByMe'] as List?)
          ?.map((e) => ReferredUser.fromJson(e))
          .toList() ?? [],
      whoReferredMe: referrer,
      securityCircles: (json['securityCircles'] as List?)?.map((e) => SecurityCircleUser.fromJson(e)).toList() ?? [],
    );
  }
}

class ReferredUser {
  final String username;
  final DateTime joinedAt;

  ReferredUser({
    required this.username,
    required this.joinedAt,
  });

  factory ReferredUser.fromJson(Map<String, dynamic> json) {
    return ReferredUser(
      username: json['username'] ?? '',
      joinedAt: DateTime.parse(json['joinDate'] ?? json['joinedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Referrer {
  final String username;
  final String referralCode;

  Referrer({
    required this.username,
    required this.referralCode,
  });

  factory Referrer.fromJson(Map<String, dynamic> json) {
    return Referrer(
      username: json['username'] ?? '',
      referralCode: json['referralCode'] ?? '',
    );
  }
}

class SecurityCircleUser {
  final String username;
  final String referralCode;
  final DateTime joinedAt;

  SecurityCircleUser({
    required this.username,
    required this.referralCode,
    required this.joinedAt,
  });

  factory SecurityCircleUser.fromJson(Map<String, dynamic> json) {
    return SecurityCircleUser(
      username: json['username'] ?? '',
      referralCode: json['referralCode'] ?? '',
      joinedAt: DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
    );
  }
} 