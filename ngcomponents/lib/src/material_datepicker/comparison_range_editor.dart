// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:core';

import 'package:ngdart/angular.dart';
import 'package:intl/intl.dart';
import 'package:ngcomponents/material_datepicker/comparison_option.dart';
import 'package:ngcomponents/material_datepicker/date_range_input.dart';
import 'package:ngcomponents/material_datepicker/range.dart';
import 'package:ngcomponents/src/material_datepicker/date_range_editor_model.dart';
import 'package:ngcomponents/material_list/material_list.dart';
import 'package:ngcomponents/material_list/material_list_item.dart';
import 'package:ngcomponents/material_select/material_dropdown_select.dart';
import 'package:ngcomponents/material_select/material_select_item.dart';
import 'package:ngcomponents/material_toggle/material_toggle.dart';
import 'package:ngcomponents/model/date/date.dart';
import 'package:ngcomponents/utils/angular/scroll_host/angular_2.dart';

/// Component used to edit the `comparison` field of a [DateRangeComparison].
/// This is meant for use in the `material-date-range-picker`, and doesn't make
/// much sense outside of it.
///
/// __Example Usage:__
///
///     <comparison-range-editor [model]="model"></comparison-range-editor>
///
@Component(
  selector: 'comparison-range-editor',
  templateUrl: 'comparison_range_editor.html',
  styleUrls: ['comparison_range_editor.scss.css'],
  directives: [
    DateRangeInputComponent,
    MaterialListComponent,
    MaterialListItemComponent,
    MaterialToggleComponent,
    NgIf,
    NgFor,
    MaterialDropdownSelectComponent,
    MaterialSelectItemComponent
  ],
)
class ComparisonRangeEditorComponent {
  final NgZone _ngZone;
  final ScrollHost? _scrollHost;
  ComparisonRangeEditorComponent(this._ngZone, @Optional() this._scrollHost);

  /// A mutable model describing a comparison date range. The only expected
  /// non-test implementation is [DateRangeEditorModel].
  @Input()
  HasComparisonRange? model;

  final Map<ComparisonOption, String> _optionMsgCache = {};
  DatepickerDateRange? _primaryDateRange;

  bool get comparisonSupported => model?.comparisonSupported ?? false;

  // Handle the comparison toggle.
  bool get comparisonEnabled => model?.comparisonEnabled ?? false;

  set comparisonEnabled(bool? value) {
    var enabled = value ?? false;
    model?.comparisonEnabled = enabled;
    if (enabled && _scrollHost != null) {
      // When users turn on toggle, scrolls to the end to make
      // comparison options discoverable.
      _ngZone.runAfterChangesObserved(
          () => _scrollHost?.scrollToPosition(_scrollHost?.scrollLength ?? 0));
    }
  }

  static final comparisonHeaderMsg = Intl.message('Compare',
      name: 'comparisonHeaderMsg',
      desc: 'Label for a toggle that turns time comparison on/off.');

  /// Gets display message from given option.
  String? comparisonOptionMsg(ComparisonOption option) {
    if (_primaryDateRange != model?.primaryRange) {
      _updateOptionMsg();
      _primaryDateRange = model?.primaryRange;
    }
    return _optionMsgCache[option];
  }

  void _updateOptionMsg() {
    if (model != null) {
      for (var option in model!.validComparisonOptions) {
        _optionMsgCache[option] =
            option.computeComparisonRange(model!.primaryRange)?.title ??
                option.displayName;
      }
    }
  }
}
