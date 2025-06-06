// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:build/build.dart';
import 'package:mustache_template/mustache.dart';

/// Writes a [newAssetId] via the provided [buildStep].
///
/// The contents of the asset is the result of rendering a mustache template
/// with [mustacheContext]. The provided [templatePath] is assumed to be rooted
/// in this library.
Future<void> writeAsset(BuildStep buildStep, String templatePath,
    Map<String, dynamic> mustacheContext, AssetId newAssetId) async {
  final templateId = AssetId('angular_gallery', templatePath);
  final String template = await buildStep.readAsString(templateId);
  final mustacheTemplate = Template(template, lenient: true);

  var output = mustacheTemplate.renderString(mustacheContext);

  // For debugging
  //print(output);

  await buildStep.writeAsString(newAssetId, output);
}
