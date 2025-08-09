import 'package:equatable/equatable.dart';
import 'package:aura_clean/models/photo_asset.dart';

abstract class PhotoCleanerState extends Equatable {
  const PhotoCleanerState();

  @override
  List<Object> get props => [];
}

class PhotoCleanerInitial extends PhotoCleanerState {}

class AnalysisInProgress extends PhotoCleanerState {}

class AnalysisComplete extends PhotoCleanerState {
  final List<PhotoAsset> duplicatePhotos;
  final List<PhotoAsset> similarPhotos;
  final List<PhotoAsset> screenshots;
  final List<PhotoAsset> largeVideos;

  const AnalysisComplete({
    required this.duplicatePhotos,
    required this.similarPhotos,
    required this.screenshots,
    required this.largeVideos,
  });

  @override
  List<Object> get props => [duplicatePhotos, similarPhotos, screenshots, largeVideos];
}

class DeletionInProgress extends PhotoCleanerState {}

class DeletionSuccess extends PhotoCleanerState {}

class DeletionFailure extends PhotoCleanerState {
  final String error;

  const DeletionFailure(this.error);

  @override
  List<Object> get props => [error];
}

class FreeTierLimitReached extends PhotoCleanerState {
  final String message;

  const FreeTierLimitReached(this.message);

  @override
  List<Object> get props => [message];
}
