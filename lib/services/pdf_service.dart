
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PdfService {
  static Future<String> generateLaporan() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (pw.Context ctx) {
      return pw.Column(children: [
        pw.Text('Laporan Audit Kualitas Produk', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.Text('Ini adalah contoh laporan yang di-generate dari aplikasi.'),
      ]);
    }));

    final dir = await getTemporaryDirectory();
    final file = File('\${dir.path}/laporan_audit.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}
