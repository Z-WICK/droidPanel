import 'dart:io' as io;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:droid_config_panel/utils/constants.dart';

final activeProjectPathProvider = StateProvider<String>((ref) {
  final currentPath = p.normalize(io.Directory.current.absolute.path);
  if (currentPath != p.separator) {
    return currentPath;
  }

  final homePath = AppConstants.homeDirectory.trim();
  if (homePath.isNotEmpty) {
    final documentsPath = p.normalize(p.join(homePath, 'Documents'));
    if (io.Directory(documentsPath).existsSync()) {
      return documentsPath;
    }
    return p.normalize(homePath);
  }
  return currentPath;
});
