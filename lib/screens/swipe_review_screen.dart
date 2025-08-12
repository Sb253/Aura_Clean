import 'dart:math';
import 'package:aura_clean/blocs/photo_cleaner_bloc.dart';
import 'package:aura_clean/blocs/photo_cleaner_event.dart';
import 'package:aura_clean/blocs/photo_cleaner_state.dart';
import 'package:aura_clean/models/photo_asset.dart';
import 'package:aura_clean/widgets/custom_button.dart';
import 'package:aura_clean/widgets/photo_card.dart';
import 'package:aura_clean/widgets/premium_gate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class SwipeReviewScreen extends StatefulWidget {
  const SwipeReviewScreen({super.key});

  @override
  State<SwipeReviewScreen> createState() => _SwipeReviewScreenState();
}

class _SwipeReviewScreenState extends State<SwipeReviewScreen> {
  final CardSwiperController _controller = CardSwiperController();
  final List<PhotoAsset> _photosToReview = [];
  final Set<PhotoAsset> _photosToDelete = {};
  double _spaceToFree = 0.0;

  @override
  void initState() {
    super.initState();
    final currentState = context.read<PhotoCleanerBloc>().state;
    if (currentState is AnalysisComplete) {
      final allPhotosSet = <PhotoAsset>{};
      allPhotosSet.addAll(currentState.duplicatePhotos);
      allPhotosSet.addAll(currentState.similarPhotos);
      allPhotosSet.addAll(currentState.screenshots);

      _photosToReview.addAll(allPhotosSet.toList());
      _photosToReview.shuffle();
    }
  }

  void _confirmAndDelete() {
    if (_photosToDelete.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Swipe left on photos to mark them for deletion first!")),
      );
      return;
    }

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text("Are you sure you want to permanently delete ${_photosToDelete.length} photos?"),
          actions: [
            CupertinoDialogAction(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text("Delete"),
              onPressed: () {
                context.read<PhotoCleanerBloc>().add(DeleteSelectedPhotosEvent(_photosToDelete.toList()));
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatBytes(double bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Sort'),
      ),
      body: SafeArea(
        child: PremiumGate(
          featureName: 'Tinder-like Swipe Review',
          child: Column(
            children: [
              if (_photosToReview.isEmpty)
                const Expanded(
                  child: Center(child: Text("No photos found to review! Run an analysis first.")),
                )
              else
                Expanded(
                  child: CardSwiper(
                    controller: _controller,
                    cardsCount: _photosToReview.length,
                    onSwipe: (index, percentThresholdX, direction) {
                      if (direction == CardSwiperDirection.left) {
                        setState(() {
                          final photo = _photosToReview[index];
                          _photosToDelete.add(photo);
                          _spaceToFree += photo.size;
                        });
                      }
                      return true;
                    },
                    numberOfCardsDisplayed: 3,
                    backCardOffset: const Offset(40, 40),
                    padding: const EdgeInsets.all(24.0),
                    cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                      final photo = _photosToReview[index];
                      return PhotoCard(photo: photo);
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Space to be Freed: ${_formatBytes(_spaceToFree)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton.filled(
                          style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red),
                          icon: const Icon(CupertinoIcons.xmark, size: 30),
                          onPressed: () => _controller.swipe(CardSwiperDirection.left),
                        ),
                        IconButton.filled(
                          style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green),
                          icon: const Icon(CupertinoIcons.checkmark_alt, size: 30),
                          onPressed: () => _controller.swipe(CardSwiperDirection.right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: "Delete Swiped Photos",
                      onPressed: _confirmAndDelete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
