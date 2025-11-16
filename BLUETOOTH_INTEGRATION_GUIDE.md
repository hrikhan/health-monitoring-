## Arduino Bluetooth Integration Guide

### Overview
This guide shows how to properly configure and use Bluetooth communication between Flutter app and Arduino devices for real-time heartbeat monitoring.

### Arduino Side Code Example

```cpp
// Arduino Code for Heartbeat Sensor
#include <SoftwareSerial.h>

// HC-05 Bluetooth Module Connections
// RX: Pin 0 (or use SoftwareSerial)
// TX: Pin 1 (or use SoftwareSerial)

SoftwareSerial BTSerial(10, 11); // RX, TX for Bluetooth Module

// Pulse Sensor connected to Analog Pin A0
const int PULSE_SENSOR_PIN = A0;

void setup() {
  Serial.begin(9600);    // Serial Monitor
  BTSerial.begin(9600);  // HC-05 Baud Rate
}

void loop() {
  // Read pulse sensor
  int pulseValue = analogRead(PULSE_SENSOR_PIN);
  
  // Convert to BPM (example: 0-1023 → 40-160 BPM)
  int bpm = map(pulseValue, 0, 1023, 40, 160);
  
  // Send to Flutter App via Bluetooth
  // Format: "BPM:72\n" or just "72\n"
  BTSerial.print("BPM:");
  BTSerial.println(bpm);
  
  // Also print to Serial Monitor for debugging
  Serial.print("BPM: ");
  Serial.println(bpm);
  
  delay(1000); // Send every 1 second
}
```

### Flutter Code - Using Bluetooth Serial

#### Step 1: Add Permission Manifest (android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

#### Step 2: Request Runtime Permissions

```dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestBluetoothPermissions() async {
  final status = await Permission.bluetooth.request();
  return status.isGranted;
}
```

#### Step 3: Scan for Bluetooth Devices

```dart
Future<void> scanBluetoothDevices() async {
  try {
    final availablePorts = await FlutterBluetoothSerial.instance.getBondedDevices();
    
    for (var device in availablePorts) {
      print('Device: ${device.name}, Address: ${device.address}');
      
      // Look for HC-05 or your specific device
      if (device.name?.contains('HC-05') ?? false) {
        await connectToDevice(device.address, device.name ?? 'Unknown');
      }
    }
  } catch (e) {
    print('Error scanning devices: $e');
  }
}
```

#### Step 4: Connect to Device

```dart
Future<bool> connectToDevice(String address, String deviceName) async {
  try {
    bluetoothStatus.value = 'connecting';
    connectedDevice.value = deviceName;
    
    _connection = await BluetoothConnection.toAddress(address);
    print('Connected to $deviceName');
    
    bluetoothStatus.value = 'connected';
    isBluetoothConnected.value = true;
    
    // Listen for data
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
```

### Real-time Data Reception

```dart
void _onDataReceived(Uint8List data) {
  try {
    // Convert bytes to string
    final receivedText = String.fromCharCodes(data).trim();
    print('Received: $receivedText');
    
    // Handle empty or incomplete data
    if (receivedText.isEmpty) return;
    
    // Parse pulse value
    int? pulseValue = _parsePulseValue(receivedText);
    
    if (pulseValue != null && pulseValue > 0) {
      // Validate BPM range (40-200 is typical for humans)
      if (pulseValue >= 40 && pulseValue <= 200) {
        updatePulse(pulseValue);
      }
    }
  } catch (e) {
    print('Error processing data: $e');
  }
}

int? _parsePulseValue(String data) {
  try {
    // Handle format: "BPM:72"
    if (data.contains(':')) {
      final parts = data.split(':');
      if (parts.length >= 2) {
        return int.parse(parts[1].trim());
      }
    }
    
    // Handle format: "72"
    return int.parse(data);
  } catch (e) {
    print('Parse error: $e');
    return null;
  }
}
```

### UI Widget for Bluetooth Control

```dart
class BluetoothControlPanel extends StatelessWidget {
  final HeartbeatController controller;
  
  const BluetoothControlPanel({
    required this.controller,
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Device List Button
            ElevatedButton.icon(
              onPressed: _showDevicesList,
              icon: const Icon(Icons.bluetooth),
              label: const Text('Scan Devices'),
            ),
            
            SizedBox(height: 12.h),
            
            // Connection Status
            Obx(
              () => Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: controller.isBluetoothConnected.value
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      controller.isBluetoothConnected.value
                          ? Icons.check_circle
                          : Icons.error,
                      color: controller.isBluetoothConnected.value
                          ? Colors.green
                          : Colors.red,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      controller.isBluetoothConnected.value
                          ? 'Connected: ${controller.connectedDevice.value}'
                          : 'Not Connected',
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Disconnect Button
            if (Obx(() => controller.isBluetoothConnected.value))
              ElevatedButton(
                onPressed: controller.disconnectBluetooth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Disconnect'),
              ),
          ],
        ),
      ),
    );
  }
  
  void _showDevicesList() async {
    try {
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      
      Get.dialog(
        AlertDialog(
          title: const Text('Select Device'),
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
                      device.name ?? 'Unknown',
                    );
                    Get.back();
                  },
                );
              },
            ),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to scan devices: $e');
    }
  }
}
```

### Debugging Tips

1. **Check Serial Output**
   - Monitor Arduino serial output using Serial Monitor
   - Verify format matches Flutter parsing logic

2. **Test with Mock Data**
   ```dart
   // Simulate Bluetooth data for testing
   void testMockPulseData() {
     updatePulse(72);
     Future.delayed(Duration(seconds: 2), () {
       updatePulse(85);
     });
   }
   ```

3. **Log All Incoming Data**
   ```dart
   void _onDataReceived(Uint8List data) {
     final raw = String.fromCharCodes(data);
     print('Raw bytes: ${data.toList()}');
     print('As string: $raw');
   }
   ```

4. **Check Baud Rate**
   - Arduino: 9600 (HC-05 default)
   - Flutter: Automatically detected

5. **Common Issues**
   - HC-05 not pairing: Try holding reset button during setup
   - Data not received: Check TX/RX connections
   - Garbled data: Verify baud rate matches (9600)
   - Connection drops: Add reconnection logic

### Enhanced Connection with Retry Logic

```dart
Future<bool> connectWithRetry(
  String address,
  String deviceName, {
  int maxRetries = 3,
}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      final success = await connectToBluetoothDevice(address, deviceName);
      if (success) return true;
    } catch (e) {
      print('Connection attempt ${i + 1} failed: $e');
      await Future.delayed(Duration(seconds: 2));
    }
  }
  return false;
}
```

### Automatic Reconnection

```dart
void setupAutoReconnect(String lastConnectedAddress) {
  // Check connection status periodically
  Timer.periodic(Duration(seconds: 5), (timer) {
    if (!isBluetoothConnected.value && lastConnectedAddress.isNotEmpty) {
      connectToBluetoothDevice(lastConnectedAddress, 'HC-05');
    }
  });
}
```

---

This guide provides everything needed for proper Bluetooth integration between Flutter and Arduino devices for heartbeat monitoring.
