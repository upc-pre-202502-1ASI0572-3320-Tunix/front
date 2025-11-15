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
                      color: Colors.black.withOpacity(0.05),
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
              
              // Header Table
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.marginLarge,
                  vertical: AppDimensions.marginMedium,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.5), // Código
                    1: FlexColumnWidth(2.5), // Nombre
                    2: FlexColumnWidth(2.0), // Especie
                    3: FlexColumnWidth(1.5), // Sexo
                    4: FlexColumnWidth(1.0), // Acción
                  },
                  children: [
                    TableRow(
                      children: [
                        _buildHeaderCell('CÓDIGO'),
                        _buildHeaderCell('NOMBRE'),
                        _buildHeaderCell('ESPECIE'),
                        _buildHeaderCell('SEXO'),
                        _buildHeaderCell('ACCIÓN'),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Data Table
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.marginLarge,
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.5), // Código
                      1: FlexColumnWidth(2.5), // Nombre
                      2: FlexColumnWidth(2.0), // Especie
                      3: FlexColumnWidth(1.5), // Sexo
                      4: FlexColumnWidth(1.0), // Acción
                    },
                    children: displayAnimals
                        .map((animal) => _buildDataRow(animal))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildDataRow(Animal animal) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      children: [
        _buildDataCell(animal.idAnimal.substring(0, 6)),
        _buildDataCell(animal.name),
        _buildDataCell(animal.specie),
        _buildDataCell(animal.sex ? 'Macho' : 'Hembra'),
        _buildActionCell(animal),
      ],
    );
  }

  Widget _buildDataCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionCell(Animal animal) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingSmall,
        ),
        child: Center(
          child: IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/clinical-history',
                arguments: animal.id, // Usar id long
              );
            },
            icon: const Icon(Icons.visibility),
            color: AppColors.primary,
            tooltip: 'Ver Historial Clínico',
          ),
        ),
      ),
    );
  }
}
