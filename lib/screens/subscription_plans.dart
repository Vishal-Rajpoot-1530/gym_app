import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../db/app_db.dart';
import '../widgets/common.dart';
import '../widgets/live.dart';

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  static const _plans = [
    (months: 1, label: '1 Month', detail: 'Flexible monthly access'),
    (months: 3, label: '3 Months', detail: 'Three months of access'),
    (months: 12, label: '1 Year', detail: 'Twelve months of access'),
    (months: 24, label: '2 Years', detail: 'Twenty-four months of access'),
  ];

  Future<void> _requestPlan(
    BuildContext context,
    Map<String, Object?> admin,
    String plan,
  ) async {
    final phone = (admin['phone'] as String? ?? '').trim();
    final message = [
      'Subscription plan request',
      'Admin ID: ${admin['id'] ?? 'Not provided'}',
      'Admin name: ${(admin['name'] as String? ?? '').trim().isEmpty ? 'Not provided' : (admin['name'] as String).trim()}',
      'Admin number: ${phone.isEmpty ? 'Not provided' : phone}',
      'Admin email: ${(admin['email'] as String? ?? '').trim().isEmpty ? 'Not provided' : (admin['email'] as String).trim()}',
      'Requested plan: $plan',
    ].join('\n');
    final uri = Uri.https('wa.me', '/8545098444', {'text': message});
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

  Widget _planCard(
    BuildContext context,
    Map<String, Object?> admin,
    ({int months, String label, String detail}) plan,
  ) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: orangeSoft,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            '${plan.months}',
            style: const TextStyle(
              color: ink,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.label,
                style: const TextStyle(
                  color: ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                plan.detail,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: ink,
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          onPressed: () => _requestPlan(context, admin, plan.label),
          child: const Text('Get plan'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: NightBackground(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const PageHeader(
              'Subscription Plans',
              subtitle: 'Choose a duration to request',
            ),
            Expanded(
              child: TopSheet(
                color: pageBg,
                child: Live<Map<String, Object?>>(
                  load: AppDb.i.currentAdmin,
                  builder: (context, admin) => ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                    children: [
                      const Text(
                        'Select your plan',
                        style: TextStyle(
                          color: ink,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Tap Get plan to send your account details and selected duration to our team on WhatsApp.',
                        style: TextStyle(
                          color: muted,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final plan in _plans)
                        _planCard(context, admin, plan),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
