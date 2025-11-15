import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/animal.dart';
import '../bloc/animal_bloc.dart';
import '../bloc/animal_event.dart';
import 'add_animal_dialog.dart';

class AnimalListPanel extends StatefulWidget {
  final List<Animal> animals;
  final int? selectedAnimalId;
  final Function(Animal)? onShowDetails;

  const AnimalListPanel({
    super.key,
    required this.animals,
    this.selectedAnimalId,
    this.onShowDetails,
  });

  @override
  State<AnimalListPanel> createState() => _AnimalListPanelState();
}

class _AnimalListPanelState extends State<AnimalListPanel> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSpecie;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (value.length >= 3 || value.isEmpty) {
      context.read<AnimalBloc>().add(FilterAnimals(
        searchQuery: value.isEmpty ? null : value,
        specieFilter: _selectedSpecie,
      ));
    }
  }

  void _onSpecieChanged(String? specie) {
    setState(() {
      _selectedSpecie = specie;
    });
    context.read<AnimalBloc>().add(FilterAnimals(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      specieFilter: specie,
    ));
  }

  List<String> _getUniqueSpecies() {
    return widget.animals.map((animal) => animal.specie).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    return Stack(
      children: [
        Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(
                isMobile ? AppDimensions.paddingMedium : AppDimensions.paddingLarge,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lista de Animales',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 20 : 24,
                          ),
                        ),
                        if (!isMobile)
                          Text(
                            '${widget.animals.length} ${widget.animals.length == 1 ? "animal" : "animales"}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 12),
                    Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AddAnimalDialog(
                              animalBloc: context.read<AnimalBloc>(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.add, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Agregar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Barra de búsqueda y filtro
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              color: Colors.white,
              child: isMobile
                  ? Column(
                      children: [
                        // Barra de búsqueda
                        TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Buscar por nombre',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMedium),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMedium),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMedium),
                              borderSide:
                                  BorderSide(color: AppColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingMedium,
                              vertical: AppDimensions.paddingSmall,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),
                        // Filtro por especie
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSpecie,
                          hint: Text(
                            'Filtrar por especie',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMedium),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMedium),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMedium),
                              borderSide:
                                  BorderSide(color: AppColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingMedium,
                              vertical: AppDimensions.paddingSmall,
                            ),
                            prefixIcon: Icon(
                              Icons.filter_list,
                              color: AppColors.primary,
                            ),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Todas las especies'),
                            ),
                            ..._getUniqueSpecies().map((specie) {
                              return DropdownMenuItem<String>(
                                value: specie,
                                child: Text(specie),
                              );
                            }),
                          ],
                          onChanged: _onSpecieChanged,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        // Barra de búsqueda
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Buscar por nombre (mín. 3 letras)',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.primary,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppDimensions.radiusMedium),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppDimensions.radiusMedium),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppDimensions.radiusMedium),
                                borderSide:
                                    BorderSide(color: AppColors.primary, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingMedium,
                                vertical: AppDimensions.paddingSmall,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.marginMedium),
                        // Filtro por especie
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedSpecie,
                            hint: Text(
                              'Filtrar por especie',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppDimensions.radiusMedium),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppDimensions.radiusMedium),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppDimensions.radiusMedium),
                                borderSide:
                                    BorderSide(color: AppColors.primary, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingMedium,
                                vertical: AppDimensions.paddingSmall,
                              ),
                              prefixIcon: Icon(
                                Icons.filter_list,
                                color: AppColors.primary,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Todas las especies'),
                              ),
                              ..._getUniqueSpecies().map((specie) {
                                return DropdownMenuItem<String>(
                                  value: specie,
                                  child: Text(specie),
                                );
                              }),
                            ],
                            onChanged: _onSpecieChanged,
                          ),
                        ),
                      ],
                    ),
            ),

        // Lista de animales en cards
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: ListView.builder(
              itemCount: widget.animals.length,
              itemBuilder: (context, index) {
                final animal = widget.animals[index];
                final isSelected = animal.id == widget.selectedAnimalId;
                return _buildAnimalCard(animal, isSelected);
              },
            ),
          ),
        ),
          ],
        ),
        // FAB en móvil
        if (isMobile)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AddAnimalDialog(
                    animalBloc: context.read<AnimalBloc>(),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            ),
          ),
      ],
    );
  }

  Widget _buildAnimalCard(Animal animal, bool isSelected) {
    return GestureDetector(
      onTap: () {
        context.read<AnimalBloc>().add(SelectAnimal(animal.id));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        color: isSelected 
            ? AppColors.primary.withValues(alpha: 0.05)
            : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Nombre y Código
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.name,
                          style: AppTextStyles.h3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${animal.idAnimal.substring(0, 6).toUpperCase()}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge de especie
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      animal.specie,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.marginMedium),
              
              // Información en grid
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  _buildInfoItem(
                    icon: Icons.wc,
                    label: 'Sexo',
                    value: animal.sexText,
                  ),
                  _buildInfoItem(
                    icon: Icons.cake,
                    label: 'Edad',
                    value: '${animal.ageInYears} años',
                  ),
                  _buildInfoItem(
                    icon: Icons.location_on,
                    label: 'Ubicación',
                    value: animal.location,
                  ),
                ],
              ),
              
              const SizedBox(height: AppDimensions.marginMedium),
              
              // Botón de ver detalles
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    try {
                      if (widget.onShowDetails != null) {
                        widget.onShowDetails!(animal);
                      } else {
                        context.read<AnimalBloc>().add(SelectAnimal(animal.id));
                      }
                    } catch (e) {
                      debugPrint('Error al mostrar detalles: $e');
                    }
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Ver Detalles'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingSmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}