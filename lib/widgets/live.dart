import 'package:flutter/material.dart';

import '../api/api_exception.dart';
import '../db/app_db.dart';

/// Loads data and automatically reloads whenever the database changes.
/// Keeps showing the old data while reloading (no flicker) and shows
/// a readable error instead of an endless spinner.
class Live<T> extends StatefulWidget {
  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)?
  errorBuilder;
  final Widget? placeholder;

  const Live({
    super.key,
    required this.load,
    required this.builder,
    this.errorBuilder,
    this.placeholder,
  });

  @override
  State<Live<T>> createState() => _LiveState<T>();
}

class _LiveState<T> extends State<Live<T>> {
  T? _data;
  Object? _error;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    AppDb.i.tick.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    AppDb.i.tick.removeListener(_reload);
    super.dispose();
  }

  Future<void> _reload() async {
    try {
      final d = await widget.load();
      if (!mounted) return;
      setState(() {
        _data = d;
        _error = null;
        _loaded = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return widget.placeholder ??
          const Center(
            child: CircularProgressIndicator(color: Color(0xfff9a31a)),
          );
    }
    if (_error != null && _data == null) {
      final error = _error!;
      final errorBuilder = widget.errorBuilder;
      if (errorBuilder != null) {
        return errorBuilder(context, error, _reload);
      }
      final serviceUnavailable = error is ApiException && error.networkError;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (serviceUnavailable ? Colors.orange : Colors.red)
                      .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  serviceUnavailable
                      ? Icons.cloud_off_outlined
                      : Icons.error_outline,
                  size: 30,
                  color: serviceUnavailable
                      ? Colors.deepOrange
                      : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                serviceUnavailable
                    ? 'Connection unavailable'
                    : 'Unable to load data',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xff171a1f),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                serviceUnavailable
                    ? ApiException.serviceUnavailableMessage
                    : 'Could not load data.\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xff6b7280), height: 1.4),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Color(0xff111418),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widget.builder(context, _data as T);
  }
}
