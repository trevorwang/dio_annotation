import 'package:meta/meta.dart';

enum HttpMethod { GET, POST, PATCH, PUT, DELETE }

@immutable
class DioApi {
  final String baseUrl;
  const DioApi({this.baseUrl: "/"});
}

@immutable
class Method {
  final HttpMethod method;
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
class Header {
  const Header();
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
  final String name;
  const Path([this.name]);
}
