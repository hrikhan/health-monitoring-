import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Constants for preference keys
  static const String _tokenKey = 'token';
  static const String _idKey = 'userId';
  static const String _heartbeatHistoryKey = 'heartbeat_history';
  static const String _studentDataKey = 'student_data';

  // Singleton instance for SharedPreferences
  static SharedPreferences? _preferences;
  static final GetStorage _getStorage = GetStorage();

  // Initialize SharedPreferences and GetStorage (call this during app startup)
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    await GetStorage.init();
  }

  // ==================== Authentication Methods ====================

  // Check if a token exists in local storage
  static bool hasToken() {
    final token = _preferences?.getString(_tokenKey);
    return token != null;
  }

  // Save the token and user ID to local storage
  static Future<void> saveToken(String token, String id) async {
    await _preferences?.setString(_tokenKey, token);
    await _preferences?.setString(_idKey, id);
  }

  // Remove the token and user ID from local storage (for logout)
  static Future<void> logoutUser() async {
    await _preferences?.remove(_tokenKey);
    await _preferences?.remove(_idKey);
    // Navigate to the login screen
    // Get.offAllNamed('/login');
  }

  // Getter for user ID
  static String? get userId => _preferences?.getString(_idKey);

  // Getter for token
  static String? get token => _preferences?.getString(_tokenKey);

  // ==================== Heartbeat History Methods ====================

  /// Save a single heartbeat reading to history
  /// [pulse] - The heartbeat value in BPM
  /// [timestamp] - Optional timestamp, defaults to current time
  static Future<void> saveHeartbeatReading({
    required int pulse,
    DateTime? timestamp,
  }) async {
    try {
      final now = timestamp ?? DateTime.now();
      final reading = {
        'pulse': pulse,
        'timestamp': now.toIso8601String(),
        'date':
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        'time':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
      };

      List<dynamic> history =
          _getStorage.read<List<dynamic>>(_heartbeatHistoryKey) ?? [];
      history.add(reading);

      // Keep only last 1000 readings to avoid excessive storage
      if (history.length > 1000) {
        history = history.sublist(history.length - 1000);
      }

      await _getStorage.write(_heartbeatHistoryKey, history);
    } catch (e) {
      print('Error saving heartbeat reading: $e');
    }
  }

  /// Get all saved heartbeat readings
  static List<Map<String, dynamic>> getHeartbeatHistory() {
    try {
      final history =
          _getStorage.read<List<dynamic>>(_heartbeatHistoryKey) ?? [];
      return List<Map<String, dynamic>>.from(
        history.map((item) => Map<String, dynamic>.from(item as Map)),
      );
    } catch (e) {
      print('Error retrieving heartbeat history: $e');
      return [];
    }
  }

  /// Get heartbeat readings from last N days
  static List<Map<String, dynamic>> getHeartbeatHistoryLastDays(int days) {
    try {
      final history = getHeartbeatHistory();
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      return history.where((reading) {
        final timestamp = DateTime.parse(reading['timestamp'] as String);
        return timestamp.isAfter(startDate);
      }).toList();
    } catch (e) {
      print('Error filtering heartbeat history: $e');
      return [];
    }
  }

  /// Clear all heartbeat history
  static Future<void> clearHeartbeatHistory() async {
    try {
      await _getStorage.remove(_heartbeatHistoryKey);
    } catch (e) {
      print('Error clearing heartbeat history: $e');
    }
  }

  // ==================== Student Data Methods ====================

  /// Save student data (mocked student readings)
  static Future<void> saveStudentData({
    required String studentName,
    required int pulse,
    DateTime? timestamp,
  }) async {
    try {
      final now = timestamp ?? DateTime.now();
      final studentReading = {
        'studentName': studentName,
        'pulse': pulse,
        'timestamp': now.toIso8601String(),
        'recordedAt':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      };

      List<dynamic> studentData =
          _getStorage.read<List<dynamic>>(_studentDataKey) ?? [];
      studentData.add(studentReading);

      await _getStorage.write(_studentDataKey, studentData);
    } catch (e) {
      print('Error saving student data: $e');
    }
  }

  /// Get all student data
  static List<Map<String, dynamic>> getStudentData() {
    try {
      final data = _getStorage.read<List<dynamic>>(_studentDataKey) ?? [];
      return List<Map<String, dynamic>>.from(
        data.map((item) => Map<String, dynamic>.from(item as Map)),
      );
    } catch (e) {
      print('Error retrieving student data: $e');
      return [];
    }
  }

  /// Clear all student data
  static Future<void> clearStudentData() async {
    try {
      await _getStorage.remove(_studentDataKey);
    } catch (e) {
      print('Error clearing student data: $e');
    }
  }
}
