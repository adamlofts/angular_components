// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';

import 'package:ngdart/angular.dart';
import 'package:ngcomponents/content/deferred_content_aware.dart';
import 'package:ngcomponents/src/laminate/components/modal/modal_controller_directive.dart';
import 'package:ngcomponents/laminate/overlay/overlay.dart';
import 'package:ngcomponents/model/action/async_action.dart';
import 'package:ngcomponents/utils/browser/dom_service/dom_service.dart';
import 'package:ngcomponents/utils/disposer/disposer.dart';

/// May be added to DI to enforce that a single [Modal] is visible at a time.
///
/// Creates a stack of modals, hiding the previous one when a new is shown.
///
/// __Example use:__
///     bootstrap(MyApp, const [GlobalModalStack]);
///
/// **NOTE**: Usage of this removes [Modal]'s built in LIFO stack.
@Injectable()
class GlobalModalStack {
  final List<Modal> _stack = <Modal>[];

  /// Size of the stack.
  int get length => _stack.length;

  /// Should be triggered when [modal] is closed.
  void onModalClosed(Modal modal) {
    assert(_stack.last == modal);
    if (_stack.last == modal) {
      _stack.removeLast();
      if (_stack.isNotEmpty) {
        _stack.last.hidden = false;
      }
    } else {
      _stack.remove(modal);
    }
  }

  /// Should be triggered when [modal] is opened.
  void onModalOpened(Modal modal) {
    if (_stack.isNotEmpty) {
      _stack.last.hidden = true;
    }
    _stack.add(modal);
  }

  /// Tell all the modals to close in reverse order.
  Future<void> closeAll() async {
    for (var modal in _stack.reversed.toList()) {
      await modal.close();
    }
  }
}

/// An ADT that can be injected by content that lives within a modal.
abstract class Modal {
  /// Attempts to close the modal.
  ///
  /// Returns a future that completes with `true` if it succeeds.
  Future<bool> close();

  /// Events that fires before making [visible] `false`.
  ///
  /// See [AsyncAction] for the API for deferring or cancelling the event.\
  @Output('close')
  Stream<AsyncAction<dynamic>?> get onClose;

  /// Attempts to open the modal.
  ///
  /// Returns a future that completes with `true` if it succeeds.
  Future<bool> open();

  /// Events that fire before making [visible] `true`.
  ///
  /// See [AsyncAction] for the API for deferring or cancelling the event.
  @Output('open')
  Stream<AsyncAction<dynamic>?> get onOpen;

  /// A stream of click events on the modal.
  ///
  /// Only is active if [preventInteraction] is `true`.
  @Output()
  Stream<void> get shieldClick;

  /// Whether the modal is visible in the DOM.
  ///
  /// **NOTE**: It is possible it is temporarily [hidden] if another modal has
  /// taken over but still reports `true` for visible.
  bool get visible;

  /// Events that fire when [visible] changes.
  @Output('visibleChange')
  Stream<bool> get onVisibleChanged;

  /// Whether the modal is temporarily hidden.
  bool get hidden;

  /// Change the temporary visibility of the modal.
  set hidden(bool hidden);
}

/// A transcluding component that hosts inner content in a centered overlay.
///
/// A `<modal>` that is created within the context of another `<modal>` (nested)
/// automatically forms a LIFO-stack in-which the newest modal is shown and the
/// previous modals are not. Once the newest modal is dismissed, the next newest
/// will be shown.
///
/// Modals are [DeferredContentAware]. Use `*deferredContent` to avoid having
/// costly inner-content be created before the modal is visible.
///
/// If [preventInteraction] is `true` (it is by default), interaction with the
/// rest of the application may be disabled until the dialog is closed.
///
/// __Example usage:__
///     <!-- With aggressive content -->
///     <modal [preventInteraction]="isModal" ([visible])="showDialog">
///       Hello World!
///     </modal>
///
///     <!-- Or, with deferred content -->
///     <modal ([visible])="showDialog">
///       <template deferredContent>
///         <expensive-component></expensive-component>
///       </template>
///     </modal>
///
/// __Events:__
///
/// - `open` -- Fires whenever the modal is opening (before visibility).
/// - `visible` -- Fires whenever visibility changes.
/// - `close` --  Fires whenever the modal is closing (before visibility).
/// - `shieldClick` -- Fires whenever the modal background is pressed.
///
/// __Properties:__
///
/// - `preventInteraction` -- Set to false to allow interaction with your app.
/// - `visible` -- Set in order to change visibility. This will trigger an open
///                and close interaction cycle that allows users to cancel.
@Component(
  selector: 'modal',
  providers: [
    ExistingProvider(DeferredContentAware, ModalComponent),
    ExistingProvider(Modal, ModalComponent),
  ],
  directives: [ModalControllerDirective],
  template: r'''
    <template [modalController]="resolvedOverlayRef">
      <ng-content></ng-content>
    </template>
  ''',
  changeDetection: ChangeDetectionStrategy.onPush,
  // TODO(google): Change preserveWhitespace to false to improve codesize.
  preserveWhitespace: true,
  visibility: Visibility.all, // Injected by dialog, et al.
)
class ModalComponent
    implements DeferredContentAware, Modal, AfterViewInit, OnDestroy {
  final Element _element;
  final Modal? _parentModal;
  final GlobalModalStack? _stack;
  final DomService _domService;

  @override
  Stream<AsyncAction<dynamic>?> get onOpen => _onOpen.stream;
  final _onOpen = StreamController<AsyncAction<dynamic>?>.broadcast(sync: true);

  @override
  Stream<AsyncAction<dynamic>?> get onClose => _onClose.stream;
  final _onClose =
      StreamController<AsyncAction<dynamic>?>.broadcast(sync: true);

  @override
  Stream<bool> get onVisibleChanged => _onVisibleChanged.stream;
  final _onVisibleChanged = StreamController<bool>.broadcast(sync: true);

  final Disposer _disposer = Disposer.oneShot();

  bool _isDestroyed = false;
  bool _isHidden = false;
  bool _isVisible = false;
  final OverlayRef _resolvedOverlayRef;
  Element? _lastFocusedElement;

  /// Whether to return focus to the last focused element before the modal
  /// opened.
  ///
  /// Defaults to true.
  @Input()
  bool restoreFocus = true;

  Future<bool>? _pendingOpen;
  Future<bool>? _pendingClose;

  ModalComponent(OverlayService overlayService, this._element, this._domService,
      @Optional() @SkipSelf() this._parentModal, @Optional() this._stack)
      : _resolvedOverlayRef =
            overlayService.createOverlayRefSync(OverlayState.Dialog) {
    _disposer
      ..addDisposable(_resolvedOverlayRef)
      ..addStreamSubscription(_resolvedOverlayRef.onVisibleChanged
          .listen(_onOverlayVisibleChanged));
  }

  @Input()
  set preventInteraction(bool preventInteraction) {
    _resolvedOverlayRef.state.captureEvents = preventInteraction != false;
  }

  @override
  void ngAfterViewInit() {
    // Propagate CSS classes of the host element to the overview element for
    // integration with Angular CSS shimming.
    var hostClassName = _element.className;
    resolvedOverlayRef.overlayElement.className += ' $hostClassName';
  }

  @override
  void ngOnDestroy() {
    if (visible) {
      _hideModalOverlay();
    }
    _isDestroyed = true;
    _disposer.dispose();
  }

  // A callback received when the overlay reports a visibility change.
  void _onOverlayVisibleChanged(bool isVisible) {
    _isVisible = isVisible;
    _onVisibleChanged.add(_isVisible);
  }

  @override
  Stream<void> get shieldClick => _resolvedOverlayRef.onPanePressed
      .where((MouseEvent e) => e.eventPhase == Event.AT_TARGET);

  @override
  Stream<bool> get contentVisible => onVisibleChanged;

  OverlayRef get resolvedOverlayRef => _resolvedOverlayRef;

  @HostBinding('attr.pane-id')
  String get uniquePaneId => _resolvedOverlayRef.uniqueId ?? '';

  // Make the overlay hosting this modal visible.
  //
  // If it has a parent, we should temporarily hide it.
  void _showModalOverlay({bool temporary = false}) {
    if (!temporary) {
      _saveFocus();
      if (_stack != null) {
        _stack?.onModalOpened(this);
      } else if (_parentModal != null) {
        _parentModal?.hidden = true;
      }
    }
    _resolvedOverlayRef.setVisible(true);
  }

  // Make the overlay hosting this modal hidden.
  //
  // If it has a parent, we should re-show it.
  void _hideModalOverlay({bool temporary = false}) {
    if (!temporary) {
      _restoreFocus();
      if (_stack != null) {
        _stack?.onModalClosed(this);
      } else if (_parentModal != null) {
        _parentModal?.hidden = false;
      }
    }
    _resolvedOverlayRef.setVisible(false);
  }

  void _saveFocus() {
    _lastFocusedElement = restoreFocus ? document.activeElement : null;
  }

  void _restoreFocus() {
    if (_lastFocusedElement == null) return;
    if (_stack != null && _stack!.length > 1 || _parentModal != null) return;
    final elementToFocus = _lastFocusedElement;
    _domService.scheduleWrite(() {
      // Only restore focus if the current active element is inside this overlay
      // or the focus was lost.
      // Note in a browser activeElement is never null and the null check below
      // is only for testing.
      if (document.activeElement != null &&
          (_resolvedOverlayRef.overlayElement
                  .contains(document.activeElement) ||
              document.activeElement == document.body)) {
        // Note that if the [elementToFocus] is no longer in the document,
        // the body element will be focused instead.
        elementToFocus!.focus();
      }
    });
  }

  @override
  Future<bool> open() {
    if (_pendingOpen == null) {
      final controller = AsyncActionController<dynamic>();
      controller.execute(_showModalOverlay);
      _pendingOpen = controller.action!.onDone.then((completed) {
        _pendingOpen = null;

        if (completed == null) {
          return false;
        }

        if (completed is bool) {
          return completed;
        }
        return false;
      });
      _onOpen.add(controller.action);
    }

    return _pendingOpen ?? Future.value(false);
  }

  @override
  Future<bool> close() {
    if (_pendingClose == null) {
      final controller = AsyncActionController<dynamic>();
      controller.execute(_hideModalOverlay);
      _pendingClose = controller.action!.onDone.then((completed) {
        _pendingClose = null;
        if (completed == null) {
          return false;
        }

        if (completed is bool) {
          return completed;
        }
        return false;
      });
      _onClose.add(controller.action);
    }
    return _pendingClose ?? Future.value(false);
  }

  @override
  bool get visible => _isVisible;
  @Input()
  set visible(bool visible) {
    if (_isVisible == visible || _isDestroyed) return;
    if (visible == true) {
      open();
    } else {
      close();
    }
  }

  @override
  bool get hidden => _isHidden;

  @override
  set hidden(bool hidden) {
    _isHidden = hidden;
    if (_isHidden) {
      _hideModalOverlay(temporary: true);
    } else {
      _showModalOverlay(temporary: true);
    }
  }
}
