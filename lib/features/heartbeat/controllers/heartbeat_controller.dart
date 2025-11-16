import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';

/// HeartbeatController
/// Manages heartbeat state, pulse animation, history, and Bluetooth connection
/// Uses GetX for reactive state management
class HeartbeatController extends GetxController {
  // Observable variables for reactive UI updates
  final currentPulse = 0.obs; // Current heartbeat value in BPM
  final animatedPulse = 0.obs; // Animated pulse value for display
  final heartbeatHistory =
      <Map<String, dynamic>>[].obs; // List of historical readings
  final studentData = <Map<String, dynamic>>[].obs; // Student heartbeat data
  final bluetoothStatus = 'disconnected'.obs; // Bluetooth connection status
  final isBluetoothConnected = false.obs; // Flag for Bluetooth connection
  final connectedDevice = ''.obs; // Name of connected Bluetooth device

  // Bluetooth serial instance
  BluetoothConnection? _connection;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _initializeBluetooth();
  }

  /// Initialize data from storage
  void _initializeData() {
    try {
      // Load existing heartbeat history
      final history = StorageService.getHeartbeatHistory();
      heartbeatHistory.assignAll(history);

      // Load existing student data
      final students = StorageService.getStudentData();
      studentData.assignAll(students);
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  /// Initialize Bluetooth connection
  /// This connects to Arduino device via Bluetooth Serial
  void _initializeBluetooth() {
    try {
      // Bluetooth is available on device
      bluetoothStatus.value = 'ready';
    } catch (e) {
      print('Bluetooth initialization error: $e');
      bluetoothStatus.value = 'error';
    }
  }

  /// Update current pulse value and trigger animation
  /// Called when new pulse data arrives from Arduino
  void updatePulse(int pulse) {
    currentPulse.value = pulse;
    _animatePulseFromZero(pulse);
    _savePulseToHistory(pulse);
  }

  /// Animate pulse value from 0 to target value
  /// Creates smooth counting animation for UI display
  void _animatePulseFromZero(int targetPulse) {
    animatedPulse.value = 0;
    // Simulate animation by incrementing value
    // In real implementation, use AnimationController
    Future.delayed(const Duration(milliseconds: 100), () {
      if (targetPulse > 0) {
        final increment = (targetPulse / 15).ceil();
        for (int i = 0; i <= 15; i++) {
          Future.delayed(Duration(milliseconds: i * 50), () {
            final newValue = (increment * i).toInt();
            if (newValue <= targetPulse) {
              animatedPulse.value = newValue;
            } else {
              animatedPulse.value = targetPulse;
            }
          });
        }
      }
    });
  }

  /// Save pulse reading to history
  void _savePulseToHistory(int pulse) async {
    await StorageService.saveHeartbeatReading(pulse: pulse);
    final history = StorageService.getHeartbeatHistory();
    heartbeatHistory.assignAll(history);
  }

  /// Get heartbeat history for last N days
  List<Map<String, dynamic>> getHeartbeatHistoryLastDays(int days) {
    return StorageService.getHeartbeatHistoryLastDays(days);
  }

  /// Add mock student heartbeat data
  void addStudentHeartbeat({
    required String studentName,
    required int pulse,
  }) async {
    await StorageService.saveStudentData(
      studentName: studentName,
      pulse: pulse,
    );
    final students = StorageService.getStudentData();
    studentData.assignAll(students);
  }

  /// Connect to Bluetooth device
  /// Requires device address from scanned devices
  Future<bool> connectToBluetoothDevice(
    String address,
    String deviceName,
  ) async {
    try {
      bluetoothStatus.value = 'connecting';
      connectedDevice.value = deviceName;

      _connection = await BluetoothConnection.toAddress(address);
      print('Connected to $deviceName at $address');

      bluetoothStatus.value = 'connected';
      isBluetoothConnected.value = true;

      // Listen for incoming data from Arduino
      _connection?.input?.listen(_onDataReceived).onDone(() {
        bluetoothStatus.value = 'disconnected';
        isBluetoothConnected.value = false;
      });

      return true;
    } catch (e) {
      print('Connection error: $e');
      bluetoothStatus.value = 'disconnected';
      isBluetoothConnected.value = false;
      return false;
    }
  }

  /// Handle incoming Bluetooth data from Arduino
  void _onDataReceived(Uint8List data) {
    try {
      // Parse incoming data from Arduino
      // Expected format: "BPM:72" or just "72"
      final receivedText = String.fromCharCodes(data).trim();
      print('Received from Arduino: $receivedText');

      if (receivedText.isNotEmpty) {
        final pulseValue = _parsePulseValue(receivedText);
        if (pulseValue != null && pulseValue > 0) {
          updatePulse(pulseValue);
        }
      }
    } catch (e) {
      print('Error parsing Bluetooth data: $e');
    }
  }

  /// Parse pulse value from received string
  int? _parsePulseValue(String data) {
    try {
      if (data.contains(':')) {
        final parts = data.split(':');
        return int.parse(parts[1].trim());
      }
      return int.parse(data);
    } catch (e) {
      print('Error parsing pulse value: $e');
      return null;
    }
  }

  /// Disconnect from Bluetooth device
  Future<void> disconnectBluetooth() async {
    try {
      await _connection?.close();
      bluetoothStatus.value = 'disconnected';
      isBluetoothConnected.value = false;
      connectedDevice.value = '';
    } catch (e) {
      print('Disconnection error: $e');
    }
  }

  /// Clear all heartbeat history
  Future<void> clearHeartbeatHistory() async {
    await StorageService.clearHeartbeatHistory();
    heartbeatHistory.clear();
  }

  /// Clear all student data
  Future<void> clearStudentData() async {
    await StorageService.clearStudentData();
    studentData.clear();
  }

  @override
  void onClose() {
    _connection?.dispose();
    super.onClose();
  }
}
