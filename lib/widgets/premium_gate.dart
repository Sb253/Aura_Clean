import 'package:aura_clean/blocs/purchase_bloc.dart';
import 'package:aura_clean/blocs/purchase_event.dart';
import 'package:aura_clean/blocs/purchase_state.dart';
import 'package:aura_clean/screens/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PremiumGate extends StatelessWidget {
  final Widget child;
  final String featureName;
  final VoidCallback? onUpgrade;

  const PremiumGate({
    super.key,
    required this.child,
    required this.featureName,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, state) {
        // If user is premium, show the feature
        if (state.isPremium) {
          return child;
        }

        // If trial is active, show the feature with trial banner
        if (state.isTrialActive) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.blue.shade100,
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Trial: ${state.trialDaysRemaining} days remaining',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showUpgradeDialog(context),
                      child: const Text('Upgrade Now'),
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          );
        }

        // If no trial and not premium, show upgrade prompt
        return _buildUpgradePrompt(context, state);
      },
    );
  }

  Widget _buildUpgradePrompt(BuildContext context, PurchaseState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            size: 64,
            color: Colors.amber.shade600,
          ),
          const SizedBox(height: 24),
          Text(
            'Premium Feature',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$featureName is a premium feature.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Start your 14-day free trial or upgrade to premium to continue.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _startTrial(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Start Free Trial'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showUpgradeDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Upgrade Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startTrial(BuildContext context) {
    context.read<PurchaseBloc>().add(StartTrial());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Free trial started! You now have 14 days to try premium features.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PaywallScreen(),
      ),
    );
  }
}
