part of 'cagnotte_bloc.dart';


enum CagnotteStatus { initial, loading, success, error }

class CagnotteState {
  final CagnotteStatus status;
  final double? cagnotte;
  final List<User>? participants;
  final String? errorMessage;

  CagnotteState({
    this.status = CagnotteStatus.initial,
    this.participants,
    this.cagnotte,
    this.errorMessage,
  });

  CagnotteState copyWith({
    CagnotteStatus? status,
    double? cagnotte,
    List<User>? participants,
    String? errorMessage,
  }) {
    return CagnotteState(
      status: status ?? this.status,
      cagnotte: cagnotte ?? this.cagnotte,
      participants: participants ?? this.participants,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
