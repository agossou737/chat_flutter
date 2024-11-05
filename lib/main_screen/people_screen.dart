import 'package:chat_app/providers/auth_provider/auth_provider.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:chat_app/utilities/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthentificationProvider>().userModel!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // search bar
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                placeholder: 'Rechercher',
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: context
                    .read<AuthentificationProvider>()
                    .getAllUserStreams(currentUser.uid!),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Une erreur s\'est produite'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "Aucun utilisateur trouvé",
                        style: GoogleFonts.openSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return ListTile(
                        leading: userImageWidget(
                          userImage: data[Constants.image],
                          radius: 30,
                          onTap: () {},
                        ),
                        title: Text(data[Constants.name]),
                        subtitle: Text(
                          data[Constants.aboutMe],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          // Navigate to the profile screen
                          Navigator.pushNamed(
                            context,
                            Constants.profileScreen,
                            arguments: document.id,
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
