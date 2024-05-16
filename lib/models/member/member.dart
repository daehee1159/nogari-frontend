class Member {
  String username = '';
  String password = '';
  String accessToken = '';
  String refreshToken = '';

  Member({required this.username, required this.password, required this.accessToken, required this.refreshToken});

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
        username : json['username'],
        password: json['password'],
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken']
    );
  }

  @override
  String toString() {
    return '{ ${this.username}, ${this.password}, ${this.accessToken}, ${this.refreshToken}, }';
  }
}

class Jwt {
  Member author;

  Jwt(this.author);

  factory Jwt.fromJson(dynamic json) {
    return Jwt(Member.fromJson(json['jwtDto']));
  }

  @override
  String toString() {
    return '{ ${this.author} }';
  }
}
