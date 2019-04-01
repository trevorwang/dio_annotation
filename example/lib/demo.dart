import 'package:dio_annotation/annotations.dart';
import 'package:dio/dio.dart';

part 'demo.g.dart';

@DioApi(baseUrl: "https://baidu.com/")
abstract class RestClient {
  static RestClient instance() => _RestClient();

  @GET("/profile/{id}")
  Future<Response<String>> profile(@Path("id") String id,
      {@Query("role") String role = "user"});

  @POST("/profile/{id}")
  Future<Response<String>> createProfile(@Path("id") String id);
}
