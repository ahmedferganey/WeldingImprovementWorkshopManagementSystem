import 'package:flutter/material.dart';

/// Custom Data Table Widget with enhanced styling
class CustomDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<dynamic>> rows;
  final bool showRowIndex;
  final void Function(int)? onRowTap;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.showRowIndex = false,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          dataRowHeight: 60,
          columns: [
            if (showRowIndex)
              const DataColumn(
                label: Text('#'),
              ),
            ...columns.map((col) => DataColumn(
              label: Text(col),
            )),
          ],
          rows: rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;

            return DataRow(
              onSelectChanged: onRowTap != null ? (_) => onRowTap!(index) : null,
              cells: [
                if (showRowIndex)
                  DataCell(Text('${index + 1}')),
                ...row.map((cell) {
                  if (cell is Widget) {
                    return DataCell(cell);
                  }
                  return DataCell(Text(cell.toString()));
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Responsive Data Table that adapts to screen size
class ResponsiveDataTable extends StatelessWidget {
  final List<String> columns;
  final List<Map<String, dynamic>> data;
  final String Function(Map<String, dynamic>) titleBuilder;
  final String Function(Map<String, dynamic>)? subtitleBuilder;
  final Widget Function(Map<String, dynamic>)? trailingBuilder;
  final void Function(Map<String, dynamic>)? onTap;

  const ResponsiveDataTable({
    super.key,
    required this.columns,
    required this.data,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.trailingBuilder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Show list on mobile, table on desktop
        if (constraints.maxWidth < 800) {
          return _buildListView();
        } else {
          return _buildDataTable();
        }
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(titleBuilder(item)),
            subtitle: subtitleBuilder != null
                ? Text(subtitleBuilder!(item))
                : null,
            trailing: trailingBuilder?.call(item),
            onTap: onTap != null ? () => onTap!(item) : null,
          ),
        );
      },
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
        rows: data.map((item) {
          return DataRow(
            cells: columns.map((col) {
              final value = item[col];
              if (value is Widget) {
                return DataCell(value);
              }
              return DataCell(Text(value?.toString() ?? ''));
            }).toList(),
            onSelectChanged: onTap != null ? (_) => onTap!(item) : null,
          );
        }).toList(),
      ),
    );
  }
}

/// Paginated Data Table
class PaginatedDataTable extends StatefulWidget {
  final List<String> columns;
  final List<List<dynamic>> rows;
  final int rowsPerPage;

  const PaginatedDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.rowsPerPage = 10,
  });

  @override
  State<PaginatedDataTable> createState() => _PaginatedDataTableState();
}

class _PaginatedDataTableState extends State<PaginatedDataTable> {
  int _currentPage = 0;

  int get totalPages => (widget.rows.length / widget.rowsPerPage).ceil();

  List<List<dynamic>> get currentPageRows {
    final start = _currentPage * widget.rowsPerPage;
    final end = (start + widget.rowsPerPage).clamp(0, widget.rows.length);
    return widget.rows.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomDataTable(
            columns: widget.columns,
            rows: currentPageRows,
            showRowIndex: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              Text('Page ${_currentPage + 1} of $totalPages'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < totalPages - 1
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Status Badge Widget
class StatusBadge extends StatelessWidget {
  final String status;
  final Color? color;

  const StatusBadge({
    super.key,
    required this.status,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
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
      case 'pass':
        return Colors.green;
      case 'fail':
        return Colors.red;
      case 'operational':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'out of service':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}