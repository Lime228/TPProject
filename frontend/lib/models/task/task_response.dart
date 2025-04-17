class TaskResponse {
  final int id;
  final String name;
  final double reward;
  final String description;
  final String startPoint;
  final String endPoint;
  final int customerId;
  final String state;

  TaskResponse({
    required this.id,
    required this.name,
    required this.reward,
    required this.description,
    required this.startPoint,
    required this.endPoint,
    required this.customerId,
    required this.state,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
      id: json['Task_ID'],
      name: json['Task_name'],
      reward: json['Reward'].toDouble(),
      description: json['Description'],
      startPoint: json['Start_point'],
      endPoint: json['End_point'],
      customerId: json['Customer_ID'],
      state: json['Task_state'],
    );
  }

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
}