// ==========================================
// lib/screens/machines_screen.dart
// ==========================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';

// import '../models/machine.dart';
import '../models/template.dart';
import '../providers/app_provider.dart';

class MachinesScreen extends StatelessWidget {
  const MachinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Machines & Templates'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AppProvider>().loadMachines();
              context.read<AppProvider>().loadTemplates();
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Machines',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (provider.machines.isEmpty)
                  const Text('No machines configured')
                else
                  Card(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Code')),
                        DataColumn(label: Text('Type')),
                      ],
                      rows: provider.machines.map((machine) {
                        return DataRow(cells: [
                          DataCell(Text(machine.name)),
                          DataCell(Text(machine.code)),
                          DataCell(Text(machine.type ?? 'N/A')),
                        ]);
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 32),
                const Text(
                  'Import Templates',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (provider.templates.isEmpty)
                  const Text('No templates configured')
                else
                  Card(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Machine ID')),
                      ],
                      rows: provider.templates.map((template) {
                        return DataRow(cells: [
                          DataCell(Text(template.name)),
                          DataCell(Text(template.description ?? 'N/A')),
                          DataCell(Text('${template.machineId}')),
                        ]);
                      }).toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMachineDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Machine'),
        backgroundColor: Colors.blue.shade900,
      ),
    );
  }

  void _showAddMachineDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final typeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Machine'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Code'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type'),
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
                final machine = Machine(
                  name: nameController.text,
                  code: codeController.text,
                  type: typeController.text,
                );

                try {
                  await context.read<AppProvider>().addMachine(machine);
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
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}