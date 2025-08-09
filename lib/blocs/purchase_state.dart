import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseState extends Equatable {
  final List<ProductDetails> products;
  final bool isPremium;
  final bool purchasePending;
  final String? error;

  const PurchaseState({
    this.products = const [],
    this.isPremium = false,
    this.purchasePending = false,
    this.error,
  });

  PurchaseState copyWith({
    List<ProductDetails>? products,
    bool? isPremium,
    bool? purchasePending,
    String? error,
  }) {
    return PurchaseState(
      products: products ?? this.products,
      isPremium: isPremium ?? this.isPremium,
      purchasePending: purchasePending ?? this.purchasePending,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [products, isPremium, purchasePending, error];
}
