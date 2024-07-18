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
                title: const Text('Cagnotte'),
              ),
              backgroundColor: Colors.white,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (cagnotteState.status == CagnotteStatus.loading)
                      const CircularProgressIndicator(),
                    if (cagnotteState.status == CagnotteStatus.success) ...[
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Contributeurs:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (cagnotteState.participants != null && cagnotteState.participants!.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: cagnotteState.participants!.length,
                            itemBuilder: (context, index) {
                              final participant = cagnotteState.participants![index];
                              return ListTile(
                                title: Text('${participant.firstname} ${participant.lastname}'),
                              );
                            },
                          ),
                        ),
                      if (cagnotteState.participants == null || cagnotteState.participants!.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Aucun contributeurs.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Total Cagnotte: ${cagnotteState.cagnotte} €',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          FormCagnotteScreen.navigateTo(context, eventId: eventId);
                        },
                        child: const Text('Contribuer à la cagnotte'),
                      ),
                    ],
                    if (cagnotteState.status == CagnotteStatus.error)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          cagnotteState.errorMessage ?? 'Failed to load cagnotte',
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    const SizedBox(height: 20),
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
