// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:ngdart/angular.dart';
//import 'package:ngforms/ngforms.dart';
import 'package:ngcomponents/focus/focus.dart';
import 'package:ngcomponents/focus/focus_list.dart';
import 'package:ngcomponents/laminate/components/modal/modal.dart';
import 'package:ngcomponents/laminate/overlay/module.dart';
import 'package:ngcomponents/material_button/material_button.dart';
import 'package:ngcomponents/material_dialog/material_dialog.dart';
import 'package:ngcomponents/material_expansionpanel/material_expansionpanel.dart';
import 'package:ngcomponents/material_expansionpanel/material_expansionpanel_auto_dismiss.dart';
import 'package:ngcomponents/material_expansionpanel/material_expansionpanel_set.dart';
import 'package:ngcomponents/material_icon/material_icon.dart';
import 'package:ngcomponents/material_input/material_input.dart';
import 'package:ngcomponents/material_yes_no_buttons/material_yes_no_buttons.dart';
import 'package:ngcomponents/model/action/async_action.dart';
import 'package:angular_gallery_section/annotation/gallery_section_config.dart';

@GallerySectionConfig(
  displayName: 'Material ExpansionPanel',
  docs: [
    MaterialExpansionPanel,
    MaterialExpansionPanelSet,
    MaterialExpansionPanelAutoDismiss,
  ],
  demos: [MaterialExpansionDemo],
)
class MaterialExpansionPanelGalleryConfig {}

@Component(
  selector: 'material-expansion-demo',
  providers: [overlayBindings],
  directives: [
    AutoFocusDirective,
    FocusListDirective,
    MaterialIconComponent,
    MaterialButtonComponent,
    MaterialExpansionPanel,
    MaterialExpansionPanelAutoDismiss,
    MaterialExpansionPanelSet,
    MaterialDialogComponent,
    MaterialInputComponent,
    materialInputDirectives,
    MaterialYesNoButtonsComponent,
    ModalComponent,
    NgModel,
  ],
  styleUrls: ['material_expansionpanel_example.scss.css'],
  templateUrl: 'material_expansionpanel_example.html',
  preserveWhitespace: true,
)
class MaterialExpansionDemo {
  String name = 'Test';
  bool isCustomToolBeltPanelExpanded = true;

  bool showConfirmation = false;
  Completer<bool>? dialogFutureCompleter;

  void showConfirmationDialog(AsyncAction event) {
    showConfirmation = true;
    dialogFutureCompleter = Completer();
    event.cancelIf(dialogFutureCompleter!.future);
  }

  void closeDialog(bool proceed) {
    showConfirmation = false;
    if (dialogFutureCompleter != null) {
      dialogFutureCompleter!.complete(!proceed);
    }
  }
}
