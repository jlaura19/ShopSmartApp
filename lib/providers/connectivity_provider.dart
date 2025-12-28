import 'package:flutter/foundation.dart';
import '../services/connectivity_service.dart';
import '../utils/logger.dart';

/// Provider for managing connectivity status
class ConnectivityProvider with ChangeNotifier {
  final ConnectivityService _connectivityService = ConnectivityService();
  
  bool _isOnline = true;
  String _connectionType = 'Unknown';

  bool get isOnline => _isOnline;
  String get connectionType => _connectionType;

  ConnectivityProvider() {
    _initConnectivity();
  }

  /// Initialize connectivity monitoring
  void _initConnectivity() async {
    // Check initial status
    _isOnline = await _connectivityService.checkConnectivity();
    _connectionType = await _connectivityService.getConnectivityType();
    notifyListeners();

    // Listen to connectivity changes
    _connectivityService.connectivityStream.listen((isConnected) {
      _isOnline = isConnected;
      _updateConnectionType();
      notifyListeners();
      
      if (isConnected) {
        appLogger.i('Device is now online');
      } else {
        appLogger.w('Device is now offline');
      }
    });
  }

  /// Update connection type
  Future<void> _updateConnectionType() async {
    _connectionType = await _connectivityService.getConnectivityType();
  }

  /// Manually refresh connectivity status
  Future<void> refreshConnectivity() async {
    _isOnline = await _connectivityService.checkConnectivity();
    _connectionType = await _connectivityService.getConnectivityType();
    notifyListeners();
  }
}
