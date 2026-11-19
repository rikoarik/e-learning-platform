import 'dart:convert';

import 'package:flutter/services.dart';

class FixtureBundle extends CachingAssetBundle {
  FixtureBundle(this.json);

  final String json;
  int loads = 0;

  @override
  Future<ByteData> load(String key) async {
    loads++;
    return ByteData.sublistView(utf8.encode(json));
  }
}
