import 'package:flutter/material.dart';
import '../models/member.dart';
import 'common.dart';

typedef RenewResult = ({int months, double amount, String method});

Future<RenewResult?> showRenewDialog(
  BuildContext context, {
  required List<PlanOption> plans,
  required int initialMonths,
  required double initialAmount,
}) {
  return showDialog<RenewResult>(
    context: context,
    builder: (_) => _RenewDialog(plans: plans, initialMonths: initialMonths, initialAmount: initialAmount),
  );
}

class _RenewDialog extends StatefulWidget {
  final List<PlanOption> plans;
  final int initialMonths;
  final double initialAmount;
  const _RenewDialog({required this.plans, required this.initialMonths, required this.initialAmount});

  @override
  State<_RenewDialog> createState() => _RenewDialogState();
}

class _RenewDialogState extends State<_RenewDialog> {
  late final TextEditingController months;
  late final TextEditingController amount;
  String method = 'Cash';
  String? error;

  @override
  void initState() {
    super.initState();
    months = TextEditingController(text: '${widget.initialMonths}');
    amount = TextEditingController(text: widget.initialAmount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    months.dispose();
    amount.dispose();
    super.dispose();
  }

  void _pick(PlanOption p) {
    setState(() {
      months.text = '${p.months}';
      amount.text = p.fee.toStringAsFixed(0);
      error = null;
    });
  }

  void _onMonths(String v) {
    final n = int.tryParse(v.trim());
    setState(() {
      error = null;
      if (n == null) return;
      final match = widget.plans.where((p) => p.months == n);
      if (match.isNotEmpty) amount.text = match.first.fee.toStringAsFixed(0);
    });
  }

  void _submit() {
    final mo = int.tryParse(months.text.trim());
    final amt = double.tryParse(amount.text.trim());
    if (mo == null || mo < 1 || mo > 120) {
      setState(() => error = 'Enter a valid number of months (1 to 120).');
      return;
    }
    if (amt == null || amt <= 0) {
      setState(() => error = 'Enter a valid amount greater than 0.');
      return;
    }
    Navigator.pop(context, (months: mo, amount: amt, method: method));
  }

  @override
  Widget build(BuildContext context) {
    final current = int.tryParse(months.text.trim());
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Renew Membership', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Pick a plan or type months and amount manually.', style: TextStyle(color: muted, fontSize: 12.5)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final p in widget.plans)
              ChoiceChip(
                label: Text('${p.label}  •  ${inr(p.fee)}'),
                selected: current == p.months,
                selectedColor: orange,
                onSelected: (_) => _pick(p),
              ),
          ]),
          const FieldLabel('Months', required: true),
          TextField(
            controller: months,
            keyboardType: TextInputType.number,
            onChanged: _onMonths,
            decoration: fieldDeco(icon: Icons.schedule, suffix: 'Month(s)', hint: 'e.g. 2'),
          ),
          const FieldLabel('Amount (₹)', required: true),
          TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() => error = null),
            decoration: fieldDeco(icon: Icons.currency_rupee_rounded, hint: 'Type amount'),
          ),
          const FieldLabel('Payment method'),
          Wrap(spacing: 8, children: [
            for (final k in kMethods)
              ChoiceChip(
                label: Text(k),
                selected: method == k,
                selectedColor: orange,
                onSelected: (_) => setState(() => method = k),
              ),
          ]),
          if (error != null) ErrorBanner(error!),
          const SizedBox(height: 18),
          PrimaryButton('Renew', icon: Icons.check_rounded, onPressed: _submit),
          const SizedBox(height: 10),
          CancelButton(onPressed: () => Navigator.pop(context)),
        ]),
      ),
    );
  }
}
