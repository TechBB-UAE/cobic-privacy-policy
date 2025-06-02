import 'package:flutter/material.dart';
import 'package:cobic/services/api_service.dart';

class MiningProvider extends ChangeNotifier {
  bool canMine = false;
  DateTime? nextMiningTime;
  bool isLoading = false;
  String? error;
  String? balance;
  String? reward;
  String? newBalance;
  String? miningRate;

  Future<void> fetchMiningStatus(String token) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiService.getMiningStatus(token);
      if (res.statusCode == 200) {
        final data = res.data;
        canMine = data['canMine'] ?? false;
        nextMiningTime = data['nextMiningTime'] != null ? DateTime.parse(data['nextMiningTime']).toUtc() : null;
        if (nextMiningTime != null && DateTime.now().toUtc().isAfter(nextMiningTime!)) {
          canMine = true;
        }
        balance = data['balance']?.toString() ?? '0.00';
        miningRate = data['miningRate']?.toString() ?? '0.00';
      } else {
        error = 'Lỗi lấy trạng thái mining';
      }
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> dailyCheckIn(String token) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiService.dailyCheckIn(token);
      if (res.statusCode == 200 && res.data['success'] == true) {
        canMine = false;
        nextMiningTime = res.data['nextCheckInTime'] != null ? DateTime.parse(res.data['nextCheckInTime']).toUtc() : null;
        reward = res.data['reward']?.toString() ?? '0.00';
        newBalance = res.data['newBalance']?.toString() ?? '0.00';
        miningRate = res.data['miningRate']?.toString() ?? miningRate;
      } else if (res.statusCode == 400) {
        canMine = false;
        nextMiningTime = res.data['nextCheckInTime'] != null ? DateTime.parse(res.data['nextCheckInTime']).toUtc() : null;
        error = res.data['error'] ?? 'Đã khai thác hôm nay';
        miningRate = res.data['miningRate']?.toString() ?? miningRate;
      } else {
        error = 'Lỗi khai thác';
      }
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  void reset() {
    canMine = false;
    nextMiningTime = null;
    isLoading = false;
    error = null;
    balance = null;
    reward = null;
    newBalance = null;
    miningRate = null;
    notifyListeners();
  }
} 