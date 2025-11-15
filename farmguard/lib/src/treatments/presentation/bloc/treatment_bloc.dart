import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_treatments_by_medical_history.dart';
import '../../domain/usecases/create_treatment.dart';
import '../../domain/usecases/delete_treatment.dart';
import 'treatment_event.dart';
import 'treatment_state.dart';

class TreatmentBloc extends Bloc<TreatmentEvent, TreatmentState> {
  final GetTreatmentsByMedicalHistory getTreatmentsByMedicalHistory;
  final CreateTreatment createTreatment;
  final DeleteTreatment deleteTreatment;

  TreatmentBloc({
    required this.getTreatmentsByMedicalHistory,
    required this.createTreatment,
    required this.deleteTreatment,
  }) : super(TreatmentInitial()) {
    on<LoadTreatments>(_onLoadTreatments);
    on<CreateTreatmentEvent>(_onCreateTreatment);
    on<DeleteTreatmentEvent>(_onDeleteTreatment);
  }

  Future<void> _onLoadTreatments(
    LoadTreatments event,
    Emitter<TreatmentState> emit,
  ) async {
    emit(TreatmentLoading());

    final result = await getTreatmentsByMedicalHistory(event.medicalHistoryId);

    result.fold(
      (failure) => emit(TreatmentError(failure.message)),
      (treatments) => emit(TreatmentLoaded(
        treatments: treatments,
        medicalHistoryId: event.medicalHistoryId,
      )),
    );
  }

  Future<void> _onCreateTreatment(
    CreateTreatmentEvent event,
    Emitter<TreatmentState> emit,
  ) async {
    emit(TreatmentCreating());

    final result = await createTreatment(
      medicalHistoryId: event.medicalHistoryId,
      title: event.title,
      notes: event.notes,
      startDate: event.startDate,
      status: event.status,
    );

    result.fold(
      (failure) => emit(TreatmentError(failure.message)),
      (treatment) {
        emit(TreatmentCreated(treatment));
        // Recargar la lista de tratamientos
        add(LoadTreatments(event.medicalHistoryId));
      },
    );
  }

  Future<void> _onDeleteTreatment(
    DeleteTreatmentEvent event,
    Emitter<TreatmentState> emit,
  ) async {
    // Guardar el estado actual para recargar después
    final currentState = state;
    
    final result = await deleteTreatment(event.id);

    result.fold(
      (failure) => emit(TreatmentError(failure.message)),
      (_) {
        // Recargar la lista de tratamientos si teníamos un estado cargado
        if (currentState is TreatmentLoaded) {
          add(LoadTreatments(currentState.medicalHistoryId));
        }
      },
    );
  }
}
