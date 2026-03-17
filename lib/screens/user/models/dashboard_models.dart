import 'package:flutter/material.dart';

class NavItemData {
  const NavItemData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class DashboardMetric {
  const DashboardMetric({
    required this.title,
    required this.value,
    required this.caption,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String caption;
  final Color color;
  final IconData icon;
}

class UserTask {
  const UserTask({
    required this.title,
    required this.status,
    required this.dueDate,
    required this.priority,
  });

  final String title;
  final String status;
  final String dueDate;
  final String priority;
}

class QuickActionData {
  const QuickActionData({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

class UpcomingEvent {
  const UpcomingEvent({
    required this.title,
    required this.time,
    required this.tag,
  });

  final String title;
  final String time;
  final String tag;
}

class AttendanceDay {
  const AttendanceDay({required this.day, required this.value});

  final String day;
  final double value;
}

class UserFinanceProfile {
  const UserFinanceProfile({
    required this.name,
    required this.email,
    required this.currencyPreference,
    required this.twoFactorEnabled,
    required this.biometricEnabled,
    required this.bankImportEnabled,
  });

  final String name;
  final String email;
  final String currencyPreference;
  final bool twoFactorEnabled;
  final bool biometricEnabled;
  final bool bankImportEnabled;

  UserFinanceProfile copyWith({
    String? name,
    String? email,
    String? currencyPreference,
    bool? twoFactorEnabled,
    bool? biometricEnabled,
    bool? bankImportEnabled,
  }) {
    return UserFinanceProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      currencyPreference: currencyPreference ?? this.currencyPreference,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      bankImportEnabled: bankImportEnabled ?? this.bankImportEnabled,
    );
  }
}

class IncomeRecord {
  const IncomeRecord({
    required this.source,
    required this.category,
    required this.amount,
    required this.recordedOn,
    required this.bankSynced,
  });

  final String source;
  final String category;
  final double amount;
  final DateTime recordedOn;
  final bool bankSynced;
}

class ExpenseRecord {
  const ExpenseRecord({
    required this.title,
    required this.category,
    required this.amount,
    required this.spentOn,
    required this.recurring,
    required this.bankSynced,
  });

  final String title;
  final String category;
  final double amount;
  final DateTime spentOn;
  final bool recurring;
  final bool bankSynced;
}

class CategoryBudget {
  const CategoryBudget({
    required this.category,
    required this.limit,
    required this.spent,
  });

  final String category;
  final double limit;
  final double spent;

  double get utilization {
    if (limit <= 0) {
      return 0;
    }
    return spent / limit;
  }
}

class BudgetPlan {
  const BudgetPlan({
    required this.cadence,
    required this.totalLimit,
    required this.totalSpent,
    required this.categories,
  });

  final String cadence;
  final double totalLimit;
  final double totalSpent;
  final List<CategoryBudget> categories;

  double get utilization {
    if (totalLimit <= 0) {
      return 0;
    }
    return totalSpent / totalLimit;
  }
}

class SavingsGoal {
  const SavingsGoal({
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.suggestedAutoTransfer,
  });

  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final double suggestedAutoTransfer;

  double get progress {
    if (targetAmount <= 0) {
      return 0;
    }
    return currentAmount / targetAmount;
  }
}

class InvestmentHolding {
  const InvestmentHolding({
    required this.assetName,
    required this.assetType,
    required this.investedAmount,
    required this.currentValue,
    required this.riskLevel,
  });

  final String assetName;
  final String assetType;
  final double investedAmount;
  final double currentValue;
  final String riskLevel;

  double get returnAmount => currentValue - investedAmount;

  double get returnPercent {
    if (investedAmount <= 0) {
      return 0;
    }
    return (returnAmount / investedAmount) * 100;
  }
}

class ReportSeriesPoint {
  const ReportSeriesPoint({
    required this.label,
    required this.income,
    required this.expense,
  });

  final String label;
  final double income;
  final double expense;
}
