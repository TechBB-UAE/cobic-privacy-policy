import 'package:flutter/material.dart';
import 'package:cobic/services/referral_service.dart';
import 'package:cobic/models/referral_stats.dart';

class ReferralProvider extends ChangeNotifier {
  ReferralStats? referralStats;
  bool isLoading = false;
  String? error;

  Future<void> fetchReferralStats() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      referralStats = await ReferralService.getReferralStats();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
} 