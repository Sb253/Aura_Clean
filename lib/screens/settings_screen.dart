import 'package:aura_clean/blocs/theme_bloc.dart';
import 'package:aura_clean/screens/paywall_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aura_clean/blocs/theme_event.dart';
import 'package:aura_clean/blocs/theme_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildSectionTitle(context, 'Appearance'),
          _buildSettingsCard(context,
            children: [
              _buildSettingsItem(
                context,
                icon: CupertinoIcons.moon_stars_fill,
                title: 'Dark Mode',
                trailing: BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return CupertinoSwitch(
                      value: state.themeData.brightness == Brightness.dark,
                      onChanged: (bool value) {
                        context.read<ThemeBloc>().add(ThemeChanged(isDark: value));
                      },
                      activeTrackColor: Theme.of(context).primaryColor,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildSectionTitle(context, 'Subscription'),
          _buildSettingsCard(context,
            children: [
              _buildSettingsItem(
                  context,
                  icon: CupertinoIcons.creditcard_fill,
                  title: 'Manage Subscription',
                  trailing: const Icon(CupertinoIcons.forward),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PaywallScreen()),
                    );
                  }
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildSectionTitle(context, 'About'),
          _buildSettingsCard(context,
            children: [
              _buildSettingsItem(
                  context,
                  icon: CupertinoIcons.question_circle_fill,
                  title: 'Help & Feedback',
                  onTap: () {}
              ),
              const Divider(height: 1, indent: 50),
              _buildSettingsItem(
                  context,
                  icon: CupertinoIcons.doc_text_fill,
                  title: 'Privacy Policy',
                  onTap: () {}
              ),
              const Divider(height: 1, indent: 50),
              _buildSettingsItem(
                  context,
                  icon: CupertinoIcons.info_circle_fill,
                  title: 'Terms of Service',
                  onTap: () {}
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, {required IconData icon, required String title, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade500),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
