import 'package:flutter/material.dart';
// TODO: ajusta la ruta a tu theme
import '../../../../core/theme/theme.dart';
import 'section_card.dart';

class BillingTabPlaceholder extends StatelessWidget {
  const BillingTabPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCard(
            title: 'Plan Actual',
            child: Container(
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusLarge),
              ),
              child: Text(
                'Información del plan (boceto)',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.marginLarge),
          SectionCard(
            title: 'Métodos de pago',
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Text(
                'Aquí irán los campos de tarjeta y la lista de planes. (Boceto)',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
