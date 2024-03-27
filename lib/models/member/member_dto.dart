class MemberDto {
  String username = '';
  String password = '';
  String accessToken = '';
  String refreshToken = '';

  MemberDto({required this.username, required this.password, required this.accessToken, required this.refreshToken});

  factory MemberDto.fromJson(Map<String, dynamic> json) {
    return MemberDto(
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
  MemberDto author;

  Jwt(this.author);

  factory Jwt.fromJson(dynamic json) {
    return Jwt(MemberDto.fromJson(json['jwtDto']));
  }

  @override
  String toString() {
    return '{ ${this.author} }';
  }
}
