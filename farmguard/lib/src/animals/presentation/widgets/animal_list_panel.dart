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

  const AnimalListPanel({
    super.key,
    required this.animals,
    this.selectedAnimalId,
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
    return Column(
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
                'Lista de Animales',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.animals.length} ${widget.animals.length == 1 ? "animal" : "animales"}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddAnimalDialog(),
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
          ),
        ),

        // Barra de búsqueda y filtro
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          color: Colors.white,
          child: Row(
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
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
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
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
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

        // Tabla
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              children: [
                // Tabla de cabeceras con border redondeado
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.5), // CÓDIGO
                      1: FlexColumnWidth(2.5), // NOMBRE
                      2: FlexColumnWidth(2.0), // ESPECIE
                      3: FlexColumnWidth(1.5), // FRECUENCIA
                      4: FlexColumnWidth(1.5), // TEMPERATURA
                      5: FlexColumnWidth(1.0), // SEXO
                      6: FlexColumnWidth(1.0), // ACCIONES (reducido)
                    },
                    children: [
                      TableRow(
                        children: [
                          _buildHeaderCell('CÓDIGO'),
                          _buildHeaderCell('NOMBRE'),
                          _buildHeaderCell('ESPECIE'),
                          _buildHeaderCell('FRECUENCIA'),
                          _buildHeaderCell('TEMPERATURA'),
                          _buildHeaderCell('SEXO'),
                          _buildHeaderCell('ACCIONES'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Tabla de datos sin bordes
                Expanded(
                  child: SingleChildScrollView(
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.5), // CÓDIGO
                        1: FlexColumnWidth(2.5), // NOMBRE
                        2: FlexColumnWidth(2.0), // ESPECIE
                        3: FlexColumnWidth(1.5), // FRECUENCIA
                        4: FlexColumnWidth(1.5), // TEMPERATURA
                        5: FlexColumnWidth(1.0), // SEXO
                        6: FlexColumnWidth(1.0), // ACCIONES (reducido)
                      },
                      children: widget.animals.map((animal) {
                        final isSelected = animal.id == widget.selectedAnimalId;
                        return TableRow(
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color.fromARGB(255, 234, 232, 252) 
                                : Colors.transparent,
                          ),
                          children: [
                            _buildDataCell(
                              animal.idAnimal.substring(0, 6).toUpperCase(),
                              TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            _buildDataCell(
                              animal.name,
                              TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                            _buildDataCellWidget(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  animal.specie,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ),
                            _buildDataCell(
                              '${animal.hearRate} bpm',
                              AppTextStyles.bodySmall,
                            ),
                            _buildDataCell(
                              '${animal.temperature}°C',
                              AppTextStyles.bodySmall,
                            ),
                            _buildDataCell(
                              animal.sexText,
                              AppTextStyles.bodySmall,
                            ),
                            _buildDataCellWidget(
                              IconButton(
                                onPressed: () {
                                  context.read<AnimalBloc>().add(SelectAnimal(animal.id));
                                },
                                icon: Icon(
                                  Icons.visibility,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                                tooltip: 'Inspeccionar',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, TextStyle style) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: style,
        ),
      ),
    );
  }

  Widget _buildDataCellWidget(Widget widget) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Center(child: widget),
      ),
    );
  }
}