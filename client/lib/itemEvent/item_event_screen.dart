  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:flutter_flash_event/eventParty/bloc/event_party_bloc.dart';
  import 'package:flutter_flash_event/formItemEvent/form_item_event_screen.dart';
  import 'package:flutter_flash_event/formParticipant/form_participant_screen.dart';
  import 'package:flutter_flash_event/itemEvent/bloc/item_event_bloc.dart';
  import 'package:flutter_flash_event/participant/bloc/participant_bloc.dart';

  class ItemEventScreen extends StatelessWidget {
    static const String routeName = '/item-event';

    static navigateTo(BuildContext context, {required int id}) {
      Navigator.of(context).pushNamed(routeName, arguments: id);
    }

    final int id;

    const ItemEventScreen({super.key, required this.id});

    @override
    Widget build(BuildContext context) {
      return BlocProvider(
        create: (context) => ItemEventBloc()..add(ItemEventDataLoaded(id: id)),
        child: BlocBuilder<ItemEventBloc, ItemEventState>(
          builder: (context, state) {
            final itemEvents = state.itemEvents;

            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  title: Text('Choses à ramener'),
                ),
                backgroundColor: Colors.white,
                body: Column(
                  children: [
                    if (state.status == ItemEventStatus.loading)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (state.status == ItemEventStatus.success && itemEvents != null)
                      Expanded( // Add Expanded here
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            final itemEvent = state.itemEvents?[index];
                            return ListTile(
                              leading: Icon(Icons.person),
                              title: Text(itemEvent!.name),
                              subtitle: Text('${itemEvent.firstname + ' ' + itemEvent.lastname}'),
                            );
                          },
                          itemCount: state.itemEvents?.length,
                        ),
                      ),
                    FloatingActionButton(
                      onPressed: () async {
                        FormItemEventScreen.navigateTo(context, id: id);

                        // Handle the new participant data if needed
                      },
                      child: Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }
