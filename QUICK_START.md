## Quick Start Guide - Health Monitoring Flutter App

### Installation & Setup

#### 1. Get Dependencies
```bash
flutter pub get
```

#### 2. Run the App
```bash
# Development
flutter run

# Release build
flutter build apk --release
```

### File Structure Summary

```
health_monitoring/
├── pubspec.yaml                    # Dependencies (includes fl_chart, get_storage, etc.)
├── lib/
│   ├── main.dart                  # Entry point - initializes GetStorage & StorageService
│   ├── app.dart                   # App configuration with localization support
│   ├── routes/app_routes.dart    # Route definitions (login & main screens)
│   ├── core/
│   │   ├── localization/
│   │   │   ├── en_US.dart        # English translations
│   │   │   └── bn_BD.dart        # Bengali translations (বাংলা)
│   │   ├── services/
│   │   │   └── storage_service.dart  # Data persistence with GetStorage
│   │   └── bindings/
│   │       └── controller_binder.dart # GetX dependency injection
│   └── features/heartbeat/
│       ├── controllers/
│       │   └── heartbeat_controller.dart  # State management (GetX)
│       ├── screens/
│       │   ├── main_screen.dart         # Bottom navigation container
│       │   ├── home_screen.dart         # Animated heartbeat display
│       │   ├── history_screen.dart      # FL Chart with history
│       │   └── student_screen.dart      # Student heartbeat readings
│       └── widgets/
│           └── heartbeat_widget.dart    # Reusable animated heart widget
```

### Three Main Features

#### 1️⃣ **Home Screen** - Animated Heartbeat Monitor
- Big pulsing heart animation in center
- Real-time BPM counter (0 → current value)
- Bluetooth connection status
- Current pulse display with timestamp
- Summary statistics
- **Data Source**: Arduino via Bluetooth Serial

#### 2️⃣ **History Screen** - Graphical Analysis
- Line chart of last 7 days (using FL Chart)
- Statistics: Average, Max, Min pulse rates
- Scrollable list of recent readings
- Clear history option
- Date/time for each reading

#### 3️⃣ **Student Screen** - Class Monitoring
- 8 mock students with heartbeat data (ready for real API)
- Color-coded status (Green=Normal, Orange=Elevated, Red=High)
- Student ID and name display
- Summary stats (Total, Average, Normal count)
- Add student functionality placeholder

### Key Technologies

| Feature | Technology |
|---------|-----------|
| State Management | GetX (Rx variables) |
| Data Storage | GetStorage + SharedPreferences |
| Charts | FL Chart |
| Bluetooth | flutter_bluetooth_serial |
| Localization | GetX (English/Bengali) |
| Responsive UI | flutter_screenutil |
| Animations | Flutter AnimationController |

### How Data Flows

```
Arduino Device
   ↓ (Bluetooth Serial)
"BPM:72\n"
   ↓
HeartbeatController._onDataReceived()
   ↓
Parse: 72
   ↓
updatePulse(72)
   ↓
Animate: 0 → 72
   ↓
Save to GetStorage
   ↓
UI Updates via Obx()
```

### Getting Started with Features

#### 🔧 Connect to Arduino
```dart
// In HeartbeatController
await controller.connectToBluetoothDevice(
  'XX:XX:XX:XX:XX:XX', // Arduino MAC address
  'HC-05'               // Device name
);
```

#### 📊 View History Data
```dart
// Get last 7 days
final weekHistory = controller.getHeartbeatHistoryLastDays(7);

// Get all history
final allHistory = controller.heartbeatHistory;
```

#### 👨‍🎓 Add Student Data
```dart
// Save a student reading
controller.addStudentHeartbeat(
  studentName: 'Ahmed Hassan',
  pulse: 72,
);
```

#### 🌍 Switch Language
```dart
// Change to Bengali
Get.updateLocale(Locale('bn', 'BD'));

// Change to English
Get.updateLocale(Locale('en', 'US'));
```

### Localization Examples

| Label | English | Bengali |
|-------|---------|---------|
| Home | Home | হোম |
| History | History | ইতিহাস |
| Student | Student | শিক্ষার্থী |
| Your Beat | Your Beat | আপনার স্পন্দন |
| BPM | BPM | BPM |
| Status | Connected | সংযুক্ত |

### Color Scheme

| Element | Color |
|---------|-------|
| Heartbeat/Pulse | Red (Colors.red.shade600) |
| History Chart | Blue (Colors.blue.shade600) |
| Student Section | Teal (Colors.teal.shade600) |
| Status Good | Green (Colors.green.shade600) |
| Status Warning | Orange (Colors.orange.shade600) |
| Background | Light Gray (Colors.grey.shade50) |

### Animation Details

1. **Heartbeat Animation**
   - Heart icon pulses 0.8x → 1.0x scale
   - Duration: 800ms
   - Repeats infinitely

2. **Pulse Waves**
   - 3 expanding circles around heart
   - Outermost: 0.5x → 1.5x scale
   - Duration: 1 second
   - Smooth easing curves

3. **Pulse Counter**
   - Animates from 0 to current BPM
   - Updates every 50ms
   - Total duration: ~750ms

### Storage Details

**GetStorage Keys**:
- `heartbeat_history` - Array of {pulse, timestamp, date, time}
- `student_data` - Array of {studentName, pulse, timestamp, recordedAt}

**Max Records**: 1000 (auto-trimmed)
**Storage Location**: Device local storage (persistent)

### Testing

#### Mock Data
```dart
// Simulate heartbeat data
void addMockPulseData() {
  controller.updatePulse(72);
  Future.delayed(Duration(seconds: 1), () {
    controller.updatePulse(85);
  });
}
```

#### Check History
```dart
// Print all stored data
print(controller.heartbeatHistory);
print(controller.studentData);
```

### Common Tasks

#### Task: Add New Screen
1. Create `new_screen.dart` in `screens/`
2. Add route in `app_routes.dart`
3. Add tab in `main_screen.dart`

#### Task: Modify Colors
- Edit colors in each screen's build method
- Or create a colors file in `core/utils/colors.dart`

#### Task: Add More Student Data
- Extend mock list in `student_screen.dart`
- Or integrate real API

#### Task: Change Refresh Rate
- Modify `delay()` in Arduino code
- Or adjust Flutter listener intervals

### Debugging

#### View Logs
```dart
// In any controller
print('Current pulse: ${currentPulse.value}');
print('Bluetooth status: ${bluetoothStatus.value}');
print('History count: ${heartbeatHistory.length}');
```

#### Check Storage
```dart
// Access GetStorage
final box = GetStorage();
print(box.read('heartbeat_history'));
```

#### Monitor Bluetooth
```dart
// Check connection status
Obx(() => Text(
  controller.isBluetoothConnected.value ? 'Connected' : 'Disconnected'
))
```

### Performance Tips

1. **Use Obx() for reactive widgets** - Only rebuilds on observable changes
2. **Limit chart data** - Show only last 7 days for smooth rendering
3. **Pagination** - Use ListView.builder for large lists
4. **Optimize animations** - Use SingleTickerProviderStateMixin for one animation

### Troubleshooting

| Issue | Solution |
|-------|----------|
| App crashes on startup | Check GetStorage initialization in main.dart |
| Bluetooth not connecting | Verify device is paired and permission granted |
| History chart blank | Ensure data exists in heartbeatHistory observable |
| Localization not working | Update locale with `Get.updateLocale()` |
| High memory usage | Clear old history with `clearHeartbeatHistory()` |

### Next Steps

1. ✅ Setup dependencies - `flutter pub get`
2. ✅ Test with mock data - No Arduino needed initially
3. ✅ Connect Arduino device - Use Bluetooth scanning
4. ✅ Monitor real pulse - Watch history chart populate
5. ✅ Deploy to device - Build APK/AAB

---

**For detailed information, see**:
- `IMPLEMENTATION_GUIDE.md` - Full architecture details
- `BLUETOOTH_INTEGRATION_GUIDE.md` - Arduino Bluetooth setup

**Happy Coding!** 💓
