import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class GroceryExportService {
  static Future<void> downloadAndShareList(String listTitle, List<String> items) async {
    final buffer = StringBuffer();
    buffer.writeln('$listTitle');
    buffer.writeln('-------------------');
    for (var item in items) {
      buffer.writeln('• $item');
    }
    buffer.writeln('\nShared via NumSense App');
    
    final String content = buffer.toString();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/${listTitle.replaceAll(' ', '_')}.txt');
    await file.writeAsString(content);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: content, 
      subject: 'My Grocery List: $listTitle',
    );
  }
}