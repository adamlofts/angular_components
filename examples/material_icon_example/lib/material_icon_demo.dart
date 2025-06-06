// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ngdart/angular.dart';
import 'package:ngcomponents/material_button/material_button.dart';
import 'package:ngcomponents/material_icon/material_icon.dart';
import 'package:ngcomponents/material_input/material_input.dart';
import 'package:ngcomponents/model/ui/icon.dart';
import 'package:angular_gallery_section/annotation/gallery_section_config.dart';

@GallerySectionConfig(
  displayName: 'Material Icon',
  docs: [MaterialIconComponent],
  demos: [MaterialIconDemoComponent],
)
class GlyphGalleryConfig {}

@Component(
  selector: 'material-icon-demo',
  directives: [
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialInputComponent
  ],
  exports: [done, doneAll, doneOutline],
  templateUrl: 'material_icon_demo.html',
  styleUrls: ['material_icon_demo.scss.css'],
  preserveWhitespace: true,
)
class MaterialIconDemoComponent {
  Icon iconModel = done;
  String iconColor = 'blue';
  String iconName = 'alarm';
}

const done = Icon('done');
const doneAll = Icon('done_all');
const doneOutline = Icon('done_outline');
