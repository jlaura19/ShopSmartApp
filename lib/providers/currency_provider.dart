import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../providers/user_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/logger.dart';

/// Provider for managing currency preferences
class CurrencyProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  String _currencyCode = 'USD'; // Default currency

  String get currencyCode => _currencyCode;
  String get currencySymbol => SupportedCurrencies.getSymbol(_currencyCode);

  /// Initialize currency from user profile
  void initializeCurrency(String? userCurrency) {
    if (userCurrency != null && userCurrency.isNotEmpty) {
      _currencyCode = userCurrency;
      appLogger.i('Currency initialized: $_currencyCode');
      notifyListeners();
    }
  }

  /// Update currency preference
  Future<bool> updateCurrency(String newCurrencyCode, String userId) async {
    try {
      // Validate currency code
      if (SupportedCurrencies.getByCode(newCurrencyCode) == null) {
        appLogger.w('Invalid currency code: $newCurrencyCode');
        return false;
      }

      // Update in Firestore
      await _firestoreService.updateUser(userId, {
        'preferredCurrency': newCurrencyCode,
        'updatedAt': DateTime.now(),
      });

      // Update local state
      _currencyCode = newCurrencyCode;
      appLogger.i('Currency updated to: $newCurrencyCode');
      notifyListeners();
      
      return true;
    } catch (e) {
      appLogger.e('Error updating currency', error: e, stackTrace: StackTrace.current);
      return false;
    }
  }

  /// Format amount with current currency
  String format(double amount) {
    return CurrencyFormatter.format(amount, _currencyCode);
  }

  /// Format amount without decimals
  String formatWhole(double amount) {
    return CurrencyFormatter.formatWhole(amount, _currencyCode);
  }

  /// Format compact (e.g., 1.5K)
  String formatCompact(double amount) {
    return CurrencyFormatter.formatCompact(amount, _currencyCode);
  }
}
