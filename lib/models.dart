import 'package:cloud_firestore/cloud_firestore.dart';

class FullCard {
  final String id; // Document ID from Firestore
  final String themeId; // The ID of the parent theme
  final String title;
  final String description;
  final String? userId; // To easily associate with the user

  FullCard({
    required this.id,
    required this.themeId,
    required this.title,
    required this.description,
    this.userId,
  });

  bool get isNotEmpty => title.isNotEmpty && description.isNotEmpty;
}

class Theme {
  final String id;
  final String name;
  final String? userId;

  Theme({required this.id, required this.name, this.userId});
  factory Theme.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return Theme(id: doc.id, name: data['name'] ?? '', userId: data['userId']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'userId': userId,
      'createdAt':
          FieldValue.serverTimestamp(), // Optional: for ordering/tracking
    };
  }
}
