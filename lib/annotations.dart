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
  final Map<String, String> headers;
  const Method(this.method, {this.headers = const {}});
}

@immutable
class GET extends Method {
  final Map<String, String> headers;
  const GET({this.headers})
      : super(HttpMethod.GET, headers: headers ?? const {});
}

@immutable
class POST extends Method {
  final Map<String, String> headers;
  const POST({this.headers})
      : super(HttpMethod.POST, headers: headers ?? const {});
}

@immutable
class PATCH extends Method {
  final Map<String, String> headers;
  const PATCH({this.headers})
      : super(HttpMethod.PATCH, headers: headers ?? const {});
}

@immutable
class PUT extends Method {
  final Map<String, String> headers;
  const PUT({this.headers})
      : super(HttpMethod.PUT, headers: headers ?? const {});
}

@immutable
class DELETE extends Method {
  final Map<String, String> headers;
  const DELETE({this.headers})
      : super(HttpMethod.DELETE, headers: headers ?? const {});
}

@immutable
class Header {
  const Header();
}

@immutable
class Body {
  const Body();
}

@immutable
class Field {
  final String name;
  const Field([this.name]);
}

@immutable
class Path {
  final String name;
  const Path([this.name]);
}
