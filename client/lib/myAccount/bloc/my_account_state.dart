part of 'my_account_bloc.dart';


enum MyAccountStatus { initial, loading, success, error }

class MyAccountState {
  final MyAccountStatus status;
  final User? user;
  final String? errorMessage;

  MyAccountState({
    this.status = MyAccountStatus.initial,
    this.user,
    this.errorMessage,
  });

  MyAccountState copyWith({
    MyAccountStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return MyAccountState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}