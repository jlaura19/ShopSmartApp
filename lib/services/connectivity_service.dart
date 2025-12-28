import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/logger.dart';

/// Service to monitor network connectivity status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  /// Stream of connectivity status changes
  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((results) {
      // Check if any connection is available
      final isConnected = results.any((result) => 
        result != ConnectivityResult.none
      );
      appLogger.i('Connectivity changed: ${isConnected ? "Online" : "Offline"}');
      return isConnected;
    });
  }
  
  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final isConnected = results.any((result) => 
        result != ConnectivityResult.none
      );
      appLogger.d('Current connectivity: ${isConnected ? "Online" : "Offline"}');
      return isConnected;
    } catch (e) {
      appLogger.e('Error checking connectivity', error: e);
      return false;
    }
  }
  
  /// Get detailed connectivity type
  Future<String> getConnectivityType() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.wifi)) {
        return 'WiFi';
      } else if (results.contains(ConnectivityResult.mobile)) {
        return 'Mobile Data';
      } else if (results.contains(ConnectivityResult.ethernet)) {
        return 'Ethernet';
      } else {
        return 'Offline';
      }
    } catch (e) {
      appLogger.e('Error getting connectivity type', error: e);
      return 'Unknown';
    }
  }
}
