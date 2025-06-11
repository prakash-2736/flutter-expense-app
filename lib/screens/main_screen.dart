// import 'package:flutter/material.dart';
// import 'home_screen.dart';
// import 'profile_screen.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
//   int _currentIndex = 0;
//   final List<Widget> _screens = [HomeScreen(), ProfileScreen()];

//   @override
//   Widget build(BuildContext context) {
//     final Color selectedColor = const Color(0xFFFF6F61); // Coral
//     final Color unselectedColor = const Color(0x994B0082); // Indigo 60% opacity
//     final Color bgColor = Colors.white;

//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: PhysicalModel(
//           color: bgColor,
//           elevation: 10,
//           borderRadius: BorderRadius.circular(30),
//           shadowColor: Colors.black26,
//           child: Container(
//             decoration: BoxDecoration(
//               color: bgColor,
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: BottomNavigationBar(
//               currentIndex: _currentIndex,
//               onTap: (index) => setState(() => _currentIndex = index),
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               type: BottomNavigationBarType.fixed,
//               selectedItemColor: selectedColor,
//               unselectedItemColor: unselectedColor,
//               showUnselectedLabels: true,
//               selectedLabelStyle: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14,
//               ),
//               unselectedLabelStyle: const TextStyle(fontSize: 13),
//               items: [
//                 BottomNavigationBarItem(
//                   icon: AnimatedScale(
//                     scale: _currentIndex == 0 ? 1.2 : 1.0,
//                     duration: const Duration(milliseconds: 200),
//                     curve: Curves.easeOut,
//                     child: Icon(Icons.home),
//                   ),
//                   label: 'Home',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: AnimatedScale(
//                     scale: _currentIndex == 1 ? 1.2 : 1.0,
//                     duration: const Duration(milliseconds: 200),
//                     curve: Curves.easeOut,
//                     child: Icon(Icons.person),
//                   ),
//                   label: 'Profile',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [const HomeScreen(), const ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Theme.of(context).colorScheme.primary;
    final Color unselectedColor = Colors.grey.shade600;
    final Color bgColor = Colors.white;
    final Color selectedBg =
        Colors.grey.shade200; // Light background for selected tab

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          height: 80, // Reduced height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavTab(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
                color: selectedColor,
                selectedBg: selectedBg,
                unselectedColor: unselectedColor,
              ),
              _NavTab(
                icon: Icons.person_rounded,
                label: 'Profile',
                selected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
                color: selectedColor,
                selectedBg: selectedBg,
                unselectedColor: unselectedColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  final Color selectedBg;
  final Color unselectedColor;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
    required this.selectedBg,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                decoration: BoxDecoration(
                  color: selected ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: color.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                padding: const EdgeInsets.all(7),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : unselectedColor,
                  size: selected ? 26 : 22,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 350),
                style: GoogleFonts.nunitoSans(
                  color: selected ? color : unselectedColor,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: selected ? 13 : 12,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

