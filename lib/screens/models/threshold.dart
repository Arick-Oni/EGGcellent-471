class Threshold {
  final double temp;
  final double ldr;

  Threshold({required this.temp, required this.ldr});

  Map<String, dynamic> toJson() => {
        'temp': temp,
        'ldr': ldr,
      };

  factory Threshold.fromJson(Map<String, dynamic> json) => Threshold(
        temp: (json['temp'] ?? 0.0).toDouble(),
        ldr: (json['ldr'] ?? 0.0).toDouble(),
      );
}
