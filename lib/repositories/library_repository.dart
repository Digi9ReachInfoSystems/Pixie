import 'package:cloud_firestore/cloud_firestore.dart';

class FetchStoryRepository1 {
  final FirebaseFirestore _firestore;

  FetchStoryRepository1({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchStories(
      DocumentReference userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('fav_stories')
          .where('user_ref', isEqualTo: userId)
          .get();

      // Parse the data into a list of maps, including the DocumentReference
      List<Map<String, dynamic>> stories = querySnapshot.docs.map((doc) {
        return {
          'title': doc['title'],
          'story': doc['story'],
          'storytype': doc['storytype'],
          'audiofile': doc['audiofile'],
          'genre': doc['genre'],
          'isfav': doc['isfav'],
          'language': doc['language'],
          'createdTime': doc['createdTime'], // Include the createdTime field
          'reference': doc.reference, // Include the DocumentReference
        };
      }).toList();

      // Sort the stories by 'createdTime', placing null values last
      stories.sort((a, b) {
        final timeA = a['createdTime'] as Timestamp?;
        final timeB = b['createdTime'] as Timestamp?;

        if (timeA == null && timeB == null) return 0; // Both null, equal
        if (timeA == null) return 1; // Place null timeA after timeB
        if (timeB == null) return -1; // Place null timeB after timeA

        return timeB.compareTo(timeA); // Descending order
      });

      return stories;
    } catch (e) {
      throw Exception('Failed to fetch stories: $e');
    }
  }
}
