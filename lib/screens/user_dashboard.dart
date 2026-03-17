import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'user/data/dashboard_seed_data.dart';
import 'user/models/dashboard_models.dart';
import 'user/usersidebar/Calendar.dart';
import 'user/usersidebar/Profile.dart';
import 'user/usersidebar/Report.dart';
import 'user/usersidebar/Transactions.dart';
import 'user/usersidebar/📈 Investments.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedSection = 0;
  String _selectedBudgetCadence = 'Monthly';

  late UserFinanceProfile _profile;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  late List<IncomeRecord> _incomeRecords;
  late List<ExpenseRecord> _expenseRecords;
  late List<SavingsGoal> _savingsGoals;

  @override
  void initState() {
    super.initState();
    _profile = seededUserProfile;
    _nameController = TextEditingController(text: _profile.name);
    _emailController = TextEditingController(text: _profile.email);

    _incomeRecords = List<IncomeRecord>.from(seedIncomeRecords);
    _expenseRecords = List<ExpenseRecord>.from(seedExpenseRecords);
    _savingsGoals = List<SavingsGoal>.from(seedSavingsGoals);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String get _currencySymbol {
    switch (_profile.currencyPreference) {
      case 'EUR':
        return 'EUR ';
      case 'GBP':
        return 'GBP ';
      case 'INR':
        return 'INR ';
      case 'AED':
        return 'AED ';
      case 'USD':
      default:
        return r'$';
    }
  }

  String _money(double value, {int decimals = 0}) {
    final isNegative = value < 0;
    final rounded = value.abs().toStringAsFixed(decimals);
    final parts = rounded.split('.');
    final whole = parts[0];
    final decimal = parts.length > 1 ? parts[1] : '';

    final buffer = StringBuffer();
    for (int i = 0; i < whole.length; i++) {
      final reverseIndex = whole.length - i;
      buffer.write(whole[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    final number =
        decimals > 0 ? '${buffer.toString()}.$decimal' : buffer.toString();
    return '${isNegative ? '-' : ''}$_currencySymbol$number';
  }

  String _dateLabel(DateTime date) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final month = monthNames[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }

  double get _totalIncome {
    return _incomeRecords.fold<double>(0, (sum, item) => sum + item.amount);
  }

  double get _totalExpense {
    return _expenseRecords.fold<double>(0, (sum, item) => sum + item.amount);
  }

  double get _netCashFlow => _totalIncome - _totalExpense;

  double get _fixedIncome {
    return _incomeRecords
        .where((item) => item.category == 'Fixed')
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  double get _variableIncome {
    return _incomeRecords
        .where((item) => item.category == 'Variable')
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  double get _investmentIncome {
    return _incomeRecords
        .where((item) => item.category == 'Investments')
        .fold<double>(0, (sum, item) => sum + item.amount);
  }

  double get _todayExpense {
    final now = DateTime.now();
    return _expenseRecords.where((item) {
      return item.spentOn.year == now.year &&
          item.spentOn.month == now.month &&
          item.spentOn.day == now.day;
    }).fold<double>(0, (sum, item) => sum + item.amount);
  }

  BudgetPlan get _selectedBudgetPlan {
    return seedBudgetPlans.firstWhere(
      (plan) => plan.cadence == _selectedBudgetCadence,
      orElse: () => seedBudgetPlans.first,
    );
  }

  List<CategoryBudget> get _nearLimitBudgets {
    return _selectedBudgetPlan.categories
        .where((item) => item.utilization >= 0.85)
        .toList();
  }

  Map<String, double> get _expenseCategoryTotals {
    final map = <String, double>{};
    for (final item in _expenseRecords) {
      map[item.category] = (map[item.category] ?? 0) + item.amount;
    }
    return map;
  }

  List<ExpenseRecord> get _recurringExpenses {
    return _expenseRecords.where((item) => item.recurring).toList();
  }

  double get _portfolioInvested {
    return seedInvestmentHoldings.fold<double>(
      0,
      (sum, item) => sum + item.investedAmount,
    );
  }

  double get _portfolioCurrent {
    return seedInvestmentHoldings.fold<double>(
      0,
      (sum, item) => sum + item.currentValue,
    );
  }

  double get _portfolioReturnAmount => _portfolioCurrent - _portfolioInvested;

  double get _portfolioReturnPercent {
    if (_portfolioInvested <= 0) {
      return 0;
    }
    return (_portfolioReturnAmount / _portfolioInvested) * 100;
  }

  double get _riskScore {
    double weighted = 0;
    double total = 0;

    for (final item in seedInvestmentHoldings) {
      final weight = item.currentValue;
      final level = _riskValue(item.riskLevel);
      weighted += weight * level;
      total += weight;
    }

    if (total <= 0) {
      return 0;
    }
    return weighted / total;
  }

  String get _riskLabel {
    if (_riskScore <= 1.4) {
      return 'Low Risk Profile';
    }
    if (_riskScore <= 2.2) {
      return 'Balanced Risk Profile';
    }
    return 'High Risk Profile';
  }

  int _riskValue(String riskLevel) {
    switch (riskLevel) {
      case 'Low':
        return 1;
      case 'Medium':
        return 2;
      case 'High':
      default:
        return 3;
    }
  }

  double get _annualIncome {
    return seedMonthlyReportSeries.fold<double>(
      0,
      (sum, item) => sum + item.income,
    );
  }

  double get _annualExpense {
    return seedMonthlyReportSeries.fold<double>(
      0,
      (sum, item) => sum + item.expense,
    );
  }

  double get _averageSavingsRate {
    if (seedMonthlyReportSeries.isEmpty) {
      return 0;
    }

    final sum = seedMonthlyReportSeries.fold<double>(0, (total, point) {
      if (point.income <= 0) {
        return total;
      }
      return total + ((point.income - point.expense) / point.income);
    });

    return (sum / seedMonthlyReportSeries.length) * 100;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showAddIncomeDialog() async {
    final sourceController = TextEditingController();
    final amountController = TextEditingController();
    String category = 'Variable';
    bool bankSynced = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Income Entry'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: sourceController,
                      decoration: const InputDecoration(labelText: 'Source'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Amount'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: category,
                      items: const [
                        DropdownMenuItem(value: 'Fixed', child: Text('Fixed')),
                        DropdownMenuItem(
                            value: 'Variable', child: Text('Variable')),
                        DropdownMenuItem(
                            value: 'Investments', child: Text('Investments')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          category = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Imported via bank API'),
                      value: bankSynced,
                      onChanged: (value) {
                        setDialogState(() {
                          bankSynced = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(amountController.text.trim());
                    if (sourceController.text.trim().isEmpty ||
                        amount == null ||
                        amount <= 0) {
                      _showMessage('Enter valid source and amount.');
                      return;
                    }

                    setState(() {
                      _incomeRecords = [
                        IncomeRecord(
                          source: sourceController.text.trim(),
                          category: category,
                          amount: amount,
                          recordedOn: DateTime.now(),
                          bankSynced: bankSynced,
                        ),
                        ..._incomeRecords,
                      ];
                    });

                    Navigator.of(context).pop();
                    _showMessage('Income entry added.');
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddExpenseDialog() async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    String category = 'Food';
    bool recurring = false;
    bool bankSynced = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Expense Entry'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Amount'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: category,
                      items: const [
                        DropdownMenuItem(value: 'Food', child: Text('Food')),
                        DropdownMenuItem(value: 'Rent', child: Text('Rent')),
                        DropdownMenuItem(
                            value: 'Transport', child: Text('Transport')),
                        DropdownMenuItem(
                            value: 'Entertainment',
                            child: Text('Entertainment')),
                        DropdownMenuItem(value: 'Bills', child: Text('Bills')),
                        DropdownMenuItem(
                            value: 'Shopping', child: Text('Shopping')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          category = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Recurring expense'),
                      value: recurring,
                      onChanged: (value) {
                        setDialogState(() {
                          recurring = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Imported from bank sync'),
                      value: bankSynced,
                      onChanged: (value) {
                        setDialogState(() {
                          bankSynced = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(amountController.text.trim());
                    if (titleController.text.trim().isEmpty ||
                        amount == null ||
                        amount <= 0) {
                      _showMessage('Enter valid title and amount.');
                      return;
                    }

                    setState(() {
                      _expenseRecords = [
                        ExpenseRecord(
                          title: titleController.text.trim(),
                          category: category,
                          amount: amount,
                          spentOn: DateTime.now(),
                          recurring: recurring,
                          bankSynced: bankSynced,
                        ),
                        ..._expenseRecords,
                      ];
                    });

                    Navigator.of(context).pop();
                    _showMessage('Expense entry added.');
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddSavingsGoalDialog() async {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final currentController = TextEditingController();
    final transferController = TextEditingController();

    DateTime targetDate = DateTime.now().add(const Duration(days: 180));

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Savings Goal'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Goal name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: targetController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Target amount'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: currentController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Current saved amount'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: transferController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Suggested monthly auto transfer',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Target date'),
                      subtitle: Text(_dateLabel(targetDate)),
                      trailing: const Icon(Icons.calendar_month_rounded),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: targetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2032),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            targetDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final target =
                        double.tryParse(targetController.text.trim());
                    final current =
                        double.tryParse(currentController.text.trim());
                    final transfer =
                        double.tryParse(transferController.text.trim());

                    if (nameController.text.trim().isEmpty ||
                        target == null ||
                        current == null ||
                        transfer == null ||
                        target <= 0 ||
                        current < 0 ||
                        transfer <= 0) {
                      _showMessage('Enter valid goal details.');
                      return;
                    }

                    setState(() {
                      _savingsGoals = [
                        SavingsGoal(
                          name: nameController.text.trim(),
                          targetAmount: target,
                          currentAmount: current,
                          targetDate: targetDate,
                          suggestedAutoTransfer: transfer,
                        ),
                        ..._savingsGoals,
                      ];
                    });

                    Navigator.of(context).pop();
                    _showMessage('Savings goal created.');
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Current password'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Confirm password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (oldController.text.isEmpty ||
                    newController.text.length < 8) {
                  _showMessage(
                      'Use a valid current password and a new password of at least 8 chars.');
                  return;
                }
                if (newController.text != confirmController.text) {
                  _showMessage('New password and confirmation do not match.');
                  return;
                }

                Navigator.of(context).pop();
                _showMessage('Password updated successfully.');
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _saveProfile() {
    setState(() {
      _profile = _profile.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
    });

    _showMessage('Profile settings saved.');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1080;
        final hideSidebar = _selectedSection == 1 ||
            _selectedSection == 6 ||
            _selectedSection == 7 ||
            _selectedSection == 8 ||
            _selectedSection == 9;
        final sectionLabel = userDashboardSections[_selectedSection].label;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F6FB),
          appBar: isDesktop
              ? null
              : AppBar(
                  backgroundColor: Colors.white,
                  scrolledUnderElevation: 0.5,
                  leading: hideSidebar
                      ? IconButton(
                          onPressed: () => setState(() => _selectedSection = 0),
                          icon: const Icon(Icons.arrow_back_rounded),
                        )
                      : null,
                  title: Text(sectionLabel),
                  actions: [
                    IconButton(
                      onPressed: () => setState(() => _selectedSection = 1),
                      icon: const Icon(Icons.person_outline_rounded),
                    ),
                  ],
                ),
          drawer: (isDesktop || hideSidebar)
              ? null
              : Drawer(
                  child: SafeArea(
                    child: _buildSidebar(compact: true),
                  ),
                ),
          body: SafeArea(
            child: Row(
              children: [
                if (isDesktop && !hideSidebar)
                  Container(
                    width: 260,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(color: Color(0xFFE3EBF4)),
                      ),
                    ),
                    child: _buildSidebar(compact: false),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isDesktop ? 24 : 16,
                      16,
                      isDesktop ? 24 : 16,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hideSidebar)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  setState(() => _selectedSection = 0),
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: const Text('Back to Dashboard Sections'),
                            ),
                          ),
                        _buildTopBanner(),
                        const SizedBox(height: 16),
                        _buildSectionContent(constraints.maxWidth),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebar({required bool compact}) {
    final visibleSidebarSections =
        userDashboardSections.asMap().entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(compact ? 16 : 20, 18, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MoneyPilot',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F355B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _profile.name,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: visibleSidebarSections.length,
            itemBuilder: (context, index) {
              final item = visibleSidebarSections[index].value;
              final targetIndex = visibleSidebarSections[index].key;
              final selected = targetIndex == _selectedSection;
              return Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: InkWell(
                  onTap: () {
                    if (item.label == 'Investments') {
                      if (compact) {
                        Navigator.of(context).pop();
                      }
                      Navigator.of(this.context).push(
                        MaterialPageRoute(
                          builder: (_) => const UserInvestmentsPage(),
                        ),
                      );
                      return;
                    }

                    if (item.label == 'Transactions') {
                      if (compact) {
                        Navigator.of(context).pop();
                      }
                      Navigator.of(this.context).push(
                        MaterialPageRoute(
                          builder: (_) => const TransactionsPage(),
                        ),
                      );
                      return;
                    }

                    if (item.label == 'Calendar') {
                      if (compact) {
                        Navigator.of(context).pop();
                      }
                      Navigator.of(this.context).push(
                        MaterialPageRoute(
                          builder: (_) => const CalendarPage(),
                        ),
                      );
                      return;
                    }

                    if (item.label == 'Profile') {
                      if (compact) {
                        Navigator.of(context).pop();
                      }
                      Navigator.of(this.context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfilePage(),
                        ),
                      );
                      return;
                    }

                    if (item.label == 'Reports') {
                      if (compact) {
                        Navigator.of(context).pop();
                      }
                      Navigator.of(this.context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReportsPage(),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _selectedSection = targetIndex;
                    });
                    if (!compact) return;
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE8F0FE)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          color: selected
                              ? const Color(0xFF1A73E8)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: selected
                                  ? const Color(0xFF1A73E8)
                                  : const Color(0xFF334155),
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopBanner() {
    final now = DateTime.now();
    final month = _dateLabel(DateTime(now.year, now.month, 1)).split(' ').first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F355B), Color(0xFF1A73E8), Color(0xFF2FA98F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A73E8).withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${_profile.name.split(' ').first}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track income, spending, budgets, goals, and investments in one place.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _heroPill('Month', month),
              _heroPill('Income', _money(_totalIncome)),
              _heroPill('Expenses', _money(_totalExpense)),
              _heroPill('Cash Flow', _money(_netCashFlow)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSectionContent(double width) {
    switch (_selectedSection) {
      case 0:
        return _buildOverviewSection(width);
      case 1:
        return _buildProfileSection(width);
      case 2:
        return _buildIncomeSection(width);
      case 3:
        return _buildExpenseSection(width);
      case 4:
        return _buildBudgetingSection(width);
      case 5:
        return _buildSavingsSection(width);
      case 6:
        return _buildInvestmentsSection(width);
      case 7:
      case 8:
        return _buildOverviewSection(width);
      case 9:
        return _buildReportsSection(width);
      default:
        return _buildOverviewSection(width);
    }
  }

  Widget _buildOverviewSection(double width) {
    final isWide = width > 1100;

    final cards = [
      _MetricCardData(
        title: 'Net Cash Flow',
        value: _money(_netCashFlow),
        hint: 'Income minus expenses',
        color: const Color(0xFF1A73E8),
        icon: Icons.currency_exchange_rounded,
      ),
      _MetricCardData(
        title: 'Budget Used',
        value: '${(_selectedBudgetPlan.utilization * 100).toStringAsFixed(0)}%',
        hint: '${_selectedBudgetPlan.cadence} plan utilization',
        color: const Color(0xFFF29900),
        icon: Icons.account_balance_wallet_rounded,
      ),
      _MetricCardData(
        title: 'Savings Goals',
        value: '${_savingsGoals.length}',
        hint: 'Active savings targets',
        color: const Color(0xFF0F9D58),
        icon: Icons.savings_rounded,
      ),
      _MetricCardData(
        title: 'Portfolio Return',
        value: '${_portfolioReturnPercent.toStringAsFixed(1)}%',
        hint: _money(_portfolioReturnAmount),
        color: _portfolioReturnAmount >= 0
            ? const Color(0xFF0F9D58)
            : const Color(0xFFDB4437),
        icon: Icons.candlestick_chart_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricGrid(cards, width),
        const SizedBox(height: 14),
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildQuickActionsCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildNearLimitAlertsCard()),
            ],
          )
        else ...[
          _buildQuickActionsCard(),
          const SizedBox(height: 12),
          _buildNearLimitAlertsCard(),
        ],
      ],
    );
  }

  Widget _buildQuickActionsCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: _showAddIncomeDialog,
                icon: const Icon(Icons.add_card_rounded),
                label: const Text('Add Income'),
              ),
              FilledButton.tonalIcon(
                onPressed: _showAddExpenseDialog,
                icon: const Icon(Icons.post_add_rounded),
                label: const Text('Add Expense'),
              ),
              FilledButton.tonalIcon(
                onPressed: _showAddSavingsGoalDialog,
                icon: const Icon(Icons.flag_rounded),
                label: const Text('Create Goal'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => setState(() => _selectedSection = 9),
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('View Reports'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNearLimitAlertsCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget Alerts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (_nearLimitBudgets.isEmpty)
            const Text(
              'All category budgets are in a healthy range.',
              style: TextStyle(color: Color(0xFF64748B)),
            )
          else
            ..._nearLimitBudgets.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF5D08A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFF29900)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item.category}: ${_money(item.spent)} of ${_money(item.limit)} used (${(item.utilization * 100).toStringAsFixed(0)}%).',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(double width) {
    final isWide = width > 1050;

    final basicProfile = _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _profile.currencyPreference,
            items: supportedCurrencies
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _profile = _profile.copyWith(currencyPreference: value);
              });
            },
            decoration: const InputDecoration(
              labelText: 'Currency Preference',
              prefixIcon: Icon(Icons.currency_exchange_rounded),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Basic Details'),
            ),
          ),
        ],
      ),
    );

    final securityPanel = _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Two-factor Authentication (2FA)'),
            value: _profile.twoFactorEnabled,
            onChanged: (value) {
              setState(() {
                _profile = _profile.copyWith(twoFactorEnabled: value);
              });
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Biometric Login'),
            value: _profile.biometricEnabled,
            onChanged: (value) {
              setState(() {
                _profile = _profile.copyWith(biometricEnabled: value);
              });
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Automatic Bank API Import'),
            subtitle: const Text('Optional auto-sync for income and expenses'),
            value: _profile.bankImportEnabled,
            onChanged: (value) {
              setState(() {
                _profile = _profile.copyWith(bankImportEnabled: value);
              });
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _showChangePasswordDialog,
            icon: const Icon(Icons.lock_reset_rounded),
            label: const Text('Change Password'),
          ),
        ],
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: basicProfile),
          const SizedBox(width: 12),
          Expanded(child: securityPanel),
        ],
      );
    }

    return Column(
      children: [
        basicProfile,
        const SizedBox(height: 12),
        securityPanel,
      ],
    );
  }

  Widget _buildIncomeSection(double width) {
    final isWide = width > 1100;

    final summary = _buildMetricGrid(
      [
        _MetricCardData(
          title: 'Salary',
          value: _money(
            _incomeRecords
                .where((item) => item.source.toLowerCase().contains('salary'))
                .fold<double>(0, (sum, item) => sum + item.amount),
          ),
          hint: 'Primary fixed income',
          color: const Color(0xFF1A73E8),
          icon: Icons.payments_rounded,
        ),
        _MetricCardData(
          title: 'Freelance',
          value: _money(_variableIncome),
          hint: 'Variable category income',
          color: const Color(0xFFF29900),
          icon: Icons.laptop_mac_rounded,
        ),
        _MetricCardData(
          title: 'Investments',
          value: _money(_investmentIncome),
          hint: 'Dividend and gains cashflow',
          color: const Color(0xFF0F9D58),
          icon: Icons.trending_up_rounded,
        ),
        _MetricCardData(
          title: 'Fixed vs Variable',
          value:
              '${_fixedIncome > 0 ? ((_fixedIncome / _totalIncome) * 100).toStringAsFixed(0) : '0'}% fixed',
          hint: _money(_fixedIncome),
          color: const Color(0xFF0F355B),
          icon: Icons.balance_rounded,
        ),
      ],
      width,
    );

    final records = _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Income Tracking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showAddIncomeDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Income'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Track salary, freelance, and investment income. Categorize fixed and variable sources and optionally sync from bank APIs.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          ..._incomeRecords.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.source,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.category} | ${_dateLabel(item.recordedOn)} | ${item.bankSynced ? 'Bank sync' : 'Manual entry'}',
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _money(item.amount),
                    style: const TextStyle(
                      color: Color(0xFF0F9D58),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final split = _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Income Mix',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _progressRow('Fixed Income', _fixedIncome, _totalIncome,
              const Color(0xFF1A73E8)),
          const SizedBox(height: 10),
          _progressRow('Variable Income', _variableIncome, _totalIncome,
              const Color(0xFFF29900)),
          const SizedBox(height: 10),
          _progressRow('Investments', _investmentIncome, _totalIncome,
              const Color(0xFF0F9D58)),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.sync_alt_rounded),
            title: const Text('Automatic Bank API Import'),
            subtitle: Text(_profile.bankImportEnabled ? 'Enabled' : 'Disabled'),
            trailing: Switch(
              value: _profile.bankImportEnabled,
              onChanged: (value) {
                setState(() {
                  _profile = _profile.copyWith(bankImportEnabled: value);
                });
              },
            ),
          ),
        ],
      ),
    );

    if (isWide) {
      return Column(
        children: [
          summary,
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: records),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: split),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        summary,
        const SizedBox(height: 12),
        records,
        const SizedBox(height: 12),
        split,
      ],
    );
  }

  Widget _buildExpenseSection(double width) {
    final isWide = width > 1100;

    final summary = _buildMetricGrid(
      [
        _MetricCardData(
          title: 'Total Expenses',
          value: _money(_totalExpense),
          hint: 'Tracked expenses in current period',
          color: const Color(0xFFDB4437),
          icon: Icons.money_off_csred_rounded,
        ),
        _MetricCardData(
          title: 'Today Spending',
          value: _money(_todayExpense),
          hint: 'Daily spending entry',
          color: const Color(0xFFF29900),
          icon: Icons.today_rounded,
        ),
        _MetricCardData(
          title: 'Recurring',
          value: '${_recurringExpenses.length} items',
          hint: 'Subscriptions and bills',
          color: const Color(0xFF1A73E8),
          icon: Icons.replay_circle_filled_rounded,
        ),
        _MetricCardData(
          title: 'Synced Entries',
          value: '${_expenseRecords.where((item) => item.bankSynced).length}',
          hint: 'Imported from bank sync',
          color: const Color(0xFF0F9D58),
          icon: Icons.sync_rounded,
        ),
      ],
      width,
    );

    final expenseList = _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Expense Tracking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showAddExpenseDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Expense'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Capture daily spending manually or through bank sync and classify expenses by category.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          ..._expenseRecords.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.category} | ${_dateLabel(item.spentOn)} | ${item.recurring ? 'Recurring' : 'One-time'} | ${item.bankSynced ? 'Bank sync' : 'Manual'}',
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _money(item.amount),
                    style: const TextStyle(
                      color: Color(0xFFDB4437),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final categories = _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ..._expenseCategoryTotals.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        _money(entry.value),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value:
                          _totalExpense == 0 ? 0 : entry.value / _totalExpense,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE6ECF3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          _categoryColor(entry.key)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Recurring Expenses',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ..._recurringExpenses.take(4).map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(Icons.autorenew_rounded, size: 18),
                  title: Text(item.title),
                  subtitle: Text('${item.category} | ${_money(item.amount)}'),
                ),
              ),
        ],
      ),
    );

    if (isWide) {
      return Column(
        children: [
          summary,
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: expenseList),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: categories),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        summary,
        const SizedBox(height: 12),
        expenseList,
        const SizedBox(height: 12),
        categories,
      ],
    );
  }

  Widget _buildBudgetingSection(double width) {
    final plan = _selectedBudgetPlan;

    return Column(
      children: [
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Budgeting',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Configure monthly or weekly budgets, allocate category limits, and get alerts before overspending.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ['Monthly', 'Weekly'].map((cadence) {
                  final selected = cadence == _selectedBudgetCadence;
                  return ChoiceChip(
                    label: Text(cadence),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        _selectedBudgetCadence = cadence;
                      });
                    },
                    selectedColor: const Color(0xFFE8F0FE),
                    labelStyle: TextStyle(
                      color: selected
                          ? const Color(0xFF1A73E8)
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plan.cadence} Budget: ${_money(plan.totalSpent)} / ${_money(plan.totalLimit)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: plan.utilization.clamp(0.0, 1.0),
                        minHeight: 9,
                        backgroundColor: const Color(0xFFE6ECF3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          plan.utilization >= 0.9
                              ? const Color(0xFFDB4437)
                              : const Color(0xFF1A73E8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category-wise Allocation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...plan.categories.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.category,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '${_money(item.spent)} / ${_money(item.limit)}',
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: item.utilization.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE6ECF3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            item.utilization >= 0.9
                                ? const Color(0xFFDB4437)
                                : item.utilization >= 0.8
                                    ? const Color(0xFFF29900)
                                    : const Color(0xFF0F9D58),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_nearLimitBudgets.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF5D08A)),
                  ),
                  child: Text(
                    'Alert: You are nearing limits in ${_nearLimitBudgets.map((item) => item.category).join(', ')}.',
                    style: const TextStyle(
                      color: Color(0xFF8A5A00),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsSection(double width) {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Savings and Goals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showAddSavingsGoalDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Goal'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Create and track savings goals like vacation, emergency fund, and retirement with suggested auto transfers.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          ..._savingsGoals.map(
            (goal) {
              final progress = goal.progress.clamp(0.0, 1.0).toDouble();
              final remaining =
                  math.max(0.0, goal.targetAmount - goal.currentAmount);
              final daysLeft =
                  goal.targetDate.difference(DateTime.now()).inDays;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Color(0xFF1A73E8),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Saved ${_money(goal.currentAmount)} of ${_money(goal.targetAmount)} | Remaining ${_money(remaining)}',
                      style: const TextStyle(
                          color: Color(0xFF64748B), fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE6ECF3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF1A73E8)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _tag('Target: ${_dateLabel(goal.targetDate)}'),
                        _tag(
                          daysLeft >= 0
                              ? 'Days left: $daysLeft'
                              : 'Target date passed',
                        ),
                        _tag(
                            'Suggested auto transfer: ${_money(goal.suggestedAutoTransfer)} / month'),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentsSection(double width) {
    final isWide = width > 1100;

    final summary = _buildMetricGrid(
      [
        _MetricCardData(
          title: 'Portfolio Value',
          value: _money(_portfolioCurrent),
          hint: 'Current valuation',
          color: const Color(0xFF1A73E8),
          icon: Icons.account_balance_rounded,
        ),
        _MetricCardData(
          title: 'Invested Amount',
          value: _money(_portfolioInvested),
          hint: 'Total capital deployed',
          color: const Color(0xFF0F355B),
          icon: Icons.savings_rounded,
        ),
        _MetricCardData(
          title: 'Performance',
          value: '${_portfolioReturnPercent.toStringAsFixed(2)}%',
          hint: _money(_portfolioReturnAmount),
          color: _portfolioReturnAmount >= 0
              ? const Color(0xFF0F9D58)
              : const Color(0xFFDB4437),
          icon: Icons.trending_up_rounded,
        ),
        _MetricCardData(
          title: 'Risk Analysis',
          value: _riskLabel,
          hint: 'Score ${_riskScore.toStringAsFixed(2)} / 3.00',
          color: const Color(0xFFF29900),
          icon: Icons.shield_outlined,
        ),
      ],
      width,
    );

    final holdings = _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ...seedInvestmentHoldings.map(
            (holding) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          holding.assetName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${holding.assetType} | Risk: ${holding.riskLevel}',
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _money(holding.currentValue),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${holding.returnPercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: holding.returnAmount >= 0
                              ? const Color(0xFF0F9D58)
                              : const Color(0xFFDB4437),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final riskCard = _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Risk Analysis',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            _riskLabel,
            style: const TextStyle(
              color: Color(0xFF0F355B),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'The score is based on distribution of holdings across low, medium, and high-risk assets.',
            style: TextStyle(color: Colors.blueGrey.shade700),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (_riskScore / 3.0).clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: const Color(0xFFE6ECF3),
              valueColor: AlwaysStoppedAnimation<Color>(
                _riskScore <= 1.4
                    ? const Color(0xFF0F9D58)
                    : _riskScore <= 2.2
                        ? const Color(0xFFF29900)
                        : const Color(0xFFDB4437),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Risk Score: ${_riskScore.toStringAsFixed(2)} / 3.00',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );

    final investmentsCore = isWide
        ? Column(
            children: [
              summary,
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: holdings),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: riskCard),
                ],
              ),
            ],
          )
        : Column(
            children: [
              summary,
              const SizedBox(height: 12),
              holdings,
              const SizedBox(height: 12),
              riskCard,
            ],
          );

    return investmentsCore;
  }

  Widget _buildReportsSection(double width) {
    final latestMonth =
        seedMonthlyReportSeries.isEmpty ? null : seedMonthlyReportSeries.last;
    final isWide = width > 1100;

    final summaryCards = _buildMetricGrid(
      [
        _MetricCardData(
          title: 'Annual Income',
          value: _money(_annualIncome),
          hint: 'Last 12 months',
          color: const Color(0xFF0F9D58),
          icon: Icons.trending_up_rounded,
        ),
        _MetricCardData(
          title: 'Annual Expenses',
          value: _money(_annualExpense),
          hint: 'Last 12 months',
          color: const Color(0xFFDB4437),
          icon: Icons.trending_down_rounded,
        ),
        _MetricCardData(
          title: 'Annual Savings',
          value: _money(_annualIncome - _annualExpense),
          hint: 'Income minus expenses',
          color: const Color(0xFF1A73E8),
          icon: Icons.savings_rounded,
        ),
        _MetricCardData(
          title: 'Avg Savings Rate',
          value: '${_averageSavingsRate.toStringAsFixed(1)}%',
          hint: latestMonth == null
              ? 'No report data'
              : 'Latest month: ${latestMonth.label}',
          color: const Color(0xFF0F355B),
          icon: Icons.insights_rounded,
        ),
      ],
      width,
    );

    final chartRow = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildExpensePieCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildTrendCard()),
            ],
          )
        : Column(
            children: [
              _buildExpensePieCard(),
              const SizedBox(height: 12),
              _buildTrendCard(),
            ],
          );

    return Column(
      children: [
        summaryCards,
        const SizedBox(height: 12),
        chartRow,
        const SizedBox(height: 12),
        _buildMonthlySummaryTable(),
      ],
    );
  }

  Widget _buildExpensePieCard() {
    final totals = _expenseCategoryTotals;
    final total = totals.values.fold<double>(0, (sum, value) => sum + value);

    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      const Color(0xFF1A73E8),
      const Color(0xFF0F9D58),
      const Color(0xFFF29900),
      const Color(0xFF7C3AED),
      const Color(0xFFDB4437),
      const Color(0xFF0F355B),
    ];

    final segments = <_PieSegment>[];
    for (int i = 0; i < entries.length; i++) {
      segments.add(
        _PieSegment(
          label: entries[i].key,
          value: entries[i].value,
          color: colors[i % colors.length],
        ),
      );
    }

    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Distribution',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pie chart of expense categories',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          if (segments.isEmpty)
            const Text('No expense data available.')
          else
            Row(
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(
                    painter: _ExpensePiePainter(segments: segments),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: segments
                        .map(
                          (segment) => Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: segment.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    segment.label,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  total == 0
                                      ? '0%'
                                      : '${(segment.value / total * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTrendCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Income vs Expense Trend',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Trend analysis across monthly reports',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CustomPaint(
              painter: _TrendChartPainter(series: seedMonthlyReportSeries),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              _LegendDot(color: Color(0xFF0F9D58), label: 'Income'),
              SizedBox(width: 12),
              _LegendDot(color: Color(0xFFDB4437), label: 'Expense'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryTable() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Summaries',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Month')),
                DataColumn(label: Text('Income')),
                DataColumn(label: Text('Expense')),
                DataColumn(label: Text('Savings')),
                DataColumn(label: Text('Savings %')),
              ],
              rows: seedMonthlyReportSeries.map((point) {
                final savings = point.income - point.expense;
                final rate =
                    point.income == 0 ? 0 : (savings / point.income) * 100;
                return DataRow(
                  cells: [
                    DataCell(Text(point.label)),
                    DataCell(Text(_money(point.income))),
                    DataCell(Text(_money(point.expense))),
                    DataCell(
                      Text(
                        _money(savings),
                        style: TextStyle(
                          color: savings >= 0
                              ? const Color(0xFF0F9D58)
                              : const Color(0xFFDB4437),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DataCell(Text('${rate.toStringAsFixed(1)}%')),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(List<_MetricCardData> cards, double width) {
    int columns = 4;
    if (width < 1200) {
      columns = 2;
    }
    if (width < 700) {
      columns = 1;
    }

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 132,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];
        return _panel(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: card.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(card.icon, color: card.color),
                  ),
                  const Spacer(),
                  Text(
                    card.title,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                card.value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                card.hint,
                style: TextStyle(
                  color: card.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _progressRow(String label, double value, double total, Color color) {
    final ratio = total == 0 ? 0.0 : value / total;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              _money(value),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFFE6ECF3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFF1A73E8);
      case 'Rent':
        return const Color(0xFFDB4437);
      case 'Transport':
        return const Color(0xFFF29900);
      case 'Entertainment':
        return const Color(0xFF7C3AED);
      case 'Bills':
        return const Color(0xFF0F9D58);
      default:
        return const Color(0xFF0F355B);
    }
  }

  Widget _panel({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EBF4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MetricCardData {
  const _MetricCardData({
    required this.title,
    required this.value,
    required this.hint,
    required this.color,
    required this.icon,
  });

  final String title;
  final String value;
  final String hint;
  final Color color;
  final IconData icon;
}

class _PieSegment {
  const _PieSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _ExpensePiePainter extends CustomPainter {
  const _ExpensePiePainter({required this.segments});

  final List<_PieSegment> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (sum, item) => sum + item.value);
    if (total <= 0) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final segment in segments) {
      final sweep = (segment.value / total) * math.pi * 2;
      paint.color = segment.color;
      canvas.drawArc(rect, startAngle, sweep, true, paint);
      startAngle += sweep;
    }

    final holePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.56, holePaint);
  }

  @override
  bool shouldRepaint(covariant _ExpensePiePainter oldDelegate) {
    return oldDelegate.segments != segments;
  }
}

class _TrendChartPainter extends CustomPainter {
  const _TrendChartPainter({required this.series});

  final List<ReportSeriesPoint> series;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.length < 2) {
      return;
    }

    const leftPadding = 20.0;
    const rightPadding = 12.0;
    const topPadding = 16.0;
    const bottomPadding = 22.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;
    if (chartWidth <= 0 || chartHeight <= 0) {
      return;
    }

    double maxValue = 0;
    for (final point in series) {
      maxValue = math.max(maxValue, math.max(point.income, point.expense));
    }
    if (maxValue <= 0) {
      maxValue = 1;
    }

    final axisPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(leftPadding, topPadding + chartHeight),
      axisPaint,
    );
    canvas.drawLine(
      Offset(leftPadding, topPadding + chartHeight),
      Offset(leftPadding + chartWidth, topPadding + chartHeight),
      axisPaint,
    );

    final incomePath = Path();
    final expensePath = Path();

    final incomePaint = Paint()
      ..color = const Color(0xFF0F9D58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    final expensePaint = Paint()
      ..color = const Color(0xFFDB4437)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    final dotIncome = Paint()..color = const Color(0xFF0F9D58);
    final dotExpense = Paint()..color = const Color(0xFFDB4437);

    for (int i = 0; i < series.length; i++) {
      final x = leftPadding + (i / (series.length - 1)) * chartWidth;
      final incomeY = topPadding +
          chartHeight -
          ((series[i].income / maxValue) * chartHeight);
      final expenseY = topPadding +
          chartHeight -
          ((series[i].expense / maxValue) * chartHeight);

      if (i == 0) {
        incomePath.moveTo(x, incomeY);
        expensePath.moveTo(x, expenseY);
      } else {
        incomePath.lineTo(x, incomeY);
        expensePath.lineTo(x, expenseY);
      }

      canvas.drawCircle(Offset(x, incomeY), 2.8, dotIncome);
      canvas.drawCircle(Offset(x, expenseY), 2.8, dotExpense);
    }

    canvas.drawPath(incomePath, incomePaint);
    canvas.drawPath(expensePath, expensePaint);

    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < series.length; i += 2) {
      final x = leftPadding + (i / (series.length - 1)) * chartWidth;
      labelPainter.text = TextSpan(
        text: series[i].label,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
      );
      labelPainter.layout();
      labelPainter.paint(canvas, Offset(x - 8, topPadding + chartHeight + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.series != series;
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
