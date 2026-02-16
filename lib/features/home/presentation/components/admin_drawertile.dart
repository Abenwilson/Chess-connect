import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/admin/list_of_users/users.dart';
import 'package:photographers/admin/pages/add%20products/presentation/pages/add_products.dart';
import 'package:photographers/admin/pages/user%20orders/user_orders.dart';
import 'package:photographers/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:photographers/features/home/presentation/components/my_drawertile.dart';
import 'package:photographers/features/profile/domain/entities/profile_user.dart';
import 'package:photographers/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:photographers/features/profile/presentation/pages/profile_page.dart';
import 'package:photographers/features/search/presentation/pages/search_pages.dart';

class AdminDrawertile extends StatefulWidget {
  const AdminDrawertile({super.key});

  @override
  State<AdminDrawertile> createState() => _AdminDrawertileState();
}

class _AdminDrawertileState extends State<AdminDrawertile> {
  ProfileUser? currentUser;

  @override
  void initState() {
    super.initState();
    getcurrentUser();
  }

  void getcurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    final profileCubit = context.read<ProfileCubits>();

    String? uid = authCubit.currentUser?.uid;
    if (uid != null) {
      final fetchedUser = await profileCubit.getUserProfile(uid);
      if (fetchedUser != null) {
        setState(() {
          currentUser = fetchedUser;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: currentUser?.profileImagUrl != null
                ? CachedNetworkImage(
                    imageUrl: currentUser!.profileImagUrl,
                    errorWidget: (context, url, error) =>
                        Icon(Icons.person, size: 60),
                    imageBuilder: (context, imageProvider) => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : Icon(Icons.person, size: 60), // Default icon if no image
          ),
          SizedBox(
            height: 50,
          ),
          // home

          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: MyDrawertile(
                title: "H O M E",
                icon: Icons.home,
                ontap: () {
                  Navigator.of(context).pop();
                }),
          ),
          SizedBox(
            height: 10,
          ),
          // profile

          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: MyDrawertile(
                title: "P R O F I L E",
                icon: Icons.person_2_outlined,
                ontap: () {
                  Navigator.of(context).pop();

                  // get current user id
                  final user = context.read<AuthCubit>().currentUser;
                  String? uid = user!.uid;

                  //navigate profile page
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return Profile(
                      uid: uid,
                    );
                  }));
                }),
          ),
          SizedBox(
            height: 10,
          ),
          // search

          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: MyDrawertile(
                title: " S E A R C H ",
                icon: Icons.search,
                ontap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SearchPages()))),
          ),
          SizedBox(
            height: 10,
          ),

          // settings

          // Padding(
          //   padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          //   child: MyDrawertile(
          //       title: "S E T T I N G S", icon: Icons.settings, ontap: () {}),
          // ),
          // SizedBox(
          //   height: 10,
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: MyDrawertile(
                title: "A D D  P R O D U C T",
                icon: Icons.shopping_bag_outlined,
                ontap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return AddProducts();
                  }));
                }),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: MyDrawertile(
                title: "U S E R S",
                icon: Icons.person,
                ontap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UserListPage()));
                }),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: MyDrawertile(
                title: "O R D E R S",
                icon: Icons.person,
                ontap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminOrdersPage()));
                }),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: MyDrawertile(
                title: "L O G O U T",
                icon: Icons.logout,
                ontap: () {
                  context.read<AuthCubit>().logout();
                }),
          ),
          SizedBox(
            height: 50,
          ),
        ],
      )),
    );
  }
}
