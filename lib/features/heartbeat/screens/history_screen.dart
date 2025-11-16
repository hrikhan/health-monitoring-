import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/heartbeat_controller.dart';

/// HistoryScreen
/// Displays heartbeat history with FL Chart line graph
/// Shows date/time along with pulse values
/// Data is retrieved from GetStorage persistent storage
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
          isEnglish ? 'History of Your Heartbeat' : 'আপনার হৃদস্পন্দনের ইতিহাস',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade600,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: Text(
                  '${controller.heartbeatHistory.length}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(
        () => controller.heartbeatHistory.isEmpty
            ? _buildEmptyState(isEnglish)
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),

                    // Chart Card
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEnglish ? 'Last 7 Days' : 'গত ৭ দিন',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              _buildLineChart(controller, isEnglish),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Statistics
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildStatisticsCards(controller, isEnglish),
                    ),

                    SizedBox(height: 20.h),

                    // Data Table Header
                    if (controller.heartbeatHistory.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEnglish
                                  ? 'Recent Readings'
                                  : 'সাম্প্রতিক রিডিং',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _showClearDialog(
                                  context,
                                  controller,
                                  isEnglish,
                                );
                              },
                              child: Text(
                                isEnglish ? 'Clear' : 'মুছুন',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 12.h),

                    // Data List
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.heartbeatHistory.length,
                        itemBuilder: (context, index) {
                          final reading =
                              controller.heartbeatHistory[controller
                                      .heartbeatHistory
                                      .length -
                                  1 -
                                  index];
                          return _buildReadingCard(reading, isEnglish);
                        },
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState(bool isEnglish) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            isEnglish ? 'No data available' : 'কোন ডেটা উপলব্ধ নেই',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isEnglish
                ? 'Start monitoring your heartbeat'
                : 'আপনার হৃদস্পন্দন পর্যবেক্ষণ শুরু করুন',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build line chart for pulse history
  Widget _buildLineChart(HeartbeatController controller, bool isEnglish) {
    final history = controller.getHeartbeatHistoryLastDays(7);

    if (history.isEmpty) {
      return SizedBox(
        height: 200.h,
        child: Center(
          child: Text(
            isEnglish
                ? 'No data for this period'
                : 'এই সময়ের জন্য কোন ডেটা নেই',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
          ),
        ),
      );
    }

    // Prepare chart data
    final spots = <FlSpot>[];
    for (int i = 0; i < history.length; i++) {
      spots.add(FlSpot(i.toDouble(), (history[i]['pulse'] as int).toDouble()));
    }

    final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 250.h,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30.h,
                interval: (history.length / 5).ceil().toDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= history.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      history[index]['time'].toString().substring(0, 5),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (maxY - minY) / 4,
                reservedSize: 40.w,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey.shade600,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue.shade600,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 4.r,
                      color: Colors.blue.shade600,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.shade100.withOpacity(0.3),
              ),
            ),
          ],
          minY: (minY - 10).clamp(30, double.infinity),
          maxY: maxY + 10,
        ),
      ),
    );
  }

  /// Build statistics cards
  Widget _buildStatisticsCards(HeartbeatController controller, bool isEnglish) {
    final history = controller.heartbeatHistory;

    if (history.isEmpty) {
      return const SizedBox();
    }

    final pulses = history.map((h) => h['pulse'] as int).toList();
    final avg = (pulses.fold<int>(0, (a, b) => a + b) / pulses.length).round();
    final max = pulses.reduce((a, b) => a > b ? a : b);
    final min = pulses.reduce((a, b) => a < b ? a : b);

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      children: [
        _buildStatCard(
          label: isEnglish ? 'Average' : 'গড়',
          value: avg.toString(),
          color: Colors.blue,
        ),
        _buildStatCard(
          label: isEnglish ? 'Maximum' : 'সর্বোচ্চ',
          value: max.toString(),
          color: Colors.red,
        ),
        _buildStatCard(
          label: isEnglish ? 'Minimum' : 'সর্বনিম্ন',
          value: min.toString(),
          color: Colors.green,
        ),
      ],
    );
  }

  /// Build individual stat card
  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build reading card
  Widget _buildReadingCard(Map<String, dynamic> reading, bool isEnglish) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade50, Colors.grey.shade100],
          ),
        ),
        padding: EdgeInsets.all(12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reading['date']} ${reading['time']}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isEnglish ? 'Pulse' : 'স্পন্দন',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${reading['pulse']} BPM',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show clear history dialog
  void _showClearDialog(
    BuildContext context,
    HeartbeatController controller,
    bool isEnglish,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text(
          isEnglish ? 'Clear History' : 'ইতিহাস মুছুন',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          isEnglish
              ? 'Are you sure you want to clear all history?'
              : 'আপনি কি সমস্ত ইতিহাস মুছে ফেলতে নিশ্চিত?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              isEnglish ? 'Cancel' : 'বাতিল করুন',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.clearHeartbeatHistory();
              Get.back();
              Get.snackbar(
                isEnglish ? 'Success' : 'সফল',
                isEnglish ? 'History cleared' : 'ইতিহাস মুছে ফেলা হয়েছে',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text(
              isEnglish ? 'Clear' : 'মুছুন',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
