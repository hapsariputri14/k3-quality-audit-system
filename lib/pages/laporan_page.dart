
import 'package:flutter/material.dart';
import '../services/pdf_service.dart';

class LaporanPage extends StatelessWidget {
  const LaporanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final path = await PdfService.generateLaporan();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF saved to: $path')));
        },
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Generate Laporan PDF'),
      ),
    );
  }
}
