// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';

import 'package:ngdart/angular.dart';
import 'package:intl/intl.dart';
import 'package:ngcomponents/button_decorator/button_decorator.dart';
import 'package:ngcomponents/dynamic_component/dynamic_component.dart';
import 'package:ngcomponents/focus/keyboard_only_focus_indicator.dart';
import 'package:ngcomponents/material_checkbox/material_checkbox.dart';
import 'package:ngcomponents/material_icon/material_icon.dart';
import 'package:ngcomponents/src/material_tree/material_tree_node.dart';
import 'package:ngcomponents/src/material_tree/material_tree_root.dart';
import 'package:ngcomponents/mixins/material_dropdown_base.dart';
import 'package:ngcomponents/model/selection/selection_options.dart';

const materialTreeLeftPaddingToken =
    OpaqueToken('MaterialTreeGroupComponent_materialTreeLeftPaddingToken');

/// An internal component for rendering selection options.
///
/// It must be rendered as a child of a [MaterialTreeRoot] implementation.
///
/// __Example use__:
///     <material-tree-group [group]="group"></material-tree-group>
@Component(
  selector: 'material-tree-group',
  changeDetection: ChangeDetectionStrategy.onPush,
  directives: [
    ButtonDirective,
    DynamicComponent,
    MaterialIconComponent,
    KeyboardOnlyFocusIndicatorDirective,
    MaterialCheckboxComponent,
    MaterialTreeGroupComponent,
    NgFor,
    NgIf,
    NgClass
  ],
  directiveTypes: [
    Typed<MaterialTreeGroupComponent>.of([#T]),
  ],
  templateUrl: 'material_tree_group.html',
  styleUrls: ['material_tree_group.scss.css'],
)
class MaterialTreeGroupComponent<T> extends MaterialTreeNode<T?>
    implements OnDestroy {
  @HostBinding('attr.role')
  static const hostRole = 'group';

  static final defaultConstantLeftPadding = 24;
  static final baseGridStep = 8; // Based on $mat-grid
  static final rowIndentationStep =
      baseGridStep * 5; // DUPLICATION of _size.scss
  static final checkboxWidth = baseGridStep * 5; // DUPLICATION of _size.scss
  final DropdownHandle? _dropdownHandle;
  @Input()
  int level = 0;
  @Input()
  bool parentHasCheckbox = false;
  @Input()
  @override
  bool allowParentSingleSelection = false;
  @Input()
  @override
  bool allowParentMultiSelection = true;
  @Input()
  bool deselectOnTrigger = true;
  final MaterialTreeRoot _root;

  int? _maxInitialOptionsShown;

  /// Maximum number of options to show and hide the rest with a "View more"
  /// link.
  ///
  /// If not specified, all options are displayed and "View more" link won't be
  /// visible.
  int? get maxInitialOptionsShown => _maxInitialOptionsShown;

  @Input()
  set maxInitialOptionsShown(int? value) {
    _maxInitialOptionsShown = value;

    if (_maxInitialOptionsShown != null) {
      _sliceOptionGroup(_maxInitialOptionsShown!);
    }
  }

  OptionGroup _visibleGroup = OptionGroup([]);

  /// The current visible options group.
  ///
  /// This is the same as [group] when [maxInitialOptionsShown] is not set,
  /// otherwise it contains the first [maxInitialOptionsShown] options from
  /// [group].
  OptionGroup get visibleGroup => _visibleGroup;

  /// The constant padding for every row.
  final String fixedPadding;

  MaterialTreeGroupComponent(
      this._root,
      ChangeDetectorRef changeDetector,
      [@Optional()
          this._dropdownHandle,
      @Optional()
      @Inject(materialTreeLeftPaddingToken)
          int? constantLeftPadding])
      : fixedPadding = '${constantLeftPadding ?? defaultConstantLeftPadding}px',
        super(_root as MaterialTreeRoot<T>, changeDetector);

  // This is only used to standardize all the different group components.
  @HostBinding('class.material-tree-group')
  final bool isMaterialTreeGroup = true;

  bool showCheckbox(option) =>
      showSelectionState &&
      (isSelectable(option) || showDisabledCheckbox(option));

  // This returns the item indentation based on it's level.
  // Level 0 means it's the higher parent in the hierarchy, and it gets
  // a constant definition.
  String getIndent(option) {
    int padding = 0;
    if (level > 0) {
      padding += (level - 1) * rowIndentationStep;
      if (!showCheckbox(option) || parentHasCheckbox) {
        padding += checkboxWidth;
      }
    }

    return '${padding}px';
  }

  String getLastIndent(OptionGroup group) {
    if (group.isNotEmpty) {
      return getIndent(group.last);
    }

    return '0px';
  }

  void handleExpansion(Event e, Object option) {
    toggleExpansion(option as T);
    e.stopPropagation();
  }

  void handleSelectionOrExpansion(Event e, Object option) {
    if (!isExpandable(option as T) && isSelectable(option as T) ||
        (allowParentSingleSelection && isSelectable(option as T)) ||
        (allowParentMultiSelection && isSelectable(option as T))) {
      final previouslyToggledNode = _root.previouslyToggledNode;
      _root.previouslyToggledNode = option;

      // If [option] is already selected, do not deselect it unless
      // [deselectOnTrigger] is `true`.
      if (!isSelected(option as T) || deselectOnTrigger) {
        setSelectionState(option as T, !isSelected(option as T));
      }

      // Handle shift + select behavior for multi-selection.
      if (isMultiSelect &&
          previouslyToggledNode != null &&
          (e is MouseEvent && e.shiftKey)) {
        toggleSelectionRangeInclusive(previouslyToggledNode, option as T,
            isSelected(previouslyToggledNode));
      }

      // For single select, within a dropdown, close the dropdown on toggle.
      if (!isMultiSelect && !allowParentSingleSelection) {
        _dropdownHandle?.close();
      }
    } else {
      toggleExpansion(option as T);
    }
    e.stopPropagation();
  }

  void _sliceOptionGroup(int end) {
    if (end < group.length) {
      _visibleGroup = group.slicedOptionGroup(0, end);
    } else {
      _visibleGroup = group;
    }
  }

  /// Sets option group and visible option group if [maxInitialOptionsShown] is
  /// specified.
  @Input()
  @override
  set group(OptionGroup _group) {
    super.group = _group as OptionGroup<T>;

    if (_maxInitialOptionsShown == null) {
      _visibleGroup = group;
      return;
    }

    _sliceOptionGroup(_maxInitialOptionsShown!);
  }

  /// Toggles on the collapsed options.
  void viewMoreOptions(Event event) {
    event.preventDefault();
    event.stopImmediatePropagation();

    _visibleGroup = group;
  }

  /// Whether "View more" link should be visible.
  bool get viewMoreLinkVisible =>
      _maxInitialOptionsShown != null && !identical(_visibleGroup, group);

  @override
  void ngOnDestroy() {
    onDestroy();
  }

  static final viewMoreMsg = Intl.message('View more',
      desc: 'Label for a link that allows user to see the collapsed options.');
}
