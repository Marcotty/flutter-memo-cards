import 'package:cloud_firestore/cloud_firestore.dart';

class FullCardModel {
  final String id; // Document ID from Firestore
  final String themeId; // The ID of the parent theme
  final String title;
  final String description;
  final String? userId; // To easily associate with the user

  FullCardModel({
    required this.id,
    required this.themeId,
    required this.title,
    required this.description,
    this.userId,
  });

  factory FullCardModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FullCardModel(
      id: doc.id,
      themeId: data['themeId'] ?? '', // Make sure this is stored in Firestore
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    // When writing, we don't include 'id' as it's the document ID
    return {
      'themeId': themeId,
      'title': title,
      'description': description,
      'userId': userId,
      'createdAt':
          FieldValue.serverTimestamp(), // Optional: for ordering/tracking
    };
  }

  // Helper for updates if you need to modify an existing object
  FullCardModel copyWith({
    String? id,
    String? themeId,
    String? title,
    String? description,
    String? userId,
  }) {
    return FullCardModel(
      id: id ?? this.id,
      themeId: themeId ?? this.themeId,
      title: title ?? this.title,
      description: description ?? this.description,
      userId: userId ?? this.userId,
    );
  }
}

class ThemeModel {
  final String id; // Document ID from Firestore
  final String name; // The String you mentioned for Theme
  final String? userId; // To easily associate with the user
  ThemeModel({required this.id, required this.name, this.userId});
  factory ThemeModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ThemeModel(
      id: doc.id,
      name: data['name'] ?? '',
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    // When writing, we don't include 'id' as it's the document ID
    return {
      'name': name,
      'userId': userId,
      'createdAt':
          FieldValue.serverTimestamp(), // Optional: for ordering/tracking
    };
  }

  // Helper for updates if you need to modify an existing object
  ThemeModel copyWith({String? id, String? name, String? userId}) {
    return ThemeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
    );
  }
}
