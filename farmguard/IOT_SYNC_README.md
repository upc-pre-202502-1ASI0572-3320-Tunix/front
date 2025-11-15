# Sistema de Sincronización IoT para Animales

## Descripción

Este sistema actualiza automáticamente los datos vitales de los animales (frecuencia cardíaca, temperatura y ubicación) mediante consultas periódicas a dispositivos IoT.

## Funcionalidad

### 1. Consulta de Datos IoT
- Cada animal tiene una URL IoT asociada (`urlIot`)
- El sistema realiza una petición GET a esta URL para obtener datos simulados
- La respuesta es una lista de registros con el siguiente formato:

```json
[
  {
    "idAnimal": 1,
    "heartRate": 96,
    "temperature": 32,
    "location": "-23.466133, -51.840034",
    "id": "48a84e57c551790e1caa"
  },
  {
    "idAnimal": 1,
    "heartRate": 96,
    "temperature": 32,
    "location": "-23.466049, -51.839985",
    "id": "1b1e61cb125bae5af023"
  }
]
```

### 2. Rotación de Datos
- El sistema guarda en caché todos los registros obtenidos
- Cada 15 segundos, rota al siguiente registro de la lista
- Al llegar al final, vuelve al principio (rotación circular)
- Esto simula la recepción continua de datos del dispositivo IoT

### 3. Actualización en Tiempo Real
- Los datos se actualizan automáticamente en la UI
- No es necesario refrescar manualmente
- Los cambios son inmediatos y visibles en:
  - Panel de detalle del animal
  - Indicadores de salud (colores según rangos normales)
  - Ubicación en tiempo real

## Arquitectura

### Componentes Principales

1. **IotData (Entity)**
   - Representa un registro de datos IoT
   - Ubicación: `lib/src/animals/domain/entities/iot_data.dart`

2. **IotDataModel (Model)**
   - Implementación del modelo para serialización JSON
   - Ubicación: `lib/src/animals/data/models/iot_data_model.dart`

3. **IotRemoteDataSource**
   - Maneja las peticiones HTTP a la URL IoT
   - Ubicación: `lib/src/animals/data/datasources/iot_remote_data_source.dart`

4. **IotSyncService**
   - Gestiona la sincronización periódica
   - Implementa la lógica de rotación cada 15 segundos
   - Expone un Stream para notificar cambios
   - Ubicación: `lib/src/animals/data/services/iot_sync_service.dart`

5. **AnimalBloc (actualizado)**
   - Integra el servicio de sincronización
   - Maneja eventos de inicio/detención de sincronización
   - Actualiza el estado con los nuevos datos IoT
   - Ubicación: `lib/src/animals/presentation/bloc/animal_bloc.dart`

### Flujo de Datos

```
URL IoT → IotRemoteDataSource → IotSyncService → Stream
                                                    ↓
                                            AnimalBloc → UI
```

## Eventos del BLoC

### StartIotSync
Inicia la sincronización IoT para un animal específico.

```dart
context.read<AnimalBloc>().add(
  StartIotSync(
    animalId: animal.id,
    iotUrl: animal.urlIot,
  ),
);
```

### StopIotSync
Detiene la sincronización activa.

```dart
context.read<AnimalBloc>().add(const StopIotSync());
```

### UpdateAnimalIotData
Actualiza los datos de un animal (disparado automáticamente por el servicio).

```dart
context.read<AnimalBloc>().add(
  UpdateAnimalIotData(
    animalId: animalId,
    heartRate: iotData.heartRate,
    temperature: iotData.temperature.toDouble(),
    location: iotData.location,
  ),
);
```

## Uso en la UI

### AnimalDetailPanel
- Automáticamente inicia la sincronización al mostrar un animal
- Detiene la sincronización al cerrar el panel
- Reinicia la sincronización si cambia el animal seleccionado

```dart
@override
void initState() {
  super.initState();
  _startIotSync();
}

@override
void dispose() {
  context.read<AnimalBloc>().add(const StopIotSync());
  super.dispose();
}
```

## Formulario de Creación

Los campos de frecuencia cardíaca y temperatura ahora son **opcionales** en el formulario de creación:

- Si se dejan vacíos, se usan valores por defecto (70 bpm, 38°C)
- Estos valores serán reemplazados automáticamente por los datos IoT
- El hint text indica que los valores se actualizarán desde IoT

## Consideraciones

1. **Timeout**: Las peticiones HTTP tienen un timeout de 10 segundos
2. **Manejo de Errores**: Si falla la sincronización, se imprime un log pero no se detiene la app
3. **Memoria**: El servicio guarda en caché solo la lista actual de datos
4. **Performance**: Un solo timer activo por animal, se cancela automáticamente al cambiar
5. **Estado**: Los datos actualizados se propagan a todas las vistas (lista y detalle)

## Próximas Mejoras

- [ ] Implementar reconexión automática si falla la petición
- [ ] Agregar indicador visual de sincronización activa
- [ ] Soporte para WebSockets en lugar de polling
- [ ] Gráficos históricos de datos vitales
- [ ] Alertas cuando los valores están fuera de rango normal
