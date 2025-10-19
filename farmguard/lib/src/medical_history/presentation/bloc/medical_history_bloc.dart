import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_medical_history_by_animal.dart';
import 'medical_history_event.dart';
import 'medical_history_state.dart';

class MedicalHistoryBloc extends Bloc<MedicalHistoryEvent, MedicalHistoryState> {
  final GetMedicalHistoryByAnimal getMedicalHistoryByAnimal;

  MedicalHistoryBloc({
    required this.getMedicalHistoryByAnimal,
  }) : super(MedicalHistoryInitial()) {
    on<LoadMedicalHistory>(_onLoadMedicalHistory);
    on<LoadAnimalDetails>(_onLoadAnimalDetails);
  }

  Future<void> _onLoadMedicalHistory(
    LoadMedicalHistory event,
    Emitter<MedicalHistoryState> emit,
  ) async {
    emit(MedicalHistoryLoading());

    final result = await getMedicalHistoryByAnimal(event.animalId);

    result.fold(
      (failure) => emit(MedicalHistoryError(failure.message)),
      (medicalHistory) => emit(MedicalHistoryLoaded(medicalHistory)),
    );
  }
  
  void _onLoadAnimalDetails(
    LoadAnimalDetails event,
    Emitter<MedicalHistoryState> emit,
  ) {
    final currentState = state;
    if (currentState is MedicalHistoryLoaded) {
      emit(MedicalHistoryLoaded(
        currentState.medicalHistory.copyWith(
          animalName: event.animalName,
          animalPhotoUrl: event.animalPhotoUrl,
        ),
      ));
    }
  }
}
