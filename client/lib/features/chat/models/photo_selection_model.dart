// features/chat/models/photo_selection_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'photo_selection_model.freezed.dart';

/// Photo selection item model
@freezed
@Freezed(makeCollectionsUnmodifiable: false)
abstract class PhotoSelectionItem with _$PhotoSelectionItem {
  const factory PhotoSelectionItem({
    required XFile photo,
    required int selectionOrder, // Selection order, starting from 1
    required String id,
  }) = _PhotoSelectionItem;
}

extension PhotoSelectionItemX on PhotoSelectionItem {
  /// Get photo path
  String get path => photo.path;

  /// Get photo name
  String get name => photo.name;

  /// Get file size
  Future<int> get size => photo.length();
}

/// Photo selection state model
@freezed
@Freezed(makeCollectionsUnmodifiable: false)
abstract class PhotoSelectionState with _$PhotoSelectionState {
  const factory PhotoSelectionState({
    @Default(<XFile>[]) List<XFile> availablePhotos,
    @Default(<String, PhotoSelectionItem>{})
    Map<String, PhotoSelectionItem> selectedPhotos, // key is photo.path
    @Default(false) bool isLoading,
    String? errorMessage,
    @Default(false) bool hasPermission,
    @Default(9) int maxSelectionCount, // Default maximum 9 selections
  }) = _PhotoSelectionState;
}

extension PhotoSelectionStateX on PhotoSelectionState {
  /// Get selected photo count
  int get selectedCount => selectedPhotos.length;

  /// Check if selection limit is reached
  bool get isSelectionLimitReached => selectedCount >= maxSelectionCount;

  /// Check if there are selected photos
  bool get hasSelectedPhotos => selectedPhotos.isNotEmpty;

  /// Get sorted list of selected photos
  List<PhotoSelectionItem> get selectedPhotosList {
    final list = selectedPhotos.values.toList();
    list.sort((a, b) => a.selectionOrder.compareTo(b.selectionOrder));
    return list;
  }

  /// Check if photo is selected
  bool isPhotoSelected(XFile photo) {
    return selectedPhotos.containsKey(photo.path);
  }

  /// Get photo selection order (if selected)
  int? getPhotoSelectionOrder(XFile photo) {
    return selectedPhotos[photo.path]?.selectionOrder;
  }

  /// Toggle photo selection state
  PhotoSelectionState togglePhotoSelection(XFile photo) {
    final photoPath = photo.path;
    final newSelectedPhotos = Map<String, PhotoSelectionItem>.from(
      selectedPhotos,
    );

    if (newSelectedPhotos.containsKey(photoPath)) {
      // If already selected, deselect
      final removedItem = newSelectedPhotos.remove(photoPath)!;

      // Reorder subsequent photos
      final reorderedPhotos = <String, PhotoSelectionItem>{};
      int newOrder = 1;

      for (final item in selectedPhotosList) {
        if (item.selectionOrder < removedItem.selectionOrder) {
          reorderedPhotos[item.path] = item;
          newOrder = item.selectionOrder + 1;
        } else if (item.selectionOrder > removedItem.selectionOrder) {
          reorderedPhotos[item.path] = item.copyWith(selectionOrder: newOrder);
          newOrder++;
        }
      }

      return copyWith(selectedPhotos: reorderedPhotos);
    } else {
      // If not selected and limit not reached, add selection
      if (!isSelectionLimitReached) {
        final newItem = PhotoSelectionItem(
          photo: photo,
          selectionOrder: selectedCount + 1,
          id: photoPath,
        );
        newSelectedPhotos[photoPath] = newItem;
        return copyWith(selectedPhotos: newSelectedPhotos);
      }
      return this; // Limit reached, no changes
    }
  }

  /// Clear all selections
  PhotoSelectionState clearSelection() {
    return copyWith(selectedPhotos: {});
  }
}
