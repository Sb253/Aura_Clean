import 'package:aura_clean/blocs/photo_cleaner_bloc.dart';
import 'package:aura_clean/blocs/purchase_bloc.dart';
import 'package:aura_clean/models/photo_asset.dart';
import 'package:aura_clean/repositories/photo_repository.dart';
import 'package:aura_clean/screens/paywall_screen.dart';
import 'package:aura_clean/widgets/custom_button.dart';
import 'package:aura_clean/widgets/photo_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewScreen extends StatefulWidget {
  final List<PhotoAsset> photosToReview;
  final String categoryTitle;

  const ReviewScreen({
    super.key,
    required this.photosToReview,
    required this.categoryTitle,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final List<PhotoAsset> _photosToDelete = [];
  late List<PhotoAsset> _reviewDeck;
  double _spaceToFree = 0.0;
  final PhotoRepository _photoRepository = PhotoRepository();

  @override
  void initState() {
    super.initState();
    _reviewDeck = List.from(widget.photosToReview);
  }

  void _handleSwipe(bool delete) {
    if (_reviewDeck.isEmpty) return;
    setState(() {
      final swipedPhoto = _reviewDeck.removeLast();
      if (delete) {
        _photosToDelete.add(swipedPhoto);
        _spaceToFree += swipedPhoto.size / (1024 * 1024);
      }
    });
  }

  void _handleSmartSelect(bool isPremium) {
    if (_reviewDeck.isEmpty) return;
    if (!isPremium) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaywallScreen()));
      return;
    }

    final bestPhoto = _photoRepository.findBestPhoto(_reviewDeck);

    setState(() {
      for (final photo in _reviewDeck) {
        if (photo.id != bestPhoto?.id) {
          if (!_photosToDelete.contains(photo)) {
            _photosToDelete.add(photo);
            _spaceToFree += photo.size / (1024 * 1024);
          }
        }
      }
      _reviewDeck.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Kept the best photo and marked others for deletion.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<PurchaseBloc>().state.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            Text(
              _reviewDeck.isNotEmpty
                  ? "Photo ${widget.photosToReview.length - _reviewDeck.length + 1} of ${widget.photosToReview.length}"
                  : "Review Complete!",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildPhotoStack(),
            ),
            const SizedBox(height: 20),
            _buildActionButtons(isPremium),
            const SizedBox(height: 20),
            CustomButton(
              text: "Clean ${_spaceToFree.toStringAsFixed(1)} MB",
              onPressed: _photosToDelete.isNotEmpty
                  ? () {
                context.read<PhotoCleanerBloc>().add(DeleteSelectedPhotosEvent(_photosToDelete));
                Navigator.of(context).pop();
              }
                  : null,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoStack() {
    if (_reviewDeck.isEmpty) {
      return Center(
        child: Text("No more photos to review in this category.", style: Theme.of(context).textTheme.bodySmall),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: _reviewDeck.asMap().entries.map((entry) {
        final index = entry.key;
        final photo = entry.value;

        if (index < _reviewDeck.length - 3) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! < -500) {
              _handleSwipe(true);
            } else if (details.primaryVelocity! > 500) {
              _handleSwipe(false);
            }
          },
          child: PhotoCard(photoAsset: photo),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(bool isPremium) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          heroTag: 'keep_btn',
          onPressed: () => _handleSwipe(false),
          backgroundColor: Colors.white,
          child: const Icon(CupertinoIcons.chevron_down, color: Colors.green, size: 30),
        ),
        FloatingActionButton.large(
          heroTag: 'smart_select_btn',
          onPressed: () => _handleSmartSelect(isPremium),
          backgroundColor: const Color(0xFF007AFF),
          child: isPremium
              ? const Icon(CupertinoIcons.sparkles, color: Colors.white, size: 40)
              : const Icon(CupertinoIcons.lock_fill, color: Colors.white, size: 35),
        ),
        FloatingActionButton(
          heroTag: 'delete_btn',
          onPressed: () => _handleSwipe(true),
          backgroundColor: Colors.white,
          child: const Icon(CupertinoIcons.chevron_up, color: Colors.red, size: 30),
        ),
      ],
    );
  }
}
