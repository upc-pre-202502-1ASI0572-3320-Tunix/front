import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_vaccines_by_medical_history.dart';
import '../../domain/usecases/create_vaccine.dart';
import '../../domain/usecases/delete_vaccine.dart';
import 'vaccine_event.dart';
import 'vaccine_state.dart';

class VaccineBloc extends Bloc<VaccineEvent, VaccineState> {
  final GetVaccinesByMedicalHistory getVaccinesByMedicalHistory;
  final CreateVaccine createVaccine;
  final DeleteVaccine deleteVaccine;

  VaccineBloc({
    required this.getVaccinesByMedicalHistory,
    required this.createVaccine,
    required this.deleteVaccine,
  }) : super(VaccineInitial()) {
    on<LoadVaccines>(_onLoadVaccines);
    on<CreateVaccineEvent>(_onCreateVaccine);
    on<DeleteVaccineEvent>(_onDeleteVaccine);
  }

  Future<void> _onLoadVaccines(
    LoadVaccines event,
    Emitter<VaccineState> emit,
  ) async {
    emit(VaccineLoading());

    final result = await getVaccinesByMedicalHistory(event.medicalHistoryId);

    result.fold(
      (failure) => emit(VaccineError(failure.message)),
      (vaccines) => emit(VaccineLoaded(
        vaccines: vaccines,
        medicalHistoryId: event.medicalHistoryId,
      )),
    );
  }

  Future<void> _onCreateVaccine(
    CreateVaccineEvent event,
    Emitter<VaccineState> emit,
  ) async {
    emit(VaccineCreating());

    final result = await createVaccine(
      medicalHistoryId: event.medicalHistoryId,
      name: event.name,
      manufacturer: event.manufacturer,
      schema: event.schema,
    );

    result.fold(
      (failure) => emit(VaccineError(failure.message)),
      (vaccine) {
        emit(VaccineCreated(vaccine));
        // Recargar la lista de vacunas
        add(LoadVaccines(event.medicalHistoryId));
      },
    );
  }

  Future<void> _onDeleteVaccine(
    DeleteVaccineEvent event,
    Emitter<VaccineState> emit,
  ) async {
    emit(VaccineDeleting());

    final result = await deleteVaccine(event.vaccineId);

    result.fold(
      (failure) => emit(VaccineError(failure.message)),
      (_) {
        emit(VaccineDeleted());
        // Recargar la lista de vacunas
        add(LoadVaccines(event.medicalHistoryId));
      },
    );
  }
}
