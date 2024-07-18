extension StringExtension on String {
  bool get isValidEmail {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(this);
  }

  bool get isValidName {
    final nameRegExp = RegExp(r"^[a-zA-Z\s]+$");
    return nameRegExp.hasMatch(this);
  }

  bool get isValidPhone {
    final phoneRegExp = RegExp(r"^(?:[+0]9)?[0-9]{10}$");
    return phoneRegExp.hasMatch(this);
  }

  bool get isValidInteger {
    final integerRegExp = RegExp(r"^-?[0-9]+$");
    return integerRegExp.hasMatch(this);
  }

  bool get isValidDouble {
    final doubleRegExp = RegExp(r"^-?\d+(\.\d+)?$");
    return doubleRegExp.hasMatch(this);
  }
}