import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:typed_data';
import '../../../../core/config/app_config.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/animal_bloc.dart';
import '../bloc/animal_event.dart';

class AddAnimalDialog extends StatefulWidget {
  const AddAnimalDialog({super.key});

  @override
  State<AddAnimalDialog> createState() => _AddAnimalDialogState();
}

class _AddAnimalDialogState extends State<AddAnimalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlIotController = TextEditingController();
  final _locationController = TextEditingController();
  final _hearRateController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _birthDateController = TextEditingController();
  
  int _selectedSpecie = 0;
  bool _sex = false; // false = Hembra por defecto
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isLoading = false;

  final List<String> _specieNames = [
    'Vaca',
    'Caballo',
    'Oveja',
    'Cerdo',
    'Cabra',
    'Pollo',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _urlIotController.dispose();
    _locationController.dispose();
    _hearRateController.dispose();
    _temperatureController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) {
          setState(() {
            _selectedImageBytes = reader.result as Uint8List;
            _selectedImageName = file.name;
          });
        });

        reader.readAsArrayBuffer(file);
      }
    });
  }

  DateTime? _parseBirthDate(String value) {
    // Espera formato DD/MM/YYYY
    final parts = value.split('/');
    if (parts.length != 3) return null;
    
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    
    if (day == null || month == null || year == null) return null;
    if (day < 1 || day > 31) return null;
    if (month < 1 || month > 12) return null;
    if (year < 1900 || year > DateTime.now().year) return null;
    
    try {
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      final inventoryId = authState is Authenticated ? authState.user.inventoryId : 1;
      
      // Crear multipart request
      final uri = Uri.parse('${AppConfig.baseUrl}/animals/$inventoryId');
      final request = http.MultipartRequest('POST', uri);
      
      // Agregar headers
      request.headers['Content-Type'] = 'multipart/form-data';
      
      // Agregar campos de texto
      request.fields['name'] = _nameController.text;
      request.fields['specie'] = _selectedSpecie.toString();
      request.fields['urlIot'] = _urlIotController.text;
      request.fields['location'] = _locationController.text;
      request.fields['hearRate'] = _hearRateController.text;
      request.fields['temperature'] = _temperatureController.text;
      request.fields['sex'] = _sex.toString();
      
      // Parsear y convertir birthDate a formato ISO 8601
      final birthDate = _parseBirthDate(_birthDateController.text);
      if (birthDate != null) {
        request.fields['birthDate'] = birthDate.toUtc().toIso8601String();
      }
      
      // Agregar imagen si fue seleccionada
      if (_selectedImageBytes != null && _selectedImageName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _selectedImageBytes!,
            filename: _selectedImageName!,
          ),
        );
      }
      
      // Enviar request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) {
          Navigator.of(context).pop();
          CustomSnackbar.showSuccess(context, 'Animal agregado correctamente');
          
          // Recargar lista de animales
          context.read<AnimalBloc>().add(LoadAnimals(inventoryId));
        }
      } else {
        throw Exception('Error al crear el animal: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(
          context,
          'Error al agregar el animal: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Text('Agregar Nuevo Animal'),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Cerrar',
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Especie
                DropdownButtonFormField<int>(
                  value: _selectedSpecie,
                  decoration: InputDecoration(
                    labelText: 'Especie *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: List.generate(6, (index) {
                    return DropdownMenuItem(
                      value: index,
                      child: Text(_specieNames[index]),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedSpecie = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Fecha de Nacimiento
                TextFormField(
                  controller: _birthDateController,
                  decoration: InputDecoration(
                    labelText: 'Fecha de Nacimiento (DD/MM/YYYY) *',
                    hintText: '18/10/2023',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la fecha de nacimiento';
                    }
                    final date = _parseBirthDate(value);
                    if (date == null) {
                      return 'Formato inválido. Use DD/MM/YYYY';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Sexo
                DropdownButtonFormField<bool>(
                  value: _sex,
                  decoration: InputDecoration(
                    labelText: 'Sexo *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: false,
                      child: Text('Hembra'),
                    ),
                    DropdownMenuItem(
                      value: true,
                      child: Text('Macho'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sex = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Frecuencia cardíaca
                TextFormField(
                  controller: _hearRateController,
                  decoration: InputDecoration(
                    labelText: 'Frecuencia Cardíaca (bpm) *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la frecuencia cardíaca';
                    }
                    final int? rate = int.tryParse(value);
                    if (rate == null || rate < 30 || rate > 150) {
                      return 'Valor debe estar entre 30 y 150 bpm';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Temperatura
                TextFormField(
                  controller: _temperatureController,
                  decoration: InputDecoration(
                    labelText: 'Temperatura (°C) *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la temperatura';
                    }
                    final int? temp = int.tryParse(value);
                    if (temp == null || temp < 30 || temp > 45) {
                      return 'Valor debe estar entre 30 y 45 °C';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Ubicación
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Ubicación (coordenadas) *',
                    hintText: 'Ej: -12.0464, -77.0428',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la ubicación';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // URL IoT
                TextFormField(
                  controller: _urlIotController,
                  decoration: InputDecoration(
                    labelText: 'URL IoT *',
                    hintText: 'https://...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la URL IoT';
                    }
                    if (!value.startsWith('http://') && !value.startsWith('https://')) {
                      return 'La URL debe comenzar con http:// o https://';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Imagen
                const Text(
                  'Foto del Animal (opcional)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: _selectedImageBytes != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle, size: 48, color: Colors.green),
                                      SizedBox(height: 8),
                                      Text('Imagen seleccionada'),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedImageBytes = null;
                                      _selectedImageName = null;
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.all(4),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Toca para seleccionar una imagen'),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
