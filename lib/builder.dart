import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'annotations.dart';

class MultiplierGenerator extends GeneratorForAnnotation<DioApi> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final baseUrl = annotation.read('baseUrl').literalValue;

    return 'aaa';
  }
}
