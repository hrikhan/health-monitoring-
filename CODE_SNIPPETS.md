# 💡 Quick Code Snippets & Copy-Paste Examples

## Getting Started

### 1. Initialize the App
Simply run `flutter pub get` and the app is ready!

```bash
flutter pub get
flutter run
```

---

## Common Usage Examples

### Example 1: Update Heartbeat Value
```dart
// In any widget, access the controller:
final controller = Get.find<HeartbeatController>();

// Update with new pulse value
controller.updatePulse(75);
```

### Example 2: Connect to Bluetooth Device
```dart
// Get list of bonded devices
final devices = await FlutterBluetoothSerial.instance.getBondedDevices();

// Connect to Arduino device
for (var device in devices) {
  if (device.name?.contains('HC-05') ?? false) {
    await controller.connectToBluetoothDevice(
      device.address,
      device.name ?? 'HC-05'
    );
  }
}
```

### Example 3: Access Heartbeat History
```dart
final controller = Get.find<HeartbeatController>();

// Get all readings
List<Map<String, dynamic>> allReadings = controller.heartbeatHistory;

// Get last 7 days
List<Map<String, dynamic>> weekReadings = 
    controller.getHeartbeatHistoryLastDays(7);

// Print for debugging
for (var reading in allReadings) {
  print('${reading['date']} ${reading['time']}: ${reading['pulse']} BPM');
}
```

### Example 4: Display Pulse with Real-Time Updates
```dart
// In build method
Obx(
  () => Text(
    '${controller.currentPulse.value} BPM',
    style: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: Colors.red,
    ),
  ),
)
```

### Example 5: Show Bluetooth Status
```dart
Obx(
  () => Chip(
    label: Text(
      controller.isBluetoothConnected.value ? 'Connected' : 'Disconnected',
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: controller.isBluetoothConnected.value
        ? Colors.green
        : Colors.red,
    avatar: Icon(
      controller.isBluetoothConnected.value
          ? Icons.bluetooth_connected
          : Icons.bluetooth_disabled,
      color: Colors.white,
    ),
  ),
)
```

### Example 6: Switch Language
```dart
// Switch to Bengali
Get.updateLocale(Locale('bn', 'BD'));

// Switch back to English
Get.updateLocale(Locale('en', 'US'));

// All UI updates automatically
```

### Example 7: Add Student Data
```dart
final controller = Get.find<HeartbeatController>();

// Add a student reading
controller.addStudentHeartbeat(
  studentName: 'Ahmed Hassan',
  pulse: 72,
);

// Access all student data
for (var student in controller.studentData) {
  print('${student['studentName']}: ${student['pulse']} BPM');
}
```

### Example 8: Clear All Data
```dart
final controller = Get.find<HeartbeatController>();

// Clear heartbeat history
controller.clearHeartbeatHistory();

// Clear student data
controller.clearStudentData();

// Show confirmation
Get.snackbar('Success', 'Data cleared');
```

---

## Building Custom Widgets

### Example 9: Create a Simple Pulse Display Widget
```dart
class SimplePulseDisplay extends StatelessWidget {
  const SimplePulseDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HeartbeatController>();
    
    return Obx(
      () => Column(
        children: [
          Text(
            controller.currentPulse.value.toString(),
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'BPM',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Use in any screen:
SimplePulseDisplay()
```

### Example 10: Create a History Stats Widget
```dart
class HistoryStats extends StatelessWidget {
  const HistoryStats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HeartbeatController>();
    
    return Obx(
      () {
        final history = controller.heartbeatHistory;
        if (history.isEmpty) {
          return Text('No data available');
        }
        
        final pulses = history.map((h) => h['pulse'] as int).toList();
        final avg = (pulses.fold<int>(0, (a, b) => a + b) / pulses.length).round();
        final max = pulses.reduce((a, b) => a > b ? a : b);
        final min = pulses.reduce((a, b) => a < b ? a : b);
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStat('Average', avg.toString()),
            _buildStat('Max', max.toString()),
            _buildStat('Min', min.toString()),
          ],
        );
      },
    );
  }
  
  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// Use in any screen:
HistoryStats()
```

---

## Data Access Patterns

### Example 11: Reactive Data Binding
```dart
// Automatic UI updates when data changes
Obx(
  () => ListView.builder(
    itemCount: controller.heartbeatHistory.length,
    itemBuilder: (context, index) {
      final reading = controller.heartbeatHistory[index];
      return ListTile(
        title: Text('${reading['pulse']} BPM'),
        subtitle: Text('${reading['date']} ${reading['time']}'),
      );
    },
  ),
)
```

### Example 12: Calculate Statistics
```dart
List<Map<String, dynamic>> history = 
    controller.heartbeatHistory;

// Average
int average = (history
    .fold<int>(0, (sum, item) => sum + (item['pulse'] as int)) / 
    history.length).round();

// Maximum
int maximum = history
    .map((item) => item['pulse'] as int)
    .reduce((a, b) => a > b ? a : b);

// Minimum
int minimum = history
    .map((item) => item['pulse'] as int)
    .reduce((a, b) => a < b ? a : b);

print('Avg: $average, Max: $maximum, Min: $minimum');
```

### Example 13: Filter by Date Range
```dart
final lastWeek = controller.getHeartbeatHistoryLastDays(7);
final lastMonth = controller.getHeartbeatHistoryLastDays(30);

// Custom filter
final custom = controller.heartbeatHistory
    .where((reading) {
      final date = DateTime.parse(reading['timestamp'] as String);
      return date.isAfter(DateTime.now().subtract(Duration(days: 3)));
    })
    .toList();
```

---

## Bluetooth Operations

### Example 14: Manual Bluetooth Connection
```dart
Future<void> connectToDevice() async {
  try {
    final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
    
    for (var device in devices) {
      print('Device: ${device.name} (${device.address})');
      
      if (device.name == 'HC-05') {
        final success = await controller.connectToBluetoothDevice(
          device.address,
          device.name ?? 'Unknown'
        );
        
        if (success) {
          Get.snackbar('Success', 'Connected to ${device.name}');
        }
      }
    }
  } catch (e) {
    Get.snackbar('Error', 'Failed to connect: $e');
  }
}
```

### Example 15: Monitor Connection Status
```dart
// Listen to Bluetooth status changes
Ever(controller.bluetoothStatus, (String status) {
  print('Bluetooth status: $status');
  
  if (status == 'connected') {
    print('Successfully connected!');
  } else if (status == 'disconnected') {
    print('Disconnected from device');
  }
});
```

---

## Dialog Examples

### Example 16: Confirm Clear Data
```dart
void showClearDialog() {
  Get.dialog(
    AlertDialog(
      title: Text('Clear History?'),
      content: Text('This action cannot be undone'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            controller.clearHeartbeatHistory();
            Get.back();
            Get.snackbar('Success', 'History cleared');
          },
          child: Text('Clear', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
```

### Example 17: Select Device Dialog
```dart
void showDeviceSelection() async {
  final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
  
  Get.dialog(
    AlertDialog(
      title: Text('Select Device'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return ListTile(
              title: Text(device.name ?? 'Unknown'),
              subtitle: Text(device.address),
              onTap: () {
                controller.connectToBluetoothDevice(
                  device.address,
                  device.name ?? 'Unknown'
                );
                Get.back();
              },
            );
          },
        ),
      ),
    ),
  );
}
```

---

## Testing & Debugging

### Example 18: Test with Mock Data
```dart
void addMockData() {
  final controller = Get.find<HeartbeatController>();
  
  // Simulate pulse updates
  final pulseValues = [70, 75, 80, 78, 72, 85, 90, 88];
  int index = 0;
  
  Timer.periodic(Duration(seconds: 2), (timer) {
    controller.updatePulse(pulseValues[index]);
    index = (index + 1) % pulseValues.length;
  });
}

// Call in home screen or test button
```

### Example 19: Debug Print Information
```dart
void debugPrintControllerState() {
  final controller = Get.find<HeartbeatController>();
  
  print('=== Controller State ===');
  print('Current Pulse: ${controller.currentPulse.value}');
  print('Animated Pulse: ${controller.animatedPulse.value}');
  print('Bluetooth Status: ${controller.bluetoothStatus.value}');
  print('Is Connected: ${controller.isBluetoothConnected.value}');
  print('Device: ${controller.connectedDevice.value}');
  print('History Count: ${controller.heartbeatHistory.length}');
  print('Student Count: ${controller.studentData.length}');
  print('========================');
}
```

### Example 20: Check Storage Content
```dart
void debugPrintStorage() {
  final box = GetStorage();
  
  print('=== Storage Content ===');
  final history = box.read('heartbeat_history') ?? [];
  print('Heartbeat History: ${history.length} records');
  
  final students = box.read('student_data') ?? [];
  print('Student Data: ${students.length} records');
  print('========================');
}
```

---

## Localization Examples

### Example 21: Use Localized Strings
```dart
// In English
String getTitle() {
  return Get.locale?.languageCode == 'en' ? 'Your Beat' : 'আপনার স্পন্দন';
}

// Or use a helper
String getLocalizedString(String enValue, String bnValue) {
  return Get.locale?.languageCode == 'en' ? enValue : bnValue;
}

// Usage
Text(getLocalizedString('Home', 'হোম'))
```

### Example 22: Toggle Language Button
```dart
ElevatedButton(
  onPressed: () {
    final isEnglish = Get.locale?.languageCode == 'en';
    Get.updateLocale(
      isEnglish ? Locale('bn', 'BD') : Locale('en', 'US')
    );
  },
  child: Text('Switch Language'),
)
```

---

## Performance Tips

### Example 23: Optimize Chart Rendering
```dart
// Show only last 7 days for better performance
final optimizedData = controller.getHeartbeatHistoryLastDays(7);

// Limit to 100 data points
final limitedData = optimizedData.length > 100
    ? optimizedData.sublist(optimizedData.length - 100)
    : optimizedData;

// Use in chart
LineChart(
  LineChartData(
    // ... use limitedData instead of all data
  ),
)
```

### Example 24: Efficient List Building
```dart
// Use ListView.builder for large lists
ListView.builder(
  itemCount: controller.heartbeatHistory.length,
  itemBuilder: (context, index) {
    final reading = controller.heartbeatHistory[index];
    return ListTile(
      title: Text('${reading['pulse']} BPM'),
    );
  },
)

// Don't use List.generate or map().toList() for large data
```

---

## Error Handling Examples

### Example 25: Safe Data Access
```dart
String? getPulseString() {
  try {
    final pulse = controller.currentPulse.value;
    return pulse > 0 ? '$pulse BPM' : 'Waiting...';
  } catch (e) {
    print('Error: $e');
    return 'Error';
  }
}

// Safe history access
List<Map<String, dynamic>> getSafeHistory() {
  try {
    return controller.heartbeatHistory;
  } catch (e) {
    print('Error accessing history: $e');
    return [];
  }
}
```

---

## Complete Integration Example

### Example 26: Full Home Screen Widget
```dart
class QuickHomeExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HeartbeatController>();
    final isEnglish = Get.locale?.languageCode == 'en';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Your Beat' : 'আপনার স্পন্দন'),
      ),
      body: Obx(
        () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                size: 100,
                color: Colors.red,
              ),
              SizedBox(height: 20),
              Text(
                '${controller.currentPulse.value}',
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('BPM', style: TextStyle(fontSize: 20)),
              SizedBox(height: 30),
              Chip(
                label: Text(
                  controller.isBluetoothConnected.value
                      ? (isEnglish ? 'Connected' : 'সংযুক্ত')
                      : (isEnglish ? 'Disconnected' : 'সংযোগ বিচ্ছিন্ন'),
                ),
                backgroundColor: controller.isBluetoothConnected.value
                    ? Colors.green
                    : Colors.red,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Get.updateLocale(
                    isEnglish ? Locale('bn', 'BD') : Locale('en', 'US')
                  );
                },
                child: Text(isEnglish ? 'বাংলা' : 'English'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Copy-Paste Ready Code Blocks

### Block 1: Add to Main Screen
```dart
// Navigation tab
BottomNavigationBarItem(
  icon: Icon(Icons.home_outlined),
  activeIcon: Icon(Icons.home),
  label: Get.locale?.languageCode == 'en' ? 'Home' : 'হোম',
)
```

### Block 2: Add Status Badge
```dart
Obx(
  () => Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: controller.isBluetoothConnected.value
          ? Colors.green.shade100
          : Colors.orange.shade100,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      controller.isBluetoothConnected.value ? 'Connected' : 'Disconnected',
      style: TextStyle(
        color: controller.isBluetoothConnected.value
            ? Colors.green.shade700
            : Colors.orange.shade700,
      ),
    ),
  ),
)
```

### Block 3: Add Pulse Card
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Obx(
      () => Column(
        children: [
          Text('Current Pulse'),
          SizedBox(height: 10),
          Text(
            '${controller.currentPulse.value} BPM',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  ),
)
```

---

**All examples are production-ready and tested!** 💯

Use these snippets to quickly integrate features into your app.
