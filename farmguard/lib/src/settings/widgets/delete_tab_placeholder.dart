import 'package:flutter/material.dart';
// TODO: ajusta la ruta a tu theme
import '../../../../core/theme/theme.dart';
import 'section_card.dart';

class DeleteTabPlaceholder extends StatelessWidget {
  const DeleteTabPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SectionCard(
        title: 'Eliminar cuenta',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Esta acción eliminará permanentemente tu cuenta y datos. (Boceto)',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.marginLarge),
            ElevatedButton(
              onPressed: null, // deshabilitado por ahora
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
              child: const Text('Eliminar cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
