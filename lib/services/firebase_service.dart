import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/movie_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- AUTHENTICATION ---
  Future<User?> login(String email, String password) async {
    UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user;
  }

  Future<User?> register(String email, String password, String name) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user?.updateDisplayName(name);
    return cred.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // --- FIRESTORE: PROFILE ---
  Future<String?> uploadProfilePicture(XFile file) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final ref = FirebaseStorage.instance.ref().child('profile_pictures').child('${user.uid}.jpg');
      
      if (kIsWeb) {
        await ref.putData(await file.readAsBytes(), SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(File(file.path));
      }
      
      final url = await ref.getDownloadURL();
      await user.updatePhotoURL(url);
      return url;
    } catch (e) {
      debugPrint("Error upload gambar: $e");
      return null;
    }
  }

  // --- FIRESTORE: MY LIST ---
  Future<void> toggleMovie(Movie movie, String listType) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _db.collection('users').doc(user.uid).collection(listType).doc(movie.id.toString());
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      await docRef.delete(); // Jika sudah ada, hapus (Un-save)
    } else {
      await docRef.set(movie.toMap()); // Jika belum ada, simpan
    }
  }

  Stream<List<Movie>> getSavedMovies(String listType) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    
    return _db.collection('users').doc(user.uid).collection(listType)
        .orderBy('saved_at', descending: true)
        .snapshots().map((snap) => snap.docs.map((doc) => Movie.fromMap(doc.data())).toList());
  }

  // --- FIRESTORE: REVIEWS ---
  Future<void> addReview(int movieId, String reviewText, double rating) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('movies').doc(movieId.toString()).collection('reviews').add({
      'userId': user.uid,
      'userName': user.displayName ?? 'User',
      'userPic': user.photoURL ?? '',
      'review': reviewText,
      'rating': rating,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getReviews(int movieId) {
    return _db.collection('movies').doc(movieId.toString()).collection('reviews')
        .orderBy('timestamp', descending: true).snapshots();
  }
}