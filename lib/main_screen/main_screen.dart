import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chat_app/main_screen/chat_list_screen.dart';
import 'package:chat_app/main_screen/group_screen.dart';
import 'package:chat_app/main_screen/people_screen.dart';
import 'package:chat_app/providers/auth_provider/auth_provider.dart';
import 'package:chat_app/utilities/asset_manager.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:chat_app/utilities/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;
  final PageController pageController = PageController(initialPage: 0);

  // get saved theme mode

  void getThemeMode() async {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();

    if (savedThemeMode == AdaptiveThemeMode.dark) {
      setState(() {
        isDarkMode = true;
      });
    } else {
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    final AuthentificationProvider authProvider =
        context.watch<AuthentificationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chat Pro'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: userImageWidget(
              userImage: authProvider.userModel!.image!,
              radius: 20,
              onTap: () {
                // Navigate to user profile uuid as argument

                Navigator.pushNamed(
                  context,
                  Constants.profileScreen,
                  arguments: authProvider.userModel!.uid,
                );
              },
            ),
          )
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group),
            label: "Groups",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.globe),
            label: "People",
          ),
        ],
        currentIndex: currentIndex,
        onTap: (value) {
          pageController.animateToPage(value,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeIn);
          setState(() {
            currentIndex = value;
          });
        },
      ),
    );
  }

  int currentIndex = 0;

  final List<Widget> pages = const [
    ChatListScreen(),
    GroupScreen(),
    PeopleScreen(),
  ];
}
