import 'dart:io';

class DirectoryListing {
  List<FileSystemEntity> directoryContents;
  StringBuffer html = StringBuffer();

  DirectoryListing(this.directoryContents);

  String render() {
    return '''
    <html>
    <body>
      ${directoryContents.map((child) => FileEntry(child).render()).join()}
    </body>
    </html>
    ''';
  }
}

class FileEntry {
  FileSystemEntity fileSystemEntity;

  FileEntry(this.fileSystemEntity);

  String render() {
    return '''
    <div>
      <a href="/${fileSystemEntity.uri.path}">${fileSystemEntity.uri.toFilePath()}</a>
    </div>
    ''';
  }
}
