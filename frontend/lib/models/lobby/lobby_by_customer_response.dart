import 'lobby_response.dart';

class LobbyByCustomerResponse {
  final List<LobbyResponse> lobbies;

  LobbyByCustomerResponse({required this.lobbies});

  factory LobbyByCustomerResponse.fromJson(List<dynamic> json) {
    return LobbyByCustomerResponse(
      lobbies: json.map((item) => LobbyResponse.fromJson(item)).toList(),
    );
  }
}