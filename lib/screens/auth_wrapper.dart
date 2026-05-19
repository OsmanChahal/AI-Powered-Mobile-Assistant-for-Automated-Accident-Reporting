import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import '../models/report_state.dart';
import '../services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  final ReportState state;

  const AuthWrapper({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the snapshot has user data, then they're already signed in.
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          }

          // User is signed in — check if profile is complete
          return FutureBuilder<bool>(
            future: AuthService.hasCompletedProfile(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final bool profileComplete = profileSnapshot.data ?? false;

              if (!profileComplete) {
                // Profile incomplete — show register screen with Google data
                return RegisterScreen(
                  isGoogleSignUp: true,
                  googleFirstName: user.displayName?.split(' ').first ?? '',
                  googleLastName: user.displayName?.split(' ').skip(1).join(' ') ?? '',
                  googleEmail: user.email ?? '',
                );
              }

              return HomeScreen(state: state);
            },
          );
        }

        // While waiting for the auth state to load, show a loading spinner
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
