class AppUser {
  final String uid;
  final String? name;
  final String email;
  final bool? emailVerified;
  String? phoneNumber;

  final String? profileImageUrl;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.emailVerified,
    this.profileImageUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json["uid"],
      name: json['name'],
      email: json["email"],
      emailVerified: json["emailVerified"],
      profileImageUrl: json["photoURL"],
    );
  }
}
