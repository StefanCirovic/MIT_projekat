import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:e_menza/screens/home/home_screen.dart';
import 'package:e_menza/screens/profile/profile_screen.dart';
import 'package:e_menza/screens/buy/buy_screen.dart';
import 'package:e_menza/providers/student_providers.dart';
import 'package:e_menza/screens/admin/admin_dashboard_screen.dart';

class RootScreen extends StatefulWidget {
  static const String routeName = "/RootScreen";
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late List<Widget> screens;
  int currentScreen = 0;
  late PageController controller;

  @override
  void initState() {
    super.initState();

    // Pripremi ekrane na osnovu uloge
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);

    if (studentProvider.isAdmin) {
      screens = const [
        AdminDashboardScreen(),
      ];
    } else {
      screens = const [
        HomeScreen(),
        BuyScreen(),
        ProfileScreen(),
      ];
    }
    controller = PageController(initialPage: currentScreen);
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: screens,
      ),
      bottomNavigationBar: studentProvider.isAdmin
          ? null
          : NavigationBar(
              selectedIndex: currentScreen,
              onDestinationSelected: (index) {
                setState(() => currentScreen = index);
                controller.jumpToPage(currentScreen);
              },
              destinations: _userDestinations(),
            ),
    );
  }

  List<NavigationDestination> _adminDestinations() {
    return const [
      NavigationDestination(
        selectedIcon: Icon(Icons.dashboard),
        icon: Icon(Icons.dashboard_outlined),
        label: "Admin Panel",
      ),
    ];
  }

  List<NavigationDestination> _userDestinations() {
    return const [
      NavigationDestination(
        selectedIcon: Icon(IconlyBold.home),
        icon: Icon(IconlyLight.home),
        label: "Home",
      ),
      NavigationDestination(
        selectedIcon: Icon(IconlyBold.buy),
        icon: Icon(IconlyLight.buy),
        label: "Buy",
      ),
      NavigationDestination(
        selectedIcon: Icon(IconlyBold.profile),
        icon: Icon(IconlyLight.profile),
        label: "Profile",
      )
    ];
  }
}
