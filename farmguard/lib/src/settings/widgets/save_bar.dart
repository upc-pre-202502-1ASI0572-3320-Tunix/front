import 'package:flutter/material.dart';
// TODO: ajusta la ruta a tu theme
import '../../../../core/theme/theme.dart';

/// Barra inferior con botón Guardar. Escucha a un ChangeNotifier
/// (tu SettingsController) para habilitar/deshabilitar el botón.
class SaveBar extends StatelessWidget {
  final Listenable isSavingListenable;
  final Listenable hasChangesListenable;
  final VoidCallback onPressed;

  const SaveBar({
    super.key,
    required this.isSavingListenable,
    required this.hasChangesListenable,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([isSavingListenable, hasChangesListenable]),
      builder: (context, _) {
        // Leemos flags del controller (SettingsController) de forma segura.
        final controller = isSavingListenable as dynamic;
        final bool isSaving = (controller.isSaving as bool?) ?? false;
        final bool hasChanges =
            ((hasChangesListenable as dynamic).hasChanges as bool?) ?? false;

        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 280,
              child: ElevatedButton(
                onPressed: (isSaving || !hasChanges) ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusLarge),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ),
          ),
        );
      },
    );
  }
}
