import 'package:http/http.dart' as http;
import '../globals.dart' as globals;

Future<bool> addToFavorites(String id) async {
  print("Start post favorite with $id and ${globals.user["access_token"]}");
  var headers = {'Authorization': 'Bearer ${globals.user["access_token"]}'};
  var request = http.MultipartRequest(
      'POST', Uri.parse('https://api.imgur.com/3/image/$id/favorite'));

  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    print(await response.stream.bytesToString());
    return true;
  } else {
    print(response.reasonPhrase);
    return false;
  }
}
