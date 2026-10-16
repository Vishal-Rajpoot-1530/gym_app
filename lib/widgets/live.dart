import 'package:flutter/material.dart';
import '../db/app_db.dart';

/// Loads data and automatically reloads whenever the database changes.
/// Keeps showing the old data while reloading (no flicker) and shows
/// a readable error instead of an endless spinner.
class Live<T> extends StatefulWidget {
  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? placeholder;

  const Live({super.key, required this.load, required this.builder, this.placeholder});

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
          const Center(child: CircularProgressIndicator(color: Color(0xfff9a31a)));
    }
    if (_error != null && _data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
            const SizedBox(height: 10),
            Text('Could not load data\n$_error', textAlign: TextAlign.center),
            const SizedBox(height: 10),
            TextButton(onPressed: _reload, child: const Text('Retry')),
          ]),
        ),
      );
    }
    return widget.builder(context, _data as T);
  }
}
