import '../base_request.dart';
import '../base_response.dart';

class TaskModel implements BaseRequest<TaskModel>, BaseResponse {
  @override
  final int id;
  final String name;
  final double reward;
  final String description;
  final String startPoint;
  final String endPoint;
  final int customerId;
  final String state;

  TaskModel({
    this.id = 0, // 0 для новых задач
    required this.name,
    required this.reward,
    required this.description,
    required this.startPoint,
    required this.endPoint,
    required this.customerId,
    required this.state,
  });

  // Реализация BaseRequest - для создания задач
  @override
  Map<String, dynamic> toCreateJson() => {
    'Task_name': name,
    'Reward': reward,
    'Description': description,
    'Start_point': startPoint,
    'End_point': endPoint,
    'Customer_ID': customerId,
    'Task_state': state,
  };

  // Реализация BaseResponse - для полных данных
  @override
  Map<String, dynamic> toJson() => {
    'Task_ID': id,
    'Task_name': name,
    'Reward': reward,
    'Description': description,
    'Start_point': startPoint,
    'End_point': endPoint,
    'Customer_ID': customerId,
    'Task_state': state,
  };

  // Парсинг из JSON
  TaskModel fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['Task_ID'] ?? 0,
      name: json['Task_name'],
      reward: json['Reward'] is int
          ? (json['Reward'] as int).toDouble()
          : json['Reward'].toDouble(),
      description: json['Description'],
      startPoint: json['Start_point'],
      endPoint: json['End_point'],
      customerId: json['Customer_ID'],
      state: json['Task_state'],
    );
  }

  // Для списка задач (заменяет TaskListResponse)
  List<TaskModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }

  // Для задач по customerId (заменяет TaskByCustomerResponse)
  List<TaskModel> listByCustomerFromJson(List<dynamic> jsonList) {
    return listFromJson(jsonList); // Можно добавить специфичную логику при необходимости
  }

  // Валидация
  void validate() {
    if (name.isEmpty) throw ArgumentError('Task name cannot be empty');
    if (reward <= 0) throw ArgumentError('Reward must be positive');
    if (customerId <= 0) throw ArgumentError('Customer ID must be positive');
  }
}