import 'package:aura_clean/blocs/purchase_bloc.dart';
import 'package:aura_clean/blocs/photo_cleaner_event.dart';
import 'package:aura_clean/blocs/photo_cleaner_state.dart';
import 'package:aura_clean/repositories/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aura_clean/models/photo_asset.dart';
import 'package:aura_clean/repositories/photo_repository.dart';

const int dailyDeletionLimit = 15;

class PhotoCleanerBloc extends Bloc<PhotoCleanerEvent, PhotoCleanerState> {
  final PhotoRepository _photoRepository;
  final PurchaseBloc _purchaseBloc;
  final SettingsRepository _settingsRepository;

  PhotoCleanerBloc(this._photoRepository, this._purchaseBloc, this._settingsRepository)
      : super(PhotoCleanerInitial()) {
    on<StartAnalysisEvent>(_onStartAnalysis);
    on<DeleteSelectedPhotosEvent>(_onDeleteSelectedPhotos);
  }

  Future<void> _onStartAnalysis(
    StartAnalysisEvent event,
    Emitter<PhotoCleanerState> emit,
  ) async {
    emit(AnalysisInProgress());
    try {
      final allPhotos = await _photoRepository.getAllPhotos();

      final duplicates = await _photoRepository.findDuplicatePhotos(allPhotos);
      final similar = await _photoRepository.findSimilarPhotos(allPhotos);
      final screenshots = await _photoRepository.findScreenshots(allPhotos);
      final largeVideos = await _photoRepository.findLargeVideos(allPhotos);

      emit(AnalysisComplete(
        duplicatePhotos: duplicates,
        similarPhotos: similar,
        screenshots: screenshots,
        largeVideos: largeVideos,
      ));
    } catch (e) {
      emit(DeletionFailure("Failed to analyze photos: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteSelectedPhotos(
    DeleteSelectedPhotosEvent event,
    Emitter<PhotoCleanerState> emit,
  ) async {
    if (_purchaseBloc.state.isPremium) {
      await _performDeletion(event.photosToDelete, emit);
    } else {
      final dailyCount = await _settingsRepository.getDailyDeletionCount();

      if (dailyCount + event.photosToDelete.length > dailyDeletionLimit) {
        emit(const FreeTierLimitReached("You've reached the free tier limit. Upgrade to continue."));
      } else {
        await _performDeletion(event.photosToDelete, emit);
        await _settingsRepository.incrementDailyDeletionCount(event.photosToDelete.length);
      }
    }
  }

  Future<void> _performDeletion(
      List<PhotoAsset> photos, Emitter<PhotoCleanerState> emit) async {
    emit(DeletionInProgress());
    try {
      await _photoRepository.deletePhotos(photos);
      emit(DeletionSuccess());
      add(StartAnalysisEvent()); // Refresh photo list
    } catch (e) {
      emit(DeletionFailure("Failed to delete photos: ${e.toString()}"));
    }
  }
}
