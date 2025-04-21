import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/profile/presentation/component/user_tile.dart';
import 'package:photographers/features/search/presentation/cubits/search_states.dart';
import 'package:photographers/features/search/presentation/cubits/serach_cubits.dart';
import 'package:photographers/reponsive/constrained_scaffold.dart';

class SearchPages extends StatefulWidget {
  const SearchPages({super.key});

  @override
  State<SearchPages> createState() => _SearchPagesState();
}

class _SearchPagesState extends State<SearchPages> {
  final TextEditingController searchController = TextEditingController();
  late final searchCubits = context.read<SerachCubits>();
  void onSearchChanged() {
    final query = searchController.text;
    searchCubits.SearchUsers(query);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  //Build Ui
  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: SizedBox(
          width: 500,
          height: 40,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.inversePrimary),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.inversePrimary),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'search user',
                hintStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ),
      ),

      // Search Result
      body: BlocBuilder<SerachCubits, SearchStates>(builder: (context, state) {
        //loaded
        if (state is SearchLoaded) {
          // no user
          if (state.users.isEmpty) {
            return const Center(child: Text("no user Found"));
          }

          //users
          return ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              return UserTile(user: user!);
            },
          );
        }
        //loading
        else if (state is Searchloading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        //error
        else if (state is SearchError) {
          return Center(
            child: Text(state.message),
          );
        }
        return const Center(child: Text("Start Searching for users..."));
      }),
    );
  }
}
