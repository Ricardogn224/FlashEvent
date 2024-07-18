import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/cagnotte/bloc/cagnotte_bloc.dart';
import 'package:flutter_flash_event/core/models/event.dart';
import 'package:flutter_flash_event/formCagnotte/form_cagnotte_screen.dart';

class CagnotteScreen extends StatelessWidget {
  static const String routeName = '/cagnotte';

  static navigateTo(BuildContext context, {required int eventId}) {
    Navigator.of(context).pushNamed(routeName, arguments: eventId);
  }

  final int eventId;

  const CagnotteScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CagnotteBloc()..add(CagnotteDataLoaded(id: eventId)),
      child: BlocBuilder<CagnotteBloc, CagnotteState>(
        builder: (context, cagnotteState) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text('Cagnotte'),
              ),
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (cagnotteState.status == CagnotteStatus.loading)
                      CircularProgressIndicator(),
                    if (cagnotteState.status == CagnotteStatus.success && cagnotteState.cagnotte != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Total Cagnotte: ${cagnotteState.cagnotte} €',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    if (cagnotteState.status == CagnotteStatus.error)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Failed to load cagnotte',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        FormCagnotteScreen.navigateTo(context, eventId: eventId);
                      },
                      child: Text('Contribuer à la cagnotte'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
