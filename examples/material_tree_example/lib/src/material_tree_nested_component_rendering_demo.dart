// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ngdart/angular.dart';
import 'package:ngcomponents/material_tree/material_tree.dart';
import 'material_tree_demo_options.dart' as data;
import 'package:ngcomponents/model/selection/selection_options.dart';
import 'package:ngcomponents/model/ui/has_factory.dart';

import 'material_tree_component_renderer.template.dart' as tree;

/// An example that renders a [MaterialTreeComponent] with nested options.
///
/// All options are formatted by [sampleItemRenderer].
@Component(
  selector: 'material-tree-nested-component-rendering-demo',
  directives: [MaterialTreeComponent],
  template: r'''
      <h1>Nested with custom component renderer</h1>
      <pre>
  // See material_tree_nested_single_demo.dart
  final SelectionOptions nestedOptions = data.nestedOptions;

  // See material_tree_component_renderer.dart
  ComponentRenderer sampleComponentRenderer = (_) => ComponentRendererExample;
      </pre>
      <pre>
  &lt;material-tree
    [options]="nestedOptions"
    [factoryRenderer]="sampleComponentFactory"&gt;
  &lt;/material-tree&gt;
      </pre>
      <div class="shadow" style="width: 400px; margin: 24px;">
        <material-tree
          [options]="nestedOptions"
          [factoryRenderer]="sampleComponentFactory">
        </material-tree>
      </div>
    ''',
  styleUrls: ['material_shadow.scss.css'],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class MaterialTreeNestedComponentRenderingComponent {
  final SelectionOptions nestedOptions = data.nestedOptions;
  FactoryRenderer? sampleComponentFactory =
      (_) => tree.ComponentRendererExampleNgFactory;

  @ViewChild(MaterialTreeComponent)
  MaterialTreeComponent? materialTree;
}
