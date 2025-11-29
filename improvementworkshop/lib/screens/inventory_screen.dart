// ==========================================
// lib/screens/inventory_screen.dart
// ==========================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';

// import '../models/item.dart';
import '../providers/app_provider.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AppProvider>().loadItems(),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.items.isEmpty) {
            return const Center(child: Text('No items in inventory'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Item ID')),
                  DataColumn(label: Text('Item Name')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Unit')),
                  DataColumn(label: Text('Reorder Level')),
                  DataColumn(label: Text('Status')),
                ],
                rows: provider.items.map((item) {
                  final isLow = item.quantity != null &&
                      item.reorderLevel != null &&
                      item.quantity! <= item.reorderLevel!;

                  return DataRow(cells: [
                    DataCell(Text(item.itemId)),
                    DataCell(Text(item.itemName)),
                    DataCell(Text('${item.quantity ?? 0}')),
                    DataCell(Text(item.unit ?? '')),
                    DataCell(Text('${item.reorderLevel ?? 0}')),
                    DataCell(
                      isLow
                          ? const Chip(
                        label: Text('Low Stock', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.red,
                      )
                          : const Chip(
                        label: Text('OK', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: Colors.blue.shade900,
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final itemIdController = TextEditingController();
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController();
    final reorderController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Inventory Item'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: itemIdController,
                decoration: const InputDecoration(labelText: 'Item ID'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unit (kg, pcs, etc.)'),
              ),
              TextFormField(
                controller: reorderController,
                decoration: const InputDecoration(labelText: 'Reorder Level'),
                keyboardType: TextInputType.number,
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
                final item = Item(
                  itemId: itemIdController.text,
                  itemName: nameController.text,
                  quantity: int.tryParse(quantityController.text),
                  unit: unitController.text,
                  reorderLevel: int.tryParse(reorderController.text),
                );

                try {
                  await context.read<AppProvider>().addItem(item);
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
