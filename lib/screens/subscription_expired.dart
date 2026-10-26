import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../db/app_db.dart';
import '../widgets/common.dart';
import '../widgets/live.dart';
import 'auth.dart';
import 'shell.dart';

class SubscriptionExpiredScreen extends StatefulWidget {
  const SubscriptionExpiredScreen({super.key});

  @override
  State<SubscriptionExpiredScreen> createState() =>
      _SubscriptionExpiredScreenState();
}

class _SubscriptionExpiredScreenState extends State<SubscriptionExpiredScreen> {
  static const _contactNumber = '918545098444';
  static const _contactNumbers = [
    '+91 8009768896',
    '+91 9369620030',
    '+91 8545098444',
  ];
  static const _plans = [
    (title: 'Monthly', duration: '1 month', price: 150),
    (title: 'Quarterly', duration: '3 months', price: 300),
    (title: 'Yearly', duration: '12 months', price: 1000),
  ];

  bool checking = false;
  bool returningToLogin = false;

  Future<void> _returnToLogin() async {
    if (returningToLogin) return;
    setState(() => returningToLogin = true);
    try {
      await AppDb.i.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (_) => false,
      );
    } catch (error) {
      if (mounted) {
        snack(context, 'Could not return to login: $error');
        setState(() => returningToLogin = false);
      }
    }
  }

  Future<void> _requestPlan(
    BuildContext context,
    Map<String, Object?> admin,
    ({String title, String duration, int price}) plan,
  ) async {
    final message = [
      'Subscription renewal request',
      'Admin ID: ${admin['id'] ?? 'Not provided'}',
      'Admin name: ${(admin['name'] as String? ?? '').trim()}',
      'Admin email: ${(admin['email'] as String? ?? '').trim()}',
      'Requested plan: ${plan.title} (${plan.duration})',
    ].join('\n');
    final uri = Uri.https('wa.me', '/$_contactNumber', {'text': message});
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        snack(context, 'Could not open WhatsApp or a browser on this device.');
      }
    } on PlatformException {
      if (context.mounted) {
        snack(context, 'Could not open WhatsApp or a browser on this device.');
      }
    }
  }

  Future<void> _checkSubscription() async {
    if (checking) return;
    setState(() => checking = true);
    try {
      final admin = await AppDb.i.currentAdmin();
      if (!mounted) return;
      if (admin['subscription_active'] == true) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => const Shell()));
      } else {
        snack(
          context,
          'The plan is still expired. Please contact us to renew.',
        );
      }
    } catch (error) {
      if (mounted) snack(context, 'Could not check subscription: $error');
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  Widget _planCard(
    BuildContext context,
    Map<String, Object?> admin,
    ({String title, String duration, int price}) plan,
  ) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: lineGrey),
    ),
    child: Row(
      children: [
        const Icon(Icons.workspace_premium_rounded, color: orange),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.title,
                style: const TextStyle(
                  color: ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${plan.duration}  •  ${inr(plan.price)}',
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: ink,
          ),
          onPressed: () => _requestPlan(context, admin, plan),
          child: const Text('Renew'),
        ),
      ],
    ),
  );

  Widget _content(Map<String, Object?> admin) {
    final subscription = admin['subscription'] as Map<String, Object?>?;
    final hasPreviousSubscription = subscription != null;
    final plan = (subscription?['plan_type'] as String? ?? 'unknown')
        .toLowerCase();
    final duration = (subscription?['duration_months'] as num?)?.toInt();
    final expiry = DateTime.tryParse(
      subscription?['expiry_date'] as String? ?? '',
    );
    final planTitle = switch (plan) {
      'monthly' => 'Monthly',
      'quarterly' => 'Quarterly',
      'yearly' => 'Yearly',
      'unknown' => 'No active plan',
      _ => plan,
    };
    final durationLabel = duration == null
        ? 'Not available'
        : duration == 1
        ? '1 month'
        : '$duration months';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      children: [
        const Icon(Icons.lock_clock_rounded, color: warnRed, size: 52),
        const SizedBox(height: 14),
        Text(
          hasPreviousSubscription
              ? 'Subscription expired'
              : 'Subscription required',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ink,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Renew your gym subscription to continue. Management services are '
          'unavailable until the plan is active.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: lineGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasPreviousSubscription
                    ? 'Previous subscription'
                    : 'Subscription status',
                style: TextStyle(
                  color: ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text('Plan: $planTitle', style: const TextStyle(color: ink)),
              const SizedBox(height: 6),
              Text(
                'Duration: $durationLabel',
                style: const TextStyle(color: ink),
              ),
              const SizedBox(height: 6),
              Text(
                '${hasPreviousSubscription ? 'Expired' : 'Plan expiry'}: ${expiry == null ? 'Not available' : DateFormat('dd MMM yyyy').format(expiry)}',
                style: const TextStyle(
                  color: warnRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Choose a plan to renew',
          style: TextStyle(
            color: ink,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        for (final plan in _plans) _planCard(context, admin, plan),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: blueSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RewantechSolutions',
                style: TextStyle(color: ink, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Contact numbers',
                style: TextStyle(color: muted, fontSize: 13),
              ),
              for (final number in _contactNumbers)
                Text(
                  number,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: checking ? null : _checkSubscription,
          icon: checking
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
          label: Text(
            checking ? 'Checking...' : 'I have renewed — check again',
          ),
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: returningToLogin ? null : _returnToLogin,
          icon: returningToLogin
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.arrow_back_rounded),
          label: Text(
            returningToLogin ? 'Returning to login...' : 'Back to login',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Scaffold(
      body: NightBackground(
        child: SafeArea(
          child: TopSheet(
            color: pageBg,
            child: Live<Map<String, Object?>>(
              load: AppDb.i.currentAdmin,
              builder: (context, admin) => _content(admin),
            ),
          ),
        ),
      ),
    ),
  );
}
