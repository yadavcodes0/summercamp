import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:summer_camp/config/supabase_config.dart';
import 'package:summer_camp/firebase_options.dart';
import 'package:summer_camp/providers/admin_dashboard_provider.dart';
import 'package:summer_camp/providers/volunteer_provider.dart';
import 'package:summer_camp/providers/child_provider.dart';
import 'package:summer_camp/screens/admin/admin_layout.dart';
import 'package:summer_camp/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use clean URL paths (/admin) instead of hash (#/admin)
  usePathUrlStrategy();

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint('Supabase Init Error: $e');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Init Error: $e');
  }

  // Check URL path at startup to determine which app to show
  final uri = Uri.base;
  final isAdmin = uri.path.contains('admin') ||
      uri.fragment.contains('admin');

  runApp(SummerCampApp(isAdmin: isAdmin));
}

// ═══════════════════════════════════════════════════════════════
// UNIFIED APP — Routes to Admin or Mobile based on URL path
// ═══════════════════════════════════════════════════════════════
class SummerCampApp extends StatelessWidget {
  final bool isAdmin;
  const SummerCampApp({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    if (isAdmin) {
      return _buildAdminApp();
    }
    return _buildMobileApp();
  }

  // ── Admin Panel App ──
  Widget _buildAdminApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChildProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
      ],
      child: MaterialApp(
        title: 'Summer Camp Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFf97b06),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFF5F5FA),
        ),
        initialRoute: '/admin',
        onGenerateInitialRoutes: (initialRoute) {
          // Push a single route for /admin (bypasses Flutter's default
          // behaviour of splitting the path into segments)
          return [
            MaterialPageRoute(
              settings: const RouteSettings(name: '/admin'),
              builder: (_) => const AdminLayout(),
            ),
          ];
        },
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const AdminLayout(),
          );
        },
      ),
    );
  }

  // ── Mobile App ──
  Widget _buildMobileApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChildProvider()),
        ChangeNotifierProvider(create: (_) => VolunteerProvider()),
      ],
      child: MaterialApp(
        title: 'Summer Camp 2026',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFf97b06),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.splineSansTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFFFF8F2),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: GoogleFonts.splineSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFf97b06),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.splineSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0D5CC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0D5CC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFf97b06), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFEEE6DF)),
            ),
            color: Colors.white,
          ),
        ),
        builder: (context, child) {
          return Container(
            color: const Color(0xFFE0D5CC),
            child: Center(
              child: ClipRect(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: child,
                ),
              ),
            ),
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}
