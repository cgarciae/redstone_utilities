part of redstone.utilities;

ObjectId stringToId(String s) => new ObjectId.fromHexString(s);

ModifierBuilder getModifierBuilder(Object obj, [MongoDb dbConn]) {
  dbConn = dbConn == null ? db : dbConn;
  Map<String, dynamic> map = dbConn.encode(obj);

  map = cleanMap(map);

  Map mod = {r'$set': map};

  return new ModifierBuilder()..map = mod;
}

dynamic cleanMap(dynamic json) {
  if (json is List) {
    return json.map(cleanMap).toList();
  } else if (json is Map) {
    var map = {};
    for (String key in json.keys) {
      var value = json[key];

      if (value == null) continue;

      if (value is List || value is Map) map[key] = cleanMap(value);
      else map[key] = value;
    }
    return map;
  } else {
    return json;
  }
}
