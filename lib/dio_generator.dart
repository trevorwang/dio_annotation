import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import 'package:build/build.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:code_builder/code_builder.dart';

import 'package:source_gen/source_gen.dart';
import 'package:dio/dio.dart';
import 'package:tuple/tuple.dart';
import 'annotations.dart' as annotations;

class DioGenerator extends GeneratorForAnnotation<annotations.DioApi> {
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
        ..fields.add(_buildDefinitionTypeMethod(className))
        ..constructors.addAll([_generateConstructor(baseUrl)])
        ..methods.addAll(_parseMethods(element))
        ..extend = refer(className);
    });

    final emitter = new DartEmitter();
    return new DartFormatter().format('${classBuilder.accept(emitter)}');
  }

  Field _buildDefinitionTypeMethod(String superType) => Field((m) => m
    ..name = 'dio'
    ..modifier = FieldModifier.final$
    ..assignment = refer('Dio').newInstance([]).code);

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
    annotations.GET,
    annotations.POST,
    annotations.DELETE,
    annotations.PUT,
    annotations.PATCH,
    annotations.Method
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

  ConstantReader _getHeadersAnnotation(MethodElement method) {
    final annot = _typeChecker(annotations.Headers)
        .firstAnnotationOf(method, throwOnUnresolved: false);
    if (annot != null) return new ConstantReader(annot);
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

  Tuple2<ParameterElement, ConstantReader> _getAnnotation(
      MethodElement m, Type type) {
    for (final p in m.parameters) {
      final a = _typeChecker(type).firstAnnotationOf(p);
      if (a != null) {
        return Tuple2(p, ConstantReader(a));
      }
    }
    return null;
  }

  Method _generateMethod(MethodElement m) {
    final httpMehod = _getMethodAnnotation(m);

    return Method((mm) {
      mm
        ..name = m.displayName
        ..modifier = MethodModifier.async
        ..returns = refer(m.returnType.displayName);

      /// required parameters
      mm.requiredParameters.addAll(m.parameters
          .where((it) => it.isNotOptional)
          .map((it) => Parameter((p) => p
            ..name = it.name
            ..type = Reference(it.type.displayName))));

      /// optional & positional parameters
      mm.optionalParameters.addAll(m.parameters
          .where((i) => i.isOptionalPositional)
          .map((it) => Parameter((p) => p
            ..name = it.name
            ..type = Reference(it.type.displayName)
            ..defaultTo = Code(it.defaultValueCode))));

      /// named parameters
      mm.optionalParameters.addAll(
          m.parameters.where((i) => i.isNamed).map((it) => Parameter((p) => p
            ..named = true
            ..name = it.name
            ..type = Reference(it.type.displayName)
            ..defaultTo = Code(it.defaultValueCode))));

      mm.body = _generateRequest(m, httpMehod);
    });
  }

  Expression _generatePath(MethodElement m, ConstantReader method) {
    final paths = _getAnnotations(m, annotations.Path);

    String definePath = method.peek("path").stringValue;

    paths.forEach((k, v) {
      final value = v.peek("value")?.stringValue ?? k.displayName;
      definePath = definePath.replaceFirst("{$value}", "\$${k.displayName}");
    });
    return literal(definePath);
  }

  Code _generateRequest(MethodElement m, ConstantReader httpMehod) {
    final _queryParamsVar = "queryParameters";
    final _optionsVar = "options";
    final path = _generatePath(m, httpMehod);
    final queries = _getAnnotations(m, annotations.Query);
    final queryParameters = queries.map((p, ConstantReader r) {
      final value = r.peek("value")?.stringValue ?? p.displayName;
      return MapEntry(literal(value), refer(p.displayName));
    });

    final queryMap = _getAnnotations(m, annotations.QueryMap);
    Map<Expression, Expression> headers = _generateHeaders(m);
    final options = refer("RequestOptions").newInstance([], {
      "method": literal(httpMehod.peek("method").stringValue),
      "headers": literalMap(headers)
    });

    final namedArguments = <String, Expression>{};
    namedArguments[_queryParamsVar] = refer(_queryParamsVar);
    namedArguments[_optionsVar] = options;

    final blocks = <Code>[];
    blocks.add(literalMap(queryParameters, refer("String"), refer("dynamic"))
        .assignFinal(_queryParamsVar)
        .statement);
    if (queryMap.isNotEmpty) {
      blocks.add(refer('$_queryParamsVar.addAll').call(
        [refer("${queryMap.keys.first.displayName} ?? {}")],
      ).statement);
    }

    blocks.add(
      refer("dio.request")
          .call([
            path,
          ], namedArguments)
          .returned
          .statement,
    );

    return Block.of(blocks);
  }

  Map<Expression, Expression> _generateHeaders(MethodElement m) {
    final anno = _getHeadersAnnotation(m);
    final headersMap = anno?.peek("value")?.mapValue ?? {};
    final headers = headersMap.map((k, v) {
      return MapEntry(literal(k.toStringValue()), literal(v.toStringValue()));
    });

    final annosInParam = _getAnnotations(m, annotations.Header);
    final headersInParams = annosInParam.map((k, v) {
      final value = v.peek("value")?.stringValue ?? k.displayName;
      return MapEntry(literal(value), literal(k.displayName));
    });
    headers.addAll(headersInParams);
    return headers;
  }
}
