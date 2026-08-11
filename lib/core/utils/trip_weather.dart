class TripWeatherInfo {
  final String condition;
  final int celsius;
  final String iconName;

  const TripWeatherInfo({
    required this.condition,
    required this.celsius,
    required this.iconName,
  });
}

class TripWeather {
  TripWeather._();

  static TripWeatherInfo forDestination(String destination) {
    final hash = destination.trim().toLowerCase().hashCode.abs();
    const data = [
      ('Sunny', 28, 'sunny'),
      ('Partly cloudy', 24, 'partly'),
      ('Light rain', 19, 'rain'),
      ('Clear sky', 26, 'clear'),
      ('Warm & breezy', 22, 'breeze'),
    ];
    final item = data[hash % data.length];
    final tempOffset = hash % 8;
    return TripWeatherInfo(
      condition: item.$1,
      celsius: item.$2 + tempOffset - 4,
      iconName: item.$3,
    );
  }
}
