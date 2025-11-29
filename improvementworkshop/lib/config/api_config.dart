class ApiConfig {
  // Backend URL on Render.com
  static const String baseUrl = 'https://welding-backend-v1-0.onrender.com';
  // static const String developmentBackendUrl = 'http://localhost:8000';

  // API Endpoints
  static const String machines = '$baseUrl/machines';
  static const String templates = '$baseUrl/templates';
  static const String workOrders = '$baseUrl/workorders';
  static const String equipment = '$baseUrl/equipment';
  static const String inspections = '$baseUrl/inspections';
  static const String employees = '$baseUrl/employees';
  static const String items = '$baseUrl/items';

  // Upload endpoint (requires template_id)
  static String upload(int templateId) => '$baseUrl/upload/$templateId';

  // Schedule import endpoint
  static String scheduleImport(int templateId) => '$baseUrl/schedule/import/$templateId';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}