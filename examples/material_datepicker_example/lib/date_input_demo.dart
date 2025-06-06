// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ngdart/angular.dart';
import 'package:ngcomponents/material_datepicker/date_input.dart';
import 'package:ngcomponents/material_datepicker/module.dart';
import 'package:ngcomponents/material_input/material_input.dart';
import 'package:ngcomponents/model/date/date.dart';

@Component(
  selector: 'date-input-demo',
  directives: [DateInputDirective, materialInputDirectives],
  providers: [datepickerBindings],
  templateUrl: 'date_input_demo.html',
)
class DateInputDemoComponent {
  Date requiredDate = Date.today();
  Date? optionalDate;

  Date get today => Date.today();

  String formatDate(Date? date) => date == null ? '(null)' : date.toString();

  void resetToToday() {
    requiredDate = today;
    optionalDate = today;
  }
}
