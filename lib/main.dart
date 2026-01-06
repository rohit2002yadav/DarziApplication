import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_page.dart';
import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'auth/forgot_password_page.dart';
import 'auth/verify_otp_page.dart';
import 'auth/reset_password_page.dart';
import 'profile/profile_page.dart';
import 'profile/edit_profile_page.dart';
import 'profile/measurements_page.dart';
import 'screens/customer/order_history_page.dart'; // Import history page
import 'screens/order/choose_fabric_page.dart';
import 'screens/order/i_have_fabric_page.dart';
import 'screens/order/fabric_handover_page.dart';
import 'screens/order/select_garment_page.dart';
import 'screens/order/add_measurements_page.dart';
import 'tailor/tailor_list_page.dart';
import 'tailor/tailor_profile_page.dart';
import 'utils/globals.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6A1B9A);
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'Darzi Direct',
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansTextTheme(textTheme),
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: const BorderSide(color: primaryColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          prefixIconColor: primaryColor,
        ),
        listTileTheme: ListTileThemeData(
          iconColor: primaryColor,
          titleTextStyle: GoogleFonts.notoSans(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primaryColor,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        dividerTheme: DividerThemeData(
          thickness: 1,
          space: 1,
          color: Colors.grey.shade200,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUpPage());
          case '/home':
             final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(builder: (_) => HomePage(userData: args));
          case '/forgot-password':
            return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
          case '/verify-otp':
            final args = settings.arguments as String?;
            return MaterialPageRoute(builder: (_) => VerifyOtpPage(email: args));
          case '/reset-password':
            final args = settings.arguments as String?;
            return MaterialPageRoute(builder: (_) => ResetPasswordPage(email: args));
          case '/profile':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(builder: (_) => ProfilePage(userData: args));
          case '/edit-profile':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(builder: (_) => EditProfilePage(userData: args));
          case '/measurements':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(builder: (_) => MeasurementsPage(userData: args));
          case '/order-history':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(builder: (_) => OrderHistoryPage(userData: args));
          case '/choose-fabric':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(builder: (_) => ChooseFabricPage(userData: args));
          case '/select-garment':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(builder: (_) => SelectGarmentPage(userData: args));
          case '/add-measurements':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(builder: (_) => AddMeasurementsPage(userData: args));
          case '/i-have-fabric':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(builder: (_) => IHaveFabricPage(userData: args));
          case '/fabric-handover':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(builder: (_) => FabricHandoverScreen(userData: args));
          case '/tailor-list':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(builder: (_) => TailorListPage(userData: args));
          case '/tailor-profile':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(builder: (_) => TailorProfilePage(tailorData: args));
          default:
            return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      },
    );
  }
}
