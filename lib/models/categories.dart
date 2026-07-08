import 'package:flutter/material.dart';

/// Canonical spending/income categories used across the app.
///
/// Keep this list stable — category names are persisted in the database as
/// plain strings, so renaming a value here would orphan existing rows.
class AppCategory {
  // Spending
  static const food = 'Food';
  static const grocery = 'Grocery';
  static const shopping = 'Shopping';
  static const travel = 'Travel';
  static const bills = 'Bills';
  static const fuel = 'Fuel';
  static const entertainment = 'Entertainment';
  static const medical = 'Medical';
  static const emi = 'EMI';
  static const bankCharges = 'Bank Charges';
  static const cash = 'Cash Withdrawal';
  static const transfer = 'Transfer';
  static const investment = 'Investment';
  // Income
  static const salary = 'Salary';
  static const refund = 'Refund';
  static const cashback = 'Cashback';
  static const interest = 'Interest';
  static const income = 'Other Income';
  // Fallback
  static const others = 'Others';

  /// Categories that represent money coming in (excluded from spend charts).
  static const incomeCategories = {salary, refund, cashback, interest, income};

  static bool isIncome(String category) => incomeCategories.contains(category);

  /// All categories in display order.
  static const all = <String>[
    food, grocery, shopping, travel, bills, fuel, entertainment, medical,
    emi, bankCharges, cash, transfer, investment,
    salary, refund, cashback, interest, income,
    others,
  ];

  /// The set the LLM is allowed to choose from when categorizing a merchant.
  static const aiChoosable = <String>[
    food, grocery, shopping, travel, bills, fuel, entertainment, medical,
    emi, bankCharges, cash, transfer, investment, others,
  ];

  static Color colorFor(String category) {
    switch (category) {
      case food:
        return const Color(0xFFFF6B6B);
      case grocery:
        return const Color(0xFF51CF66);
      case shopping:
        return const Color(0xFF845EF7);
      case travel:
        return const Color(0xFF4DABF7);
      case bills:
        return const Color(0xFFFFA94D);
      case fuel:
        return const Color(0xFF20C997);
      case entertainment:
        return const Color(0xFFF783AC);
      case medical:
        return const Color(0xFFE64980);
      case emi:
        return const Color(0xFF7048E8);
      case bankCharges:
        return const Color(0xFFA9754A);
      case cash:
        return const Color(0xFF495057);
      case transfer:
        return const Color(0xFF3BC9DB);
      case investment:
        return const Color(0xFF1098AD);
      case salary:
        return const Color(0xFF37B24D);
      case refund:
        return const Color(0xFF94D82D);
      case cashback:
        return const Color(0xFF66D9E8);
      case interest:
        return const Color(0xFF0CA678);
      case income:
        return const Color(0xFF2F9E44);
      case others:
      default:
        return const Color(0xFF868E96);
    }
  }

  static IconData iconFor(String category) {
    switch (category) {
      case food:
        return Icons.restaurant;
      case grocery:
        return Icons.local_grocery_store;
      case shopping:
        return Icons.shopping_bag;
      case travel:
        return Icons.directions_car;
      case bills:
        return Icons.receipt_long;
      case fuel:
        return Icons.local_gas_station;
      case entertainment:
        return Icons.movie;
      case medical:
        return Icons.local_hospital;
      case emi:
        return Icons.event_repeat;
      case bankCharges:
        return Icons.account_balance;
      case cash:
        return Icons.atm;
      case transfer:
        return Icons.swap_horiz;
      case investment:
        return Icons.trending_up;
      case salary:
        return Icons.payments;
      case refund:
        return Icons.undo;
      case cashback:
        return Icons.savings;
      case interest:
        return Icons.percent;
      case income:
        return Icons.account_balance_wallet;
      case others:
      default:
        return Icons.category;
    }
  }
}
