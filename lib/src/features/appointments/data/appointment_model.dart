import 'package:json_annotation/json_annotation.dart';

part 'appointment_model.g.dart';

@JsonSerializable()
class Appointment {
  final String id;
  @JsonKey(name: 'pet_id')
  final String petId;
  @JsonKey(name: 'user_id')
  final String userId;
  final DateTime date;
  final String description;
  final String status;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const Appointment({
    required this.id,
    required this.petId,
    required this.userId,
    required this.date,
    required this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}