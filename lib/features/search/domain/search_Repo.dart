import 'package:photographers/features/profile/domain/entities/profile_user.dart';

abstract class SearchRepo {
  Future<List<ProfileUser?>> Searchusers(String query);
}
