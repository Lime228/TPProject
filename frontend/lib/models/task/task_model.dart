import '../base_request.dart';
import '../base_response.dart';

class TaskModel implements BaseRequest<TaskModel>, BaseResponse {
  @override
  int id;
  String name;
  int reward;
  String description;
  String startPoint;
  String endPoint;
  int state;
  int customerId;

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
    int? reward,
    String? description,
    String? startPoint,
    String? endPoint,
    int? customerId,
    int? state,
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
  Map<String, dynamic> createRequest(int lId) => {
    'name': name,
    'reward': reward,
    'description': description,
    'startdate': startPoint,
    'enddate': endPoint,
    'customerid': customerId,
    'lobbyid': lId
  };

  Map<String, dynamic> updateRequest() => {
    'taskId': id,
    'name': name,
    'reward': reward,
    'description': description,
    'startdate': startPoint,
    'enddate': endPoint,
    // 'customerid': customerId, его там нету пока, надо добавить
    //'state': state
    // не забыть про гет
  };

  Map<String, dynamic> deleteRequest() => {
    'taskId':id
  };
  // Реализация BaseResponse
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'reward': reward,
    'description': description,
    'startdate': startPoint,
    'enddate': endPoint,
    'customerid': customerId,
    'isActive': state,
  };

  factory TaskModel.fromResponse(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      name: json['name'],
      reward: (json['reward'] is int) ? (json['reward'] as int).toDouble() : json['reward'].toDouble(),
      description: json['description'],
      startPoint: json['startDate'],
      endPoint: json['endDate'],
      customerId: json['customerId'],
      state: json['isActive'],
      isCompleted: json['isCompleted'] ?? false,
      isOverdue: json['isOverdue'] ?? false,
    );
  }

  @override
  TaskModel fromJson(Map<String, dynamic> json) {
    return TaskModel.fromResponse(json);
  }

  static List<TaskModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => TaskModel.fromResponse(json)).toList();
  }
}
