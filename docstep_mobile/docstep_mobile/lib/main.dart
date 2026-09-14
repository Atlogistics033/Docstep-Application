import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/public/guest_layout.dart';
import 'screens/doctor/doctor_layout.dart';
import 'screens/employer/employer_layout.dart';
import 'screens/admin/dashboard_screen.dart';
import 'screens/patient/patient_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: const DocStepApp(),
    ),
  );
}

class DocStepApp extends StatelessWidget {
  const DocStepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocStep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme
          .lightTheme, // Hamara Soft Teal, White, Lavender, Navy theme yahan connected hai
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const GuestLayout(),
        '/doctor/dashboard': (context) => const DoctorLayout(),
        '/employer/dashboard': (context) => const EmployerLayout(),
        '/patient/dashboard': (context) => const PatientLayout(),
        '/admin/dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}
