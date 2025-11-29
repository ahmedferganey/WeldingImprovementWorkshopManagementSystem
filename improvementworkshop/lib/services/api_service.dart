// For local development, change to: 'http://localhost:8000'
// Your frontend URL is: https://weldingworkshop-f4697.web.app

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/models.dart';
// import '../models/Item.dart';

class ApiService {
  // Helper method for GET requests
  Future<List<T>> _getList<T>(
      String url,
      T Function(Map<String, dynamic>) fromJson,
      ) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Helper method for POST requests
  Future<T> _post<T>(
      String url,
      Map<String, dynamic> body,
      T Function(Map<String, dynamic>) fromJson,
      ) async {
    try {
      final response = await http
          .post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return fromJson(json.decode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to create: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Work Orders
  Future<List<WorkOrder>> getWorkOrders() async {
    return _getList(ApiConfig.workOrders, WorkOrder.fromJson);
  }

  Future<WorkOrder> createWorkOrder(WorkOrder workOrder) async {
    return _post(ApiConfig.workOrders, workOrder.toJson(), WorkOrder.fromJson);
  }

  // Equipment
  Future<List<Equipment>> getEquipment() async {
    return _getList(ApiConfig.equipment, Equipment.fromJson);
  }

  Future<Equipment> createEquipment(Equipment equipment) async {
    return _post(ApiConfig.equipment, equipment.toJson(), Equipment.fromJson);
  }

  // Inspections
  Future<List<Inspection>> getInspections() async {
    return _getList(ApiConfig.inspections, Inspection.fromJson);
  }

  Future<Inspection> createInspection(Inspection inspection) async {
    return _post(ApiConfig.inspections, inspection.toJson(), Inspection.fromJson);
  }

  // Employees
  Future<List<Employee>> getEmployees() async {
    return _getList(ApiConfig.employees, Employee.fromJson);
  }

  Future<Employee> createEmployee(Employee employee) async {
    return _post(ApiConfig.employees, employee.toJson(), Employee.fromJson);
  }

  // Items (Inventory)
  Future<List<Item>> getItems() async {
    return _getList(ApiConfig.items, Item.fromJson);
  }

  Future<Item> createItem(Item item) async {
    return _post(ApiConfig.items, item.toJson(), Item.fromJson);
  }

  // Machines
  Future<List<Machine>> getMachines() async {
    return _getList(ApiConfig.machines, Machine.fromJson);
  }

  Future<Machine> createMachine(Machine machine) async {
    return _post(ApiConfig.machines, machine.toJson(), Machine.fromJson);
  }

  // Templates
  Future<List<Template>> getTemplates() async {
    return _getList(ApiConfig.templates, Template.fromJson);
  }

  Future<Template> createTemplate(Template template) async {
    return _post(ApiConfig.templates, template.toJson(), Template.fromJson);
  }

  // File Upload
  Future<Map<String, dynamic>> uploadFile(int templateId, String filePath, List<int> fileBytes) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.upload(templateId)),
      );

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filePath.split('/').last,
      ));

      final streamedResponse = await request.send().timeout(ApiConfig.receiveTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }
}