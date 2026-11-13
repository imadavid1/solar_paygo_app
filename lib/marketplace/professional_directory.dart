import 'marketplace_data.dart';

const allProfessions = 'All professions';
const allLocations = 'All locations';
const professionalAssetRoot = 'assets/images/catalogue/professionals';

class SampleProfessional {
  const SampleProfessional({required this.id, required this.name, required this.profession, required this.location, required this.email, required this.yearsExperience, required this.imageAsset, required this.photoIndex});
  final String id, name, profession, location, email, imageAsset;
  final int yearsExperience, photoIndex;
  bool get isFemale => photoIndex == 2 || photoIndex == 5;
}

const _slugs = [
  'solar-installer', 'electrician', 'carpenter', 'painter', 'plumber',
  'welder', 'bricklayer', 'tiler', 'roofer', 'air-conditioning-technician',
  'generator-technician', 'cctv-installer', 'appliance-repairer',
  'interior-designer', 'gardener', 'auto-electrician', 'mechanic',
  'refrigeration-technician', 'pop-ceiling-installer', 'handyman',
];
const _men = ['James', 'Daniel', 'Michael', 'David', 'Samuel', 'Joseph', 'Thomas', 'Benjamin', 'Peter', 'William'];
const _women = ['Emily', 'Grace', 'Sarah', 'Elizabeth', 'Olivia', 'Charlotte', 'Emma', 'Sophia', 'Lucy', 'Alice'];
const _surnames = ['Smith', 'Wilson', 'Taylor', 'Brown', 'Clark', 'Robinson', 'Walker', 'Hall', 'Lewis', 'Green', 'White', 'Harris', 'Martin', 'King', 'Wright', 'Scott', 'Baker', 'Young', 'Adams', 'Hill'];

List<SampleProfessional> sampleProfessionalsFor(String profession, String location) {
  final trade = professionTypes.indexOf(profession);
  final place = nigeriaLocations.indexOf(location);
  if (trade < 0 || place < 0) throw ArgumentError('Choose a listed profession and Nigerian location.');
  final profiles = List.generate(6, (index) {
    final female = index == 2 || index == 5;
    // Preserve the original four names/experience values while adding two men.
    final nameOffset = index == 5 ? 3 : index == 3 ? 4 : index == 4 ? 5 : index;
    final first = (female ? _women : _men)[(trade + place + nameOffset) % 10];
    final last = _surnames[(trade * 3 + place + nameOffset * 5) % _surnames.length];
    final slug = _slugs[trade];
    final id = '${trade + 1}-${place + 1}-${index + 1}';
    return SampleProfessional(
      id: id, name: '$first $last', profession: profession, location: location,
      email: '${first.toLowerCase()}.${last.toLowerCase()}.$id@example.com',
      yearsExperience: 3 + ((trade * 3 + place + nameOffset * 2) % 14),
      imageAsset: '$professionalAssetRoot/$slug-v2.png', photoIndex: index,
    );
  });
  // A deterministic shuffle varies ordering by trade and state without reshuffling on rebuild.
  var seed = (trade + 1) * 101 + (place + 1) * 37;
  for (var i = profiles.length - 1; i > 0; i--) {
    seed = (seed * 1664525 + 1013904223) & 0x7fffffff;
    final j = seed % (i + 1);
    final value = profiles[i]; profiles[i] = profiles[j]; profiles[j] = value;
  }
  return profiles;
}

class ProfessionalSearchResult {
  const ProfessionalSearchResult({required this.profiles, required this.profession, required this.location, required this.notice, required this.total});
  final List<SampleProfessional> profiles;
  final String profession, location, notice;
  final int total;
  String get title => '${profession == allProfessions ? 'Professionals' : '$profession professionals'}${location == allLocations ? ' across Nigeria' : ' in $location'}';
}

String _normal(String text) => text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
bool _phrase(String text, String phrase) => ' $text '.contains(' $phrase ');

const _extraAliases = <String, List<String>>{
  'Solar Installer': ['solar', 'solar installation', 'solar installers', 'solar panel installer', 'solar panel installers'],
  'Electrician': ['electricians', 'electrical', 'electrical technician'],
  'Carpenter': ['carpenters', 'carpentry'],
  'Painter': ['painters', 'painting', 'decorator'],
  'Plumber': ['plumbers', 'plumbing'],
  'Welder': ['welders', 'welding'],
  'Bricklayer': ['bricklayers', 'bricklaying', 'mason'],
  'Tiler': ['tilers', 'tiling'],
  'Roofer': ['roofers', 'roofing'],
  'Air-conditioning Technician': ['air conditioning', 'air conditioner', 'ac technician', 'hvac'],
  'Generator Technician': ['generator', 'generator repair'],
  'CCTV Installer': ['cctv', 'security camera', 'cctv installers'],
  'Appliance Repairer': ['appliance repair', 'appliances'],
  'Interior Designer': ['interior design', 'interior designers'],
  'Gardener': ['gardeners', 'gardening', 'landscaper'],
  'Auto Electrician': ['auto electricians', 'car electrician', 'auto electrical'],
  'Mechanic': ['mechanics', 'car mechanic', 'automotive mechanic'],
  'Refrigeration Technician': ['refrigeration', 'fridge repair', 'refrigerator repair'],
  'POP Ceiling Installer': ['pop', 'pop ceiling', 'ceiling installer', 'ceiling installers'],
  'Handyman': ['handymen', 'general repairs'],
};

int _distance(String a, String b) {
  var row = List.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final next = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final values = [next[j - 1] + 1, row[j] + 1, row[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1)];
      next[j] = values.reduce((x, y) => x < y ? x : y);
    }
    row = next;
  }
  return row.last;
}

ProfessionalSearchResult searchSampleProfessionals({required String profession, required String location, String query = ''}) {
  var trade = professionTypes.contains(profession) ? profession : allProfessions;
  var place = nigeriaLocations.contains(location) ? location : allLocations;
  var remaining = _normal(query);
  final original = remaining;
  final aliases = <(String, String)>[
    for (final item in professionTypes)
      for (final alias in [item, ...?_extraAliases[item]]) (_normal(alias), item),
  ]..sort((a, b) => b.$1.length.compareTo(a.$1.length));
  for (final alias in aliases) {
    if (_phrase(remaining, alias.$1)) {
      trade = alias.$2;
      remaining = ' $remaining '.replaceAll(' ${alias.$1} ', ' ').trim();
      break;
    }
  }
  final places = <(String, String)>[
    for (final item in nigeriaLocations) (_normal(item), item),
    ('abuja', 'FCT Abuja'), ('fct', 'FCT Abuja'),
  ]..sort((a, b) => b.$1.length.compareTo(a.$1.length));
  for (final alias in places) {
    if (_phrase(remaining, alias.$1)) {
      place = alias.$2;
      remaining = ' $remaining '.replaceAll(' ${alias.$1} ', ' ').trim();
      break;
    }
  }
  remaining = remaining.split(' ').where((word) => !const ['find', 'a', 'an', 'in', 'at', 'near', 'me', 'the', 'state', 'professional', 'professionals', 'please'].contains(word)).join(' ').trim();
  var correction = '';
  if (remaining.isNotEmpty) {
    final closest = aliases.where((a) => a.$1.length >= 5 && (a.$1.length - remaining.length).abs() <= 2).toList()
      ..sort((a, b) => _distance(remaining, a.$1).compareTo(_distance(remaining, b.$1)));
    if (closest.isNotEmpty && _distance(remaining, closest.first.$1) <= 2) {
      trade = closest.first.$2; remaining = ''; correction = 'Showing $trade sample profiles for the typed service.';
    }
  }
  final trades = trade == allProfessions ? professionTypes : [trade];
  final locations = place == allLocations ? nigeriaLocations : [place];
  final candidates = <SampleProfessional>[];
  // Round-robin order presents a mix of trades for location-only searches.
  for (var i = 0; i < 6; i++) {
    for (final location in locations) {
      for (final profession in trades) {
        candidates.add(sampleProfessionalsFor(profession, location)[i]);
      }
    }
  }
  var matches = remaining.isEmpty ? candidates : candidates.where((p) => _normal(p.name).contains(remaining)).toList();
  var notice = correction;
  if (matches.isEmpty) {
    matches = candidates;
    notice = 'No exact name or service match for "$original". Showing sample profiles for the selected profession and location.';
  }
  // Do not display the same illustrative worker photo several times in a broad search.
  final visible = <SampleProfessional>[];
  final photos = <String>{};
  for (final profile in matches) {
    if (photos.add('${profile.imageAsset}/${profile.photoIndex}')) visible.add(profile);
    if (visible.length == 12) break;
  }
  return ProfessionalSearchResult(profiles: visible, profession: trade, location: place, notice: notice, total: matches.length);
}
