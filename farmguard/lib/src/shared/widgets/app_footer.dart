import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppDimensions.paddingMedium : AppDimensions.paddingXLarge,
        vertical: AppDimensions.paddingSmall,
      ),
      color: Colors.black.withOpacity(0.8),
      child: isMobile ? _buildMobileFooter() : _buildDesktopFooter(),
    );
  }

  Widget _buildDesktopFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Copyright
        Text(
          'Copyright © 2025 Tunix. All rights reserved.',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        // Links
        Wrap(
          spacing: AppDimensions.marginMedium,
          children: [
            _buildFooterLink('Condiciones de uso'),
            _buildFooterLink('Preferencias sobre cookies'),
            _buildFooterLink('Privacidad'),
            _buildFooterLink('No vender ni compartir mi información personal'),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Links
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppDimensions.marginSmall,
          runSpacing: 4,
          children: [
            _buildFooterLink('Condiciones de uso'),
            const Text('·', style: TextStyle(color: Colors.white70)),
            _buildFooterLink('Preferencias sobre cookies'),
            const Text('·', style: TextStyle(color: Colors.white70)),
            _buildFooterLink('Privacidad'),
            const Text('·', style: TextStyle(color: Colors.white70)),
            _buildFooterLink('No vender ni compartir mi información personal'),
          ],
        ),
        const SizedBox(height: 4),
        // Copyright
        Text(
          'Copyright © 2025 Tunix. All rights reserved.',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white70,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return InkWell(
      onTap: () {
        // TODO: Implementar navegación a páginas legales
        // debugPrint('Navegando a: $text');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        child: Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white70,
            fontSize: 11,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
