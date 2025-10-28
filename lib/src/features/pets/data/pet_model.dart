// lib/src/features/pets/data/pet_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'pet_model.g.dart';

@JsonSerializable()
class Pet {
  final String id;
  final String name;
  final String type;
  final String? age;
  final String? image;
  // ... outros campos

  Pet({
    required this.id,
    required this.name,
    required this.type,
    this.age,
    this.image,
  });

  factory Pet.fromJson(Map<String, dynamic> json) => _$PetFromJson(json);

  Map<String, dynamic> toJson() => _$PetToJson(this);
}