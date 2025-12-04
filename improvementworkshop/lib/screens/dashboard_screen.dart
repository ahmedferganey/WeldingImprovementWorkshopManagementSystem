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
                // ----------------- Stats Cards -----------------
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _StatCard(
                          title: 'Work Orders',
                          value: provider.workOrders.length.toString(),
                          icon: Icons.work,
                          color: Colors.blue,
                          width: isMobile
                              ? constraints.maxWidth
                              : (constraints.maxWidth - 48) / 4,
                        ),
                        _StatCard(
                          title: 'Equipment',
                          value: provider.equipment.length.toString(),
                          icon: Icons.precision_manufacturing,
                          color: Colors.orange,
                          width: isMobile
                              ? constraints.maxWidth
                              : (constraints.maxWidth - 48) / 4,
                        ),
                        _StatCard(
                          title: 'Inspections',
                          value: provider.inspections.length.toString(),
                          icon: Icons.verified,
                          color: Colors.green,
                          width: isMobile
                              ? constraints.maxWidth
                              : (constraints.maxWidth - 48) / 4,
                        ),
                        _StatCard(
                          title: 'Employees',
                          value: provider.employees.length.toString(),
                          icon: Icons.people,
                          color: Colors.purple,
                          width: isMobile
                              ? constraints.maxWidth
                              : (constraints.maxWidth - 48) / 4,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ----------------- Charts -----------------
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 800;
                    return isMobile
                        ? Column(
                      children: [
                        _buildChartCard(
                            'Work Order Status',
                            _WorkOrderChart(
                                workOrders: provider.workOrders)),
                        const SizedBox(height: 16),
                        _buildChartCard(
                            'Inspection Results',
                            _InspectionChart(
                                inspections: provider.inspections)),
                      ],
                    )
                        : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildChartCard(
                              'Work Order Status',
                              _WorkOrderChart(
                                  workOrders: provider.workOrders)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildChartCard(
                              'Inspection Results',
                              _InspectionChart(
                                  inspections: provider.inspections)),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // ----------------- Low Stock Table -----------------
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
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _LowStockTable(items: provider.items),
                        ),
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

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }
}

// ----------------- Stat Card -----------------
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? width;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 32, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
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
      ),
    );
  }
}

// ----------------- Work Order Chart -----------------
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

// ----------------- Inspection Chart -----------------
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

// ----------------- Low Stock Table -----------------
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
