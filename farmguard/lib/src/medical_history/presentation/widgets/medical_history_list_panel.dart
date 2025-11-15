import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../animals/domain/entities/animal.dart';
import '../../../animals/presentation/bloc/animal_bloc.dart';
import '../../../animals/presentation/bloc/animal_state.dart';
import '../../../animals/presentation/bloc/animal_event.dart';

class MedicalHistoryListPanel extends StatefulWidget {
  const MedicalHistoryListPanel({super.key});

  @override
  State<MedicalHistoryListPanel> createState() => _MedicalHistoryListPanelState();
}

class _MedicalHistoryListPanelState extends State<MedicalHistoryListPanel> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSpecie;

  @override
  void dispose() {
    _searchController.dispose();  
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final animalBloc = context.read<AnimalBloc>();
    final currentState = animalBloc.state;
    
    if (currentState is AnimalLoaded) {
      animalBloc.add(FilterAnimals(
        searchQuery: value.length >= 3 ? value : null,
        specieFilter: _selectedSpecie,
      ));
    }
  }

  void _onSpecieChanged(String? value) {
    setState(() {
      _selectedSpecie = value;
    });
    
    final animalBloc = context.read<AnimalBloc>();
    final currentState = animalBloc.state;
    
    if (currentState is AnimalLoaded) {
      animalBloc.add(FilterAnimals(
        searchQuery: _searchController.text.length >= 3 ? _searchController.text : null,
        specieFilter: value,
      ));
    }
  }

  List<String> _getUniqueSpecies(List<Animal> animals) {
    final species = animals.map((a) => a.specie).toSet().toList();
    species.sort();
    return species;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimalBloc, AnimalState>(
      builder: (context, state) {
        if (state is! AnimalLoaded) {
          return const SizedBox.shrink();
        }

        final uniqueSpecies = _getUniqueSpecies(state.animals);
        final displayAnimals = state.filteredAnimals.isNotEmpty 
            ? state.filteredAnimals 
            : state.animals;

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
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
                    const SizedBox(width: AppDimensions.marginMedium),
                    Text(
                      'Historial Médico',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${displayAnimals.length} ${displayAnimals.length == 1 ? "animal" : "animales"}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search and Filter
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre o código (min. 3 caracteres)...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMedium,
                            vertical: AppDimensions.paddingSmall,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.marginMedium),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSpecie,
                        decoration: InputDecoration(
                          hintText: 'Filtrar por especie',
                          prefixIcon: const Icon(Icons.filter_list),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMedium,
                            vertical: AppDimensions.paddingSmall,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Todas las especies'),
                          ),
                          ...uniqueSpecies.map((specie) => DropdownMenuItem<String>(
                                value: specie,
                                child: Text(specie),
                              )),
                        ],
                        onChanged: _onSpecieChanged,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lista de Animales en Cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  itemCount: displayAnimals.length,
                  itemBuilder: (context, index) {
                    final animal = displayAnimals[index];
                    return _buildAnimalCard(context, animal);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimalCard(BuildContext context, Animal animal) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: AppDimensions.marginLarge),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  animal.name,
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  '#${animal.idAnimal.substring(0, 6)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.marginSmall),
            const Divider(),
            const SizedBox(height: AppDimensions.marginSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('Especie', animal.specie),
                _buildInfoColumn('Sexo', animal.sex ? 'Macho' : 'Hembra'),
              ],
            ),
            const SizedBox(height: AppDimensions.marginMedium),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/clinical-history',
                    arguments: animal.id,
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text('Ver Historial'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.marginXSmall),
        Text(
          value,
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}