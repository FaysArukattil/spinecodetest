import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetConnectivityWatcher extends StatefulWidget {
  final Widget child;
  const InternetConnectivityWatcher({super.key, required this.child});

  @override
  State<InternetConnectivityWatcher> createState() =>
      _InternetConnectivityWatcherState();
}

class _InternetConnectivityWatcherState
    extends State<InternetConnectivityWatcher> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOffline = false;
  bool _wasOffline = false;
  bool _showBackOnline = false;
  Timer? _onlineTimer;

  @override
  void initState() {
    super.initState();
    _checkInitial();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  Future<void> _checkInitial() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (_) {}
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final offline =
        results.isEmpty || results.every((r) => r == ConnectivityResult.none);
    if (!mounted) return;

    if (offline != _isOffline) {
      setState(() {
        if (!offline && _wasOffline) {
          _showBackOnline = true;
          _onlineTimer?.cancel();
          _onlineTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) setState(() => _showBackOnline = false);
          });
        }
        if (offline) {
          _wasOffline = true;
          _showBackOnline = false;
        }
        _isOffline = offline;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger != null) {
          if (_isOffline) {
            messenger.showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('No internet connection'),
                  ],
                ),
                backgroundColor: Color(0xFFD32F2F),
                duration: Duration(days: 365),
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (_wasOffline) {
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.wifi, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Back online!'),
                  ],
                ),
                backgroundColor: Color(0xFF2E7D32),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _onlineTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isOffline)
          Material(
            color: const Color(0xFFD32F2F),
            child: SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'No Internet Connection',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (_showBackOnline)
          Material(
            color: const Color(0xFF2E7D32),
            child: SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Back Online',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
