import 'package:aura_clean/screens/dashboard_screen.dart';
import 'package:aura_clean/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  Future<void> _requestPermission(BuildContext context) async {
    try {
      // First check current permission status
      final currentStatus = await PhotoManager.requestPermissionExtend();
      print('Current permission status: $currentStatus');
      
      if (currentStatus.isAuth) {
        print('Permission already granted, proceeding to dashboard');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_complete', true);

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      } else {
        print('Permission not granted, requesting permission...');
        // Request permission explicitly
        final newStatus = await PhotoManager.requestPermissionExtend();
        print('New permission status after request: $newStatus');
        
        if (newStatus.isAuth) {
          print('Permission granted after request, proceeding to dashboard');
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding_complete', true);

          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
        } else {
          print('Permission still not granted, opening settings');
          if (context.mounted) {
            // Show a dialog explaining the issue
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Permission Required'),
                content: const Text(
                  'Photo library access is required for Aura Clean to work. '
                  'Please go to Settings > Apps > Aura Clean > Permissions and enable "Storage" permission.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      PhotoManager.openSetting();
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error requesting permission: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting permission: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.photo_on_rectangle, size: 100, color: Color(0xFF007AFF)),
              const SizedBox(height: 40),
              Text(
                "Photo Library Access",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Aura Clean needs access to your photo library to scan for duplicates, screenshots, and other clutter.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              CustomButton(
                text: "Allow Access",
                onPressed: () => _requestPermission(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
