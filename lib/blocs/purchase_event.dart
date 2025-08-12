import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends PurchaseEvent {}

class BuyProduct extends PurchaseEvent {
  final ProductDetails productDetails;

  const BuyProduct(this.productDetails);

  @override
  List<Object> get props => [productDetails];
}

class RestorePurchases extends PurchaseEvent {}

class CheckTrialStatus extends PurchaseEvent {}

class StartTrial extends PurchaseEvent {}
