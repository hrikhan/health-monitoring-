import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/heartbeat_controller.dart';

/// StudentHeartbeatScreen
/// Displays student-specific heartbeat readings
/// Shows as a ListView of card widgets with mocked student data
class StudentHeartbeatScreen extends StatefulWidget {
  const StudentHeartbeatScreen({super.key});

  @override
  State<StudentHeartbeatScreen> createState() => _StudentHeartbeatScreenState();
}

class _StudentHeartbeatScreenState extends State<StudentHeartbeatScreen> {
  late List<Map<String, dynamic>> mockStudentData;

  @override
  void initState() {
    super.initState();
    _initializeMockData();
  }

  /// Initialize mock student data
  void _initializeMockData() {
    mockStudentData = [
      {
        'name': 'Ahmed Hassan',
        'studentId': 'STU001',
        'pulse': 72,
        'time': '10:30 AM',
        'status': 'Normal',
        'color': Colors.green,
      },
      {
        'name': 'Fatima Khan',
        'studentId': 'STU002',
        'pulse': 85,
        'time': '10:35 AM',
        'status': 'Elevated',
        'color': Colors.orange,
      },
      {
        'name': 'Karim Ahmed',
        'studentId': 'STU003',
        'pulse': 68,
        'time': '10:40 AM',
        'status': 'Normal',
        'color': Colors.green,
      },
      {
        'name': 'Aisha Malik',
        'studentId': 'STU004',
        'pulse': 92,
        'time': '10:45 AM',
        'status': 'High',
        'color': Colors.red,
      },
      {
        'name': 'Ali Raza',
        'studentId': 'STU005',
        'pulse': 75,
        'time': '10:50 AM',
        'status': 'Normal',
        'color': Colors.green,
      },
      {
        'name': 'Zara Khan',
        'studentId': 'STU006',
        'pulse': 88,
        'time': '10:55 AM',
        'status': 'Elevated',
        'color': Colors.orange,
      },
      {
        'name': 'Hassan Ali',
        'studentId': 'STU007',
        'pulse': 70,
        'time': '11:00 AM',
        'status': 'Normal',
        'color': Colors.green,
      },
      {
        'name': 'Noor Fatima',
        'studentId': 'STU008',
        'pulse': 78,
        'time': '11:05 AM',
        'status': 'Normal',
        'color': Colors.green,
      },
    ];
  }

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
          isEnglish ? 'Student Heartbeat' : 'শিক্ষার্থী হৃদস্পন্দন',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade600,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: Text(
                  '${mockStudentData.length}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal.shade600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: mockStudentData.isEmpty
          ? _buildEmptyState(isEnglish)
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16.h),

                  // Summary Stats
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _buildSummaryStats(mockStudentData, isEnglish),
                  ),

                  SizedBox(height: 20.h),

                  // Student List Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEnglish ? 'Student Records' : 'শিক্ষার্থী রেকর্ড',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showAddStudentDialog(
                              context,
                              controller,
                              isEnglish,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.teal.shade200),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.teal.shade600,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Student Cards List
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: mockStudentData.length,
                      itemBuilder: (context, index) {
                        final student = mockStudentData[index];
                        return _buildStudentCard(student, index, isEnglish);
                      },
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
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
          Icon(Icons.people_outline, size: 64.sp, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text(
            isEnglish ? 'No student data' : 'কোন শিক্ষার্থী ডেটা নেই',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isEnglish
                ? 'Add students to monitor their heartbeat'
                : 'তাদের হৃদস্পন্দন পর্যবেক্ষণ করতে শিক্ষার্থী যোগ করুন',
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

  /// Build summary statistics
  Widget _buildSummaryStats(
    List<Map<String, dynamic>> students,
    bool isEnglish,
  ) {
    final avgPulse =
        (students.fold<int>(
                  0,
                  (sum, student) => sum + (student['pulse'] as int),
                ) /
                students.length)
            .round();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal.shade50, Colors.teal.shade100],
          ),
        ),
        padding: EdgeInsets.all(16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              label: isEnglish ? 'Total Students' : 'মোট শিক্ষার্থী',
              value: students.length.toString(),
              icon: Icons.people,
              color: Colors.teal,
            ),
            _buildStatItem(
              label: isEnglish ? 'Average Pulse' : 'গড় স্পন্দন',
              value: avgPulse.toString(),
              icon: Icons.favorite,
              color: Colors.red,
            ),
            _buildStatItem(
              label: isEnglish ? 'Normal' : 'স্বাভাবিক',
              value: students
                  .where(
                    (s) =>
                        (s['pulse'] as int) >= 60 && (s['pulse'] as int) <= 80,
                  )
                  .length
                  .toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  /// Build stat item
  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// Build student card
  Widget _buildStudentCard(
    Map<String, dynamic> student,
    int index,
    bool isEnglish,
  ) {
    final pulse = student['pulse'] as int;
    final isNormal = pulse >= 60 && pulse <= 80;
    final isElevated = pulse > 80 && pulse <= 100;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade50, Colors.grey.shade100],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['name'] as String,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'ID: ${student['studentId']}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: (student['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      student['status'] as String,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: student['color'] as Color,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Divider
              Container(height: 0.5, color: Colors.grey.shade300),

              SizedBox(height: 12.h),

              // Pulse and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEnglish ? 'Heart Rate' : 'হৃদস্পন্দন',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.red.shade600,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${student['pulse']} BPM',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isEnglish ? 'Recorded At' : 'রেকর্ড করা হয়েছে',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        student['time'] as String,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
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
    );
  }

  /// Show add student dialog (for demonstration)
  void _showAddStudentDialog(
    BuildContext context,
    HeartbeatController controller,
    bool isEnglish,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text(
          isEnglish ? 'Add Student' : 'শিক্ষার্থী যোগ করুন',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          isEnglish
              ? 'Feature to add new students coming soon'
              : 'নতুন শিক্ষার্থী যোগ করার বৈশিষ্ট্য শীঘ্রই আসছে',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              isEnglish ? 'Close' : 'বন্ধ করুন',
              style: TextStyle(color: Colors.teal.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
