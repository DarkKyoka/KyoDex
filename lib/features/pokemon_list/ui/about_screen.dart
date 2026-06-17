import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $urlString')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open link. Please restart the app.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 67,
        backgroundColor: AppConstants.accentRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
        ),
        title: const Text(
          "About Kyodex",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Version Info
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(234, 234, 234, 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Software Version: v1.0",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
            ),

            const SizedBox(height: 35),

            // Developer Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Made by:",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(234, 234, 234, 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 35, // Slightly larger
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage("assets/images/pfpDev.gif"),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Dark Kyoka",
                                  style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.normal),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    "Developer",
                                    style: TextStyle(fontSize: 12, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _launchUrl("https://github.com/DarkKyoka"),
                                  icon: const Icon(Icons.code, color: Colors.black),
                                  tooltip: 'GitHub',
                                ),
                                IconButton(
                                  onPressed: () => _launchUrl("https://ko-fi.com/darkkyoka"),
                                  icon: const Icon(Icons.coffee, color: Colors.pinkAccent),
                                  tooltip: 'Ko-fi',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35,)

          ],
        ),
      ),
    );
  }
}
