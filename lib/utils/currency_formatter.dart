import 'package:intl/intl.dart';

/// Supported currencies with their symbols and names
class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

/// List of supported currencies
class SupportedCurrencies {
  static const List<Currency> all = [
    Currency(code: 'USD', symbol: '\$', name: 'US Dollar'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro'),
    Currency(code: 'GBP', symbol: '£', name: 'British Pound'),
    Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    Currency(code: 'KES', symbol: 'KSh', name: 'Kenyan Shilling'),
    Currency(code: 'UGX', symbol: 'USh', name: 'Ugandan Shilling'),
    Currency(code: 'TZS', symbol: 'TSh', name: 'Tanzanian Shilling'),
    Currency(code: 'NGN', symbol: '₦', name: 'Nigerian Naira'),
    Currency(code: 'ZAR', symbol: 'R', name: 'South African Rand'),
    Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
  ];

  /// Get currency by code
  static Currency? getByCode(String code) {
    try {
      return all.firstWhere((currency) => currency.code == code);
    } catch (e) {
      return null;
    }
  }

  /// Get currency symbol by code
  static String getSymbol(String code) {
    final currency = getByCode(code);
    return currency?.symbol ?? '\$';
  }
}

/// Utility class for formatting currency amounts
class CurrencyFormatter {
  /// Format amount with currency symbol
  static String format(double amount, String currencyCode) {
    final currency = SupportedCurrencies.getByCode(currencyCode);
    
    if (currency == null) {
      // Fallback to USD if currency not found
      return '\$${amount.toStringAsFixed(2)}';
    }

    // Format the number with commas
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final formattedAmount = formatter.format(amount);

    // Return with currency symbol
    // For some currencies, symbol goes after the amount
    if (currencyCode == 'EUR') {
      return '$formattedAmount ${currency.symbol}';
    } else {
      return '${currency.symbol}$formattedAmount';
    }
  }

  /// Format amount without decimals (for whole numbers)
  static String formatWhole(double amount, String currencyCode) {
    final currency = SupportedCurrencies.getByCode(currencyCode);
    
    if (currency == null) {
      return '\$${amount.toStringAsFixed(0)}';
    }

    final formatter = NumberFormat('#,##0', 'en_US');
    final formattedAmount = formatter.format(amount);

    if (currencyCode == 'EUR') {
      return '$formattedAmount ${currency.symbol}';
    } else {
      return '${currency.symbol}$formattedAmount';
    }
  }

  /// Format compact (e.g., 1.5K, 2.3M)
  static String formatCompact(double amount, String currencyCode) {
    final currency = SupportedCurrencies.getByCode(currencyCode);
    final symbol = currency?.symbol ?? '\$';

    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return format(amount, currencyCode);
    }
  }
}
