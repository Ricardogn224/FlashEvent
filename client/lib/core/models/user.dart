class User {
  final String firstname;
  final String lastname;
  final String username;
  final String email;
  final String password;

  User({
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.email,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstname: json['firstname'],
      lastname: json['lastname'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
    );
  }
}
