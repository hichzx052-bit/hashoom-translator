class VoiceOption {
  final String id;
  final String name;
  final String language;
  final String gender;
  final double pitch;
  final double rate;

  const VoiceOption({
    required this.id,
    required this.name,
    required this.language,
    this.gender = 'male',
    this.pitch = 1.0,
    this.rate = 0.5,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'language': language,
    'gender': gender,
    'pitch': pitch,
    'rate': rate,
  };

  factory VoiceOption.fromJson(Map<String, dynamic> json) => VoiceOption(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    language: json['language'] ?? '',
    gender: json['gender'] ?? 'male',
    pitch: (json['pitch'] ?? 1.0).toDouble(),
    rate: (json['rate'] ?? 0.5).toDouble(),
  );
}
