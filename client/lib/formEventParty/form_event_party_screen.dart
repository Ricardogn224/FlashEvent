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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un événement'),
      ),
      body: BlocProvider(
        create: (context) => FormEventCreateBloc(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocListener<FormEventCreateBloc, FormEventCreateState>(
            listener: (context, state) {
              if (state.status == FormStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Événement créé avec succès')),
                );
                Navigator.pop(context);
              } else if (state.status == FormStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: ${state.errorMessage}')),
                );
              }
            },
            child: BlocBuilder<FormEventCreateBloc, FormEventCreateState>(
              builder: (context, state) {
                return Form(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Nom de l\'événement'),
                        onChanged: (value) {
                          context.read<FormEventCreateBloc>().add(
                                EventNameChanged(name: value),
                              );
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Description'),
                        onChanged: (value) {
                          context.read<FormEventCreateBloc>().add(
                                EventDescriptionChanged(description: value),
                              );
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Lieu'),
                        onChanged: (value) {
                          context.read<FormEventCreateBloc>().add(
                                EventPlaceChanged(place: value),
                              );
                        },
                      ),
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
                      ElevatedButton(
                        onPressed: () {
                          final dateTimeStart = combineDateAndTime(state.dateStart, state.timeStart);
                          final dateTimeEnd = combineDateAndTime(state.dateEnd, state.timeEnd);
                          context.read<FormEventCreateBloc>().add(EventFormSubmitted(
                            dateTimeStart: dateTimeStart,
                            dateTimeEnd: dateTimeEnd,
                          ));
                        },
                        child: const Text('Créer l\'événement'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String combineDateAndTime(DateTime date, TimeOfDay time) {
    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
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
        Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
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
            ),
            const SizedBox(width: 12.0),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Heure',
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
            ),
          ],
        ),
      ],
    );
  }
}
