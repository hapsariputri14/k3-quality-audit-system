import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService fs = FirestoreService();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: fs.getAuditsStream(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          // Hitung statistik
          int totalAudit = docs.length;
          int hazardDetected = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return (data['hazardDetected'] ?? false) == true;
          }).length;
          int highRisk = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            int prob = (data['prob'] ?? 1) as int;
            int sev = (data['sev'] ?? 1) as int;
            return prob * sev >= 12;
          }).length;

          // Data chart per bulan
          Map<int, int> monthCount = {};
          for (var d in docs) {
            final data = d.data() as Map<String, dynamic>;
            Timestamp? ts = data['createdAt'] as Timestamp?;
            if (ts != null) {
              int month = ts.toDate().month;
              monthCount[month] = (monthCount[month] ?? 0) + 1;
            }
          }
          final spots = List.generate(12, (i) {
            int count = monthCount[i + 1] ?? 0;
            return FlSpot(i.toDouble(), count.toDouble());
          });

          // Overview pie chart
          final pieSections = [
            PieChartSectionData(
                value: hazardDetected.toDouble(),
                color: Colors.orange,
                title: 'Hazard'),
            PieChartSectionData(
                value: (totalAudit - hazardDetected).toDouble(),
                color: Colors.green,
                title: 'Safe'),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dashboard',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _statCard('Total Audit', totalAudit.toString(),
                        Icons.fact_check, Colors.indigo),
                    _statCard('Temuan Hazard', hazardDetected.toString(),
                        Icons.warning_amber_rounded, Colors.orange),
                    _statCard('Resiko Tinggi', highRisk.toString(),
                        Icons.trending_up, Colors.red),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _barChartCard(spots),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(width: 360, child: _pieChartCard(pieSections)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.black54)),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ])
        ],
      ),
    );
  }

  Widget _barChartCard(List<FlSpot> spots) {
    double maxY = spots.map((s) => s.y).fold(0.0, (prev, y) => y > prev ? y : prev) + 1.0;
    return Container(
      height: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)]),
      child: LineChart(LineChartData(
        minY: 0,
        maxY: maxY,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                int idx = value.toInt();
                if (idx >= 0 && idx < 12) return Text(months[idx]);
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: spots,
            color: Colors.indigo,
            belowBarData: BarAreaData(show: true, color: Colors.indigoAccent.withOpacity(0.2)),
          ),
        ],
      )),
    );
  }

  Widget _pieChartCard(List<PieChartSectionData> sections) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: PieChart(PieChartData(
              sections: sections,
              centerSpaceRadius: 30,
              sectionsSpace: 4,
              borderData: FlBorderData(show: false),
            )),
          ),
        ],
      ),
    );
  }
}
