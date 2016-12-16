library spell_corrector;

class SpellCorrector {
  final _Counter<String> _counter;

  SpellCorrector(String sourceData)
      : _counter = new _Counter()..addAll(_words(sourceData));

  /// Most probable spelling correction for [word]
  String correction(String word) {
    double max = 0.0;
    String bestWord = "";
    for (var word in candidates(word)) {
      var prob = _probability(word, _counter);
      if (prob > max) {
        bestWord = word;
        max = prob;
      }
    }
    return bestWord;
  }

  /// Generate possible spelling corrections for [word]
  Iterable<String> candidates(String word) {
    var knownCorrect = _known([word]).toList();
    if (knownCorrect.isNotEmpty) return knownCorrect;
    var knownEdits1 = _known(_edits1(word)).toList();
    if (knownEdits1.isNotEmpty) return knownEdits1;
    var knownEdits2 = _known(_edits2(word)).toList();
    if (knownEdits2.isNotEmpty) return knownEdits2;
    return [];
  }

  /// The subset of [words] that appear in the dictionary of words
  Iterable<String> _known(Iterable<String> words) sync* {
    for (var word in words) {
      if (_counter.contains(word)) yield word;
    }
  }
}

Iterable<String> _letters = "abcdefghijklmnopqrstuvwxyz"
    .codeUnits
    .map((c) => new String.fromCharCode(c));

/// Probability of [word] in [words]
double _probability(String word, _Counter<String> words) =>
    words[word] / words.keys.length;

Iterable<String> _words(String text) {
  return new RegExp(r"\w+")
      .allMatches(text.toLowerCase())
      .map((match) => match.group(0));
}

/// All edits that are one edit away from [word]
Iterable<String> _edits1(String word) sync* {
  yield* _deletes(word);
  yield* _transposes(word);
  yield* _replaces(word);
  yield* _inserts(word);
}

/// All edits that are two edits away from [word]
Iterable<String> _edits2(String word) sync* {
  for (var edit in _edits1(word)) {
    yield* _edits1(edit);
  }
}

Iterable<_Split> _splits(String word) sync* {
  for (var i = 0; i < word.length; i++) {
    yield new _Split(word.substring(0, i), word.substring(i));
  }
}

Iterable<String> _deletes(String word) sync* {
  for (var split in _splits(word)) {
    if (split.right.isNotEmpty) {
      yield split.left + split.right.substring(1);
    }
  }
}

Iterable<String> _transposes(String word) sync* {
  for (var split in _splits(word)) {
    if (split.right.length > 1) {
      yield split.left +
          split.right.substring(1, 2) +
          split.right.substring(0, 1) +
          split.right.substring(2);
    }
  }
}

Iterable<String> _replaces(String word) sync* {
  for (var split in _splits(word)) {
    for (var c in _letters) {
      if (split.right.isNotEmpty) {
        yield split.left + c + split.right.substring(1);
      }
    }
  }
}

Iterable<String> _inserts(String word) sync* {
  for (var split in _splits(word)) {
    for (var c in _letters) {
      if (split.right.isNotEmpty) {
        yield split.left + c + split.right;
      }
    }
  }
}

class _Split {
  final String left;
  final String right;
  _Split(this.left, this.right);
}

class _Counter<T> {
  final Map<T, int> _counts = {};
  operator [](T item) => _counts[item];
  void add(T item) {
    _counts.containsKey(item) ? _counts[item] += 1 : _counts[item] = 1;
  }

  void addAll(Iterable<T> items) => items.forEach(add);
  Iterable<T> get keys => _counts.keys;
  bool contains(T item) => _counts.containsKey(item);
}
