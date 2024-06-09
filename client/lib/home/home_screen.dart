import 'package:flutter/material.dart';
import 'package:flutter_flash_event/eventParty/event_details_screen.dart';
import 'package:flutter_flash_event/home/blocs/home_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(HomeDataLoaded()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is HomeDataLoadError) {
              return Center(
                child: Text(state.errorMessage),
              );
            }

            if (state is HomeDataLoadSuccess) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  final event = state.events[index];
                  return ListTile(
                    title: Text(event.name),
                    subtitle: Text(
                      event.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => EventScreen.navigateTo(context, id: event.id),
                  );
                },
                itemCount: state.events.length,
              );
            }

            return const SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to the add event screen
            Navigator.pushNamed(context, '/event_new');
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
