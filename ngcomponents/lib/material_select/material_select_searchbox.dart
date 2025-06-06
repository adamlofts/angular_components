// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';

import 'package:ngdart/angular.dart';
import 'package:ngcomponents/focus/focus_interface.dart';
import 'package:ngcomponents/material_input/material_input.dart';
import 'package:ngcomponents/mixins/focusable_mixin.dart';
import 'package:ngcomponents/model/selection/select.dart';
import 'package:ngcomponents/utils/async/async.dart';
import 'package:ngcomponents/utils/browser/events/events.dart';
import 'package:ngforms/ngforms.dart';

/// A simple component that maps an input box to the [Filterable] interface.
///
/// Any input typed will be used to call the filter method Filterable.
@Component(
  selector: 'material-select-searchbox',
  directives: [materialInputDirectives, NgModel],
  providers: [ExistingProvider(Focusable, MaterialSelectSearchboxComponent)],
  styleUrls: ['material_select_searchbox.scss.css'],
  templateUrl: 'material_select_searchbox.html',
)
class MaterialSelectSearchboxComponent extends FocusableMixin
    implements OnDestroy {
  Filterable? _filterable;
  String _inputText = '';

  /// The last future of filtering the options.
  DisposableFuture? _lastFilterFuture;

  /// Query text to filter on.
  String get inputText => _inputText;
  set inputText(String text) {
    if (_inputText != text) {
      _inputText = text;
      _filter();
    }
  }

  /// Set a handle to a [Filterable] interface to use.
  @Input()
  set filterable(Filterable callback) {
    if (_filterable != callback) {
      _filterable = callback;
      _filter();
    }
  }

  @Input()
  String? label;

  void _filter() {
    _lastFilterFuture?.dispose();
    _lastFilterFuture = _filterable?.filter(_inputText);
  }

  @ViewChild(MaterialInputComponent)
  set input(MaterialInputComponent? input) {
    focusable = input;
  }

  /// Allow typing a space character when the searchbox is used inside another
  /// component that assumes space to be an action (such as select).
  void stopSpaceKeyPropagation(KeyboardEvent keyboardEvent) {
    if (isSpaceKey(keyboardEvent)) {
      keyboardEvent.stopPropagation();
    }
  }

  @override
  ngOnDestroy() {
    _lastFilterFuture?.dispose();
    _lastFilterFuture = null;
  }
}
