import 'package:flutter/material.dart';
import 'package:kampus_konnect/domains/chat/chat_provider.dart';
import 'package:kampus_konnect/domains/homepage/unsold_post_card.dart';
import 'package:kampus_konnect/domains/user_details/app_user_provider.dart';
import 'package:kampus_konnect/domains/homepage/post_card_provider.dart';
import 'package:kampus_konnect/domains/homepage/product_details/product_details_provider.dart';
import 'domains/auth/screens/signup.dart';
import 'domains/auth/screens/login.dart';
import 'app/appcolors.dart';
import 'nav/mainpage.dart';
import 'domains/addpost/add_post_page.dart';
import 'domains/chat/chat_detail_screen.dart';
import 'domains/homepage/homepage.dart';
import 'domains/myposts/screens/my_posts_page.dart';
import 'domains/user_details/profile_page.dart';
import 'package:provider/provider.dart';
import 'domains/myposts/services&providers/my_posts_provider.dart';
import 'domains/auth/services/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static const String baseUrl = 'http://127.0.0.1:3000';
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _isTokenValid;

  @override
  void initState() {
    super.initState();
    _isTokenValid = _checkToken();
  }

  Future<bool> _checkToken() async {
    AuthService authService = AuthService();
    String? token = await authService.getToken();
    String? email = await authService.getEmail();

    if (token != null && email != null) {
      return await authService.validateToken(email, token);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MyPostsProvider()),
        ChangeNotifierProvider(create: (_) => ProductDetailsProvider()),
        ChangeNotifierProvider(create: (_) => PostCardProvider()),
        ChangeNotifierProvider(create: (_) => AppUserProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider(1))
      ],
      child: FutureBuilder<bool>(
        future: _isTokenValid,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print(snapshot);
            return MaterialApp(
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data == false) {
            print(snapshot.data);

            return MaterialApp(
              title: 'Mail Client',
              theme: appthemes.lighttheme,
              darkTheme: appthemes.darktheme,
              themeMode: ThemeMode.dark,
              home: LoginPage(),
              routes: {
                '/login': (context) => LoginPage(),
                '/main': (context) => MainPage(),
                '/home': (context) => HomePage(),
                // '/chat': (context) => Chat(),
                '/addPost': (context) => AddPost(),
                '/myPosts': (context) => MyPosts(),
                '/profile': (context) => ProfilePage(),
              },
            );
          } else {
            return MaterialApp(
              title: 'Mail Client',
              theme: appthemes.lighttheme,
              darkTheme: appthemes.darktheme,
              themeMode: ThemeMode.dark,
              home: MainPage(),
              routes: {
                '/login': (context) => LoginPage(),
                '/home': (context) => HomePage(),
                // '/chat': (context) => Chat(),
                '/addPost': (context) => AddPost(),
                '/myPosts': (context) => MyPosts(),
                '/profile': (context) => ProfilePage(),
                '/main': (context) => MainPage(),
              },
            );
          }
        },
      ),
    );
  }
}
