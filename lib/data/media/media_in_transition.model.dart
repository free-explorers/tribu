import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:tribu/data/media/media.model.dart';

part 'media_in_transition.model.freezed.dart';

@freezed
class MediaInTransition with _$MediaInTransition {
  const factory MediaInTransition(Media media,
      {required MediaTransitionStatus status,
      @Default(0) double progress,}) = _MediaInTransition;
}

enum MediaTransitionStatus { processing, uploading, downloading, done, error }
