import '../bin/spell_corrector.dart';
import 'package:resource/resource.dart';
import 'package:spell_corrector/spell_corrector.dart';
import 'package:test/test.dart';

main() {
  group('SpellCorrector', () {
    test('can correct speling', () async {
      var resource = new Resource("package:spell_corrector/big.txt");
      var contents = await resource.readAsString();
      var corrector = new SpellCorrector(contents);
      expect(corrector.correction("speling"), "spelling");
    });
  });
}
