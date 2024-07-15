import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/admin/admin_event_edit_screen.dart';
import 'package:flutter_flash_event/admin/admin_event_new_screen.dart';
import 'package:flutter_flash_event/admin/bloc/admin_bloc.dart';
import 'package:flutter_flash_event/admin/blocFeature/admin_feature_bloc.dart';

class AdminFeatureScreen extends StatelessWidget {
  static const String routeName = '/admin-features';

  static navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const AdminFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminFeatureBloc()..add(AdminFeatureLoaded()),
      child: BlocBuilder<AdminFeatureBloc, AdminFeatureState>(
        builder: (context, state) {
          final features = state.features;

          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Manage Features'),
                centerTitle: true,
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16.0), // Space between button and table
                    if (state.status == AdminFeatureStatus.loading)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (state.status == AdminFeatureStatus.success && features != null)
                      Expanded(
                          child: ListView.builder(
                            itemCount: features.length,
                            itemBuilder: (context, index) {
                              final feature = features[index];
                              return SwitchListTile(
                                title: Text(feature.name),
                                value: feature.active,
                                onChanged: (bool value) {
                                  context.read<AdminFeatureBloc>().add(
                                    UpdateFeatureStatus(
                                      feature: feature,
                                      newVal: value,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                      ),
                    if (state.status == AdminFeatureStatus.error)
                      Center(
                        child: Text(state.errorMessage ?? 'An error occurred'),
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