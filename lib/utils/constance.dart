import 'local_store.dart';

const String baseUrl = "https://girlsparadisebd.com/api/v1/";
const String ImagebaseUrl = "https://girlsparadisebd.com/public/";
// const String ImagebaseUrlAboutUs = "https://girlsparadisebd.com/";

var accessToken = "";

initiateAccessToken() async {
  accessToken = await getAccessToken();
}