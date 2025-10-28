// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pet _$PetFromJson(Map<String, dynamic> json) => Pet(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
  age: json['age'] as String?,
  image: json['image'] as String?,
);

Map<String, dynamic> _$PetToJson(Pet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'age': instance.age,
  'image': instance.image,
};
