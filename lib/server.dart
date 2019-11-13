import 'dart:io';
import 'package:dart_serve/pages.dart';
import 'package:http_server/http_server.dart';
import 'package:logging/logging.dart';

class Server {
  final Logger log = Logger('Server');

  InternetAddress _address;
  int port;
  VirtualDirectory _staticFiles;

  String certificateChain = './cert.pem';
  String serverKey = './key.pem';

  Server({
    this.port = 8080,
    InternetAddress address,
    String directory,
  })  : this._address = address ?? InternetAddress.loopbackIPv4,
        this._staticFiles = VirtualDirectory(directory ?? '.');

  Future<void> start() async {
    var serverContext = SecurityContext(); /*1*/
    serverContext.useCertificateChain(certificateChain); /*2*/
    serverContext.usePrivateKey(serverKey); /*3*/
    var server = await HttpServer.bindSecure(_address, port, serverContext);
    log.info('Listening on https://${_address.address}:${server.port}');

    _staticFiles.allowDirectoryListing = true;
    _staticFiles.directoryHandler = _directoryHandler;

    _staticFiles.errorPageHandler = _errorPageHandler;

    await server.forEach((request) async {
      HttpResponse response = await _staticFiles.serveRequest(request);
      log.info('${response.statusCode} ${request.requestedUri.path}');
    });
  }

  void _serveDirectoryContents(Directory dir, HttpRequest request) {
    var directoryListing = DirectoryListing(dir.listSync(recursive: false));
    var html = directoryListing.render();
    request.response.headers.add("content-type", "text/html");
    request.response.write(html.toString());
    request.response.close();
  }

  void _directoryHandler(Directory dir, HttpRequest request) {
    var rootDirectoryUri = Uri.file(dir.path);
    var indexFile = File(rootDirectoryUri.resolve('index.html').toFilePath());
    if (indexFile.existsSync()) {
      _staticFiles.serveFile(indexFile, request);
    } else {
      _serveDirectoryContents(dir, request);
    }
  }

  void _errorPageHandler(HttpRequest request) {
    var response = request.response;
    response.write('Not found');
    response.close();
  }
}
