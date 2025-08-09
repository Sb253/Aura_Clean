import 'package:equatable/equatable.dart';
import 'package:aura_clean/models/photo_asset.dart';

abstract class PhotoCleanerEvent extends Equatable {
  const PhotoCleanerEvent();

  @override
  List<Object> get props => [];
}

class StartAnalysisEvent extends PhotoCleanerEvent {}

class DeleteSelectedPhotosEvent extends PhotoCleanerEvent {
  final List<PhotoAsset> photosToDelete;

  const DeleteSelectedPhotosEvent(this.photosToDelete);

  @override
  List<Object> get props => [photosToDelete];
}
