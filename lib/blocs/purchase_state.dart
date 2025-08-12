import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseState extends Equatable {
  final List<ProductDetails> products;
  final bool isPremium;
  final bool purchasePending;
  final String? error;
  final bool isTrialActive;
  final int trialDaysRemaining;

  const PurchaseState({
    this.products = const [],
    this.isPremium = false,
    this.purchasePending = false,
    this.error,
    this.isTrialActive = false,
    this.trialDaysRemaining = 14,
  });

  PurchaseState copyWith({
    List<ProductDetails>? products,
    bool? isPremium,
    bool? purchasePending,
    String? error,
    bool? isTrialActive,
    int? trialDaysRemaining,
  }) {
    return PurchaseState(
      products: products ?? this.products,
      isPremium: isPremium ?? this.isPremium,
      purchasePending: purchasePending ?? this.purchasePending,
      error: error ?? this.error,
      isTrialActive: isTrialActive ?? this.isTrialActive,
      trialDaysRemaining: trialDaysRemaining ?? this.trialDaysRemaining,
    );
  }

  @override
  List<Object?> get props => [products, isPremium, purchasePending, error, isTrialActive, trialDaysRemaining];
}
