import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Cards Row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Work Orders',
                        value: provider.workOrders.length.toString(),
                        icon: Icons.work,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Equipment',
                        value: provider.equipment.length.toString(),
                        icon: Icons.precision_manufacturing,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Inspections',
                        value: provider.inspections.length.toString(),
                        icon: Icons.verified,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Employees',
                        value: provider.employees.length.toString(),
                        icon: Icons.people,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Charts Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Work Order Status',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: _WorkOrderChart(
                                  workOrders: provider.workOrders,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Inspection Results',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: _InspectionChart(
                                  inspections: provider.inspections,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Activity
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Low Stock Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _LowStockTable(items: provider.items),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 32, color: color),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkOrderChart extends StatelessWidget {
  final List workOrders;

  const _WorkOrderChart({required this.workOrders});

  @override
  Widget build(BuildContext context) {
    final statusCounts = <String, int>{};
    for (var order in workOrders) {
      final status = order.status ?? 'Unknown';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    if (statusCounts.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return PieChart(
      PieChartData(
        sections: statusCounts.entries.map((entry) {
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: '${entry.key}\n${entry.value}',
            color: _getStatusColor(entry.key),
            radius: 80,
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _InspectionChart extends StatelessWidget {
  final List inspections;

  const _InspectionChart({required this.inspections});

  @override
  Widget build(BuildContext context) {
    final resultCounts = <String, int>{};
    for (var inspection in inspections) {
      final result = inspection.result;
      resultCounts[result] = (resultCounts[result] ?? 0) + 1;
    }

    if (resultCounts.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return PieChart(
      PieChartData(
        sections: resultCounts.entries.map((entry) {
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: '${entry.key}\n${entry.value}',
            color: entry.key.toLowerCase() == 'pass' ? Colors.green : Colors.red,
            radius: 80,
          );
        }).toList(),
      ),
    );
  }
}

class _LowStockTable extends StatelessWidget {
  final List items;

  const _LowStockTable({required this.items});

  @override
  Widget build(BuildContext context) {
    final lowStockItems = items
        .where((item) =>
    item.quantity != null &&
        item.reorderLevel != null &&
        item.quantity! <= item.reorderLevel!)
        .toList();

    if (lowStockItems.isEmpty) {
      return const Text('All items are sufficiently stocked');
    }

    return DataTable(
      columns: const [
        DataColumn(label: Text('Item Name')),
        DataColumn(label: Text('Quantity')),
        DataColumn(label: Text('Reorder Level')),
      ],
      rows: lowStockItems.map((item) {
        return DataRow(cells: [
          DataCell(Text(item.itemName)),
          DataCell(Text('${item.quantity} ${item.unit ?? ''}')),
          DataCell(Text('${item.reorderLevel}')),
        ]);
      }).toList(),
    );
  }
}