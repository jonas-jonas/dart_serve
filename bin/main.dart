import 'dart:io';

import 'package:dart_serve/server.dart';
import 'package:args/args.dart';
import 'package:logging/logging.dart';

main(List<String> arguments) {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name} ${rec.time}: ${rec.message}');
  });

  var parser = ArgParser();
  // Force try-parse to return null
  parser.addOption('port', abbr: 'p', defaultsTo: '8080');
  parser.addOption('address', abbr: 'a', defaultsTo: '127.0.0.1');

  var results = parser.parse(arguments);
  var directory = '.';
  if (results.rest.length == 1) {
    directory = results.rest.first;
  }

  var server = Server(
    port: int.tryParse(results['port']),
    directory: directory,
    address: InternetAddress(results['address']),
  );
  server.start();
}
