import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class HazardPage extends StatelessWidget {
  const HazardPage({super.key});

  // Fungsi helper: infer hazard dari audit
  Map<String, dynamic> inferHazardFromAudit(Map<String, dynamic> audit) {
    int prob = 1;
    int sev = 1;
    String hazard = 'Belum dianalisis';
    String impact = 'Belum dianalisis';
    String control = 'APD & SOP'; // default

    switch (audit['overall'] ?? '') {
      case 'Unsatisfactory':
        prob = 3;
        sev = 4;
        hazard = 'Kualitas buruk';
        impact = 'Produk gagal / cacat';
        break;
      case 'Needs Improvement':
        prob = 2;
        sev = 3;
        hazard = 'Perlu perbaikan';
        impact = 'Kualitas menurun';
        break;
      case 'Satisfactory':
        prob = 1;
        sev = 1;
        hazard = 'Tidak ada';
        impact = 'Tidak ada';
        break;
    }

    final rec = (audit['recommendations'] ?? '').toString().toLowerCase();
    if (rec.contains('kemasan')) {
      hazard = 'Kerusakan kemasan';
      impact = 'Kerugian produk';
      control = 'Perbaikan kemasan, APD & SOP';
    } else if (rec.contains('fungsi') || rec.contains('material')) {
      hazard = 'Performa / material menurun';
      impact = 'Produk tidak sesuai standar';
      control = 'Pemeriksaan fungsi/material, APD & SOP';
    }

    return {
      'hazard': hazard,
      'impact': impact,
      'prob': prob,
      'sev': sev,
      'risk': prob * sev,
      'control': control,
    };
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService fs = FirestoreService();

    final hazardListStatic = [
      {
        'activity': 'Pengelasan',
        'hazard': 'Percikan api',
        'impact': 'Luka bakar',
        'prob': 3,
        'sev': 4,
        'control': 'APD lengkap, pelatihan K3'
      },
      {
        'activity': 'Pengoperasian Mesin',
        'hazard': 'Terjepit mesin',
        'impact': 'Cedera fisik',
        'prob': 2,
        'sev': 5,
        'control': 'Guard mesin, SOP ketat'
      },
      {
        'activity': 'Pengangkatan Manual',
        'hazard': 'Beban berat',
        'impact': 'Cedera punggung',
        'prob': 4,
        'sev': 3,
        'control': 'Alat bantu angkat, pelatihan'
      },
      {
        'activity': 'Inspeksi Quality',
        'hazard': 'Pencahayaan kurang',
        'impact': 'Kelelahan mata',
        'prob': 3,
        'sev': 2,
        'control': 'Penerangan memadai, istirahat'
      },
    ];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hazard Identification (HIRA)',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Tabel HIRA statis
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    MaterialStatePropertyAll(Colors.indigo.shade50),
                columns: const [
                  DataColumn(label: Text('Aktivitas')),
                  DataColumn(label: Text('Bahaya')),
                  DataColumn(label: Text('Dampak')),
                  DataColumn(label: Text('Kemungkinan')),
                  DataColumn(label: Text('Keparahan')),
                  DataColumn(label: Text('Risiko')),
                  DataColumn(label: Text('Pengendalian')),
                ],
                rows: hazardListStatic.map((h) {
                  final int prob = h['prob'] as int? ?? 1;
                  final int sev = h['sev'] as int? ?? 1;
                  final int risk = prob * sev;

                  Color color;
                  String level;
                  if (risk >= 12) {
                    color = Colors.red;
                    level = 'Tinggi';
                  } else if (risk >= 8) {
                    color = Colors.orange;
                    level = 'Sedang';
                  } else if (risk >= 4) {
                    color = Colors.yellow.shade700;
                    level = 'Rendah';
                  } else {
                    color = Colors.green;
                    level = 'Sangat Rendah';
                  }

                  return DataRow(
                    color: MaterialStatePropertyAll(color.withOpacity(0.08)),
                    cells: [
                      DataCell(Text(h['activity'].toString())),
                      DataCell(Text(h['hazard'].toString())),
                      DataCell(Text(h['impact'].toString())),
                      DataCell(Text(prob.toString())),
                      DataCell(Text(sev.toString())),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text('$risk ($level)',
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.bold)),
                      )),
                      DataCell(Text(h['control'].toString())),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Keterangan risiko
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Keterangan Tingkat Risiko',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('< 4: Sangat Rendah\n4-7: Rendah\n8-11: Sedang\n≥ 12: Tinggi'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Hazard Terdeteksi dari Audit',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Hazard dinamis dari data audit
            StreamBuilder<QuerySnapshot>(
              stream: fs.getAuditsStream(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Card(
                    color: Colors.grey[200],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text('Belum ada hazard dari audit',
                            style: TextStyle(color: Colors.grey[600])),
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        MaterialStatePropertyAll(Colors.blue.shade50),
                    columns: const [
                      DataColumn(label: Text('Produk')),
                      DataColumn(label: Text('Bahaya')),
                      DataColumn(label: Text('Dampak')),
                      DataColumn(label: Text('Probabilitas')),
                      DataColumn(label: Text('Keparahan')),
                      DataColumn(label: Text('Risiko')),
                      DataColumn(label: Text('Kontrol')),
                    ],
                    rows: docs.map((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final inferred = inferHazardFromAudit(data);

                      final int prob = inferred['prob'] as int? ?? 1;
                      final int sev = inferred['sev'] as int? ?? 1;
                      final int risk = inferred['risk'] as int? ?? (prob * sev);
                      final String hazard = inferred['hazard'] as String? ?? '-';
                      final String impact = inferred['impact'] as String? ?? '-';
                      final String control = inferred['control'] as String? ?? '-';

                      Color color;
                      String level;
                      if (risk >= 12) {
                        color = Colors.red;
                        level = 'Tinggi';
                      } else if (risk >= 8) {
                        color = Colors.orange;
                        level = 'Sedang';
                      } else if (risk >= 4) {
                        color = Colors.yellow.shade700;
                        level = 'Rendah';
                      } else {
                        color = Colors.green;
                        level = 'Sangat Rendah';
                      }

                      return DataRow(
                        color: MaterialStatePropertyAll(color.withOpacity(0.08)),
                        cells: [
                          DataCell(Text(data['productName'] ?? '-')),
                          DataCell(Text(hazard)),
                          DataCell(Text(impact)),
                          DataCell(Text(prob.toString())),
                          DataCell(Text(sev.toString())),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text('$risk ($level)',
                                style: TextStyle(
                                    color: color, fontWeight: FontWeight.bold)),
                          )),
                          DataCell(Text(control)),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
