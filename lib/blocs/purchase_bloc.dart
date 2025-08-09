import 'dart:async';
import 'package:aura_clean/constants/app_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:equatable/equatable.dart';

part 'purchase_event.dart';
part 'purchase_state.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  late StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  PurchaseBloc() : super(const PurchaseState()) {
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _purchaseSubscription.cancel(),
      onError: (error) {
        emit(state.copyWith(
            purchasePending: false, error: "An error occurred in the purchase stream."));
      },
    );

    on<LoadProducts>(_onLoadProducts);
    on<BuyProduct>(_onBuyProduct);
    on<RestorePurchases>(_onRestorePurchases);

    _inAppPurchase.isAvailable().then((available) {
      if (available) {
        add(LoadProducts());
      }
    });
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<PurchaseState> emit) async {
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(AppConstants.productIds.toSet());
    if (response.error == null) {
      final products = List<ProductDetails>.from(response.productDetails);
      products.sort((a, b) => AppConstants.productIds
          .indexOf(a.id)
          .compareTo(AppConstants.productIds.indexOf(b.id)));
      emit(state.copyWith(products: products));
    } else {
      emit(state.copyWith(error: response.error?.message));
    }
  }

  void _onBuyProduct(BuyProduct event, Emitter<PurchaseState> emit) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: event.productDetails);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _onRestorePurchases(RestorePurchases event, Emitter<PurchaseState> emit) async {
    await _inAppPurchase.restorePurchases();
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // TODO: CRITICAL - Implement server-side receipt validation before granting premium access.
        // This is a security vulnerability and must be addressed.
        emit(state.copyWith(isPremium: true, purchasePending: false));
        if (purchase.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.pending) {
        emit(state.copyWith(purchasePending: true));
      } else if (purchase.status == PurchaseStatus.error) {
        emit(state.copyWith(purchasePending: false, error: purchase.error?.message));
      } else if (purchase.status == PurchaseStatus.canceled) {
        emit(state.copyWith(purchasePending: false));
      }
    }
  }

  @override
  Future<void> close() {
    _purchaseSubscription.cancel();
    return super.close();
  }
}
