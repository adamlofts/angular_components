// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';

import 'package:ngdart/angular.dart';
import 'package:ngdart/experimental.dart';
import 'package:ngcomponents/utils/browser/dom_service/dom_service.dart';
import 'package:ngcomponents/utils/browser/dom_service/dom_service_webdriver_testability.dart';
import 'package:ngcomponents/utils/disposer/disposer.dart';

export 'package:ngcomponents/utils/browser/dom_service/dom_service.dart';

// This is a pattern which allows a singleton service to be shared in an
// application without binding the service at the application level, while
// still allowing an application to override a service if they so choose.
// This allows components to define the service they need with reasonable
// defaults. It allows component and service authors to add singleton services
// that require injectables. If you just need a singleton pattern consider
// using dart's factory pattern.

/// Factory for [DomService].
const domServiceBinding = FactoryProvider(
  DomService,
  createDomService,
  deps: [
    [DomService, Optional(), SkipSelf()],
    [Disposer, Optional()],
    NgZone,
    Window,
  ],
);

/// DI module for dom service.
const domServiceModule = Module(provide: [domServiceBinding]);

// Shared DomService resource. Currently there is only one per application.
DomService? _singletonService;

@Injectable()
DomService createDomService(@Optional() @SkipSelf() DomService? service,
    @Optional() Disposer? disposer, NgZone zone, Window window) {
  // If DomService was bound higher up the tree use that instance. This allows
  // an application to override the service at root.
  if (service != null) return service;

  if (_singletonService != null) {
    return _singletonService!;
  }

  _singletonService = DomService(zone, window);

  createDomServiceWebdriverTestability(_singletonService).register();

  disposer?.addFunction(() {
    _singletonService = null;
  });

  return _singletonService!;
}

// Initializes DOM service and wires up DomService and AcxRootDomRender
// to send layout change notifications only if dom has been mutated by angular.
void setupAcxRootDomRenderer(Injector appInjector) {
  appInjector.get(DomService)
    ..isDomMutatedPredicate = isDomRenderDirty
    ..resetIsDomMutated = resetDomRenderDirty
    ..init();
}
