// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ngdart/angular.dart';
import 'package:ngcomponents/material_tree/material_tree.dart';
import 'material_tree_demo_options.dart' as data;
import 'package:ngcomponents/model/selection/selection_model.dart';
import 'package:ngcomponents/model/selection/selection_options.dart';

@Component(
  selector: 'material-tree-nested-filterable-demo',
  directives: [MaterialTreeDropdownComponent],
  template: r'''
      <h1>Dropdown with filtering (nested)</h1>
      <div class="shadow" elevation="1" style="width: 400px; margin: 24px;">
        <div style="padding: 8px">
          <strong>Selected:</strong> {{singleSelection.selectedValues}}
        </div>
      </div>
      <div class="shadow" style="width: 388px; margin: 24px; padding: 12px;">
        <material-tree-dropdown
          [options]="filterableNestedOptions"
          [selection]="singleSelection">
        </material-tree-dropdown>
      </div>
    ''',
  styleUrls: ['material_shadow.scss.css'],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class MaterialTreeDropdownNestedFilterableDemoComponent {
  final SelectionOptions filterableNestedOptions = data.filterableNestedOptions;
  final SelectionModel singleSelection = SelectionModel.single();

  @ViewChild(MaterialTreeDropdownComponent)
  MaterialTreeDropdownComponent? materialTreeDropdownComponent;
}
