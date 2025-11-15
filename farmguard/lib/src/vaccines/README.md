# Módulo de Vacunas

Este módulo gestiona las vacunas asociadas a los historiales médicos de los animales.

## Estructura

```
vaccines/
├── domain/
│   ├── entities/
│   │   └── vaccine.dart          # Entidad Vaccine
│   ├── repositories/
│   │   └── vaccine_repository.dart
│   └── usecases/
│       └── get_vaccines_by_medical_history.dart
├── data/
│   ├── models/
│   │   └── vaccine_model.dart    # Modelo de datos con serialización JSON
│   ├── datasources/
│   │   └── vaccine_remote_data_source.dart
│   └── repositories/
│       └── vaccine_repository_impl.dart
├── presentation/
│   ├── bloc/
│   │   ├── vaccine_bloc.dart
│   │   ├── vaccine_event.dart
│   │   └── vaccine_state.dart
│   └── widgets/
│       └── vaccines_list.dart    # Widget para mostrar lista de vacunas
└── vaccines.dart                 # Barrel file
```

## Endpoint

**GET** `/api/v1/vaccines/by-medicalhistory/{medicalHistoryId}`

### Respuesta
```json
[
  {
    "id": 1,
    "name": "PARACETAMOS",
    "manufacturer": "7172731JJSD",
    "schema": "LALSDASND",
    "medicalHistoryId": 1,
    "medicalHistory": null
  }
]
```

## Uso

### Cargar vacunas por historial médico

```dart
// En un widget
BlocProvider(
  create: (context) => VaccineBloc(
    getVaccinesByMedicalHistory: GetVaccinesByMedicalHistory(
      VaccineRepositoryImpl(
        remoteDataSource: VaccineRemoteDataSourceImpl(
          apiClient: ApiClient(),
        ),
      ),
    ),
  ),
  child: VaccinesList(medicalHistoryId: medicalHistoryId),
)
```

### Estados del BLoC

- **VaccineInitial**: Estado inicial
- **VaccineLoading**: Cargando vacunas desde el API
- **VaccineLoaded**: Vacunas cargadas exitosamente
- **VaccineError**: Error al cargar vacunas

## Integración

Este módulo está integrado en `clinical_history_screen.dart` dentro de la pestaña de "Vacunas".
