import 'package:flutter/material.dart';
import 'package:flutter_5iw2/home/blocs/home_bloc.dart';
import 'package:flutter_5iw2/product/product_screen.dart';
import 'package:flutter_5iw2/shared/widgets/cart_floating_button.dart';
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
                  final product = state.products[index];
                  return ListTile(
                    leading: Image.network(product.thumbnail),
                    title: Text(product.title),
                    subtitle: Text(
                      product.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => ProductScreen.navigateTo(context, id: product.id),
                  );
                },
                itemCount: state.products.length,
              );
            }

            return const SizedBox();
          },
        ),
        floatingActionButton: const CartFloatingButton(),
      ),
    );
  }
}
