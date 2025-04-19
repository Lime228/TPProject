class TaskRequest {
  final String name;
  final double reward;
  final String description;
  final String startPoint;
  final String endPoint;
  final int customerId;
  final String state;

  TaskRequest({
    required this.name,
    required this.reward,
    required this.description,
    required this.startPoint,
    required this.endPoint,
    required this.customerId,
    required this.state,
  });

  Map<String, dynamic> toJson() => {
    'Task_name': name,
    'Reward': reward,
    'Description': description,
    'Start_point': startPoint,
    'End_point': endPoint,
    'Customer_ID': customerId,
    'Task_state': state,
  };
}