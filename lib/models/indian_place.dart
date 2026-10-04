class IndianPlace {
  final String? name;
  final String? street;
  final String? subLocality;
  final String? subAdministrativeArea;
  final String? locality;
  final String? administrativeArea;
  final String? postalCode;
  final String? country;

  IndianPlace({
    this.name,
    this.street,
    this.subLocality,
    this.subAdministrativeArea,
    this.locality,
    this.administrativeArea,
    this.postalCode,
    this.country,
  });

  String get displayLabel {
    final first = (locality != null && locality!.isNotEmpty) ? locality! : (subAdministrativeArea ?? '');
    final state = administrativeArea ?? '';
    return [first, state].where((e) => e.isNotEmpty).join(', ');
  }
}