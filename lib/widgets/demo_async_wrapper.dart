import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_state.dart';

/// 将来の API 接続点。初回表示時に短いローディングを挟む。
class DemoAsyncWrapper extends ConsumerStatefulWidget {
  const DemoAsyncWrapper({
    super.key,
    required this.cacheKey,
    required this.loading,
    required this.builder,
    this.simulateError = false,
  });

  final String cacheKey;
  final Widget loading;
  final Widget Function() builder;
  final bool simulateError;

  @override
  ConsumerState<DemoAsyncWrapper> createState() => _DemoAsyncWrapperState();
}

class _DemoAsyncWrapperState extends ConsumerState<DemoAsyncWrapper> {
  static final _loadedKeys = <String>{};
  var _loading = true;
  var _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loadedKeys.contains(widget.cacheKey)) {
      setState(() {
        _loading = false;
        _error = widget.simulateError;
      });
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _loadedKeys.add(widget.cacheKey);
    setState(() {
      _loading = false;
      _error = widget.simulateError;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return widget.loading;
    if (_error) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: '読み込みに失敗しました',
        description: 'ネットワーク接続を確認して、もう一度お試しください。',
        actionLabel: '再試行',
        onAction: () {
          _loadedKeys.remove(widget.cacheKey);
          setState(() {
            _loading = true;
            _error = false;
          });
          _load();
        },
      );
    }
    return widget.builder();
  }
}
