import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/app_db.dart';
import '../models/member.dart';
import '../screens/admin_profile.dart';
import 'live.dart';

// ------------------------------------------------------------------ colors
const orange = Color(0xfff9a31a);
const orangeSoft = Color(0xfffff1d6);
const ink = Color(0xff111418);
const night = Color(0xff0b0d10);
const panel = Color(0xff171a1f);
const fieldBg = Color(0xfff6f7f9);
const pageBg = Color(0xfff3f4f6);
const lineGrey = Color(0xffe8ebf0);
const okGreen = Color(0xff1f9d55);
const okSoft = Color(0xffdff5e6);
const warnRed = Color(0xffe5383b);
const redSoft = Color(0xffffe8e8);
const muted = Color(0xff6b7280);
const blueSoft = Color(0xffe3efff);
const blue = Color(0xff2f6fed);

// ----------------------------------------------------------------- formats
final NumberFormat _n0 = NumberFormat('#,##,##0.##', 'en_IN');
final NumberFormat _n2 = NumberFormat('#,##,##0.00', 'en_IN');
String inr(num v) => '₹${_n0.format(v)}';
String inr2(num v) => '₹${_n2.format(v)}';

String compactInr(num v) {
  if (v >= 1000) {
    final k = v / 1000;
    return '₹${k.toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k';
  }
  return inr(v);
}

String ordinal(int d) {
  if (d >= 11 && d <= 13) return '${d}th';
  switch (d % 10) {
    case 1:
      return '${d}st';
    case 2:
      return '${d}nd';
    case 3:
      return '${d}rd';
    default:
      return '${d}th';
  }
}

String planLabel(int months) => months == 1 ? '1 Month' : '$months Months';

String planTitle(int months) {
  switch (months) {
    case 1:
      return 'Monthly Standard';
    case 3:
      return 'Quarterly Pro';
    case 6:
      return 'Semi-Annual Plus';
    case 12:
      return 'Annual Elite';
    default:
      return '$months Month Custom';
  }
}

String tierName(int months) {
  switch (months) {
    case 1:
      return 'Bronze Tier';
    case 3:
      return 'Silver Tier';
    case 6:
      return 'Gold Tier';
    case 12:
      return 'Iron Tier';
    default:
      return 'Custom Tier';
  }
}

const kMethods = ['Cash', 'UPI', 'Card'];

void snack(BuildContext c, String msg) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
}

Future<void> refreshAll() async {
  AppDb.i.notifyChanged();
  await Future.delayed(const Duration(milliseconds: 450));
}

// ------------------------------------------------------------------- logo
class LogoMark extends StatelessWidget {
  final double size;

  const LogoMark({super.key, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ink,
              border: Border.all(color: orange, width: 2),
            ),
            child: Icon(Icons.fitness_center, color: orange, size: size * 0.5),
          );
        },
      ),
    );
  }
}

class BigLogo extends StatelessWidget {
  const BigLogo({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: const [
      LogoMark(size: 84),
      SizedBox(height: 12),
      ExtrudedText(
        'RTS GYM',
        depthColor: Color(0xff7a3d08),
        depth: 4,
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
      ExtrudedText(
        'MANAGEMENT',
        depthColor: Color(0xff6d3500),
        depth: 4,
        style: TextStyle(
          color: orange,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: 6,
          height: 1,
        ),
      ),
      SizedBox(height: 4),
      ExtrudedText(
        'GYM & FITNESS',
        depthColor: Color(0xff7a3d08),
        depth: 2,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 11,
          letterSpacing: 3,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class ExtrudedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color depthColor;
  final int depth;
  final TextAlign textAlign;

  const ExtrudedText(
    this.text, {
    super.key,
    required this.style,
    required this.depthColor,
    this.depth = 3,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    clipBehavior: Clip.none,
    children: [
      for (var layer = depth; layer > 0; layer--)
        Transform.translate(
          offset: Offset(layer.toDouble(), layer.toDouble()),
          child: Text(
            text,
            textAlign: textAlign,
            style: style.copyWith(color: depthColor, shadows: const []),
          ),
        ),
      Text(
        text,
        textAlign: textAlign,
        style: style.copyWith(
          shadows: [
            Shadow(
              color: orange.withValues(alpha: 0.45),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    ],
  );
}

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.22),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: orange.withValues(alpha: 0.12),
          blurRadius: 24,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.13),
                const Color(0xff17120e).withValues(alpha: 0.44),
                orange.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 18,
                right: 18,
                top: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.7),
                        orange.withValues(alpha: 0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    ),
  );
}

class NightBackground extends StatelessWidget {
  final Widget child;
  const NightBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xff1b1510), night, night],
        stops: [0, 0.35, 1],
      ),
    ),
    child: child,
  );
}

// ---------------------------------------------------------------- headers
class AdminAvatar extends StatelessWidget {
  const AdminAvatar({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder<SharedPreferences>(
    future: SharedPreferences.getInstance(),
    builder: (c, s) {
      final n = (s.data?.getString('admin_name') ?? 'Coach').trim();
      return Tooltip(
        message: 'Open profile',
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: panel,
              border: Border.all(color: orange, width: 2),
            ),
            child: Text(
              n.isEmpty ? 'C' : n[0].toUpperCase(),
              style: const TextStyle(
                color: orange,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class TabHeader extends StatelessWidget {
  final String title;
  final bool brand;
  const TabHeader(this.title, {super.key, this.brand = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 12, 14),
      child: Row(
        children: [
          const LogoMark(size: 42),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: brand
                  ? [
                      Live<String>(
                        load: AppDb.i.appName,
                        builder: (context, name) => Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                      ),
                      Text(
                        'GYM & FITNESS',
                        style: TextStyle(
                          color: orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ]
                  : [
                      Live<String>(
                        load: AppDb.i.appName,
                        builder: (context, name) => Text(
                          name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
            ),
          ),
          Live<int>(
            placeholder: const SizedBox(width: 48, height: 48),
            load: () async => (await AppDb.i.members())
                .where(
                  (m) =>
                      m.state == MStatus.dueSoon ||
                      (m.status == 'active' && m.lapsed),
                )
                .length,
            builder: (c, n) => IconButton(
              onPressed: () => showAlerts(c),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  if (n > 0)
                    Positioned(
                      right: 1,
                      top: 1,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: warnRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const AdminAvatar(),
        ],
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const PageHeader(this.title, {super.key, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 14, 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12.5,
                    ),
                  ),
              ],
            ),
          ),
          trailing ?? const LogoMark(size: 38),
        ],
      ),
    );
  }
}

class TopSheet extends StatelessWidget {
  final Widget child;
  final Color color;
  const TopSheet({super.key, required this.child, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    const r = BorderRadius.vertical(top: Radius.circular(28));
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: color, borderRadius: r),
      child: ClipRRect(borderRadius: r, child: child),
    );
  }
}

// ---------------------------------------------------------------- widgets
class Pill extends StatelessWidget {
  final String text;
  final Color bg, fg;
  final IconData? icon;
  final Color? border;
  const Pill(
    this.text, {
    super.key,
    this.bg = pageBg,
    this.fg = ink,
    this.icon,
    this.border,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(9),
      border: border == null ? null : Border.all(color: border!),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: TextStyle(
            color: fg,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.text, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
        ),
        if (action != null)
          InkWell(
            onTap: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                color: orange,
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
            ),
          ),
      ],
    ),
  );
}

class MemberAvatar extends StatelessWidget {
  final Member m;
  final double radius;
  const MemberAvatar(this.m, {super.key, this.radius = 28});

  static const _colors = [
    Color(0xff5b6b9a),
    Color(0xff8a5a44),
    Color(0xff3f7d6e),
    Color(0xff7a4f8f),
    Color(0xffa05a5a),
    Color(0xff4c6f91),
  ];

  @override
  Widget build(BuildContext context) {
    if (m.photo != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: ink,
        backgroundImage: MemoryImage(m.photo!),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: _colors[(m.id ?? 0) % _colors.length],
      child: Text(
        m.initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.62,
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool busy;
  const PrimaryButton(
    this.label, {
    super.key,
    this.icon,
    this.onPressed,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    width: double.infinity,
    child: FilledButton(
      onPressed: busy ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: orange,
        foregroundColor: ink,
        disabledBackgroundColor: orange.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: ink),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, size: 20),
                ],
              ],
            ),
    ),
  );
}

class DashedBox extends StatelessWidget {
  final double width, height;
  final Widget child;
  const DashedBox({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashPainter(),
    child: SizedBox(width: width, height: height, child: child),
  );
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
      );
    final paint = Paint()
      ..color = const Color(0xffc3c8d1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const FieldLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7, top: 16),
    child: Text.rich(
      TextSpan(
        text: text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: ink,
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: warnRed),
            ),
        ],
      ),
    ),
  );
}

OutlineInputBorder _ob(Color c, [double w = 1]) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(12),
  borderSide: BorderSide(color: c, width: w),
);

InputDecoration fieldDeco({
  String? hint,
  IconData? icon,
  String? suffix,
  Widget? suffixIcon,
}) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: Color(0xff9aa1ac)),
  prefixIcon: icon == null ? null : Icon(icon, color: muted, size: 20),
  suffixIcon: suffixIcon,
  suffixText: suffix,
  filled: true,
  fillColor: fieldBg,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
  border: _ob(lineGrey),
  enabledBorder: _ob(lineGrey),
  focusedBorder: _ob(orange, 1.6),
  errorBorder: _ob(warnRed),
  focusedErrorBorder: _ob(warnRed, 1.6),
);

class ErrorBox extends StatelessWidget {
  final String text;
  const ErrorBox(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: redSoft,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: warnRed),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: warnRed, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: warnRed,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}

// ----------------------------------------------------------------- alerts
void showAlerts(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Live<List<Member>>(
        load: () async =>
            (await AppDb.i.members())
                .where(
                  (m) =>
                      m.state == MStatus.dueSoon ||
                      (m.status == 'active' && m.lapsed),
                )
                .toList()
              ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate)),
        builder: (c, list) => ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            const Text(
              'Renewal alerts',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'All good - no renewals due this week.',
                    style: TextStyle(color: muted),
                  ),
                ),
              ),
            for (final m in list)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: MemberAvatar(m, radius: 22),
                title: Text(
                  m.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  m.lapsed
                      ? 'Lapsed ${-m.daysLeft} day(s) ago - ${DateFormat('dd MMM').format(m.expiryDate)}'
                      : (m.daysLeft == 0
                            ? 'Expires today'
                            : 'Expires in ${m.daysLeft} day(s)'),
                ),
                trailing: Icon(
                  m.lapsed ? Icons.warning_amber_rounded : Icons.schedule,
                  color: m.lapsed ? warnRed : orange,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

// ------------------------------------------------------- dialog helpers
class ErrorBanner extends StatelessWidget {
  final String text;
  const ErrorBanner(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 14),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: redSoft,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: warnRed, width: 1.4),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: warnRed),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: warnRed,
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    ),
  );
}

class CancelButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CancelButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    width: double.infinity,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: warnRed,
        side: const BorderSide(color: warnRed, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Text(
        'Cancel',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
  );
}
