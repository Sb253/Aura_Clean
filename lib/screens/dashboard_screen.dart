import 'package:aura_clean/blocs/photo_cleaner_bloc.dart';
import 'package:aura_clean/blocs/photo_cleaner_state.dart';
import 'package:aura_clean/blocs/photo_cleaner_event.dart';
import 'package:aura_clean/blocs/purchase_bloc.dart';
import 'package:aura_clean/blocs/purchase_state.dart';
import 'package:aura_clean/blocs/purchase_event.dart';
import 'package:aura_clean/models/photo_asset.dart';
import 'package:aura_clean/screens/paywall_screen.dart';
import 'package:aura_clean/screens/review_screen.dart';
import 'package:aura_clean/screens/settings_screen.dart';
import 'package:aura_clean/screens/swipe_review_screen.dart';
import 'package:aura_clean/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:animate_do/animate_do.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Ad ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() {}),
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, purchaseState) {
        final isPremium = purchaseState.isPremium;
        final isTrialActive = purchaseState.isTrialActive;
        final trialDaysRemaining = purchaseState.trialDaysRemaining;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Aura Clean'),
            centerTitle: true,
            actions: [
              if (isTrialActive && !isPremium)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Trial: ${trialDaysRemaining}d',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (purchaseState.hasTrialExpired && !isPremium)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Trial Expired',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(CupertinoIcons.settings),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
              ),
            ],
          ),
          body: BlocListener<PhotoCleanerBloc, PhotoCleanerState>(
            listener: (context, state) {
              if (state is FreeTierLimitReached) {
                _showPaywall(context, state.message);
              }
            },
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<PhotoCleanerBloc, PhotoCleanerState>(
                    builder: (context, state) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        child: Column(
                          children: [
                            _buildStorageIndicator(),
                            const SizedBox(height: 30),
                            _buildCategoryGrid(context, state),
                            const Spacer(),
                            if (state is AnalysisComplete)
                              _buildQuickSwipeButton(context, isPremium),
                            CustomButton(
                              text: state is AnalysisInProgress ? 'Analyzing...' : 'Analyze Photos',
                              isLoading: state is AnalysisInProgress,
                              onPressed: () => context.read<PhotoCleanerBloc>().add(StartAnalysisEvent()),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (_bannerAd != null && purchaseState.shouldShowAds)
                  SafeArea(
                    child: SizedBox(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickSwipeButton(BuildContext context, bool isPremium) {
    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, purchaseState) {
        final isTrialActive = purchaseState.isTrialActive;
        final trialDaysRemaining = purchaseState.trialDaysRemaining;
        final hasTrialExpired = purchaseState.hasTrialExpired;
        final canAccessSwipe = purchaseState.accessibleFeatures.contains('swipe_review');
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Column(
            children: [
              if (isTrialActive && !isPremium)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.blue.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Trial: $trialDaysRemaining days remaining',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (hasTrialExpired && !isPremium && !canAccessSwipe)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock, color: Colors.red.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Trial expired - Upgrade to access this feature',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ElevatedButton.icon(
                icon: Icon(canAccessSwipe ? CupertinoIcons.layers_alt_fill : CupertinoIcons.lock_fill),
                label: Text(canAccessSwipe ? "Quick Swipe Review" : "Start Free Trial"),
                onPressed: () {
                  if (canAccessSwipe) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => BlocProvider.value(
                      value: BlocProvider.of<PhotoCleanerBloc>(context),
                      child: const SwipeReviewScreen(),
                    )));
                  } else if (hasTrialExpired) {
                    _showUpgradeDialog(context);
                  } else {
                    _showTrialDialog(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAccessSwipe 
                      ? Theme.of(context).colorScheme.secondary
                      : hasTrialExpired ? Colors.red.shade600 : Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaywall(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Upgrade to Pro"),
        content: Text(message),
        actions: [
          CupertinoDialogAction(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop()),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Upgrade"),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
            },
          ),
        ],
      ),
    );
  }

  void _showTrialDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Start Free Trial"),
        content: const Text("Would you like to start a free 7-day trial to unlock Quick Swipe Review?"),
        actions: [
          CupertinoDialogAction(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop()),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Start Trial"),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<PurchaseBloc>().add(StartTrial());
            },
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Upgrade Required"),
        content: const Text("Your free trial has expired. Please upgrade to access this feature."),
        actions: [
          CupertinoDialogAction(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop()),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Upgrade"),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
            },
          ),
        ],
      ),
    );
  }

  void _showFeatureUpgradeDialog(BuildContext context, String featureName) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text("Upgrade Required for $featureName"),
        content: Text("You need to upgrade to access the $featureName feature."),
        actions: [
          CupertinoDialogAction(child: const Text("Cancel"), onPressed: () => Navigator.of(ctx).pop()),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Upgrade"),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
            },
          ),
        ],
      ),
    );
  }

  void _navigateToReview(BuildContext context, String title, List<PhotoAsset> photos) {
    if (photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No $title found to review.")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: BlocProvider.of<PhotoCleanerBloc>(context),
          child: ReviewScreen(photosToReview: photos, categoryTitle: title),
        ),
      ),
    );
  }

  Widget _buildStorageIndicator() {
    return FadeInUp(
      child: CircularPercentIndicator(
        radius: 100.0,
        lineWidth: 12.0,
        percent: 0.78,
        center: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("200 GB", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0)),
            Text("Used of 256 GB", style: TextStyle(fontSize: 16.0, color: Colors.grey)),
          ],
        ),
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: const Color(0xFF007AFF),
        backgroundColor: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, PhotoCleanerState state) {
    double duplicateSize = 0;
    double similarSize = 0;
    double screenshotSize = 0;
    double largeVideosSize = 0;

    if (state is AnalysisComplete) {
      duplicateSize = state.duplicatePhotos.fold(0, (sum, item) => sum + item.size) / (1024 * 1024 * 1024);
      similarSize = state.similarPhotos.fold(0, (sum, item) => sum + item.size) / (1024 * 1024 * 1024);
      screenshotSize = state.screenshots.fold(0, (sum, item) => sum + item.size) / (1024 * 1024);
      largeVideosSize = state.largeVideos.fold(0, (sum, item) => sum + item.size) / (1024 * 1024 * 1024);
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildCategoryCard(
          icon: CupertinoIcons.collections,
          title: 'Duplicates',
          subtitle: state is AnalysisComplete ? '${duplicateSize.toStringAsFixed(2)} GB' : 'Not analyzed',
          color: Colors.orange,
          onTap: () {
            if (state is AnalysisComplete) {
              _navigateToReview(context, 'Duplicates', state.duplicatePhotos);
            }
          },
          featureKey: 'duplicate_photos',
        ),
        _buildCategoryCard(
          icon: CupertinoIcons.photo_on_rectangle,
          title: 'Similar',
          subtitle: state is AnalysisComplete ? '${similarSize.toStringAsFixed(2)} GB' : 'Not analyzed',
          color: Colors.blue,
          onTap: () {
            if (state is AnalysisComplete) {
              _navigateToReview(context, 'Similar Photos', state.similarPhotos);
            }
          },
          featureKey: 'similar_photos',
        ),
        _buildCategoryCard(
          icon: CupertinoIcons.camera,
          title: 'Screenshots',
          subtitle: state is AnalysisComplete ? '${screenshotSize.toStringAsFixed(1)} MB' : 'Not analyzed',
          color: Colors.green,
          onTap: () {
            if (state is AnalysisComplete) {
              _navigateToReview(context, 'Screenshots', state.screenshots);
            }
          },
          featureKey: 'screenshots',
        ),
        _buildCategoryCard(
          icon: CupertinoIcons.video_camera_solid,
          title: 'Large Videos',
          subtitle: state is AnalysisComplete ? '${largeVideosSize.toStringAsFixed(2)} GB' : 'Not analyzed',
          color: Colors.red,
          onTap: () {
            if (state is AnalysisComplete) {
              _navigateToReview(context, 'Large Videos', state.largeVideos);
            }
          },
          featureKey: 'large_videos',
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required String featureKey,
  }) {
    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, purchaseState) {
        final canAccess = purchaseState.accessibleFeatures.contains(featureKey);
        final isPremium = purchaseState.isPremium;
        final isTrialActive = purchaseState.isTrialActive;
        
        return FadeInUp(
          delay: const Duration(milliseconds: 300),
          child: GestureDetector(
            onTap: canAccess ? onTap : () => _showFeatureUpgradeDialog(context, title),
            child: Container(
              decoration: BoxDecoration(
                color: canAccess ? Theme.of(context).cardColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              icon, 
                              size: 30, 
                              color: canAccess ? color : Colors.grey.shade400
                            ),
                            if (!canAccess && !isPremium)
                              Icon(
                                Icons.lock,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title, 
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.w600,
                                color: canAccess ? null : Colors.grey.shade600,
                              )
                            ),
                            Text(
                              subtitle, 
                              style: TextStyle(
                                fontSize: 14, 
                                color: canAccess ? Colors.grey : Colors.grey.shade400
                              )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!canAccess && !isPremium)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isTrialActive ? Colors.blue.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isTrialActive ? 'Trial' : 'Premium',
                          style: TextStyle(
                            fontSize: 10,
                            color: isTrialActive ? Colors.blue.shade700 : Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
