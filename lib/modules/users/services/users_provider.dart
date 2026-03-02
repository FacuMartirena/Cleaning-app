import 'package:get/get.dart';

import 'package:bo_cleaning/core/constants/globals.dart';

class UsersProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = Globals.apiBaseUrl;
    httpClient.timeout = const Duration(seconds: 15);
    super.onInit();
  }

  Future<Response> getUsers({int? limit, int? offset}) => get(
        Globals.usersPath,
        query: {
          if (limit != null) 'limit': limit.toString(),
          if (offset != null) 'offset': offset.toString(),
        },
      );

  Future<Response> getUser(String id) => get('${Globals.usersPath}/$id');

  Future<Response> createUser(Map<String, dynamic> body) =>
      post(Globals.usersPath, body);

  Future<Response> updateUser(String id, Map<String, dynamic> body) =>
      put('${Globals.usersPath}/$id', body);

  Future<Response> deleteUser(String id) =>
      delete('${Globals.usersPath}/$id');

  Future<Response> deactivateUser(String id) =>
      put('${Globals.usersPath}/$id/deactivate', <String, dynamic>{});

  Future<Response> activateUser(String id) =>
      put('${Globals.usersPath}/$id/activate', <String, dynamic>{});
}
