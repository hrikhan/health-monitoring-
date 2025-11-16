import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'student_screen.dart';

/// MainScreen
/// Main navigation screen with Bottom Navigation Bar
/// Contains three tabs: Home, History, and Student Heartbeat
/// Uses GetX for state management of tab navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// Current tab index
  int currentIndex = 0;

  /// List of screens for each tab
  final List<Widget> screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const StudentHeartbeatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isEnglish = Get.locale?.languageCode == 'en';

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.red.shade600,
          unselectedItemColor: Colors.grey.shade500,
          type: BottomNavigationBarType.fixed,
          items: [
            // Home Tab
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24.sp),
              activeIcon: Icon(Icons.home, size: 24.sp),
              label: isEnglish ? 'Home' : 'হোম',
            ),

            // History Tab
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined, size: 24.sp),
              activeIcon: Icon(Icons.history, size: 24.sp),
              label: isEnglish ? 'History' : 'ইতিহাস',
            ),

            // Student Tab
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline, size: 24.sp),
              activeIcon: Icon(Icons.people, size: 24.sp),
              label: isEnglish ? 'Student' : 'শিক্ষার্থী',
            ),
          ],
        ),
      ),
    );
  }
}
