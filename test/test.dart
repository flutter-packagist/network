import 'package:flutter_test/flutter_test.dart';
import 'package:network/resolve/safe_convert.dart';

void main() {
  test("convert dynamic to safe type", () {
    Object? a;
    print(a.runtimeType); // print: Null
    print(toInt(a).runtimeType); // print: int
    print(toInt(a)); // print: 0
  });

  test("convert from json key to safe type", () {
    final json = {
      'int': 1,
      'double': 1.0,
      'bool': true,
      'string': 'string',
      'map': {'key': 'value'},
      'list': ["1", "2", "3"],
    };

    print(asInt(json, 'int')); // print: 1
    print(asDouble(json, 'double')); // print: 1.0
    print(asBool(json, 'bool')); // print: true
    print(asString(json, 'string')); // print: string
    print(asMap(json, 'map')); // print: {key: value}
    print(asList(json, 'list').map((e) => toString(e)).toList()); // print [1, 2, 3]

    print("\n");
    print(asMap(json, 'int')); // print: {}
    print(asMap(json, 'double')); // print: {}
    print(asMap(json, 'bool')); // print: {}
    print(asMap(json, 'string')); // print: {}
    print(asMap(json, 'map')); // print: {}
    print(asMap(json, 'list')); // print: {}

    print("\n");
    print(asList(json, 'map').map((e) => toString(e)).toList()); // print []
  });
}