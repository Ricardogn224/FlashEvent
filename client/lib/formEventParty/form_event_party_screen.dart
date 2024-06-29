import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/formEventParty/bloc/form_event_party_bloc.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flash_event/home/home_screen.dart';

class BlocFormEventScreen extends StatelessWidget {
  const BlocFormEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormEventPartyBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Création évènement'),
        ),
        body: BlocBuilder<FormEventPartyBloc, FormEventPartyState>(
          builder: (context, state) {
            TextEditingController dateController = TextEditingController(text: state.date.value);

            Future<void> _selectDate(BuildContext context) async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null && picked != DateTime.now()) {
                String formattedDate = "${picked.day}/${picked.month}/${picked.year}";
                BlocProvider.of<FormEventPartyBloc>(context).add(DateChanged(date: BlocFormItem(value: formattedDate)));
                dateController.text = formattedDate;
              }
            }

            return Container(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: state.formKey,
                child: Column(
                  children: [
                    CustomFormField(
                      hintText: 'Name',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r"[a-zA-Z]+|\s"),
                        )
                      ],
                      onChange: (val) {
                        BlocProvider.of<FormEventPartyBloc>(context)
                            .add(NameChanged(name: BlocFormItem(value: val!)));
                      },
                      validator: (val) {
                        return state.name.error;
                      },
                    ),
                    CustomFormField(
                      hintText: 'Description',
                      onChange: (val) {
                        BlocProvider.of<FormEventPartyBloc>(context)
                            .add(DescriptionChanged(description: BlocFormItem(value: val!)));
                      },
                      validator: (val) {
                        return state.description.error;
                      },
                    ),
                    CustomFormField(
                      hintText: 'Place',
                      onChange: (val) {
                        BlocProvider.of<FormEventPartyBloc>(context)
                            .add(PlaceChanged(place: BlocFormItem(value: val!)));
                      },
                      validator: (val) {
                        return state.place.error;
                      },
                    ),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: dateController,
                          decoration: const InputDecoration(hintText: 'Date'),
                          validator: (val) {
                            return state.date.error;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<FormEventPartyBloc>(context).add(FormSubmitEvent(
                              onSuccess: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomeScreen()),
                                );
                              },
                              onError: (errorMessage) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMessage)),
                                );
                              },
                            ));
                          },
                          child: const Text('SUBMIT'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<FormEventPartyBloc>(context).add(const FormResetEvent());
                          },
                          child: const Text('RESET'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}