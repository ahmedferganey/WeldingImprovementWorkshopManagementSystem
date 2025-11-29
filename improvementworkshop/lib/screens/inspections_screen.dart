// ==========================================
// lib/screens/inspections_screen.dart
// ==========================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';

class InspectionsScreen extends StatelessWidget {
  const InspectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Inspections'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AppProvider>().loadInspections(),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.inspections.isEmpty) {
            return const Center(child: Text('No inspections recorded'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Inspection ID')),
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('Inspector')),
                  DataColumn(label: Text('Result')),
                  DataColumn(label: Text('Defect Type')),
                ],
                rows: provider.inspections.map((inspection) {
                  return DataRow(cells: [
                    DataCell(Text(inspection.inspectionId)),
                    DataCell(Text(inspection.orderId)),
                    DataCell(Text(inspection.inspector)),
                    DataCell(_ResultBadge(result: inspection.result)),
                    DataCell(Text(inspection.defectType ?? 'N/A')),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddInspectionDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Inspection'),
        backgroundColor: Colors.blue.shade900,
      ),
    );
  }

  void _showAddInspectionDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final inspectionIdController = TextEditingController();
    final orderIdController = TextEditingController();
    final inspectorController = TextEditingController();
    final defectController = TextEditingController();
    String result = 'Pass';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Inspection'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: inspectionIdController,
                decoration: const InputDecoration(labelText: 'Inspection ID'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: orderIdController,
                decoration: const InputDecoration(labelText: 'Order ID'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: inspectorController,
                decoration: const InputDecoration(labelText: 'Inspector'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: result,
                decoration: const InputDecoration(labelText: 'Result'),
                items: ['Pass', 'Fail']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => result = v!,
              ),
              TextFormField(
                controller: defectController,
                decoration: const InputDecoration(labelText: 'Defect Type (if any)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final inspection = Inspection(
                  inspectionId: inspectionIdController.text,
                  orderId: orderIdController.text,
                  inspector: inspectorController.text,
                  result: result,
                  defectType: defectController.text.isEmpty ? null : defectController.text,
                );

                try {
                  await context.read<AppProvider>().addInspection(inspection);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final String result;

  const _ResultBadge({required this.result});

  @override
  Widget build(BuildContext context) {
    final isPass = result.toLowerCase() == 'pass';
    return Chip(
      label: Text(
        result,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: isPass ? Colors.green : Colors.red,
    );
  }
}
