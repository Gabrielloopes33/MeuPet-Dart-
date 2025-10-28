import '../../../../core/api/api_service.dart';
import '../pet_model.dart';

class PetRepository {
  final ApiService _apiService;

  PetRepository(this._apiService);

  // PetRepository: com métodos getPets(), createPet(pet), updatePet(id, pet), deletePet(id)
  
  Future<List<Pet>> getPets() async {
    try {
      final response = await _apiService.get('/pets');
      final List<dynamic> petsData = response.data;
      return petsData.map((petJson) => Pet.fromJson(petJson)).toList();
    } catch (e) {
      print('Erro ao buscar pets: $e');
      return [];
    }
  }

  Future<Pet?> createPet(Pet pet) async {
    try {
      final response = await _apiService.post('/pets', data: pet.toJson());
      return Pet.fromJson(response.data);
    } catch (e) {
      print('Erro ao criar pet: $e');
      return null;
    }
  }

  Future<Pet?> updatePet(String id, Pet pet) async {
    try {
      final response = await _apiService.put('/pets/$id', data: pet.toJson());
      return Pet.fromJson(response.data);
    } catch (e) {
      print('Erro ao atualizar pet: $e');
      return null;
    }
  }

  Future<bool> deletePet(String id) async {
    try {
      await _apiService.delete('/pets/$id');
      return true;
    } catch (e) {
      print('Erro ao deletar pet: $e');
      return false;
    }
  }

  Future<Pet?> getPetById(String id) async {
    try {
      final response = await _apiService.get('/pets/$id');
      return Pet.fromJson(response.data);
    } catch (e) {
      print('Erro ao buscar pet por ID: $e');
      return null;
    }
  }
}