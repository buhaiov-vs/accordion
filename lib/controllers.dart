import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

/// ScrollIntoViewOfItems is used to adjust the position of newly
/// opened sections in the center of the screen
enum ScrollIntoViewOfItems { none, slow, fast }

/// SectionHapticFeedback controls which (if any) haptic feedback
/// should be played when clicking the header of a section.
/// Can be applied to both `Accordion` for all sections or
/// to `AccordionSection` for individula sections.
enum SectionHapticFeedback {
  none,
  light,
  medium,
  heavy,
  selection,
  vibrate,
}

/// spring to set the speed of opening/closing animations of a section
const springFast = SpringDescription(mass: 1, stiffness: 200, damping: 30);

/// `CommonParams` is used for both `Accordion` (for all sections)
/// and `AccordionSections` for individual sections.
mixin CommonParams {
  late final Color? headerBackgroundColor;
  late final Color? headerBackgroundColorOpened;
  late final double? headerBorderRadius;
  late final EdgeInsets? headerPadding;
  late final Widget? rightIcon;
  late final RxBool? flipRightIconIfOpen = true.obs;
  late final Color? contentBackgroundColor;
  late final Color? contentBorderColor;
  late final double? contentBorderWidth;
  late final double? contentBorderRadius;
  late final double? contentHorizontalPadding;
  late final double? contentVerticalPadding;
  late final double? paddingBetweenSections;
  late final double? paddingBetweenClosedSections;
  late final ScrollIntoViewOfItems? scrollIntoViewOfItems;
  late final SectionHapticFeedback? sectionOpeningHapticFeedback;
  late final SectionHapticFeedback? sectionClosingHapticFeedback;
  late final String? accordionId;
}

/// Controller for `Accordion` widget
class ListController extends GetxController {
  final controller = AutoScrollController(axis: Axis.vertical);
  UniqueKey? openSection;
  final childrenCtrls = <String, List<ListController>>{};
  final keys = List<UniqueKey>.generate(1000, (index) => UniqueKey());

  StreamController<String> controllerIsOpen =
      StreamController<String>.broadcast();

  /// Maximum number of open sections at any given time.
  /// Opening a new section will close the "oldest" open section
  int maxOpenSections = 1;

  /// adds or removes a section key from the list of open sections
  /// and notifies sections to open or close accordingly
  void updateSection(UniqueKey key) {
    if (openSection == key) {
      openSection = null;
    } else {
      openSection = key;
    }

    clearChildren(key);

    controllerIsOpen.sink.add('update list');
  }

  void clearChildren(UniqueKey key) {
    var childrenLocal = childrenCtrls.values.mapMany((item) => item);

    for (final child in childrenLocal) {
      child.openSection = null;
      child.controllerIsOpen.sink.add('update list');
      child.clearChildren(key);
    }
  }

  @override
  void onClose() {
    controllerIsOpen.close();
    controller.dispose();
    super.onClose();
  }
}

/// Controller for `AccordionSection` widgets
class SectionController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final controller = AnimationController(vsync: this);
  final isSectionOpen = false.obs;

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}
