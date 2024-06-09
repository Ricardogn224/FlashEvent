import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/eventParty/bloc/event_party_bloc.dart';

class EventScreen extends StatelessWidget {
  static const String routeName = '/event';

  static navigateTo(BuildContext context, {required int id}) {
    Navigator.of(context).pushNamed(routeName, arguments: id);
  }

  final int id;

  const EventScreen({super.key, required this.id});

  Widget _buildRating(BuildContext context, {required double rating}) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          Icons.star,
          color: index < rating ? Colors.blue : Colors.grey,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventPartyBloc()..add(EventPartyDataLoaded(id: id)),
      child: BlocBuilder<EventPartyBloc, EventPartyState>(
        builder: (context, state) {
          final eventParty = state.eventParty;
          print(eventParty);
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: Text(state.eventParty?.name ?? ''),
              ),
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  if (state.status == EventPartyStatus.loading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (state.status == EventPartyStatus.success && eventParty != null)
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${eventParty.description} €',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(eventParty.description),
                                const SizedBox(height: 10),
                                Text(eventParty.description),
                                const SizedBox(height: 10),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
