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

  bool isCompleted;
  bool isOverdue;

  TaskModel({
    this.id = 0,
    required this.name,
    required this.reward,
    required this.description,
    required this.startPoint,
    required this.endPoint,
    required this.customerId,
    required this.state,
    this.isCompleted = false,
    this.isOverdue = false,
  });

  DateTime? get deadline {
    try {
      return DateTime.parse(endPoint);
    } catch (e) {
      print('Invalid deadline format: $endPoint');
      return null;
    }
  }

  DateTime get createdAt {
    try {
      return startPoint.isNotEmpty ? DateTime.parse(startPoint) : DateTime.now();
    } catch (e) {
      print('Invalid startPoint format: $startPoint');
      return DateTime.now();
    }
  }


  TaskModel copyWith({
    int? id,
    String? name,
    double? reward,
    String? description,
    String? startPoint,
    String? endPoint,
    int? customerId,
    String? state,
    bool? isCompleted,
    bool? isOverdue,
  }) {
    return TaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      reward: reward ?? this.reward,
      description: description ?? this.description,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      customerId: customerId ?? this.customerId,
      state: state ?? this.state,
      isCompleted: isCompleted ?? this.isCompleted,
      isOverdue: isOverdue ?? this.isOverdue,
    );
  }

  // Реализация BaseRequest
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

  // Реализация BaseResponse
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

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['Task_ID'] ?? 0,
      name: json['Task_name'],
      reward: (json['Reward'] is int) ? (json['Reward'] as int).toDouble() : json['Reward'].toDouble(),
      description: json['Description'],
      startPoint: json['Start_point'],
      endPoint: json['End_point'],
      customerId: json['Customer_ID'],
      state: json['Task_state'],
      isCompleted: json['isCompleted'] ?? false,
      isOverdue: json['isOverdue'] ?? false,
    );
  }

  @override
  TaskModel fromJson(Map<String, dynamic> json) {
    return TaskModel.fromJson(json);
  }

  static List<TaskModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => TaskModel.fromJson(json)).toList();
  }
}
