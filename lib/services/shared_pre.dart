import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferneceHelper {
  static String userIdKey = "USERIDKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userPicKey = "USERPICKEY";
  static String displaynameKey = "USERDISPLAYNAMEKEY";

  Future<bool> saveUserid(String getUserid) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userIdKey, getUserid);
  }

  Future<bool> saveUserName(String getUserName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userNameKey, getUserName);
  }

  Future<bool> saveUserEmail(String getUserEmail) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userEmailKey, getUserEmail);
  }

  Future<bool> saveUserDisplayName(String getUserdisplayName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(displaynameKey, getUserdisplayName);
  }

  Future<bool> saveUserPic(String getUserPic) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(userPicKey, getUserPic);
  }

  Future<String?> getUserid() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userIdKey);
  }

  Future<String?> getUserName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userNameKey);
  }

  Future<String?> getUserEmail() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userEmailKey);
  }

  Future<String?> getUserPic() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(userPicKey);
  }

  Future<String?> getUserDisplayName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(displaynameKey);
  }
}
