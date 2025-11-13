import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../animals/presentation/screens/animals_screen.dart';

class AppSidebar extends StatefulWidget {
  const AppSidebar({super.key});

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  bool _isExpanded = false; // Inicia contraído
  bool _showText = false; // Controla la visibilidad del texto
  Timer? _expandTimer;
  Timer? _collapseTimer;
  Timer? _textTimer;

  @override
  void dispose() {
    _expandTimer?.cancel();
    _collapseTimer?.cancel();
    _textTimer?.cancel();
    super.dispose();
  }

  void _onHoverEnter() {
    // Cancelar timer de contraer si existe
    _collapseTimer?.cancel();
    _textTimer?.cancel();
    
    // Programar expansión después de 1 segundo
    _expandTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isExpanded = true;
        });
        
        // Mostrar texto después de que termine la animación (400ms)
        _textTimer = Timer(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              _showText = true;
            });
          }
        });
      }
    });
  }

  void _onHoverExit() {
    // Cancelar timers si existen
    _expandTimer?.cancel();
    _textTimer?.cancel();
    
    // Ocultar texto y contraer inmediatamente
    if (mounted) {
      setState(() {
        _showText = false;
        _isExpanded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _isExpanded ? 280 : 80,
        decoration: BoxDecoration(
          color: const Color(0xFF1B5E20), // Verde oscuro
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Logo
            _buildHeader(),
            
            const SizedBox(height: AppDimensions.marginXLarge),
            
            // Menú principal
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSmall,
                ),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.home_outlined,
                    label: 'Home',
                    isSelected: true,
                    onTap: () {
                      // Ya estamos en home
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.pets_outlined,
                    label: 'Animales',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AnimalsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.medical_information_outlined,
                    label: 'Historial Médico',
                    onTap: () {
                      Navigator.of(context).pushNamed('/medical-history');
                    },
                  ),
                ],
              ),
            ),
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              label: 'Configuración',
              onTap: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
            
            // Botón de cerrar sesión
            _buildLogoutButton(context),
            
            const SizedBox(height: AppDimensions.marginMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: _isExpanded
          ? Row(
              children: [
                // Logo fijo en 50x50
                SvgPicture.asset(
                  'assets/images/g13.svg',
                  width: 50,
                  height: 50,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                if (_showText) ...[
                  const SizedBox(width: AppDimensions.marginMedium),
                  Expanded(
                    child: Text(
                      'FarmGuard',
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            )
          : Center(
              child: SvgPicture.asset(
                'assets/images/g13.svg',
                width: 50,
                height: 50,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Material(
    color: isSelected 
      ? Colors.white.withValues(alpha: 0.15) 
      : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall + 4,
            ),
            child: _isExpanded
                ? Row(
                    children: [
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                      if (_showText) ...[
                        const SizedBox(width: AppDimensions.marginMedium),
                        Expanded(
                          child: Text(
                            label,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                : Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.marginSmall),
      child: Material(
  color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: InkWell(
          onTap: () => _showLogoutDialog(context),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingSmall + 4,
            ),
            child: _isExpanded
                ? Row(
                    children: [
                      const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 24,
                      ),
                      if (_showText) ...[
                        const SizedBox(width: AppDimensions.marginMedium),
                        Expanded(
                          child: Text(
                            'Cerrar Sesión',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  )
                : const Center(
                    child: Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Cerrar diálogo
              context.read<AuthBloc>().add(LogoutRequested());
              // Navegar al login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false, // Eliminar todas las rutas anteriores
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
