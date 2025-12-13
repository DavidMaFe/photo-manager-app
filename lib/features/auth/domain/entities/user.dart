

class User {
  final String id;
  final String email;
  final String name;
  final String? surname;

  User({required this.id, required this.email, required this.name, this.surname});

  factory User.empty() {
    return User(id: '', email: '', name: '');
  }

  bool get isValid => id.isNotEmpty && email.isNotEmpty && name.isNotEmpty;

  User copyWith({String? id, String? email, String? name, String? surname}) {
    return User(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        surname: surname ?? this.surname
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

