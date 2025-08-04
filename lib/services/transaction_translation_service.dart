import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class TransactionTranslationService {
  static String getTransactionTypeText(BuildContext context, String? type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'mining':
        return l10n.transactionTypeMining;
      case 'daily_check_in':
        return l10n.transactionTypeDailyCheckIn;
      case 'transfer':
        return l10n.transactionTypeTransfer;
      case 'qr_scan':
        return l10n.transactionTypeQrScan;
      case 'bounty':
        return l10n.transactionTypeBounty;
      default:
        return type ?? '';
    }
  }

  static String getTransactionDescription(BuildContext context, Map<String, dynamic> transaction) {
    final l10n = AppLocalizations.of(context)!;
    final type = transaction['type'];
    final description = transaction['description'];
    final amount = transaction['amount']?.toString() ?? '0';

    switch (type) {
      case 'mining':
        return l10n.miningDescription(amount);
      case 'daily_check_in':
        return l10n.dailyCheckInDescription(amount);
      case 'transfer':
        return l10n.transferDescription(description ?? '');
      case 'qr_scan':
        return l10n.qrScanDescription(amount);
      case 'bounty':
        return l10n.bountyDescription(description ?? '');
      default:
        return description?.toString() ?? '';
    }
  }
} 