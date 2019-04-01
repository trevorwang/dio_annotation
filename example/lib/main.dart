import 'demo.dart';

void main(List<String> arguments) {
  final client = RestClient.instance();
  client
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

  client
      .createProfile(
        "addafasf",
        header: "aaaaaa",
        map2: {
          "aaaa": 22222,
          "ccccc": "cccccc",
        },
        ffff: "ssssss",
        field: 555,
      )
      .then((it) => print(it));
}
