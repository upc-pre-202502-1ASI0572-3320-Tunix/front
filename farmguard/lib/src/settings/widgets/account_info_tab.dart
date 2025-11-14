import 'dart:typed_data';
import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Ajusta la ruta a tu theme si es necesario
import '../../../../core/theme/theme.dart';

import '../controllers/settings_controller.dart';
import 'section_card.dart';

class AccountInfoTab extends StatelessWidget {
  final SettingsController controller;

  const AccountInfoTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Formulario (nombre, apellido, email)
              Expanded(
                child: SectionCard(
                  title: 'Información del Usuario',
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        _inputRow(
                          label: 'Nombre',
                          child: _textField(
                            controller: controller.nameCtrl,
                            hint: 'Tu nombre',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Ingresa tu nombre'
                                : null,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),
                        _inputRow(
                          label: 'Apellido',
                          child: _textField(
                            controller: controller.lastNameCtrl,
                            hint: 'Tu apellido',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Ingresa tu apellido'
                                : null,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),
                        _inputRow(
                          label: 'Correo',
                          child: _textField(
                            controller: controller.emailCtrl,
                            hint: 'correo@empresa.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Ingresa tu correo';
                              }
                              final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                  .hasMatch(v.trim());
                              return ok ? null : 'Correo inválido';
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.marginXLarge),

              // Avatar + botón Editar
              SizedBox(width: 320, child: _avatarCard(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _avatarCard(BuildContext context) {
    return SectionCard(
      title: 'Foto de perfil',
      child: Column(
        children: [
          const SizedBox(height: AppDimensions.marginSmall),
          CircleAvatar(
            radius: 64,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: controller.avatar,
            child: controller.avatar == null
                ? const Icon(Icons.person, size: 64, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: AppDimensions.marginLarge),
          ElevatedButton.icon(
            onPressed: () => _pickImage(context),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Editar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMedium),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (picked == null) return; // usuario canceló

      if (kIsWeb) {
        // En web usamos bytes y podemos pasar el nombre del archivo
        final Uint8List bytes = await picked.readAsBytes();
        controller.setAvatarFromBytes(
          bytes,
          fileName: picked.name, // <- para el MultipartFile
        );
      } else {
        // En mobile usamos File(path)
        controller.setAvatarFromFile(File(picked.path));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Imagen seleccionada. No olvides Guardar.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo seleccionar la imagen: $e'),
        ),
      );
    }
  }

  Widget _inputRow({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 140,
          child: Text(label, style: AppTextStyles.bodyMedium),
        ),
        const SizedBox(width: AppDimensions.marginMedium),
        Expanded(child: child),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
      ),
    );
  }
}
