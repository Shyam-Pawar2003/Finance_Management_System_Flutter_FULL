import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RunPayrollDashboardPage extends StatefulWidget {
  const RunPayrollDashboardPage({super.key});

  @override
  State<RunPayrollDashboardPage> createState() =>
      _RunPayrollDashboardPageState();
}

class _RunPayrollDashboardPageState extends State<RunPayrollDashboardPage> {
  String _selectedMonth = _months[DateTime.now().month - 1];
  String _selectedYear = DateTime.now().year.toString();

  bool _includeBonus = true;
  bool _emailPayslips = true;
  bool _requiresFinalApproval = true;
  bool _isRunningPayroll = false;

  final Set<String> _excludedEmployeeIds = <String>{};
  final List<_PayrollRunRecord> _runHistory = [];

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<_PayrollEmployee> _employees = const [
    _PayrollEmployee(
      id: 'EMP-1001',
      name: 'Aarav Mehta',
      department: 'Finance',
      baseSalary: 5800,
      bonus: 420,
      deduction: 480,
    ),
    _PayrollEmployee(
      id: 'EMP-1002',
      name: 'Riya Shah',
      department: 'Accounts',
      baseSalary: 5200,
      bonus: 300,
      deduction: 430,
    ),
    _PayrollEmployee(
      id: 'EMP-1003',
      name: 'Dev Patel',
      department: 'Payroll',
      baseSalary: 6100,
      bonus: 500,
      deduction: 510,
    ),
    _PayrollEmployee(
      id: 'EMP-1004',
      name: 'Mira Joshi',
      department: 'Treasury',
      baseSalary: 5600,
      bonus: 380,
      deduction: 470,
    ),
    _PayrollEmployee(
      id: 'EMP-1005',
      name: 'Yash Rao',
      department: 'Compliance',
      baseSalary: 5400,
      bonus: 260,
      deduction: 445,
    ),
  ];

  List<_PayrollEmployee> get _includedEmployees {
    return _employees
        .where((employee) => !_excludedEmployeeIds.contains(employee.id))
        .toList();
  }

  double _grossFor(_PayrollEmployee employee) {
    return employee.baseSalary + (_includeBonus ? employee.bonus : 0);
  }

  double _taxFor(_PayrollEmployee employee) {
    return _grossFor(employee) * 0.12;
  }

  double _netFor(_PayrollEmployee employee) {
    return _grossFor(employee) - _taxFor(employee) - employee.deduction;
  }

  double get _grossTotal {
    return _includedEmployees.fold<double>(0, (sum, employee) {
      return sum + _grossFor(employee);
    });
  }

  double get _taxTotal {
    return _includedEmployees.fold<double>(0, (sum, employee) {
      return sum + _taxFor(employee);
    });
  }

  double get _deductionTotal {
    return _includedEmployees.fold<double>(0, (sum, employee) {
      return sum + employee.deduction;
    });
  }

  double get _netTotal {
    return _includedEmployees.fold<double>(0, (sum, employee) {
      return sum + _netFor(employee);
    });
  }

  String _money(double value) {
    final rounded = value.toStringAsFixed(2);
    final parts = rounded.split('.');
    final whole = parts[0];
    final decimal = parts[1];
    final buffer = StringBuffer();

    for (var i = 0; i < whole.length; i++) {
      final reverseIndex = whole.length - i;
      buffer.write(whole[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return '\$${buffer.toString()}.$decimal';
  }

  String _timestamp(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '$day/$month/$year $hour:$minute $suffix';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _toggleEmployeeInclusion(String employeeId, bool include) {
    setState(() {
      if (include) {
        _excludedEmployeeIds.remove(employeeId);
      } else {
        _excludedEmployeeIds.add(employeeId);
      }
    });
  }

  void _previewPayroll() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Payroll Preview - $_selectedMonth $_selectedYear'),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Employees Included: ${_includedEmployees.length}'),
                  const SizedBox(height: 6),
                  Text('Gross: ${_money(_grossTotal)}'),
                  Text('Tax: ${_money(_taxTotal)}'),
                  Text('Deductions: ${_money(_deductionTotal)}'),
                  Text(
                    'Net Payout: ${_money(_netTotal)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 6),
                  const Text(
                    'Employee Breakdown',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ..._includedEmployees.map(
                    (employee) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${employee.name} (${employee.id}) - Net ${_money(_netFor(employee))}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _runPayroll() async {
    if (_includedEmployees.isEmpty) {
      _showMessage('Please include at least one employee for payroll.');
      return;
    }

    if (_isRunningPayroll) return;

    var canProceed = true;
    if (_requiresFinalApproval) {
      canProceed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Final Approval Required'),
              content: Text(
                'Run payroll for ${_includedEmployees.length} employees for $_selectedMonth $_selectedYear?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Approve & Run'),
                ),
              ],
            ),
          ) ??
          false;
    }

    if (!canProceed) return;

    setState(() {
      _isRunningPayroll = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1300));

    final run = _PayrollRunRecord(
      runId:
          'PR-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      period: '$_selectedMonth $_selectedYear',
      employeeCount: _includedEmployees.length,
      netPayout: _netTotal,
      ranAt: DateTime.now(),
      emailSlips: _emailPayslips,
    );

    setState(() {
      _runHistory.insert(0, run);
      _isRunningPayroll = false;
    });

    _showMessage(
      'Payroll run ${run.runId} completed. Net payout ${_money(run.netPayout)}.',
    );
  }

  Future<void> _copyRunSummary(_PayrollRunRecord run) async {
    final summary = StringBuffer()
      ..writeln('Payroll Run Summary')
      ..writeln('Run ID: ${run.runId}')
      ..writeln('Period: ${run.period}')
      ..writeln('Employees: ${run.employeeCount}')
      ..writeln('Net Payout: ${_money(run.netPayout)}')
      ..writeln('Email Payslips: ${run.emailSlips ? 'Yes' : 'No'}')
      ..writeln('Executed: ${_timestamp(run.ranAt)}');

    await Clipboard.setData(ClipboardData(text: summary.toString()));
    _showMessage('Payroll run summary copied to clipboard.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text(
          'Run Payroll',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(),
              const SizedBox(height: 14),
              _buildConfigPanel(),
              const SizedBox(height: 14),
              _buildEmployeePanel(),
              const SizedBox(height: 14),
              _buildActionsPanel(),
              const SizedBox(height: 14),
              _buildHistoryPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F355B), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          _heroChip('Included', '${_includedEmployees.length}'),
          _heroChip('Gross', _money(_grossTotal)),
          _heroChip('Tax', _money(_taxTotal)),
          _heroChip('Net Payout', _money(_netTotal)),
        ],
      ),
    );
  }

  Widget _heroChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigPanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payroll Configuration',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<String>(
                  value: _selectedMonth,
                  decoration: const InputDecoration(
                    labelText: 'Month',
                    filled: true,
                    fillColor: Color(0xFFF8FAFC),
                  ),
                  items: _months
                      .map(
                        (month) => DropdownMenuItem(
                          value: month,
                          child: Text(month),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMonth = value;
                      });
                    }
                  },
                ),
              ),
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<String>(
                  value: _selectedYear,
                  decoration: const InputDecoration(
                    labelText: 'Year',
                    filled: true,
                    fillColor: Color(0xFFF8FAFC),
                  ),
                  items: List.generate(5, (index) {
                    final year = (DateTime.now().year - 1 + index).toString();
                    return DropdownMenuItem(value: year, child: Text(year));
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedYear = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Include monthly bonus'),
            value: _includeBonus,
            onChanged: (value) {
              setState(() {
                _includeBonus = value;
              });
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Email payslips after run'),
            value: _emailPayslips,
            onChanged: (value) {
              setState(() {
                _emailPayslips = value;
              });
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Require final approval before run'),
            value: _requiresFinalApproval,
            onChanged: (value) {
              setState(() {
                _requiresFinalApproval = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeePanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Employee Selection',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${_includedEmployees.length}/${_employees.length} included',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._employees.map(
            (employee) {
              final included = !_excludedEmployeeIds.contains(employee.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: included,
                      onChanged: (value) {
                        _toggleEmployeeInclusion(employee.id, value ?? false);
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${employee.name} (${employee.id})',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${employee.department} | Gross ${_money(_grossFor(employee))} | Net ${_money(_netFor(employee))}',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildActionsPanel() {
    return _panel(
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _previewPayroll,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Preview Payroll'),
          ),
          ElevatedButton.icon(
            onPressed: _isRunningPayroll ? null : _runPayroll,
            icon: _isRunningPayroll
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.play_arrow_rounded),
            label: Text(_isRunningPayroll ? 'Running...' : 'Run Payroll'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payroll Run History',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (_runHistory.isEmpty)
            const Text(
              'No payroll runs executed yet.',
              style: TextStyle(color: Color(0xFF64748B)),
            )
          else
            ..._runHistory.map(
              (run) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
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
                            '${run.runId} - ${run.period}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${run.employeeCount} employees | Net ${_money(run.netPayout)}',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Executed ${_timestamp(run.ranAt)}',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _copyRunSummary(run),
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EBF3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PayrollEmployee {
  const _PayrollEmployee({
    required this.id,
    required this.name,
    required this.department,
    required this.baseSalary,
    required this.bonus,
    required this.deduction,
  });

  final String id;
  final String name;
  final String department;
  final double baseSalary;
  final double bonus;
  final double deduction;
}

class _PayrollRunRecord {
  const _PayrollRunRecord({
    required this.runId,
    required this.period,
    required this.employeeCount,
    required this.netPayout,
    required this.ranAt,
    required this.emailSlips,
  });

  final String runId;
  final String period;
  final int employeeCount;
  final double netPayout;
  final DateTime ranAt;
  final bool emailSlips;
}
