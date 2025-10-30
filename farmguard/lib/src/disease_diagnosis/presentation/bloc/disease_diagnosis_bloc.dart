import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_disease_diagnosis_by_medical_history.dart';
import '../../domain/usecases/create_disease_diagnosis.dart';
import '../../domain/usecases/delete_disease_diagnosis.dart';
import 'disease_diagnosis_event.dart';
import 'disease_diagnosis_state.dart';

class DiseaseDiagnosisBloc extends Bloc<DiseaseDiagnosisEvent, DiseaseDiagnosisState> {
  final GetDiseaseDiagnosisByMedicalHistory getDiseaseDiagnosisByMedicalHistory;
  final CreateDiseaseDiagnosis createDiseaseDiagnosis;
  final DeleteDiseaseDiagnosis deleteDiseaseDiagnosis;

  DiseaseDiagnosisBloc({
    required this.getDiseaseDiagnosisByMedicalHistory,
    required this.createDiseaseDiagnosis,
    required this.deleteDiseaseDiagnosis,
  }) : super(DiseaseDiagnosisInitial()) {
    on<LoadDiseaseDiagnoses>(_onLoadDiseaseDiagnoses);
    on<CreateDiseaseDiagnosisEvent>(_onCreateDiseaseDiagnosis);
    on<DeleteDiseaseDiagnosisEvent>(_onDeleteDiseaseDiagnosis);
  }

  Future<void> _onLoadDiseaseDiagnoses(
    LoadDiseaseDiagnoses event,
    Emitter<DiseaseDiagnosisState> emit,
  ) async {
    emit(DiseaseDiagnosisLoading());

    final result = await getDiseaseDiagnosisByMedicalHistory(event.medicalHistoryId);

    result.fold(
      (failure) => emit(DiseaseDiagnosisError(failure.message)),
      (diagnoses) => emit(DiseaseDiagnosisLoaded(
        diagnoses: diagnoses,
        medicalHistoryId: event.medicalHistoryId,
      )),
    );
  }

  Future<void> _onCreateDiseaseDiagnosis(
    CreateDiseaseDiagnosisEvent event,
    Emitter<DiseaseDiagnosisState> emit,
  ) async {
    emit(DiseaseDiagnosisCreating());

    final result = await createDiseaseDiagnosis(
      medicalHistoryId: event.medicalHistoryId,
      severity: event.severity,
      notes: event.notes,
      diagnosedAt: event.diagnosedAt,
    );

    result.fold(
      (failure) => emit(DiseaseDiagnosisError(failure.message)),
      (diagnosis) {
        emit(DiseaseDiagnosisCreated(diagnosis));
        // Recargar la lista de diagnósticos
        add(LoadDiseaseDiagnoses(event.medicalHistoryId));
      },
    );
  }

  Future<void> _onDeleteDiseaseDiagnosis(
    DeleteDiseaseDiagnosisEvent event,
    Emitter<DiseaseDiagnosisState> emit,
  ) async {
    // Guardar el estado actual para recargar después
    final currentState = state;
    
    final result = await deleteDiseaseDiagnosis(event.id);

    result.fold(
      (failure) => emit(DiseaseDiagnosisError(failure.message)),
      (_) {
        // Recargar la lista de diagnósticos si teníamos un estado cargado
        if (currentState is DiseaseDiagnosisLoaded) {
          add(LoadDiseaseDiagnoses(currentState.medicalHistoryId));
        }
      },
    );
  }
}
