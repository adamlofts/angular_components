// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:ngcomponents/utils/id_generator/id_generator.dart';

/// Manages a pointer to an item in a list.
///
/// The pointer may be moved sequentially or to an arbitrary item. When the item
/// list is updated, the model keeps the previously active item as active if it
/// is still in the list.
class ActiveItemModel<T> {
  /// Creates an instance from the initial list of [items]. If [idGenerator] is
  /// null, a default instance ([SequentialIdGenerator]) is created.
  ///
  /// This is a convenience for components to create an [ActiveItemModel] as an
  /// [IdGenerator] is not always bound in DI.
  /// Note: While [idGenerator] can be null, components should always pass
  /// an injected instance of [IdGenerator] to ensure [ActiveItemModel] uses the
  /// [IdGenerator] provided by the app.
  /// If [items] is null, it is set to an empty list.
  ///
  /// [loop] decides whether the active items loops from the end of the list to
  /// the beginning of the list, and vise versa. Default is false.
  /// Common a11y practice for select components, loop is set to false.
  /// Reference: https://www.w3.org/TR/wai-aria-practices/#Listbox
  /// Common a11y practice for menu components, loop is set to true.
  /// Reference: https://www.w3.org/TR/wai-aria-practices/#menu
  ///
  /// [activateOnListChange] decides whether the first list item should
  /// activate whenever list items change. Default is true.
  /// If an item is active when the list changes and that item is in the new
  /// list, the item will remain active regardless of what this flag is set to.
  /// Auto-activating the first result may slightly speed up keyboard nav for
  /// users. It can also be detremental to a11y in others. For example, to
  /// avoid screen reader issues, multi-select comboboxes toggle list item
  /// selection via <Space> not <Enter>. To allow a space in their search query,
  /// no items can be active or else their selection will be toggled. Setting
  /// this value to false will prevent items from auto-activating when the
  /// search query changes.
  ActiveItemModel(IdGenerator? idGenerator,
      {bool loop = false,
      this.activateFirstItemByDefault = true,
      List<T> items = const []})
      : _idGenerator = idGenerator ?? SequentialIdGenerator.fromUUID() {
    _loop = loop;
    _items = items;
    if (_items.isNotEmpty) _activeIndex = activateFirstItemByDefault ? 0 : -1;
  }

  /// Stream of model change events
  Stream get modelChanged => _modelChanged.stream;
  final _modelChanged = StreamController.broadcast(sync: true);

  /// ID of currently active item.
  String get activeId => id(activeItem);

  /// Determines whether [item] is active.
  bool isActive(T item) => activeItem == item;

  /// Sets the item list, activating the first item, if the previously active
  /// item is not in the new list of items.
  ///
  /// Note: As [itemList] is not watched, [items] must be manually updated
  /// on changes.
  set items(List<T> itemList) {
    if (const ListEquality().equals(itemList, _items)) return;

    _ids.clear();
    var lastActive = activeItem;
    // Ensure [_items] can't change.
    _items = List.unmodifiable(itemList);
    if (lastActive != null) {
      var last = _items.indexOf(lastActive);
      if (last != -1) {
        _activeIndex = last;
        return;
      }
    }
    _activeIndex = activateFirstItemByDefault ? 0 : -1;
    _modelChanged.add(null);
  }

  /// Currently active item.
  T? get activeItem =>
      _items.isEmpty || _activeIndex == -1 ? null : _items[_activeIndex];

  /// Activates next element in the list, if the active item is not already the
  /// last item.
  void activateNext() {
    if (_items.isEmpty) {
      _activeIndex = -1;
    } else if (_activeIndex < _items.length - 1) {
      _activeIndex++;
    } else if (_loop) {
      _activeIndex = 0;
    }
    _modelChanged.add(null);
  }

  /// Returns the next possible active item as if activeNext was called.
  T? get peekNext {
    if (_items.isNotEmpty && _activeIndex < _items.length - 1) {
      return _items[_activeIndex + 1];
    } else if (_items.isNotEmpty && _loop) {
      return _items[0];
    } else {
      return null;
    }
  }

  /// Activates previous element in the list, if the active item is not already
  /// the first item.
  void activatePrevious() {
    if (_items.isEmpty) {
      _activeIndex = -1;
    } else if (_activeIndex > 0) {
      _activeIndex--;
    } else if (_loop) {
      _activeIndex = _items.length - 1;
    }
    _modelChanged.add(null);
  }

  /// Activates first element in the list.
  void activateFirst() {
    _activeIndex = _items.isEmpty ? -1 : 0;
    _modelChanged.add(null);
  }

  /// Activates last element in the list.
  void activateLast() {
    _activeIndex = _items.isEmpty ? -1 : _items.length - 1;
    _modelChanged.add(null);
  }

  /// Activates [value].
  /// If [value] is not found, the active pointer is set to none.
  void activate(T value) {
    _activeIndex = _items.indexOf(value);
    _modelChanged.add(null);
  }

  /// Returns an unique id for [item].
  String id(T? item) {
    if (item == null) return '';
    if (!_ids.containsKey(item)) {
      _ids[item] = _idGenerator.nextId();
    }
    return _ids[item] ?? '';
  }

  /// Whether the first list item should activate whenever the changes.
  ///
  /// Default is true. This value is disregarded if a previously active item
  /// remains in the new list.
  ///
  /// Auto-activating the first result may slightly speed up keyboard nav for
  /// users. It can also be detremental to a11y in others. For example, to
  /// avoid screen reader issues, multi-select comboboxes toggle list item
  /// selection via <Space> not <Enter>. If as the results list changes the
  /// first item is auto-activated, that would block the user from including a
  /// space in their search query.
  bool activateFirstItemByDefault = true;

  final Map<T, String> _ids = HashMap<T, String>();
  final IdGenerator _idGenerator;
  List<T> _items = [];
  late bool _loop;
  int _activeIndex = -1;
}
