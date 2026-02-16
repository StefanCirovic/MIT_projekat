import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_menza/providers/student_providers.dart';
import 'package:e_menza/widgets/title_text.dart';
import 'package:e_menza/widgets/subtitle_text.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const String routeName = "/AdminDashboardScreen";
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TitlesTextWidget(label: "Dobrodošli Admin!"),
            const SizedBox(height: 8),
            SubtitleTextWidget(
                label:
                    "${studentProvider.firstName} ${studentProvider.lastName}"),
            const SizedBox(height: 32),

            // Admin funkcionalnosti
            const TitlesTextWidget(label: "Admin Funkcije"),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildAdminCard(
                    context,
                    "Upravljanje Studentima",
                    Icons.people,
                    Colors.blue,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Student management - u implementaciji")),
                      );
                    },
                  ),
                  _buildAdminCard(
                    context,
                    "Statistike",
                    Icons.analytics,
                    Colors.green,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Statistike - u implementaciji")),
                      );
                    },
                  ),
                  _buildAdminCard(
                    context,
                    "Upravljanje Menzom",
                    Icons.restaurant,
                    Colors.orange,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Menza management - u implementaciji")),
                      );
                    },
                  ),
                  _buildAdminCard(
                    context,
                    "Podešavanja",
                    Icons.settings,
                    Colors.purple,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Podešavanja - u implementaciji")),
                      );
                    },
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }
}
