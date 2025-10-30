import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/animal.dart';
import '../bloc/animal_bloc.dart';
import '../bloc/animal_event.dart';

class AnimalDetailPanel extends StatelessWidget {
  final Animal animal;

  const AnimalDetailPanel({
    super.key,
    required this.animal,
  });

  // URL temporal de prueba mientras se arregla CORS en Firebase
  String _getImageUrl() {
    if (animal.urlPhoto.contains('firebasestorage.googleapis.com')) {
      return 'https://media.istockphoto.com/id/877742362/es/foto/retrato-de-vaca-de-gran-angular-alpes-de-tirol-del-sur-sattel-staller.jpg?s=612x612&w=0&k=20&c=jjxcNIqv-KSomavNcWj6z1P9BZBl_AnuUJDt74omqZE=';
    }
    return animal.urlPhoto;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con imagen grande
            Stack(
              children: [
                // Imagen principal
                Hero(
                  tag: 'animal_${animal.id}',
                  child: Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.network(
                      _getImageUrl(),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.pets,
                            size: 100,
                            color: AppColors.primary,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Gradiente oscuro en la parte inferior para mejor legibilidad del texto
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // Información sobre la imagen
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.name,
                          style: AppTextStyles.h2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          animal.idAnimal,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontFamily: 'monospace',
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Información detallada
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información básica
                  _SectionTitle(title: 'Información Básica'),
                  const SizedBox(height: AppDimensions.marginSmall),
                  _InfoRowNoIcon(
                    label: 'Especie',
                    value: animal.specie,
                  ),
                  _InfoRowNoIcon(
                    label: 'Sexo',
                    value: animal.sexText,
                  ),
                  _InfoRowNoIcon(
                    label: 'Fecha de Nacimiento',
                    value: DateFormat('dd/MM/yyyy').format(animal.birthDate),
                  ),
                  _InfoRowNoIcon(
                    label: 'Edad',
                    value: '${animal.ageInYears} ${animal.ageInYears == 1 ? "año" : "años"}',
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),

                  // Datos vitales
                  _SectionTitle(title: 'Datos Vitales'),
                  const SizedBox(height: AppDimensions.marginSmall),
                  _VitalSignCard(
                    icon: Icons.favorite,
                    label: 'Frecuencia Cardíaca',
                    value: '${animal.hearRate}',
                    unit: 'bpm',
                    color: Colors.red,
                  ),
                  const SizedBox(height: AppDimensions.marginSmall),
                  _VitalSignCard(
                    icon: Icons.thermostat,
                    label: 'Temperatura',
                    value: '${animal.temperature}',
                    unit: '°C',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),

                  // Ubicación
                  _SectionTitle(title: 'Ubicación'),
                  const SizedBox(height: AppDimensions.marginSmall),
                  _InfoRowCentered(
                    icon: Icons.location_on,
                    label: 'Coordenadas',
                    value: animal.location,
                  ),
                  _InfoRowCentered(
                    icon: Icons.router,
                    label: 'URL IoT', 
                    value: animal.urlIot,
                  ),
                  
                  const SizedBox(height: AppDimensions.marginLarge),
                  const Divider(),
                  const SizedBox(height: AppDimensions.marginLarge),
                  
                  // Botón Historial Médico
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/clinical-history',
                          arguments: animal.id,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                      ),
                      child: const Text('Ver Historial Médico'),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                  
                  // Botones de acción
                  Row(
                    children: [
                      // Botón Editar
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Implementar edición de animal
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.marginMedium),
                      // Botón Eliminar
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showDeleteConfirmation(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.delete, size: 20),
                              SizedBox(width: 8),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.marginMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Confirmar eliminación'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${animal.name}? Esta acción no se puede deshacer.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteAnimal(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.important,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteAnimal(BuildContext context) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Llamar al API para eliminar
      final apiClient = ApiClient();
      await apiClient.delete('/animals/${animal.idAnimal}');
      
      // Cerrar indicador de carga
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Mostrar mensaje de éxito
        CustomSnackbar.showSuccess(context, 'Animal eliminado correctamente');
        
        // Recargar la lista de animales
        final authState = context.read<AuthBloc>().state;
        final inventoryId = authState is Authenticated ? authState.user.inventoryId : 1;
        context.read<AnimalBloc>().add(LoadAnimals(inventoryId));
      }
    } catch (e) {
      // Cerrar indicador de carga
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Mostrar mensaje de error
        CustomSnackbar.showError(
          context,
          'Error al eliminar el animal: ${e.toString()}',
        );
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.h4.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// Widget para información básica sin iconos
class _InfoRowNoIcon extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRowNoIcon({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para ubicación con iconos centrados
class _InfoRowCentered extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRowCentered({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppDimensions.marginSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalSignCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _VitalSignCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
  
  Color _getHealthColor() {
    // Temperatura normal: 37-39°C
    if (unit == '°C') {
      final temp = double.tryParse(value);
      if (temp == null) return color;
      if (temp >= 37 && temp <= 39) return AppColors.healthNormal;
      if (temp >= 35 && temp < 37 || temp > 39 && temp <= 40) return AppColors.healthWarning;
      return AppColors.healthCritical;
    }
    
    // Frecuencia cardíaca normal: 60-80 bpm
    if (unit == 'bpm') {
      final bpm = int.tryParse(value);
      if (bpm == null) return color;
      if (bpm >= 60 && bpm <= 80) return AppColors.healthNormal;
      if (bpm >= 50 && bpm < 60 || bpm > 80 && bpm <= 100) return AppColors.healthWarning;
      return AppColors.healthCritical;
    }
    
    return color;
  }
  
  String _getHealthStatus() {
    final healthColor = _getHealthColor();
    if (healthColor == AppColors.healthNormal) return 'Normal';
    if (healthColor == AppColors.healthWarning) return 'Atención';
    return 'Crítico';
  }
  
  double _getProgressValue() {
    if (unit == '°C') {
      final temp = double.tryParse(value) ?? 0;
      return (temp / 45).clamp(0.0, 1.0); // Rango 0-45°C
    }
    if (unit == 'bpm') {
      final bpm = int.tryParse(value) ?? 0;
      return (bpm / 120).clamp(0.0, 1.0); // Rango 0-120 bpm
    }
    return 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final healthColor = _getHealthColor();
    final healthStatus = _getHealthStatus();
    final progress = _getProgressValue();
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium + 4),
      decoration: BoxDecoration(
        color: healthColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: healthColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: healthColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: healthColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.marginMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          value,
                          style: AppTextStyles.h3.copyWith(
                            color: healthColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          unit,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: healthColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: healthColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  healthStatus,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: healthColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          // Barra de progreso visual
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
