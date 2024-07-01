import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flash_event/Transportation/transportation_screen.dart';
import 'package:flutter_flash_event/formEventParty/form_item.dart';
import 'package:flutter_flash_event/formTransportation/bloc/form_transportation_bloc.dart';
import 'package:flutter_flash_event/itemEvent/item_event_screen.dart';
import 'package:flutter_flash_event/widgets/custom_form_field.dart';


class FormTransportationScreen extends StatelessWidget {

  static const String routeName = '/new-transportation';

  static navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int eventId;

  const FormTransportationScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormTransportationBloc(eventId: eventId)..add(InitEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Form Validation'),
        ),
        body: BlocBuilder<FormTransportationBloc, FormTransportationState>(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: state.formKey,
                child: Column(
                  children: [
                    CustomFormField(
                      hintText: 'Name',
                      onChange: (val) {
                        BlocProvider.of<FormTransportationBloc>(context)
                            .add(NameChanged(name: BlocFormItem(value: val!)));
                      },
                      validator: (val) {
                        return state.name.error;
                      },
                    ),
                    CustomFormField(
                      hintText: 'Nombre de places',
                      onChange: (val) {
                        BlocProvider.of<FormTransportationBloc>(context)
                            .add(SeatNumberChanged(seatNumber: BlocFormItem(value: val!)));
                      },
                      validator: (val) {
                        return state.seatNumber.error;
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<FormTransportationBloc>(context).add(FormSubmitEvent(
                              onSuccess: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => TransportationScreen(id: eventId)),
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
                            BlocProvider.of<FormTransportationBloc>(context).add(const FormResetEvent());
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
