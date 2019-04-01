import 'package:dio_annotation/annotations.dart';
import 'package:dio/dio.dart';

part 'demo.g.dart';

@DioApi(baseUrl: "https://httpbin.org/")
abstract class RestClient {
  static RestClient instance() => _RestClient();

  @GET("/get")
  Future<Response<String>> ip(@Query('a') String a,
      {@QueryMap() Map<String, dynamic> queryies});

  @GET("/profile/{id}")
  Future<Response<String>> profile(@Path("id") String id,
      {@Query("role") String role = "user",
      @QueryMap() Map<String, dynamic> map = const {}});

  @POST("/profile/{id}")
  Future<Response<String>> createProfile(@Path("id") String id);
}
