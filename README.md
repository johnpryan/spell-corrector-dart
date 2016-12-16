# spell-corrector-dart
Port of Peter Norvig's spelling corrector http://norvig.com/spell-correct.html

## Usage

```dart
import 'package:spell_corrector/spell_corrector.dart';
main() {
      var sourceData = "spelling spelunking";
      var corrector = new SpellCorrector(sourceData);
      print(corrector.correction("speling")); // prints "spelling"
}
```

## Command Line interface

run `pub global activate spell_corrector` to activate:
 
```bash
$ spell_corrector speling
$ spelling
```