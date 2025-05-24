import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<bool> updateUserData(Map<String, dynamic> data) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('users').doc(user.uid).update(data);
      return true;
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getFirmwareInfo() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('firmware').doc('latest').get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting firmware info: $e');
      return null;
    }
  }

  Future<bool> logYogaSession(Map<String, dynamic> sessionData) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      await _firestore.collection('users').doc(user.uid).collection('sessions').add({
        ...sessionData,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error logging yoga session: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getSoundTracks() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('sounds').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting sound tracks: $e');
      return [];
    }
  }
}
