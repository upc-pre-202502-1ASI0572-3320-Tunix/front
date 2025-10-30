import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../../../../core/theme/theme.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/auth_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Variables para la imagen
  Uint8List? _imageBytes;
  String? _imageFileName;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _pickImage() {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((e) {
          setState(() {
            _imageBytes = reader.result as Uint8List;
            _imageFileName = file.name;
          });
        });
      }
    });
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignUpRequested(
              username: _usernameController.text.trim(),
              password: _passwordController.text,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
              photoBytes: _imageBytes,
              photoFileName: _imageFileName,
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
            } else if (state is SignUpSuccess) {
              CustomSnackbar.showSuccess(context, state.message);
              Navigator.pop(context);
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
      child: Column(
        children: [
          AppBar(
            title: const Text('Registro'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: _buildRegisterForm(isLoading),
            ),
          ),
        ],
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
                      AppColors.primary.withValues(alpha: 0.3),
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
            color: Colors.black.withValues(alpha: 0.5),
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
        // Botón de retroceso
        Positioned(
          top: AppDimensions.paddingMedium,
          left: AppDimensions.paddingMedium,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
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
            shadowColor: Colors.black.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingXLarge * 1.5),
              child: _buildRegisterForm(isLoading),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Crear Cuenta',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            'Completa el formulario para registrarte',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.marginLarge),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _firstNameController,
                  labelText: 'Nombre',
                  hintText: 'Tu nombre',
                  prefixIcon: Icons.person_outline,
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.marginMedium),
              Expanded(
                child: CustomTextField(
                  controller: _lastNameController,
                  labelText: 'Apellido',
                  hintText: 'Tu apellido',
                  prefixIcon: Icons.person_outline,
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          CustomTextField(
            controller: _usernameController,
            labelText: 'Usuario',
            hintText: 'Elige un nombre de usuario',
            prefixIcon: Icons.alternate_email,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El usuario es requerido';
              }
              if (value.length < 3) {
                return 'Debe tener al menos 3 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            hintText: 'correo@ejemplo.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El email es requerido';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Email no válido';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          CustomTextField(
            controller: _passwordController,
            labelText: 'Contraseña',
            hintText: 'Mínimo 6 caracteres',
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
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirmar contraseña',
            hintText: 'Repite la contraseña',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            enabled: !isLoading,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirma tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.marginLarge),
          // Selector de imagen
          _buildImagePicker(isLoading),
          const SizedBox(height: AppDimensions.marginXLarge),
          AuthButton(
            text: 'Registrarse',
            onPressed: isLoading ? null : _onRegister,
            isLoading: isLoading,
          ),
          const SizedBox(height: AppDimensions.marginLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿Ya tienes cuenta? ',
                style: AppTextStyles.bodyMedium,
              ),
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: Text(
                  'Inicia sesión',
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

  Widget _buildImagePicker(bool isLoading) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(
          color: AppColors.textSecondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.photo_camera,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.marginSmall),
                Text(
                  'Foto de perfil (opcional)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            if (_imageBytes != null) ...[
              // Preview de la imagen seleccionada
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    child: Image.memory(
                      _imageBytes!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.marginMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _imageFileName ?? 'Imagen',
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : () {
                            setState(() {
                              _imageBytes = null;
                              _imageFileName = null;
                            });
                          },
                          icon: const Icon(Icons.delete, size: 18),
                          label: const Text('Eliminar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red[700],
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Botón para seleccionar imagen
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : _pickImage,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Seleccionar imagen'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingMedium,
                    ),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
