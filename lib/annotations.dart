import 'package:meta/meta.dart';

class HttpMethod {
  static const String GET = "GET";
  static const String POST = "POST";
  static const String PATCH = "PATCH";
  static const String PUT = "PUT";
  static const String DELETE = "DELETE";
}

@immutable
class DioApi {
  final String baseUrl;
  const DioApi({this.baseUrl: "/"});
}

@immutable
class Method {
  final String method;
  final String path;
  final Map<String, String> headers;
  const Method(this.method, this.path, {this.headers = const {}});
}

@immutable
class GET extends Method {
  final Map<String, String> headers;
  const GET(String path, {this.headers})
      : super(HttpMethod.GET, path, headers: headers ?? const {});
}

@immutable
class POST extends Method {
  final Map<String, String> headers;
  const POST(String path, {this.headers})
      : super(HttpMethod.POST, path, headers: headers ?? const {});
}

@immutable
class PATCH extends Method {
  final Map<String, String> headers;
  const PATCH(final String path, {this.headers})
      : super(HttpMethod.PATCH, path, headers: headers ?? const {});
}

@immutable
class PUT extends Method {
  final Map<String, String> headers;
  const PUT(final String path, {this.headers})
      : super(HttpMethod.PUT, path, headers: headers ?? const {});
}

@immutable
class DELETE extends Method {
  final Map<String, String> headers;
  const DELETE(final String path, {this.headers})
      : super(HttpMethod.DELETE, path, headers: headers ?? const {});
}

@immutable
class Headers {
  const Headers();
}

@immutable
class Body {
  const Body();
}

// @immutable
// class Field {
//   final String name;
//   const Field([this.name]);
// }

@immutable
class Path {
  final String value;
  const Path([this.value]);
}

@immutable
class Query {
  final String value;
  final bool encoded;
  const Query(this.value, {this.encoded});
}

@immutable
class QueryMap {
  final bool encoded;
  const QueryMap({this.encoded = false});
}

@immutable
class QueryName {
  final String value;
  final bool encoded;
  const QueryName(this.value, {this.encoded});
}
