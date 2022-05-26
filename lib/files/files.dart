import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// This is the file containing the user's general information

const PROFILE_FILE = const _CacheFile("profile.json");

/// This is the file containing the version and the upgrade information

const UPDATE_FILE = const _CacheFile("update.json");

/// This is the file containing the user's statistics

const STATS_FILE = const _CacheFile("stats.json");

/// This is the file containing the user's activities

const ACTIVITIES_FILE = const _CacheFile("activities.json");

/// This is the file containing the user's timeline

const TIMELINE_FILE = const _CacheFile("timeline.json");

/// This class represents a cache file

class _CacheFile {

  final String name;

  const _CacheFile(this.name);

  Future<File> get _localFile async {
    return File('${(await getApplicationDocumentsDirectory()).path}/$name').create();
  }

  Future<String> read() async {
    try {
      return await (await _localFile).readAsString();
    } catch (e) {
      return e.toString();
    }
  }

  void write(String content) async {
    (await _localFile).writeAsString(content);
  }
}