import 'package:e_menza/screens/admin/student_management_screen.dart';
import 'package:e_menza/screens/admin/meal_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_menza/providers/student_providers.dart';
import 'package:e_menza/providers/theme_provider.dart';
import 'package:e_menza/widgets/title_text.dart';
import 'package:e_menza/widgets/subtitle_text.dart';
import 'package:e_menza/services/assets_manager.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const String routeName = "/AdminDashboardScreen";
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TitlesTextWidget(label: "Dobrodošli Admin!"),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SubtitleTextWidget(
                label:
                    "${studentProvider.firstName} ${studentProvider.lastName}",
              ),
            ),
            const SizedBox(height: 32),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TitlesTextWidget(label: "Admin Funkcije"),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildAdminCard(
                    context,
                    "Upravljanje Studentima",
                    Icons.people,
                    Colors.blue,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const StudentManagementScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildAdminCard(
                    context,
                    "Upravljanje Menzom",
                    Icons.restaurant,
                    Colors.orange,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MealManagementScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Theme i logout
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Image.asset(
                        "${AssetsManager.imagePath}/profile/night-mode.png",
                        height: 34),
                    title: Text(themeProvider.getIsDarkTheme
                        ? "Dark Theme"
                        : "Light Theme"),
                    value: themeProvider.getIsDarkTheme,
                    onChanged: (value) {
                      themeProvider.setDarkTheme(themeValue: value);
                    },
                  ),
                  const Divider(),
                  if (studentProvider.isLoggedIn)
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () {
                          studentProvider.logout();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/LoginScreen',
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: color),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
