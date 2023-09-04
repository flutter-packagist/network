
int toInt(value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is bool) return value ? 1 : 0;
  if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? defaultValue;
  return defaultValue;
}

double toDouble(value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is bool) return value ? 1.0 : 0.0;
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

bool toBool(value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is int) return value == 0 ? false : true;
  if (value is double) return value == 0 ? false : true;
  if (value is String) {
    if (value == "1" || value.toLowerCase() == "true") return true;
    if (value == "0" || value.toLowerCase() == "false") return false;
  }
  return defaultValue;
}

String toString(value, {String defaultValue = ""}) {
  if (value == null) return defaultValue;
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value is double) return value.toString();
  if (value is bool) return value ? "true" : "false";
  return defaultValue;
}

Map<String, dynamic> toMap(value, {Map<String, dynamic>? defaultValue}) {
  if (value == null) return defaultValue ?? <String, dynamic>{};
  if (value is Map<String, dynamic>) return value;
  return defaultValue ?? <String, dynamic>{};
}

List toList(value, {List? defaultValue}) {
  if (value == null) return defaultValue ?? [];
  if (value is List) return value;
  return defaultValue ?? [];
}

int asInt(Map<String, dynamic>? json, String key, {int defaultValue = 0}) {
  if (json == null || !json.containsKey(key)) return defaultValue;
  return toInt(json[key]);
}

double asDouble(Map<String, dynamic>? json, String key, {double defaultValue = 0.0}) {
  if (json == null || !json.containsKey(key)) return defaultValue;
  return toDouble(json[key]);
}

bool asBool(Map<String, dynamic>? json, String key, {bool defaultValue = false}) {
  if (json == null || !json.containsKey(key)) return defaultValue;
  return toBool(json[key]);
}

String asString(Map<String, dynamic>? json, String key, {String defaultValue = ""}) {
  if (json == null || !json.containsKey(key)) return defaultValue;
  return toString(json[key]);
}

Map<String, dynamic> asMap(Map<String, dynamic>? json, String key, {Map<String, dynamic>? defaultValue}) {
  if (json == null || !json.containsKey(key)) return defaultValue ?? <String, dynamic>{};
  return toMap(json[key]);
}

List asList(Map<String, dynamic>? json, String key, {List? defaultValue}) {
  if (json == null || !json.containsKey(key)) return defaultValue ?? [];
  return toList(json[key]);
}

List<int> asListInt(Map<String, dynamic>? json, String key, {List? defaultValue}) {
  return asList(json, key, defaultValue: defaultValue).map((e) => toInt(e)).toList();
}

List<String> asListString(Map<String, dynamic>? json, String key, {List? defaultValue}) {
  return asList(json, key, defaultValue: defaultValue).map((e) => toString(e)).toList();
}