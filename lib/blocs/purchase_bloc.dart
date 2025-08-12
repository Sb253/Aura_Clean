import 'dart:async';
import 'package:aura_clean/constants/app_constants.dart';
import 'package:aura_clean/blocs/purchase_event.dart';
import 'package:aura_clean/blocs/purchase_state.dart';
import 'package:aura_clean/repositories/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  late StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final SettingsRepository _settingsRepository;

  PurchaseBloc({required SettingsRepository settingsRepository}) 
      : _settingsRepository = settingsRepository,
        super(const PurchaseState()) {
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
    on<CheckTrialStatus>(_onCheckTrialStatus);
    on<StartTrial>(_onStartTrial);

    _inAppPurchase.isAvailable().then((available) {
      if (available) {
        add(LoadProducts());
      }
    });
    
    // Check trial status on initialization
    add(CheckTrialStatus());
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

  void _onCheckTrialStatus(CheckTrialStatus event, Emitter<PurchaseState> emit) async {
    final isTrialActive = await _settingsRepository.isTrialActive();
    final hasTrialExpired = await _settingsRepository.hasTrialExpired();
    final trialDaysRemaining = await _settingsRepository.getTrialDaysRemaining();
    final shouldShowAds = await _settingsRepository.shouldShowAds();
    
    // Determine accessible features based on trial and premium status
    final accessibleFeatures = await _getAccessibleFeatures();
    
    emit(state.copyWith(
      isTrialActive: isTrialActive,
      hasTrialExpired: hasTrialExpired,
      trialDaysRemaining: trialDaysRemaining,
      shouldShowAds: shouldShowAds,
      accessibleFeatures: accessibleFeatures,
    ));
  }

  void _onStartTrial(StartTrial event, Emitter<PurchaseState> emit) async {
    await _settingsRepository.startTrial();
    
    // Update state after starting trial
    final isTrialActive = await _settingsRepository.isTrialActive();
    final trialDaysRemaining = await _settingsRepository.getTrialDaysRemaining();
    final shouldShowAds = await _settingsRepository.shouldShowAds();
    final accessibleFeatures = await _getAccessibleFeatures();
    
    emit(state.copyWith(
      isTrialActive: isTrialActive,
      trialDaysRemaining: trialDaysRemaining,
      shouldShowAds: shouldShowAds,
      accessibleFeatures: accessibleFeatures,
    ));
  }

  Future<List<String>> _getAccessibleFeatures() async {
    final isPremium = state.isPremium;
    final trialActive = await _settingsRepository.isTrialActive();
    
    if (isPremium) {
      // Premium users get all features
      return [
        'photo_analysis',
        'duplicate_detection',
        'similar_detection',
        'screenshot_detection',
        'large_video_detection',
        'basic_review',
        'swipe_review',
        'bulk_deletion',
        'storage_info',
        'advanced_analytics',
      ];
    }
    
    if (trialActive) {
      // During trial, all features are accessible
      return [
        'photo_analysis',
        'duplicate_detection',
        'similar_detection',
        'screenshot_detection',
        'large_video_detection',
        'basic_review',
        'swipe_review',
        'bulk_deletion',
        'storage_info',
        'advanced_analytics',
      ];
    }
    
    // After trial, only basic features
    return [
      'photo_analysis',
      'duplicate_detection',
      'basic_review',
      'storage_info',
    ];
  }

  // Method to check if a specific feature is accessible
  bool canAccessFeature(String featureName) {
    return state.accessibleFeatures.contains(featureName);
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
