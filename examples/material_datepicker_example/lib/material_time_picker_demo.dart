// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ngdart/angular.dart';
import 'package:ngcomponents/material_datepicker/material_time_picker.dart';
import 'package:ngcomponents/material_datepicker/module.dart';
import 'package:ngcomponents/utils/browser/window/module.dart';

@Component(
  selector: 'material-time-picker-demo',
  providers: [windowBindings, datepickerBindings],
  directives: [MaterialTimePickerComponent],
  templateUrl: 'material_time_picker_demo.html',
)
class MaterialTimePickerDemoComponent {
  DateTime time = DateTime.now();
  DateTime? optionalTime;
}
