import 'package:farmguard/src/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/api_client.dart';
import 'core/theme/theme.dart';
import 'src/auth/auth.dart';
import 'src/medical_history/presentation/screens/medical_history_screen.dart';
import 'src/medical_history/presentation/screens/clinical_history_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC
        BlocProvider(
          create: (context) {
            // Inicializar dependencias
            final apiClient = ApiClient();
            
            // DataSources
            final remoteDataSource = AuthRemoteDataSourceImpl(
              apiClient: apiClient,
            );
            final localDataSource = AuthLocalDataSourceImpl();
            
            // Repository
            final authRepository = AuthRepositoryImpl(
              remoteDataSource: remoteDataSource,
              localDataSource: localDataSource,
            );
            
            // Use Cases
            final signInUseCase = SignInUseCase(authRepository);
            final signUpUseCase = SignUpUseCase(authRepository);
            final logoutUseCase = LogoutUseCase(authRepository);
            
            // BLoC
            return AuthBloc(
              signInUseCase: signInUseCase,
              signUpUseCase: signUpUseCase,
              logoutUseCase: logoutUseCase,
              authRepository: authRepository,
            )..add(const CheckAuthStatus());
          },
        ),
      ],
      child: MaterialApp(
        title: 'FarmGuard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const LoginScreen(),
        routes: {
          '/register': (context) => const RegisterScreen(),
          '/medical-history': (context) => const MedicalHistoryScreen(),
          '/settings': (context) => const SettingsScreen(),

        },
        onGenerateRoute: (settings) {
          if (settings.name == '/clinical-history') {
            final animalId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => ClinicalHistoryScreen(animalId: animalId),
            );
          }
          return null;
        },
      ),
    );
  }
}

// Placeholder temporal para home
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('¡Bienvenido a FarmGuard!'),
      ),
    );
  }
}


