abstract class BaseResponse {
  final int id;

  BaseResponse({required this.id});

  Map<String, dynamic> toJson();
}