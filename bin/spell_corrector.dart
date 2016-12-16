import 'dart:io';
import 'package:resource/resource.dart' show Resource;
import 'package:spell_corrector/spell_corrector.dart';

main(List<String> args) async {
  if (args.isEmpty) {
    print("Please enter a word.");
    exit(0);
  }

  var resource = new Resource("package:spell_corrector/big.txt");
  var contents = await resource.readAsString();
  var corrector = new SpellCorrector(contents);
  print(corrector.correction(args[0]));
}
