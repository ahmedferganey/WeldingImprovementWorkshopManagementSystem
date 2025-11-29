import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/work_orders_screen.dart';
import 'screens/equipment_screen.dart';
import 'screens/inspections_screen.dart';
import 'screens/employees_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/machines_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const WeldingWorkshopApp(),
    ),
  );
}

class WeldingWorkshopApp extends StatelessWidget {
  const WeldingWorkshopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welding Workshop Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const WorkOrdersScreen(),
    const EquipmentScreen(),
    const InspectionsScreen(),
    const EmployeesScreen(),
    const InventoryScreen(),
    const MachinesScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.dashboard, label: 'Dashboard'),
    NavItem(icon: Icons.work, label: 'Work Orders'),
    NavItem(icon: Icons.precision_manufacturing, label: 'Equipment'),
    NavItem(icon: Icons.verified, label: 'Inspections'),
    NavItem(icon: Icons.people, label: 'Employees'),
    NavItem(icon: Icons.inventory, label: 'Inventory'),
    NavItem(icon: Icons.settings_input_component, label: 'Machines'),
  ];

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.blue.shade900,
            selectedIconTheme: const IconThemeData(color: Colors.white),
            unselectedIconTheme: IconThemeData(color: Colors.blue.shade200),
            selectedLabelTextStyle: const TextStyle(color: Colors.white),
            unselectedLabelTextStyle: TextStyle(color: Colors.blue.shade200),
            destinations: _navItems
                .map((item) => NavigationRailDestination(
              icon: Icon(item.icon),
              label: Text(item.label),
            ))
                .toList(),
          ),
          // Main Content Area
          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}