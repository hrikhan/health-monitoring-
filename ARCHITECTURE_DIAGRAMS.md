# Health Monitoring App - Visual Architecture & Flow Diagrams

## 📱 App Navigation Flow

```
┌─────────────────────────────────┐
│      Splash / Login Screen      │ (initial_route)
└────────────┬────────────────────┘
             │
             ↓ (after login)
┌─────────────────────────────────┐
│      MainScreen                 │ (Navigation Container)
│  ┌───────────────────────────┐  │
│  │   Current Tab Content     │  │
│  │   (3 screens swap here)   │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │  Bottom Navigation Bar    │  │
│  │  [Home] [History] [Student]  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
         │       │       │
         ↓       ↓       ↓
    ┌─────┐ ┌──────┐ ┌────────┐
    │Home │ │History│ │Student │
    │Screen│ │Screen│ │Screen │
    └─────┘ └──────┘ └────────┘
```

## 🔄 Data Flow Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    Arduino Device                        │
│              (Heartbeat Sensor + HC-05)                  │
└───────────────────────┬──────────────────────────────────┘
                        │
                        │ Serial Data "BPM:72\n"
                        ↓
┌──────────────────────────────────────────────────────────┐
│          FlutterBluetoothSerial Bridge                    │
└───────────────────────┬──────────────────────────────────┘
                        │
                        │ Uint8List bytes
                        ↓
┌──────────────────────────────────────────────────────────┐
│      HeartbeatController                                 │
│  ┌────────────────────────────────────────────────────┐  │
│  │  _onDataReceived(Uint8List data)                   │  │
│  │  ├─ String.fromCharCodes() → "BPM:72"             │  │
│  │  ├─ _parsePulseValue() → 72                        │  │
│  │  ├─ updatePulse(72)                                │  │
│  │  │  ├─ currentPulse.value = 72                     │  │
│  │  │  ├─ _animatePulseFromZero(72)                   │  │
│  │  │  │  └─ animatedPulse: 0 → 72 (750ms)           │  │
│  │  │  └─ _savePulseToHistory(72)                     │  │
│  │  └─ StorageService.saveHeartbeatReading()          │  │
│  └────────────────────────────────────────────────────┘  │
│                                                           │
│  Observables (Rx<T>):                                   │
│  ├─ currentPulse.obs (current value)                    │
│  ├─ animatedPulse.obs (animated display)               │
│  ├─ heartbeatHistory.obs (all readings)                │
│  ├─ studentData.obs (student records)                  │
│  ├─ bluetoothStatus.obs (connection state)             │
│  └─ isBluetoothConnected.obs (boolean)                 │
└──────────────────────────────────────────────────────────┘
         │           │           │           │
         ↓           ↓           ↓           ↓
    ┌────────┐  ┌─────────┐ ┌──────┐  ┌──────────┐
    │HomeUI  │  │History  │ │Chart │  │Storage   │
    │(Obx)   │  │UI (Obx) │ │(Obx) │  │(Getx)    │
    └────────┘  └─────────┘ └──────┘  └──────────┘
         │           │           │           │
         └───────────┴───────────┴───────────┘
                      ↓
            GetStorage (Persistent)
            └─ Local Device Storage
```

## 📊 Screen Component Hierarchy

### Home Screen Structure
```
HomeScreen (StatelessWidget)
├─ AppBar
│  ├─ Title: "Your Beat"
│  └─ Actions: [Bluetooth Status Badge]
│
└─ Body: SingleChildScrollView
   ├─ HeartbeatWidget (Stateful with Animations)
   │  ├─ ScaleTransition (3 pulse rings)
   │  ├─ Icon: Icons.favorite (animated)
   │  └─ Text: BPM Value (Obx listener)
   │
   ├─ Card: Bluetooth Status
   │  ├─ Obx: Connection state
   │  ├─ Icon + Text
   │  └─ Gradient background
   │
   ├─ Card: Current Pulse
   │  ├─ Obx: currentPulse.value
   │  ├─ Large text display
   │  └─ Timestamp
   │
   └─ Card: History Summary
      ├─ Total readings count
      ├─ Average pulse calculation
      └─ Gradient background
```

### History Screen Structure
```
HistoryScreen (StatelessWidget)
├─ AppBar
│  ├─ Title: "History of Your Heartbeat"
│  └─ Actions: [Reading count]
│
└─ Body: Obx listener
   ├─ If empty:
   │  └─ EmptyStateWidget
   │
   └─ If has data: SingleChildScrollView
      ├─ Card: FL Chart
      │  └─ LineChart
      │     ├─ Data points from last 7 days
      │     ├─ Grid lines
      │     ├─ Axis labels
      │     └─ Curved spline
      │
      ├─ GridView: Statistics
      │  ├─ Average card
      │  ├─ Maximum card
      │  └─ Minimum card
      │
      ├─ Header: Recent Readings
      │  └─ [Clear Button]
      │
      └─ ListView: Data List
         └─ ReadingCard (per reading)
            ├─ Date & Time
            ├─ Pulse value
            └─ Status badge
```

### Student Screen Structure
```
StudentHeartbeatScreen (StatefulWidget)
├─ AppBar
│  ├─ Title: "Student Heartbeat"
│  └─ Actions: [Student count]
│
└─ Body:
   ├─ Card: Summary Stats
   │  ├─ Total Students
   │  ├─ Average Pulse
   │  └─ Normal Count
   │
   ├─ Header: Student Records
   │  └─ [Add Button]
   │
   └─ ListView: Student Cards
      └─ StudentCard (per student)
         ├─ Name & Student ID
         ├─ Pulse with heart icon
         ├─ Status badge (color-coded)
         └─ Recording time
```

## 🎯 State Management Flow (GetX)

```
┌────────────────────────────────────────┐
│    HeartbeatController (GetxController)│
│  (Managed by GetX Binding)             │
└────────────────────────────────────────┘
           │                │
           │                │
    ┌──────┴────────┐      │
    │ Observable    │      │
    │ Variables     │      │ Listens
    │ (Rx<T>)       │      │ Changes
    ├──────────────┤      │
    │ currentPulse │      │
    │ animatedPulse│      │
    │ history      │      │
    │ status       │      │
    └──────────────┘      │
           │              │
           ↓              ↓
       ┌─────────────────────┐
       │   Obx() Listeners   │
       │  (Auto UI Rebuild)  │
       └─────────────────────┘
       │
       ├─ HomeScreen: BPM display
       ├─ HistoryScreen: Chart & list
       ├─ StudentScreen: Cards
       └─ MainScreen: Status
```

## 🔌 Bluetooth Connection Lifecycle

```
[Not Connected]
       │
       │ connectToBluetoothDevice()
       ↓
[Connecting...] ← bluetoothStatus = "connecting"
       │
       │ BluetoothConnection.toAddress()
       │ ↙                    ↘
    Success            Error/Failed
       │                    │
       ↓                    ↓
[Connected]         [Disconnected]
  ├─ isBluetoothConnected = true
  ├─ connectedDevice = name
  ├─ bluetoothStatus = "connected"
  │
  ├─ _connection.input.listen()
  │    ↓
  │  [Listening for data]
  │    ├─ Continuous data reception
  │    ├─ _onDataReceived() called
  │    └─ Parse & update pulse
  │
  └─ _connection.onDone()
       ↓
    [Disconnected]
     └─ isBluetoothConnected = false
```

## 📈 Data Persistence Layer

```
┌─────────────────────────────────────┐
│      HeartbeatController            │
│      (in-memory data)               │
│  ┌─────────────────────────────┐   │
│  │ heartbeatHistory: [...]     │   │
│  │ studentData: [...]          │   │
│  └─────────────────────────────┘   │
└──────────────┬──────────────────────┘
               │
    ┌──────────┴──────────┐
    │ StorageService      │
    │ (Save/Load/Clear)   │
    └──────────┬──────────┘
               │
    ┌──────────┴──────────┐
    │   GetStorage        │
    │   (Local Storage)   │
    ├─────────────────────┤
    │heartbeat_history:   │
    │ [{pulse, timestamp,│
    │   date, time}, ...] │
    │                     │
    │student_data:       │
    │ [{name, pulse,     │
    │   timestamp}, ...] │
    └─────────────────────┘
```

## 🎨 Color Theme Flow

```
┌─────────────────────────────────┐
│   App Colors & Themes           │
├─────────────────────────────────┤
│                                 │
│ Home Screen:                    │
│ ├─ Primary: Colors.red.600     │
│ ├─ Icon: ♥ (red)               │
│ └─ Cards: red.50 → pink.50     │
│                                 │
│ History Screen:                 │
│ ├─ Primary: Colors.blue.600    │
│ ├─ Chart: blue line            │
│ └─ Cards: blue.50 → gray.100   │
│                                 │
│ Student Screen:                 │
│ ├─ Primary: Colors.teal.600    │
│ ├─ Icons: teal                 │
│ └─ Cards: teal.50 → teal.100   │
│                                 │
│ Status Colors:                  │
│ ├─ Normal (60-80): Green.600   │
│ ├─ Elevated (80-100): Orange   │
│ └─ High (100+): Red.600        │
│                                 │
└─────────────────────────────────┘
```

## 🌍 Localization Flow

```
┌──────────────────────────────┐
│  Get.locale (Current Locale) │
└──────────┬───────────────────┘
           │
    ┌──────┴──────┐
    ↓             ↓
 en_US.dart    bn_BD.dart
 (English)     (Bengali)
    │             │
    ├─ home       ├─ হোম
    ├─ history    ├─ ইতিহাস
    ├─ student    ├─ শিক্ষার্থী
    ├─ yourBeat   ├─ আপনার স্পন্দন
    │ ...         │ ...
    └─────┬───────┘
          │
          ↓
    ┌──────────────────┐
    │  UI Widgets      │
    │ (Auto Updates)   │
    └──────────────────┘

Change Language:
Get.updateLocale(Locale('bn', 'BD'))
  └─ All Obx widgets rebuild
```

## 🎬 Animation Sequence

```
User connects to Arduino
       │
       ↓ [Bluetooth data received]
  "BPM:72"
       │
       ↓ [Parse successful]
  72 (int)
       │
       ↓ [updatePulse(72) called]
       
┌──────────────────────────────┐
│  Animation Starts             │
├──────────────────────────────┤
│                              │
│ Timeline (0ms - 750ms):     │
│                              │
│ 0ms:    ├─ Heart scale 0.8x  │
│         ├─ Counter: 0 BPM    │
│         ├─ Pulse ring 1 out  │
│                              │
│ 100ms:  ├─ Heart animate     │
│         ├─ Counter: 4 BPM    │
│                              │
│ 250ms:  ├─ Counter: 12 BPM   │
│         ├─ Rings expanding   │
│                              │
│ 500ms:  ├─ Counter: 48 BPM   │
│         ├─ Rings near outer  │
│                              │
│ 750ms:  ├─ Counter: 72 BPM   │
│         ├─ Rings complete    │
│         └─ Heart at 1.0x     │
│                              │
│ Loop back to start           │
│ (Animation repeats)          │
│                              │
└──────────────────────────────┘
```

## 📁 File Dependencies

```
main.dart
  ↓
app.dart
  ├─ routes/app_routes.dart
  ├─ core/bindings/controller_binder.dart
  │   └─ features/heartbeat/controllers/heartbeat_controller.dart
  │       └─ core/services/storage_service.dart
  │
  └─ features/heartbeat/screens/main_screen.dart
     ├─ home_screen.dart
     │  └─ widgets/heartbeat_widget.dart
     ├─ history_screen.dart
     │  ├─ fl_chart (external)
     │  └─ heartbeat_controller.dart
     └─ student_screen.dart
        └─ heartbeat_controller.dart

Localization:
  ├─ core/localization/en_US.dart
  └─ core/localization/bn_BD.dart
```

## ⚡ Performance Optimization

```
┌────────────────────────────────┐
│   Performance Strategies        │
├────────────────────────────────┤
│                                │
│ 1. Observables (Rx<T>):       │
│    ├─ Only rebuild Obx widgets│
│    └─ No full widget rebuild   │
│                                │
│ 2. GetX Binding:              │
│    ├─ Lazy initialization      │
│    └─ Memory efficient         │
│                                │
│ 3. Chart Optimization:        │
│    ├─ Show last 7 days only   │
│    ├─ Limit data points       │
│    └─ Cache computed values    │
│                                │
│ 4. Storage:                   │
│    ├─ Auto-trim to 1000 items │
│    ├─ Fast local storage       │
│    └─ No network latency       │
│                                │
│ 5. UI:                         │
│    ├─ SingleChildScrollView    │
│    ├─ ListView.builder         │
│    └─ Responsive sizing        │
│                                │
└────────────────────────────────┘
```

---

This comprehensive visual architecture shows how all components interconnect and the flow of data through the entire application.
