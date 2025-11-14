// lib/features/settings/presentation/widgets/delete_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/theme.dart';
import '../.././auth/presentation/bloc/auth_bloc.dart';
import '../.././auth/presentation/bloc/auth_event.dart';
import '../.././auth/presentation/screens/login_screen.dart';
import '../controllers/settings_controller.dart';
import 'section_card.dart';

class DeleteTab extends StatelessWidget {
  final SettingsController controller;

  const DeleteTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Center(
          child: SectionCard(
            title: 'Eliminar cuenta',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Esta acción eliminará permanentemente tu cuenta y todos tus datos.\n'
                  'No podrás deshacerla.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.marginLarge),
                ElevatedButton(
                  onPressed: controller.isDeleting
                      ? null
                      : () => _confirmAndDelete(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                  ),
                  child: controller.isDeleting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Eliminar cuenta'),
                ),
                if (!controller.isDeleting && controller.lastError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      controller.lastError!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Seguro que deseas eliminar tu cuenta?\n'
          'Esta acción no se puede revertir.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusSmall),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await controller.deleteAccount();
    if (!context.mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar la cuenta. Intenta nuevamente.'),
        ),
      );
      return;
    }

    // 🔥 Aquí hacemos lo MISMO que el AppSidebar al cerrar sesión:
    // 1) Mandamos el evento de logout al AuthBloc
    context.read<AuthBloc>().add(LogoutRequested());

    // 2) Navegamos al LoginScreen limpiando toda la pila de navegación
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }
}
