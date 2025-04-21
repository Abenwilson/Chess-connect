import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/search/domain/search_Repo.dart';
import 'package:photographers/features/search/presentation/cubits/search_states.dart';

class SerachCubits extends Cubit<SearchStates> {
  final SearchRepo searchRepo;
  SerachCubits({required this.searchRepo}) : super(SearchInitial());

  Future<void> SearchUsers(String query) async {
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }
    try {
      emit(Searchloading());
      final users = await searchRepo.Searchusers(query);
      emit(SearchLoaded(users));
    } catch (e) {
      emit(SearchError("errror on searching users"));
    }
  }
}
