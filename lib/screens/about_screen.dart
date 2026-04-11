import 'package:flutter/material.dart';
import 'package:smart_reserve_admin/widgets/ui/background_shapes.dart';
import 'package:smart_reserve_admin/widgets/build_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundShapes(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const BuildAppBar(title: "About"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("About App"),
              const SizedBox(height: 10),
              _buildInfoCard(
                child: const Text(
                  "Smart Reserve Admin is the management application for the Smart Reserve platform. "
                  "Monitor bookings, manage staff access, and configure slots with ease.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildSectionTitle("About Developer"),
              const SizedBox(height: 10),
              _buildInfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDeveloperField(
                      "Name",
                      "Keerthivasan S",
                    ),
                    const Divider(),
                    _buildDeveloperField(
                      "Designation",
                      "Mobile App Developer - Alumnus(2025 - B.E CSE (AI & ML))",
                    ),
                    const Divider(),
                    InkWell(
                      onTap: () => _launchUrl(
                        "https://www.linkedin.com/in/KeerthiVasan-ai/",
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.link, color: Colors.blue.shade700),
                            const SizedBox(width: 10),
                            Text(
                              "LinkedIn Profile",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF124076),
      ),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDeveloperField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
