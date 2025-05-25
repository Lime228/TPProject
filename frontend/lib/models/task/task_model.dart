import 'dart:convert';

class TaskModel{
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
      state: state ?? this.state,
      customerId: customerId ?? this.customerId,

      isCompleted: isCompleted ?? this.isCompleted,
      isOverdue: isOverdue ?? this.isOverdue,
    );
  }


  @override
  Map<String, dynamic> createRequest(int lId) => {
    'name': name,
    'reward': reward.toInt(),
    'description': description,
    'startdate': startPoint,
    'enddate': endPoint,
    'lobbyid': lId,
    'customerid': customerId,
  };

  Map<String, dynamic> updateRequest() => {
    'taskId': id,
    'name': name,
    'description': description,
    'reward': reward,
    'startdate': startPoint,
    'enddate': endPoint,
    'state': state,
    'customerid': customerId,
  };

  Map<String, dynamic> deleteRequest() => {
    'taskId':id
  };


  factory TaskModel.fromResponse(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      name: utf8.decode(json['name'].toString().codeUnits), // Декодируем имя
      reward: json['reward']?.toInt() ?? 0,
      description: utf8.decode(json['description'].toString().codeUnits), // Декодируем описание
      startPoint: json['startDate'],
      endPoint: json['endDate'],
      customerId: json['customerId'],
      state: json['isActive'],

      isCompleted: json['isCompleted'] ?? false, // это че то лишнее надо с этим что то сделать
      isOverdue: json['isOverdue'] ?? false,
    );
  }


  // static List<TaskModel> listFromJson(List<dynamic> jsonList) {
  //   return jsonList.map((json) => TaskModel.fromResponse(json)).toList();
  // }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      name: json['name'],
      reward: json['reward']?.toInt() ?? 0,
      description: json['description'],
      startPoint: json['startDate'],
      endPoint: json['endDate'],
      customerId: json['customerId'],
      state: json['isActive'],

      isCompleted: json['isCompleted'] ?? false,
      isOverdue: json['isOverdue'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'reward': reward,
    'description': description,
    'startdate': startPoint,
    'enddate': endPoint,
    'lobbyid': state,
    'customerid': customerId,
    'isCompleted': isCompleted,
    'isOverdue': isOverdue,
  };
}
