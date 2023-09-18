import "package:flutter_test/flutter_test.dart";
import "package:network/resolve/safe_convert.dart";

void main() {
  test("convert dynamic to safe type", () {
    Object? a;
    assert(a.runtimeType.toString() == "Null"); // print: Null
    assert(toInt(a).runtimeType.toString() == "int"); // print: int
    assert(toInt(a) == 0); // print: 0
  });

  test("convert from json key to safe type", () {
    final json = {
      "int": 1,
      "double": 1.0,
      "bool": true,
      "string": "string",
      "map": {"key": "value"},
      "list": ["1", "2", "3"],
    };

    assert(asInt(json, "int") == 1); // print: 1
    assert(asDouble(json, "double") == 1.0); // print: 1.0
    assert(asBool(json, "bool") == true); // print: true
    assert(asString(json, "string") == "string"); // print: string
    assert(asMap(json, "map").containsKey("key")); // print: {key: value}
    assert(asList(json, "list").map((e) => toString(e)).toList().join(",") ==
        "1,2,3"); // print [1, 2, 3]

    print(asMap(json, "int")); // print: {}
    print(asMap(json, "double")); // print: {}
    print(asMap(json, "bool")); // print: {}
    print(asMap(json, "string")); // print: {}
    print(asMap(json, "map")); // print: {}
    print(asMap(json, "list")); // print: {}

    print("\n");
    print(asList(json, "map").map((e) => toString(e)).toList()); // print []
  });

  test("convert from json key to safe generic type", () {
    final json = {
      "int": 1,
      "double": 1.0,
      "bool": true,
      "string": "string",
      "map": {"key": "value"},
      "list": ["1", "2", "3"],
    };

    assert(asT<int>(json, "int") == 1); // print: 1
    assert(asT<double>(json, "double") == 1.0); // print: 1.0
    assert(asT<bool>(json, "bool") == true); // print: true
    assert(asT<String>(json, "string") == "string"); // print: string
    assert(asT<Map>(json, "map").containsKey("key")); // print: {key: value}
    assert(asT<List>(json, "list").map((e) => toString(e)).toList().join(",") ==
        "1,2,3"); // print [1, 2, 3]

    print(asT<Map<String, dynamic>>(json, "int")); // print: {}
    print(asT<Map<String, dynamic>>(json, "double")); // print: {}
    print(asT<Map<String, dynamic>>(json, "bool")); // print: {}
    print(asT<Map<String, dynamic>>(json, "string")); // print: {}
    print(asT<Map<String, dynamic>>(json, "map")); // print: {}
    print(asT<Map<String, dynamic>>(json, "list")); // print: {}

    print("\n");
    print(asT<List>(json, "map").map((e) => toString(e)).toList()); // print []
  });
}
