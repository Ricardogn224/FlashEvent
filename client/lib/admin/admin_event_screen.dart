import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/admin/admin_event_edit_screen.dart';
import 'package:flutter_flash_event/admin/admin_event_new_screen.dart';
import 'package:flutter_flash_event/admin/bloc/admin_bloc.dart';

class AdminEventScreen extends StatelessWidget {
  static const String routeName = '/admin-events';

  static navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const AdminEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminBloc()..add(AdminEventsLoaded()),
      child: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          final events = state.events;

          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Manage Events'),
                centerTitle: true,
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // "Create a New Event" button
                    ElevatedButton(
                      onPressed: () {
                        AdminEventNewScreen.navigateTo(context);
                      },
                      child: const Text('Create a New Event'),
                    ),
                    const SizedBox(height: 16.0), // Space between button and table
                    if (state.status == AdminStatus.loading)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (state.status == AdminStatus.success && events != null)
                      Expanded(
                        child: SingleChildScrollView(
                          child: events.isNotEmpty
                              ? DataTable(
                            columns: const [
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Description')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: events.map((event) {
                              return DataRow(cells: [
                                DataCell(Text(event.name)),
                                DataCell(Text(event.description)),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        AdminEventEditScreen.navigateTo(context, id: event.id);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        // Handle delete action
                                      },
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          )
                              : const Center(child: Text('No events found')),
                        ),
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