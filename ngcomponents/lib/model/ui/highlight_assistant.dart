// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ngcomponents/model/ui/has_renderer.dart';
import 'package:ngcomponents/model/ui/highlighted_text_model.dart';

/// Maintains a reference to the highlighter and a cache of highlighted data.
class HighlightAssistant {
  static final RegExp _separatorRegex = RegExp(r'[,\s]+');

  // Cache highlight segments.
  final _highlightCache =
      <String, Map<dynamic, List<HighlightedTextSegment>>>{};

  final Highlighter? _optionHighlighter;

  // Lazy private highlighter getter.
  TextHighlighter? __textHighlighter;

  /// Gets the default text highlighter, creating a cached instance if needed.
  TextHighlighter get _textHighlighter => __textHighlighter ??=
      TextHighlighter(matchFromStartOfWord: _matchFromStartOfWord);

  /// Whether matches should only highlight at the start of words.
  bool _matchFromStartOfWord;

  /// Creates new HighlightAssistant, using provided [optionHighlighter] or
  /// TextHighlighter if no value is provided.
  HighlightAssistant(
      {Highlighter? optionHighlighter, bool matchFromStartOfWord = false})
      : _optionHighlighter = optionHighlighter,
        _matchFromStartOfWord = matchFromStartOfWord;

  List<HighlightedTextSegment> highlightOption<T>(
      String lastQuery, dynamic item, ItemRenderer<T>? itemRenderer) {
    var queryHighlightCache = _highlightCache[lastQuery] ??= {};
    var value = queryHighlightCache[item];

    if (value == null) {
      String render = '';
      if (itemRenderer != null) {
        render = itemRenderer(item) ?? '';
      }
      value = (_optionHighlighter != null
          ? _optionHighlighter!(lastQuery, item)
          : _textHighlighter.highlight(
              render, lastQuery.split(_separatorRegex)));
      queryHighlightCache[item] = value;
    }
    return value;
  }
}
