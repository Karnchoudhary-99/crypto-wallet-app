/// A custom 128-word list used for demo seed phrases.
///
/// This is NOT the BIP-39 wordlist, and phrases built from it are NOT
/// BIP-39 mnemonics: they cannot be imported into a real wallet. The list
/// is deliberately small and self-contained so the package stays
/// dependency-light and the phrase format stays easy to test. Demo only:
/// never use these phrases to hold real funds.
const List<String> kWordlist = [
  // Fruits and food.
  'apple', 'banana', 'cherry', 'mango', 'lemon', 'grape', 'peach', 'pear',
  'plum', 'melon', 'kiwi', 'berry', 'fig', 'date', 'olive', 'lime',
  // Landscapes and weather.
  'river', 'ocean', 'mountain', 'valley', 'forest', 'desert', 'island',
  'beach', 'stone', 'cloud', 'storm', 'thunder', 'snow', 'rain', 'wind',
  'leaf',
  // Animals.
  'tiger', 'lion', 'eagle', 'wolf', 'bear', 'fox', 'deer', 'horse',
  'rabbit', 'mouse', 'snake', 'shark', 'whale', 'dolphin', 'monkey',
  'panda',
  // Colours and materials.
  'red', 'blue', 'green', 'yellow', 'purple', 'orange', 'silver', 'golden',
  'copper', 'iron', 'marble', 'crystal', 'amber', 'coral', 'ivory',
  'scarlet',
  // Places and buildings.
  'book', 'pen', 'paper', 'table', 'chair', 'window', 'door', 'bridge',
  'tower', 'castle', 'garden', 'market', 'school', 'library', 'museum',
  'theater',
  // Qualities.
  'happy', 'brave', 'calm', 'swift', 'gentle', 'loyal', 'honest', 'quiet',
  'clever', 'strong', 'kind', 'warm', 'soft', 'bright', 'sharp', 'quick',
  // Directions and times.
  'north', 'south', 'east', 'west', 'spring', 'summer', 'autumn', 'winter',
  'morning', 'evening', 'night', 'dawn', 'dusk', 'noon', 'midnight',
  'horizon',
  // Music.
  'guitar', 'piano', 'drum', 'flute', 'harp', 'trumpet', 'cello', 'banjo',
  'organ', 'choir', 'melody', 'rhythm', 'harmony', 'song', 'dance',
  'concert',
];
