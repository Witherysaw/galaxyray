

class UserModel {
  String? userEmail;
  String? userId;
  // String? phoneNumber;

  UserModel({this.userEmail, this.userId});

  UserModel.fromJson(Map<String, dynamic> json) {
    userEmail = json["userEmail"];
    userId = json["userId"];
    // phoneNumber = json["phoneNumber"];
  }

  Map<String, String> toJson() {
    return {
      'userEmail': userEmail!,
      'userId': userId!,
      // 'phoneNumber': '016',
    };
  }
}