// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ngdart/angular.dart';
import 'package:ngcomponents/material_datepicker/material_date_time_picker.dart';
import 'package:ngcomponents/material_datepicker/module.dart';
import 'package:ngcomponents/utils/browser/window/module.dart';

@Component(
  selector: 'material-date-time-picker-demo',
  providers: [windowBindings, datepickerBindings],
  directives: [MaterialDateTimePickerComponent],
  templateUrl: 'material_date_time_picker_demo.html',
)
class MaterialDateTimePickerDemoComponent {
  DateTime dateTime = DateTime.now();
  DateTime? optionalTime;
}
