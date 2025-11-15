import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../animals/presentation/screens/animals_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignInRequested(
              username: _usernameController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    return ScaffoldMessenger(
      child: Scaffold(
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
          if (state is AuthError) {
            CustomSnackbar.showError(context, state.message);
          } else if (state is Authenticated) {
            CustomSnackbar.showSuccess(
              context,
              '¡Bienvenido, ${state.user.username}!',
            );
            // Navegar a la pantalla de animales
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AnimalsScreen(),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Column(
            children: [
              Expanded(
                child: isMobile 
                    ? _buildMobileLayout(isLoading)
                    : _buildDesktopLayout(isLoading),
              ),
              const AppFooter(),
            ],
          );
        },
      ),
      ),
    );
  }

  Widget _buildMobileLayout(bool isLoading) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.marginXLarge),
            SvgPicture.asset(
              'assets/images/g13.svg',
              width: 80,
              height: 80,
              colorFilter: ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            Text(
              'FarmGuard',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            Text(
              'Inicia sesión o crea una cuenta',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.marginXLarge),
            _buildLoginForm(isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(bool isLoading) {
    return Stack(
      children: [
        // Imagen de fondo
        Positioned.fill(
          child: Image.asset(
            'assets/images/farm_background.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback a gradiente si no encuentra la imagen
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      Colors.black87,
                      Colors.black,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Overlay oscuro para contraste
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        // Contenido
        Row(
          children: [
            // Lado izquierdo - Logo y texto
            Expanded(
              flex: 5,
              child: _buildLeftSide(),
            ),
            // Lado derecho - Formulario en Card
            Expanded(
              flex: 5,
              child: _buildRightSide(isLoading),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeftSide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo SVG
          SvgPicture.asset(
            'assets/images/g13.svg',
            width: 120,
            height: 120,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: AppDimensions.marginXLarge),
          // FarmGuard
          Text(
            'FarmGuard',
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppDimensions.marginLarge),
          // Subtítulo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              'Inicia sesión o crea una cuenta',
              style: AppTextStyles.h4.copyWith(
                color: Colors.white70,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSide(bool isLoading) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 60,
          vertical: AppDimensions.paddingLarge,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            elevation: 12,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingXLarge * 1.5),
              child: _buildLoginForm(isLoading),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Iniciar Sesión',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            'Ingresa tus credenciales para continuar',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.marginXLarge),
          CustomTextField(
            controller: _usernameController,
            labelText: 'Usuario',
            hintText: 'Ingresa tu usuario',
            prefixIcon: Icons.person_outline,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El usuario es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          CustomTextField(
            controller: _passwordController,
            labelText: 'Contraseña',
            hintText: 'Ingresa tu contraseña',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            enabled: !isLoading,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La contraseña es requerida';
              }
              if (value.length < 6) {
                return 'Debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isLoading ? null : () {},
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.marginLarge),
          AuthButton(
            text: 'Iniciar Sesión',
            onPressed: isLoading ? null : _onLogin,
            isLoading: isLoading,
          ),
          const SizedBox(height: AppDimensions.marginXLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿No tienes cuenta? ',
                style: AppTextStyles.bodyMedium,
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/register');
                      },
                child: Text(
                  'Regístrate',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
