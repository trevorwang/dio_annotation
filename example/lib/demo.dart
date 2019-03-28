import 'package:dio_annotation/annotations.dart';
import 'package:dio/dio.dart';

part 'demo.g.dart';

@DioApi(baseUrl: "https://baidu.com/")
abstract class RestClient {
  factory RestClient.instance() => _RestClient();
  @GET("/profile")
  Future<Response<String>> profile();
}
