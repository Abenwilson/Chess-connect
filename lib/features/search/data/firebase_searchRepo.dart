import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photographers/features/profile/domain/entities/profile_user.dart';
import 'package:photographers/features/search/domain/search_Repo.dart';

class FirebaseSearchrepo implements SearchRepo {
  @override
  Future<List<ProfileUser?>> Searchusers(String query) async {
    try {
      final result = await FirebaseFirestore.instance
          .collection("users")
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name',
              isLessThanOrEqualTo:
                  '$query\uf8ff') //'$query\uf8ff' used to increase the search value range
          .get();
      return result.docs
          .map((doc) => ProfileUser.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception("error searching users:$e");
    }
  }
}
