/// Kenya's 47 counties (Constitution of Kenya 2010, First Schedule).
///
/// Must match backend/directory/counties.py exactly: the API stores these display names.
/// County choice is made manually by the user and kept on the device only; HATUA never
/// asks for GPS location.
const nationwide = 'Nationwide';

const kenyanCounties = <String>[
  'Baringo', 'Bomet', 'Bungoma', 'Busia', 'Elgeyo-Marakwet', 'Embu', 'Garissa', 'Homa Bay',
  'Isiolo', 'Kajiado', 'Kakamega', 'Kericho', 'Kiambu', 'Kilifi', 'Kirinyaga', 'Kisii',
  'Kisumu', 'Kitui', 'Kwale', 'Laikipia', 'Lamu', 'Machakos', 'Makueni', 'Mandera',
  'Marsabit', 'Meru', 'Migori', 'Mombasa', "Murang'a", 'Nairobi', 'Nakuru', 'Nandi',
  'Narok', 'Nyamira', 'Nyandarua', 'Nyeri', 'Samburu', 'Siaya', 'Taita-Taveta', 'Tana River',
  'Tharaka-Nithi', 'Trans Nzoia', 'Turkana', 'Uasin Gishu', 'Vihiga', 'Wajir', 'West Pokot',
];

/// A listing for [listingCounty] is relevant to someone who picked [selected]
/// (null = all counties). Nationwide listings are relevant everywhere.
bool countyMatches(String listingCounty, String? selected) =>
    selected == null || listingCounty == selected || listingCounty == nationwide;
