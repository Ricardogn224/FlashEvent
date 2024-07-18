part of 'form_cagnotte_bloc.dart';

abstract class FormCagnotteEvent extends Equatable {
  const FormCagnotteEvent();

  @override
  List<Object> get props => [];
}

class FormSubmitEvent extends FormCagnotteEvent {
  final VoidCallback onSuccess;
  final Function(String) onError;

  const FormSubmitEvent({required this.onSuccess, required this.onError});

  @override
  List<Object> get props => [onSuccess, onError];
}

class FormResetEvent extends FormCagnotteEvent {
  const FormResetEvent();
}

class InitEvent extends FormCagnotteEvent {
  const InitEvent();
}

class ContributionChanged extends FormCagnotteEvent {
  const ContributionChanged({required this.contribution});
  final BlocFormItem contribution;
  @override
  List<Object> get props => [contribution];
}
