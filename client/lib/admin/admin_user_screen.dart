import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flash_event/admin/admin_user_edit_screen.dart';
import 'package:flutter_flash_event/admin/bloc/admin_bloc.dart';

class AdminUserScreen extends StatelessWidget {

  static const String routeName = '/admin-user ';

  static navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  const AdminUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminBloc()..add(AdminDataLoaded()),
      child: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          final users = state.users;



          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Manage Users'),
                centerTitle: true,
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (state.status == AdminStatus.loading)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    if (state.status == AdminStatus.success && users != null)
                      Expanded(
                        child: SingleChildScrollView(
                          child: users.isNotEmpty
                              ? DataTable(
                            columns: const [
                              DataColumn(label: Text('First Name')),
                              DataColumn(label: Text('Last Name')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: users.map((user) {
                              return DataRow(cells: [
                                DataCell(Text(user.firstname)),
                                DataCell(Text(user.lastname)),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        AdminUserEditScreen.navigateTo(context, id: user.id);
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
                              : const Center(child: Text('No users found')),
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
