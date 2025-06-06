// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ngdart/angular.dart';
import 'package:ngcomponents/src/material_tooltip/tooltip_controller.dart';
import 'package:ngcomponents/utils/disposer/disposer.dart';

const materialTooltipBindings = [ClassProvider(TooltipController)];

const materialTooltipModule = Module(provide: materialTooltipBindings);

// This is a pattern which allows a singleton service to be shared in an
// application without binding the service at the application level, while
// still allowing an application to override a service if they so choose.
// This allows components to define the service they need with reasonable
// defaults. It allows component and service authors to add singleton services
// that require injectables. If you just need a singleton pattern consider
// using dart's factory pattern.

/// Factory for [TooltipController].
const tooltipControllerBinding = FactoryProvider(
  TooltipController,
  createTooltipController,
  deps: [
    [TooltipController, Optional(), SkipSelf()],
    [Disposer, Optional()],
  ],
);

// Shared [TooltipController] resource. Currently there is only one per
// application.
TooltipController? _singletonController;

@Injectable()
TooltipController? createTooltipController(
    @Optional() @SkipSelf() TooltipController? controller,
    @Optional() Disposer? disposer) {
  // If TooltipController was bound higher up the tree use that instance. This
  // allows an application to override the service at root.
  if (controller != null) return controller;

  if (_singletonController != null) return _singletonController;

  _singletonController = TooltipController();
  disposer?.addFunction(() {
    _singletonController = null;
  });
  return _singletonController;
}
