import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../widgets/app_sidebar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;

    if (isMobile) {
      return _buildMobileLayout();
    }

    return _buildDesktopLayout();
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar fijo a la izquierda
          const AppSidebar(),
          
          // Contenido principal
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmGuard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: const AppSidebar(),
      ),
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Container(
      color: AppColors.background,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Bienvenido de nuevo!',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),
                  Text(
                    'Aquí está el resumen de tu granja',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Contenido - Grid de cards
          SliverPadding(
            padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: AppDimensions.marginLarge,
                mainAxisSpacing: AppDimensions.marginLarge,
              ),
              delegate: SliverChildListDelegate([
                _buildStatCard(
                  title: 'Granjas Activas',
                  value: '0',
                  icon: Icons.agriculture,
                  color: AppColors.primary,
                ),
                _buildStatCard(
                  title: 'Sensores Conectados',
                  value: '0',
                  icon: Icons.sensors,
                  color: Colors.blue,
                ),
                _buildStatCard(
                  title: 'Alertas Pendientes',
                  value: '0',
                  icon: Icons.notifications_active,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  title: 'Monitoreo en Tiempo Real',
                  value: 'Activo',
                  icon: Icons.online_prediction,
                  color: AppColors.success,
                ),
              ]),
            ),
          ),
          
          // Sección de acciones rápidas
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingXLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Acciones Rápidas',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppDimensions.marginLarge),
                  Wrap(
                    spacing: AppDimensions.marginMedium,
                    runSpacing: AppDimensions.marginMedium,
                    children: [
                      _buildQuickActionButton(
                        label: 'Agregar Granja',
                        icon: Icons.add_location_alt,
                        onTap: () {
                          // Implementar navegación
                        },
                      ),
                      _buildQuickActionButton(
                        label: 'Ver Sensores',
                        icon: Icons.device_hub,
                        onTap: () {
                          // Implementar navegación
                        },
                      ),
                      _buildQuickActionButton(
                        label: 'Ver Reportes',
                        icon: Icons.analytics,
                        onTap: () {
                          // Implementar navegación
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.marginXLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h1.copyWith(
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
    );
  }
}
