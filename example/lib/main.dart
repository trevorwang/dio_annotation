import 'demo.dart';

void main(List<String> arguments) {
  RestClient.instance()
      .ip(
    "bbb",
    queryies: {
      "c": "ggggg",
      "d": 24353535,
    },
    header: "googogogo",
  )
      .then((ip) {
    print(ip);
  });
}
