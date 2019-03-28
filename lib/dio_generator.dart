import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:code_builder/code_builder.dart';

import 'package:source_gen/source_gen.dart';
import 'package:dio/dio.dart';
import 'annotations.dart' as dio;

class DioGenerator extends GeneratorForAnnotation<dio.DioApi> {
  static const String _baseUrlArg = 'baseUrl';
  static const String _headersArg = "headers";

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      final name = element.displayName;
      throw new InvalidGenerationSourceError(
        'Generator cannot target `$name`.',
        todo: 'Remove the [DioApi] annotation from `$name`.',
      );
    }
    return _implementClass(element, annotation);
  }

  String _implementClass(ClassElement element, ConstantReader annotation) {
    final className = element.name;
    final name = '_$className';
    final baseUrl = annotation?.peek(_baseUrlArg)?.stringValue ?? '';

    final classBuilder = new Class((c) {
      c
        ..name = name
        ..constructors.addAll([_generateConstructor(baseUrl)])
        ..methods.addAll(_parseMethods(element))
        ..fields.add(_buildDefinitionTypeMethod(className))
        ..extend = refer(className);
    });

    final emitter = new DartEmitter();
    return new DartFormatter().format('${classBuilder.accept(emitter)}');
  }

  Field _buildDefinitionTypeMethod(String superType) => Field(
        (m) => m
          ..name = 'dio'
          ..modifier = FieldModifier.final$
          ..assignment = Code("Dio()"),
      );

  Constructor _generateConstructor(String baseUrl) => Constructor((c) {
        c.body = Code("this.dio.options.baseUrl = '$baseUrl';");
      });

  Iterable<Method> _parseMethods(ClassElement element) =>
      element.methods.where((MethodElement m) {
        final methodAnnot = _getMethodAnnotation(m);
        return methodAnnot != null &&
            m.isAbstract &&
            m.returnType.isDartAsyncFuture;
      }).map((m) => _generateMethod(m));

  final _methodsAnnotations = const [
    dio.GET,
    dio.POST,
    dio.DELETE,
    dio.PUT,
    dio.PATCH,
    dio.Method
  ];

  TypeChecker _typeChecker(Type type) => new TypeChecker.fromRuntime(type);
  ConstantReader _getMethodAnnotation(MethodElement method) {
    for (final type in _methodsAnnotations) {
      final annot = _typeChecker(type)
          .firstAnnotationOf(method, throwOnUnresolved: false);
      if (annot != null) return new ConstantReader(annot);
    }
    return null;
  }

  Map<ParameterElement, ConstantReader> _getAnnotations(
      MethodElement m, Type type) {
    var annot = <ParameterElement, ConstantReader>{};
    for (final p in m.parameters) {
      final a = _typeChecker(type).firstAnnotationOf(p);
      if (a != null) {
        annot[p] = new ConstantReader(a);
      }
    }
    return annot;
  }

  Method _generateMethod(MethodElement m) {
    return Method((mm) {
      mm.name = m.name;
    });
  }
}
