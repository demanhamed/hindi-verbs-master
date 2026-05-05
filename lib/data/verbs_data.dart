import '../../models/verb_model.dart';

/// Raw data for all 100 Hindi verbs.
/// Each entry maps to the ordered list from the source material.
final List<Map<String, dynamic>> verbsRawData = [
  // 1-10
  {
    'hindi': 'लेना',
    'romanized': 'Lenā',
    'english': 'to take',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'देना',
    'romanized': 'Denā',
    'english': 'to give',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'खाना',
    'romanized': 'Khānā',
    'english': 'to eat',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'पीना',
    'romanized': 'Pīnā',
    'english': 'to drink',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'पूछना',
    'romanized': 'Pūchnā',
    'english': 'to ask',
    'cat': VerbCategory.communication
  },
  {
    'hindi': 'बोलना',
    'romanized': 'Bolnā',
    'english': 'to speak',
    'cat': VerbCategory.communication
  },
  {
    'hindi': 'सुनना',
    'romanized': 'Sunnā',
    'english': 'to listen',
    'cat': VerbCategory.communication
  },
  {
    'hindi': 'देखना',
    'romanized': 'Dekhnā',
    'english': 'to see / watch',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'चलना',
    'romanized': 'Chalnā',
    'english': 'to walk',
    'cat': VerbCategory.movement
  },
  {
    'hindi': 'दौड़ना',
    'romanized': 'Dauṛnā',
    'english': 'to run',
    'cat': VerbCategory.movement
  },
  // 11-20
  {
    'hindi': 'बैठना',
    'romanized': 'Baiṭhnā',
    'english': 'to sit',
    'cat': VerbCategory.movement
  },
  {
    'hindi': 'खड़ा होना',
    'romanized': 'Khaṛā honā',
    'english': 'to stand',
    'cat': VerbCategory.movement
  },
  {
    'hindi': 'सोना',
    'romanized': 'Sonā',
    'english': 'to sleep',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'जागना',
    'romanized': 'Jāgnā',
    'english': 'to wake up',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'पढ़ना',
    'romanized': 'Paṛhnā',
    'english': 'to read / study',
    'cat': VerbCategory.cognition
  },
  {
    'hindi': 'लिखना',
    'romanized': 'Likhnā',
    'english': 'to write',
    'cat': VerbCategory.cognition
  },
  {
    'hindi': 'सीखना',
    'romanized': 'Sīkhnā',
    'english': 'to learn',
    'cat': VerbCategory.cognition
  },
  {
    'hindi': 'सिखाना',
    'romanized': 'Sikhānā',
    'english': 'to teach',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'खेलना',
    'romanized': 'Khelnā',
    'english': 'to play',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'गाना',
    'romanized': 'Gānā',
    'english': 'to sing',
    'cat': VerbCategory.emotion
  },
  // 21-30
  {
    'hindi': 'नाचना',
    'romanized': 'Nāchnā',
    'english': 'to dance',
    'cat': VerbCategory.emotion
  },
  {
    'hindi': 'हँसना',
    'romanized': 'Hansnā',
    'english': 'to laugh',
    'cat': VerbCategory.emotion
  },
  {
    'hindi': 'रोना',
    'romanized': 'Ronā',
    'english': 'to cry',
    'cat': VerbCategory.emotion
  },
  {
    'hindi': 'मुस्कुराना',
    'romanized': 'Muskurānā',
    'english': 'to smile',
    'cat': VerbCategory.emotion
  },
  {
    'hindi': 'काम करना',
    'romanized': 'Kām karnā',
    'english': 'to work',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'बनाना',
    'romanized': 'Banānā',
    'english': 'to make / create',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'करना',
    'romanized': 'Karnā',
    'english': 'to do',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'खोलना',
    'romanized': 'Kholnā',
    'english': 'to open',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'बंद करना',
    'romanized': 'Band karnā',
    'english': 'to close',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'धोना',
    'romanized': 'Dhonā',
    'english': 'to wash',
    'cat': VerbCategory.physical
  },
  // 31-40
  {
    'hindi': 'साफ करना',
    'romanized': 'Sāf karnā',
    'english': 'to clean',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'पकाना',
    'romanized': 'Pakānā',
    'english': 'to cook',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'काटना',
    'romanized': 'Kāṭnā',
    'english': 'to cut',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'खरीदना',
    'romanized': 'Kharīdnā',
    'english': 'to buy',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'बेचना',
    'romanized': 'Becnā',
    'english': 'to sell',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'भेजना',
    'romanized': 'Bhejnā',
    'english': 'to send',
    'cat': VerbCategory.communication
  },
  {
    'hindi': 'लाना',
    'romanized': 'Lānā',
    'english': 'to bring',
    'cat': VerbCategory.movement
  },
  {
    'hindi': 'जाना',
    'romanized': 'Jānā',
    'english': 'to go',
    'cat': VerbCategory.movement
  },
  {
    'hindi': 'आना',
    'romanized': 'Ānā',
    'english': 'to come',
    'cat': VerbCategory.movement
  },
  {
    'hindi': 'मिलना',
    'romanized': 'Milnā',
    'english': 'to meet',
    'cat': VerbCategory.social
  },
  // 41-50
  {
    'hindi': 'ढूँढना',
    'romanized': 'Ḍhūṁḍhnā',
    'english': 'to search',
    'cat': VerbCategory.cognition
  },
  {
    'hindi': 'पाना',
    'romanized': 'Pānā',
    'english': 'to get / find',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'रखना',
    'romanized': 'Rakhnā',
    'english': 'to keep / place',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'उठाना',
    'romanized': 'Uṭhānā',
    'english': 'to lift / pick up',
    'cat': VerbCategory.movement
  },
  {
    'hindi': 'गिरना',
    'romanized': 'Girnā',
    'english': 'to fall',
    'cat': VerbCategory.movement
  },
  {
    'hindi': 'उठना',
    'romanized': 'Uṭhnā',
    'english': 'to rise / get up',
    'cat': VerbCategory.movement
  },
  {
    'hindi': 'चलाना',
    'romanized': 'Chalānā',
    'english': 'to drive',
    'cat': VerbCategory.movement
  },
  {
    'hindi': 'रोकना',
    'romanized': 'Roknā',
    'english': 'to stop',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'शुरू करना',
    'romanized': 'Shurū karnā',
    'english': 'to start',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'खत्म करना',
    'romanized': 'Khatm karnā',
    'english': 'to finish',
    'cat': VerbCategory.physical
  },
  // 51-60
  {
    'hindi': 'सोचना',
    'romanized': 'Sochnā',
    'english': 'to think',
    'cat': VerbCategory.cognition
  },
  {
    'hindi': 'समझना',
    'romanized': 'Samajhnā',
    'english': 'to understand',
    'cat': VerbCategory.cognition
  },
  {
    'hindi': 'जानना',
    'romanized': 'Jānnā',
    'english': 'to know',
    'cat': VerbCategory.cognition
  },
  {
    'hindi': 'पहचानना',
    'romanized': 'Pahachānnā',
    'english': 'to recognize',
    'cat': VerbCategory.cognition
  },
  {
    'hindi': 'याद करना',
    'romanized': 'Yād karnā',
    'english': 'to remember',
    'cat': VerbCategory.cognition
  },
  {
    'hindi': 'भूलना',
    'romanized': 'Bhūlnā',
    'english': 'to forget',
    'cat': VerbCategory.cognition
  },
  {
    'hindi': 'चाहना',
    'romanized': 'Chāhnā',
    'english': 'to want',
    'cat': VerbCategory.emotion
  },
  {
    'hindi': 'पसंद करना',
    'romanized': 'Pasand karnā',
    'english': 'to like',
    'cat': VerbCategory.emotion
  },
  {
    'hindi': 'नापसंद करना',
    'romanized': 'Nāpasand karnā',
    'english': 'to dislike',
    'cat': VerbCategory.emotion
  },
  {
    'hindi': 'प्यार करना',
    'romanized': 'Pyār karnā',
    'english': 'to love',
    'cat': VerbCategory.emotion
  },
  // 61-70
  {
    'hindi': 'नफरत करना',
    'romanized': 'Nafrat karnā',
    'english': 'to hate',
    'cat': VerbCategory.emotion
  },
  {
    'hindi': 'डरना',
    'romanized': 'Ḍarnā',
    'english': 'to fear',
    'cat': VerbCategory.emotion
  },
  {
    'hindi': 'कोशिश करना',
    'romanized': 'Koshish karnā',
    'english': 'to try',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'जीतना',
    'romanized': 'Jītnā',
    'english': 'to win',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'हारना',
    'romanized': 'Hārnā',
    'english': 'to lose',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'इंतज़ार करना',
    'romanized': 'Intazār karnā',
    'english': 'to wait',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'मदद करना',
    'romanized': 'Madad karnā',
    'english': 'to help',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'पकड़ना',
    'romanized': 'Pakaṛnā',
    'english': 'to catch / hold',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'छोड़ना',
    'romanized': 'Choṛnā',
    'english': 'to leave / release',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'तोड़ना',
    'romanized': 'Toṛnā',
    'english': 'to break',
    'cat': VerbCategory.physical
  },
  // 71-80
  {
    'hindi': 'बनना',
    'romanized': 'Bannā',
    'english': 'to become',
    'cat': VerbCategory.cognition
  },
  {
    'hindi': 'रहना',
    'romanized': 'Rahnā',
    'english': 'to live / stay',
    'cat': VerbCategory.movement
  },
  {
    'hindi': 'मरना',
    'romanized': 'Marnā',
    'english': 'to die',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'जन्म लेना',
    'romanized': 'Janm lenā',
    'english': 'to be born',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'बदलना',
    'romanized': 'Badalnā',
    'english': 'to change',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'सुधारना',
    'romanized': 'Sudhārnā',
    'english': 'to improve / fix',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'बिगाड़ना',
    'romanized': 'Bigāṛnā',
    'english': 'to spoil / damage',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'चलाना',
    'romanized': 'Chalānā',
    'english': 'to operate / use',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'पहनना',
    'romanized': 'Pahannā',
    'english': 'to wear',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'उतारना',
    'romanized': 'Utārnā',
    'english': 'to remove / take off',
    'cat': VerbCategory.physical
  },
  // 81-90
  {
    'hindi': 'सजाना',
    'romanized': 'Sajānā',
    'english': 'to decorate',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'भेजना',
    'romanized': 'Bhejnā',
    'english': 'to deliver',
    'cat': VerbCategory.communication
  },
  {
    'hindi': 'बुलाना',
    'romanized': 'Bulānā',
    'english': 'to call / invite',
    'cat': VerbCategory.communication
  },
  {
    'hindi': 'चिल्लाना',
    'romanized': 'Chillānā',
    'english': 'to shout',
    'cat': VerbCategory.communication
  },
  {
    'hindi': 'बताना',
    'romanized': 'Batānā',
    'english': 'to tell / inform',
    'cat': VerbCategory.communication
  },
  {
    'hindi': 'दिखाना',
    'romanized': 'Dikhānā',
    'english': 'to show',
    'cat': VerbCategory.communication
  },
  {
    'hindi': 'पूछना',
    'romanized': 'Pūchnā',
    'english': 'to question',
    'cat': VerbCategory.communication
  },
  {
    'hindi': 'जवाब देना',
    'romanized': 'Jawāb denā',
    'english': 'to answer',
    'cat': VerbCategory.communication
  },
  {
    'hindi': 'मानना',
    'romanized': 'Mānnā',
    'english': 'to agree / believe',
    'cat': VerbCategory.cognition
  },
  {
    'hindi': 'इंकार करना',
    'romanized': 'Inkār karnā',
    'english': 'to refuse / deny',
    'cat': VerbCategory.social
  },
  // 91-100
  {
    'hindi': 'शुरू होना',
    'romanized': 'Shurū honā',
    'english': 'to begin',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'खत्म होना',
    'romanized': 'Khatm honā',
    'english': 'to end',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'घूमना',
    'romanized': 'Ghūmnā',
    'english': 'to travel / roam',
    'cat': VerbCategory.movement
  },
  {
    'hindi': 'रहना',
    'romanized': 'Rahnā',
    'english': 'to stay',
    'cat': VerbCategory.movement
  },
  {
    'hindi': 'सोचना',
    'romanized': 'Sochnā',
    'english': 'to consider',
    'cat': VerbCategory.cognition
  },
  {
    'hindi': 'कोशिश करना',
    'romanized': 'Koshish karnā',
    'english': 'to attempt',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'जीतना',
    'romanized': 'Jītnā',
    'english': 'to succeed',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'हारना',
    'romanized': 'Hārnā',
    'english': 'to fail',
    'cat': VerbCategory.social
  },
  {
    'hindi': 'करना',
    'romanized': 'Karnā',
    'english': 'to perform / do',
    'cat': VerbCategory.physical
  },
  {
    'hindi': 'होना',
    'romanized': 'Honā',
    'english': 'to be / exist',
    'cat': VerbCategory.cognition
  },
];

List<VerbModel> buildVerbList() {
  return verbsRawData.asMap().entries.map((entry) {
    final id = entry.key + 1;
    final d = entry.value;
    return VerbModel(
      id: id,
      hindi: d['hindi'] as String,
      romanized: d['romanized'] as String,
      english: d['english'] as String,
      category: d['cat'] as VerbCategory,
    );
  }).toList();
}
