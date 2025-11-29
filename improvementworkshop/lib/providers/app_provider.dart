import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';


class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Data lists
  List<WorkOrder> _workOrders = [];
  List<Equipment> _equipment = [];
  List<Inspection> _inspections = [];
  List<Employee> _employees = [];
  List<Item> _items = [];
  List<Machine> _machines = [];
  List<Template> _templates = [];

  // Loading states
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<WorkOrder> get workOrders => _workOrders;
  List<Equipment> get equipment => _equipment;
  List<Inspection> get inspections => _inspections;
  List<Employee> get employees => _employees;
  List<Item> get items => _items;
  List<Machine> get machines => _machines;
  List<Template> get templates => _templates;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all data
  Future<void> loadAllData() async {
    await Future.wait([
      loadWorkOrders(),
      loadEquipment(),
      loadInspections(),
      loadEmployees(),
      loadItems(),
      loadMachines(),
      loadTemplates(),
    ]);
  }

  // Work Orders
  Future<void> loadWorkOrders() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _workOrders = await _apiService.getWorkOrders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWorkOrder(WorkOrder workOrder) async {
    try {
      _isLoading = true;
      notifyListeners();

      final created = await _apiService.createWorkOrder(workOrder);
      _workOrders.add(created);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Equipment
  Future<void> loadEquipment() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _equipment = await _apiService.getEquipment();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEquipment(Equipment equipment) async {
    try {
      _isLoading = true;
      notifyListeners();

      final created = await _apiService.createEquipment(equipment);
      _equipment.add(created);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Inspections
  Future<void> loadInspections() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _inspections = await _apiService.getInspections();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addInspection(Inspection inspection) async {
    try {
      _isLoading = true;
      notifyListeners();

      final created = await _apiService.createInspection(inspection);
      _inspections.add(created);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Employees
  Future<void> loadEmployees() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _employees = await _apiService.getEmployees();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEmployee(Employee employee) async {
    try {
      _isLoading = true;
      notifyListeners();

      final created = await _apiService.createEmployee(employee);
      _employees.add(created);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Items
  Future<void> loadItems() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _items = await _apiService.getItems();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(Item item) async {
    try {
      _isLoading = true;
      notifyListeners();

      final created = await _apiService.createItem(item);
      _items.add(created);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Machines
  Future<void> loadMachines() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _machines = await _apiService.getMachines();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMachine(Machine machine) async {
    try {
      _isLoading = true;
      notifyListeners();

      final created = await _apiService.createMachine(machine);
      _machines.add(created);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Templates
  Future<void> loadTemplates() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _templates = await _apiService.getTemplates();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTemplate(Template template) async {
    try {
      _isLoading = true;
      notifyListeners();

      final created = await _apiService.createTemplate(template);
      _templates.add(created);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // File upload
  Future<Map<String, dynamic>> uploadFile(int templateId, String filePath, List<int> fileBytes) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await _apiService.uploadFile(templateId, filePath, fileBytes);

      _isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}