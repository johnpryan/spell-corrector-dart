import 'dart:io';

Counter<String> wordCounts;

main(List<String> args) async {
  var file = new File('big.txt');
  var contents = await file.readAsString();
  var allWords = words(contents);
  wordCounts = new Counter<String>()..addAll(allWords);
  if (args.isEmpty) {
    print("Please enter a word");
    exit(0);
  }
  print(correction(args[0]));
}

int probability(String word, Counter<String> words) =>
    words[word] / words.keys.length;

Iterable<String> words(String text) {
  return new RegExp(r"\w+")
      .allMatches(text.toLowerCase())
      .map((match) => match.group(0));
}

const String _letters = "abcdefghijklmnopqrstuvwxyz";
Iterable<String> letters =
    _letters.codeUnits.map((c) => new String.fromCharCode(c));

String correction(String word) {
  int max = 0;
  String bestWord = "";
  for (var word in candidates(word)) {
    var prob = probability(word, wordCounts);
    if (prob > max) {
      bestWord = word;
      max = prob;
    }
  }
  return bestWord;
}

Iterable<String> candidates(String word) {
  var knownCorrect = known([word]).toList();
  if (knownCorrect.isNotEmpty) return knownCorrect;
  var knownEdits1 = known(edits1(word)).toList();
  if (knownEdits1.isNotEmpty) return knownEdits1;
  var knownEdits2 = known(edits2(word)).toList();
  if (knownEdits2.isNotEmpty) return knownEdits2;
  return [];
}

Iterable<String> known(Iterable<String> words) sync* {
  for (var word in words) {
    if (wordCounts.contains(word)) yield word;
  }
}

Iterable<String> edits1(String word) sync* {
  yield* deletes(word);
  yield* transposes(word);
  yield* replaces(word);
  yield* inserts(word);
}

Iterable<String> edits2(String word) sync* {
  for (var edit in edits1(word)) {
    yield* edits1(edit);
  }
}

Iterable<Split> splits(String word) sync* {
  for (var i = 0; i < word.length; i++) {
    yield new Split(word.substring(0, i), word.substring(i));
  }
}

Iterable<String> deletes(String word) sync* {
  for (var split in splits(word)) {
    if (split.right.isNotEmpty) {
      yield split.left + split.right.substring(1);
    }
  }
}

Iterable<String> transposes(String word) sync* {
  for (var split in splits(word)) {
    if (split.right.length > 1) {
      yield split.left +
          split.right.substring(1, 2) +
          split.right.substring(0, 1) +
          split.right.substring(2);
    }
  }
}

Iterable<String> replaces(String word) sync* {
  for (var split in splits(word)) {
    for (var c in letters) {
      if (split.right.isNotEmpty) {
        yield split.left + c + split.right.substring(1);
      }
    }
  }
}

Iterable<String> inserts(String word) sync* {
  for (var split in splits(word)) {
    for (var c in letters) {
      if (split.right.isNotEmpty) {
        yield split.left + c + split.right;
      }
    }
  }
}

class Split {
  final String left;
  final String right;
  Split(this.left, this.right);
}

class Counter<T> {
  final Map<T, int> _counts = {};
  operator [](T item) => _counts[item];
  void add(T item) {
    _counts.containsKey(item) ? _counts[item] += 1 : _counts[item] = 1;
  }

  void addAll(Iterable<T> items) => items.forEach(add);
  Iterable<T> get keys => _counts.keys;
  bool contains(T item) => _counts.containsKey(item);
}
