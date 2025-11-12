import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'dart:math' as math;

class DataAuditPage extends StatefulWidget {
  const DataAuditPage({Key? key}) : super(key: key);

  @override
  State<DataAuditPage> createState() => _DataAuditPageState();
}

class _DataAuditPageState extends State<DataAuditPage>
    with SingleTickerProviderStateMixin {
  final FirestoreService _fs = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _auditorCtrl = TextEditingController();
  final _productCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _recommendationsCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _appearance;
  String? _function;
  String? _material;
  String? _dimensions;
  String? _overall;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _auditorCtrl.dispose();
    _productCtrl.dispose();
    _modelCtrl.dispose();
    _recommendationsCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = {
      'productName': _productCtrl.text.trim(),
      'auditDate':
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
      'auditor': _auditorCtrl.text.trim(),
      'modelVersion': _modelCtrl.text.trim(),
      'appearance': _appearance ?? '',
      'function': _function ?? '',
      'material': _material ?? '',
      'dimensions': _dimensions ?? '',
      'overall': _overall ?? '',
      'recommendations': _recommendationsCtrl.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _fs.addAudit(data);

    setState(() => _isSubmitting = false);

    _formKey.currentState!.reset();
    _productCtrl.clear();
    _auditorCtrl.clear();
    _modelCtrl.clear();
    _recommendationsCtrl.clear();
    _appearance = _function = _material = _dimensions = _overall = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Data audit berhasil disimpan!')),
    );
  }

  Widget _buildRadio(String? group, String label, void Function(String?) onChanged) {
    return Expanded(
      child: RadioListTile<String>(
        title: Text(label),
        value: label,
        groupValue: group,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildQuestion(String title, String? group, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        Row(
          children: [
            _buildRadio(group, 'Satisfactory', onChanged),
            _buildRadio(group, 'Needs Improvement', onChanged),
            _buildRadio(group, 'Unsatisfactory', onChanged),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // HEADER
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Product Quality Audit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Comprehensive Quality Assessment System',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // FORM CARD
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _productCtrl,
                            decoration: const InputDecoration(labelText: 'Nama Produk'),
                            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _auditorCtrl,
                            decoration: const InputDecoration(labelText: 'Nama Auditor'),
                            validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: 'Tanggal Audit', border: OutlineInputBorder()),
                              child: Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _modelCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Model/Versi Produk'),
                          ),
                          const SizedBox(height: 20),
                          const Text('Penilaian Kualitas:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          _buildQuestion('Appearance (Tampilan)', _appearance,
                              (v) => setState(() => _appearance = v)),
                          _buildQuestion('Function/Performance', _function,
                              (v) => setState(() => _function = v)),
                          _buildQuestion('Material Quality', _material,
                              (v) => setState(() => _material = v)),
                          _buildQuestion('Dimensions', _dimensions,
                              (v) => setState(() => _dimensions = v)),
                          _buildQuestion('Overall Quality', _overall,
                              (v) => setState(() => _overall = v)),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _recommendationsCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Rekomendasi',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : _submitForm,
                              icon: _isSubmitting
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save),
                              label: const Text('Simpan Audit'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                backgroundColor: const Color(0xFF667EEA),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // TABEL DATA AUDIT
                  const Text(
                    'Daftar Data Audit',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: _fs.getAuditsStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return const Text('Belum ada data audit',
                            style: TextStyle(color: Colors.white70));
                      }
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor:
                              MaterialStateProperty.all(Colors.deepPurple[100]),
                          columns: const [
                            DataColumn(label: Text('Produk')),
                            DataColumn(label: Text('Auditor')),
                            DataColumn(label: Text('Tanggal')),
                            DataColumn(label: Text('Model')),
                            DataColumn(label: Text('Overall')),
                            DataColumn(label: Text('Rekomendasi')),
                            DataColumn(label: Text('Aksi')),
                          ],
                          rows: docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return DataRow(cells: [
                              DataCell(Text(data['productName'] ?? '-')),
                              DataCell(Text(data['auditor'] ?? '-')),
                              DataCell(Text(data['auditDate'] ?? '-')),
                              DataCell(Text(data['modelVersion'] ?? '-')),
                              DataCell(Text(data['overall'] ?? '-')),
                              DataCell(Text(data['recommendations'] ?? '-')),
                              DataCell(IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _fs.deleteAudit(doc.id),
                              )),
                            ]);
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}