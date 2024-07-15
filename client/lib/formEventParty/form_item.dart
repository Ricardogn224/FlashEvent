import 'dart:ffi';

class BlocFormItem {
  final String? error;
  final String value;
  const BlocFormItem({this.error, this.value = ''});

  BlocFormItem copyWith({
    String? error,
    String? value,
  }) {
    return BlocFormItem(
      error: error ?? this.error,
      value: value ?? this.value,
    );
  }
}

class BlocFormItemBool {
  final String? error;
  final bool value;
  const BlocFormItemBool({this.error, this.value = false});

  BlocFormItemBool copyWith({
    String? error,
    bool? value,
  }) {
    return BlocFormItemBool(
      error: error ?? this.error,
      value: value ?? this.value,
    );
  }
}
