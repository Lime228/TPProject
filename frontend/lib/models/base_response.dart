abstract class BaseResponse {
  int id;

  BaseResponse({required this.id});

  Map<String, dynamic> toJson();
}