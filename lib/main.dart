import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/commute_setup_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/degrees_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/library_screen.dart';
import 'screens/create_podcast_screen.dart';
import 'screens/podcast_player_screen.dart';
import 'providers/commute_provider.dart';
import 'providers/learning_provider.dart';
import 'providers/profile_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CommuteProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commute Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFE5B13),
        scaffoldBackgroundColor: const Color(0xFF131111),
        //textTheme: GoogleFonts.lexendTextTheme(ThemeData.dark().textTheme),
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFE5B13),
          secondary: Color(0xFFFE5B13),
          surface: Color(0xFF232120),
          background: Color(0xFF131111),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/commute-setup': (context) => const CommuteSetupScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/degrees': (context) => const DegreesScreen(),
        '/explore': (context) => const ExploreScreen(),
        '/library': (context) => const LibraryScreen(),
        '/create': (context) => const CreatePodcastScreen(),
        '/podcast-player': (context) => const PodcastPlayerScreen(),
      },
    );
  }
}

