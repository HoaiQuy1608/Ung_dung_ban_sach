import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:ungdungbansach/providers/cart_provider.dart';
import 'package:ungdungbansach/providers/auth_provider.dart';
import 'package:ungdungbansach/providers/book_service.dart';
import 'package:ungdungbansach/providers/order_provider.dart';
import 'package:ungdungbansach/providers/notification_provider.dart';
import 'package:ungdungbansach/providers/theme_provider.dart';
import 'package:ungdungbansach/utils/app_theme.dart';
import 'package:ungdungbansach/screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => BookService()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Bookify',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme.copyWith(
              textTheme: GoogleFonts.nunitoTextTheme(AppTheme.lightTheme.textTheme),
            ),
            darkTheme: AppTheme.darkTheme.copyWith(
              textTheme: GoogleFonts.nunitoTextTheme(AppTheme.darkTheme.textTheme),
            ),
            themeMode: themeProvider.themeMode,
            builder: EasyLoading.init(),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}

