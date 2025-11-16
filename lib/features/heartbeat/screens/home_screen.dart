import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/heartbeat_controller.dart';
import '../widgets/heartbeat_widget.dart';

/// HomeScreen
/// Displays the main heartbeat monitoring interface
/// Shows animated heartbeat, Bluetooth connection status, and pulse data
/// Heartbeat data comes from Arduino via Bluetooth connection
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HeartbeatController>();
    final isEnglish = Get.locale?.languageCode == 'en';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isEnglish ? 'Your Beat' : 'আপনার স্পন্দন',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade600,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: Chip(
                  label: Text(
                    controller.isBluetoothConnected.value
                        ? (isEnglish ? 'Connected' : 'সংযুক্ত')
                        : (isEnglish ? 'Disconnected' : 'সংযোগ বিচ্ছিন্ন'),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                    ),
                  ),
                  backgroundColor: controller.isBluetoothConnected.value
                      ? Colors.green.shade600
                      : Colors.orange.shade600,
                  avatar: Icon(
                    controller.isBluetoothConnected.value
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Animated Heartbeat Display
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: const HeartbeatWidget(),
            ),

            SizedBox(height: 30.h),

            // Bluetooth Status Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Obx(
                () => Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blue.shade50, Colors.blue.shade100],
                      ),
                    ),
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bluetooth,
                              color: Colors.blue.shade600,
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              isEnglish ? 'Bluetooth Status' : 'ব্লুটুথ অবস্থা',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: controller.isBluetoothConnected.value
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            controller.isBluetoothConnected.value
                                ? (isEnglish
                                      ? 'Connected to ${controller.connectedDevice.value}'
                                      : '${controller.connectedDevice.value} এর সাথে সংযুক্ত')
                                : (isEnglish ? 'Not Connected' : 'সংযুক্ত নয়'),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: controller.isBluetoothConnected.value
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          isEnglish
                              ? 'Pulse from Arduino via Bluetooth Serial'
                              : 'Arduino থেকে Bluetooth এর মাধ্যমে স্পন্দন',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Pulse Data Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Obx(
                () => Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.red.shade50, Colors.pink.shade50],
                      ),
                    ),
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.red.shade600,
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              isEnglish ? 'Current Pulse' : 'বর্তমান স্পন্দন',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.currentPulse.value.toString(),
                                  style: TextStyle(
                                    fontSize: 40.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'BPM',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  isEnglish ? 'Last Reading' : 'শেষ রিডিং',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  DateTime.now().toString().split('.')[0],
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // History Summary Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Obx(
                () => Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.purple.shade50, Colors.purple.shade100],
                      ),
                    ),
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.history,
                              color: Colors.purple.shade600,
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              isEnglish
                                  ? 'History Summary'
                                  : 'ইতিহাস সারসংক্ষেপ',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem(
                              label: isEnglish ? 'Total Readings' : 'মোট রিডিং',
                              value: controller.heartbeatHistory.length
                                  .toString(),
                              context: context,
                            ),
                            _buildStatItem(
                              label: isEnglish ? 'Avg Pulse' : 'গড় স্পন্দন',
                              value: _calculateAveragePulse(
                                controller.heartbeatHistory,
                              ),
                              context: context,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  /// Build stat item widget
  Widget _buildStatItem({
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Calculate average pulse from history
  String _calculateAveragePulse(List<Map<String, dynamic>> history) {
    if (history.isEmpty) return '0';
    final sum = history.fold<int>(
      0,
      (prev, current) => prev + (current['pulse'] as int),
    );
    final average = sum ~/ history.length;
    return average.toString();
  }
}
