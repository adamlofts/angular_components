// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ngdart/angular.dart';
import 'package:ngcomponents/app_layout/material_stackable_drawer.dart';
import 'package:ngcomponents/content/deferred_content.dart';
import 'package:ngcomponents/material_button/material_button.dart';
import 'package:ngcomponents/material_icon/material_icon.dart';
import 'package:ngcomponents/material_toggle/material_toggle.dart';

@Component(
  selector: 'mat-stacking-drawer-demo',
  directives: [
    DeferredContentDirective,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialStackableDrawerComponent,
    MaterialToggleComponent,
  ],
  templateUrl: 'stacking_drawer_example.html',
  styleUrls: [
    'app_layout_example.scss.css',
    'package:ngcomponents/app_layout/layout.scss.css',
    'stacking_drawer_example.scss.css',
  ],
)
class MaterialStackingDrawerExample {
  bool end = false;
  bool overlay = false;

  bool drawerVisible = false;
  bool drawer2Visible = false;
}
