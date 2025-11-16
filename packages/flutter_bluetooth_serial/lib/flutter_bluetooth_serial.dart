// Local stub of `flutter_bluetooth_serial` used for development and testing when
// the real plugin cannot be built. This provides a minimal API surface used by
// the app: `FlutterBluetoothSerial.instance.getBondedDevices()` and
// `BluetoothConnection.toAddress(...)` returning an object with `input` stream
// and `close()` / `dispose()` methods.

library flutter_bluetooth_serial;

import 'dart:async';
import 'dart:typed_data';

class BluetoothDevice {
  String? name;
  String address;

  BluetoothDevice({this.name, required this.address});
}

class BluetoothConnection {
  final String address;
  final StreamController<Uint8List> _controller =
      StreamController<Uint8List>.broadcast();
  Timer? _timer;

  BluetoothConnection._(this.address) {
    // Simulate incoming BPM data every 2 seconds.
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      final bpm = 60 + (DateTime.now().second % 60); // vary between 60..119
      final s = 'BPM:$bpm\n';
      _controller.add(Uint8List.fromList(s.codeUnits));
    });
  }

  Stream<Uint8List>? get input => _controller.stream;

  static Future<BluetoothConnection> toAddress(String address) async {
    // Simulate connection delay
    await Future.delayed(const Duration(milliseconds: 400));
    return BluetoothConnection._(address);
  }

  Future<void> close() async {
    _timer?.cancel();
    // allow any pending events to flush
    await _controller.close();
  }

  void dispose() {
    _timer?.cancel();
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}

class FlutterBluetoothSerial {
  FlutterBluetoothSerial._private();
  static final FlutterBluetoothSerial _instance =
      FlutterBluetoothSerial._private();
  static FlutterBluetoothSerial get instance => _instance;

  Future<List<BluetoothDevice>> getBondedDevices() async {
    // Provide a default mocked HC-05 device so existing code can attempt to connect.
    return [BluetoothDevice(name: 'HC-05', address: '00:11:22:33:44:55')];
  }
}
