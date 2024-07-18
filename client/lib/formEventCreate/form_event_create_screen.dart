import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/formEventCreate/bloc/form_event_create_bloc.dart';
import 'package:flutter_flash_event/formEventCreate/bloc/form_event_create_event.dart';
import 'package:flutter_flash_event/formEventCreate/bloc/form_event_create_state.dart';
import 'package:intl/intl.dart';

class FormEventCreateScreen extends StatelessWidget {
  static const String routeName = '/event_create';

  static navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const FormEventCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Créer un événement'),
      ),
      body: BlocProvider(
        create: (context) => FormEventCreateBloc(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocListener<FormEventCreateBloc, FormEventCreateState>(
            listener: (context, state) {
              if (state.status == FormStatus.loading) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
              } else if (state.status == FormStatus.success) {
                Navigator.pop(context); // Dismiss the loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Événement créé avec succès')),
                ).closed.then((_) {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                });
              } else if (state.status == FormStatus.error) {
                Navigator.pop(context); // Dismiss the loading dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: ${state.errorMessage}')),
                );
              }
            },
            child: BlocBuilder<FormEventCreateBloc, FormEventCreateState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Nom de l\'événement',
                          onChanged: (value) {
                            context.read<FormEventCreateBloc>().add(
                              EventNameChanged(name: value),
                            );
                          },
                          validator: _validateName,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: 'Description',
                          onChanged: (value) {
                            context.read<FormEventCreateBloc>().add(
                              EventDescriptionChanged(description: value),
                            );
                          },
                          validator: _validateDescription,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          label: 'Lieu',
                          onChanged: (value) {
                            context.read<FormEventCreateBloc>().add(
                              EventPlaceChanged(place: value),
                            );
                          },
                          validator: _validatePlace,
                        ),
                        const SizedBox(height: 20),
                        _DateTimePicker(
                          labelText: 'Date de début',
                          selectedDate: state.dateStart,
                          selectedTime: state.timeStart,
                          onSelectedDate: (date) {
                            context.read<FormEventCreateBloc>().add(
                              EventDateStartChanged(dateStart: date),
                            );
                          },
                          onSelectedTime: (time) {
                            context.read<FormEventCreateBloc>().add(
                              EventTimeStartChanged(timeStart: time),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _DateTimePicker(
                          labelText: 'Date de fin',
                          selectedDate: state.dateEnd,
                          selectedTime: state.timeEnd,
                          onSelectedDate: (date) {
                            context.read<FormEventCreateBloc>().add(
                              EventDateEndChanged(dateEnd: date),
                            );
                          },
                          onSelectedTime: (time) {
                            context.read<FormEventCreateBloc>().add(
                              EventTimeEndChanged(timeEnd: time),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        SwitchListTile(
                          title: const Text('Transport Actif'),
                          value: state.transportActive,
                          onChanged: (value) {
                            context.read<FormEventCreateBloc>().add(
                              EventTransportActiveChanged(transportActive: value),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Builder( // Use Builder to get the correct context
                          builder: (context) => SizedBox(
                            width: double.infinity, // Make button same width as inputs
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6058E9), // Custom button color
                                foregroundColor: Colors.white, // Button text color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  final validationMessage = _validateDates(
                                      state.dateStart,
                                      state.timeStart,
                                      state.dateEnd,
                                      state.timeEnd
                                  );

                                  if (validationMessage != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(validationMessage)),
                                    );
                                    return; // Stop the submission process if dates are invalid
                                  }

                                  final dateTimeStart = combineDateAndTime(state.dateStart, state.timeStart);
                                  final dateTimeEnd = combineDateAndTime(state.dateEnd, state.timeEnd);
                                  context.read<FormEventCreateBloc>().add(EventFormSubmitted(
                                    dateTimeStart: dateTimeStart.toString(),
                                    dateTimeEnd: dateTimeEnd.toString(),
                                  ));
                                }
                              },
                              child: const Text('Créer l\'événement'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required ValueChanged<String> onChanged,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Entrez $label',
        labelText: label,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }

  DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le nom de l\'événement est requis';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'La description est requise';
    }
    return null;
  }

  String? _validatePlace(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le lieu est requis';
    }
    return null;
  }

  String? _validateDates(DateTime dateStart, TimeOfDay timeStart, DateTime dateEnd, TimeOfDay timeEnd) {
    final dateTimeStart = combineDateAndTime(dateStart, timeStart);
    final dateTimeEnd = combineDateAndTime(dateEnd, timeEnd);
    if (dateTimeEnd.isBefore(dateTimeStart)) {
      return 'La date et l\'heure de fin doivent être supérieures à la date et l\'heure de début';
    }
    return null;
  }
}

class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker({
    Key? key,
    required this.labelText,
    required this.selectedDate,
    required this.selectedTime,
    required this.onSelectedDate,
    required this.onSelectedTime,
  }) : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> onSelectedDate;
  final ValueChanged<TimeOfDay> onSelectedTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000, 1),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      onSelectedDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      onSelectedTime(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.titleLarge!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(labelText, style: valueStyle),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: 'Sélectionnez une date',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
            ),
            baseStyle: valueStyle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(DateFormat.yMMMd().format(selectedDate), style: valueStyle),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(context),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: 'Sélectionnez une heure',
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
            ),
            baseStyle: valueStyle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(selectedTime.format(context), style: valueStyle),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
