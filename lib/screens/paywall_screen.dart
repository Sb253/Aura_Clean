import 'package:aura_clean/blocs/purchase_bloc.dart';
import 'package:aura_clean/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _selectedPlanId = 'aura_pro_yearly';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PurchaseBloc, PurchaseState>(
      listener: (context, state) {
        if (state.isPremium) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Congratulations! You are now a Premium user.")),
          );
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("An error occurred: ${state.error}")),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(CupertinoIcons.xmark, color: Colors.white70),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const Spacer(),
                      FadeInDown(
                        child: Text("Upgrade to Aura Pro", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(height: 30),
                      _buildFeatureRow(icon: CupertinoIcons.check_mark_circled_solid, text: "Unlimited Cleaning"),
                      _buildFeatureRow(icon: CupertinoIcons.sparkles, text: "AI Smart Select"),
                      _buildFeatureRow(icon: CupertinoIcons.film, text: "Video Compression"),
                      _buildFeatureRow(icon: CupertinoIcons.nosign, text: "Ad-Free Experience"),
                      const Spacer(flex: 2),
                      ..._buildPlanOptions(state.products),
                      const Spacer(),
                      Text("Join over 50,000 users who keep their phone clean with Aura Pro.", style: GoogleFonts.inter(fontSize: 12, color: Colors.white54)),
                      const SizedBox(height: 15),
                      CustomButton(
                        text: "Start 7-Day Free Trial",
                        isLoading: state.purchasePending,
                        onPressed: () {
                          final selectedProduct = state.products.firstWhere((p) => p.id == _selectedPlanId, orElse: () => state.products.first);
                          context.read<PurchaseBloc>().add(BuyProduct(selectedProduct));
                        },
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => context.read<PurchaseBloc>().add(RestorePurchases()),
                        child: Text("Restore Purchase", style: GoogleFonts.inter(color: Colors.grey.shade400)),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                if (state.purchasePending)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPlanOptions(List<ProductDetails> products) {
    if (products.isEmpty) {
      return [const Center(child: CircularProgressIndicator())];
    }

    final annualPlan = products.firstWhere((p) => p.id == 'aura_pro_yearly', orElse: () => products.first);
    final monthlyPlan = products.firstWhere((p) => p.id == 'aura_pro_monthly', orElse: () => products.first);
    final lifetimePlan = products.firstWhere((p) => p.id == 'aura_pro_max_lifetime', orElse: () => products.first);

    return [
      Row(
        children: [
          Expanded(child: _buildSubscriptionCard(monthlyPlan, "\$4.99/mo")),
          const SizedBox(width: 15),
          Expanded(child: _buildSubscriptionCard(annualPlan, "\$2.49/mo", isFeatured: true)),
        ],
      ),
      const SizedBox(height: 15),
      _buildSubscriptionCard(lifetimePlan, "Pay once, keep forever"),
    ];
  }

  Widget _buildSubscriptionCard(ProductDetails product, String displayPrice, {bool isFeatured = false}) {
    final bool isSelected = _selectedPlanId == product.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = product.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF).withOpacity(0.2) : Colors.grey.shade800.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF007AFF) : (isFeatured ? Colors.amber : Colors.transparent),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            if (isFeatured) Text("SAVE 50%", style: GoogleFonts.inter(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
            if (isFeatured) const SizedBox(height: 4),
            Text(product.title.replaceFirst("(Aura Clean)", "").trim(), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 4),
            Text(displayPrice, style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF007AFF), size: 22),
          const SizedBox(width: 12),
          Text(text, style: GoogleFonts.inter(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
