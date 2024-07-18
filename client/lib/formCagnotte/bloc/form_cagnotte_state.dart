part of 'form_cagnotte_bloc.dart';

class FormCagnotteState extends Equatable {
  const FormCagnotteState({
    this.contribution = const BlocFormItem(error: 'Entrer contribution'),
    this.formKey,
  });

  final BlocFormItem contribution;
  final GlobalKey<FormState>? formKey;

  FormCagnotteState copyWith({
    BlocFormItem? contribution,
    GlobalKey<FormState>? formKey,
  }) {
    return FormCagnotteState(
      contribution: contribution ?? this.contribution,
      formKey: formKey,
    );
  }

  @override
  List<Object> get props => [contribution];
}

enum FormStatus { none, inProgress, valid, invalid }