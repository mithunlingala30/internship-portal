import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    }
    return null;
  }

  Future<void> registerWithEmailAndPassword(
      String email, String password, String name, String role) async {
    final UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    final avatarInitials = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    final user = UserModel(
      id: result.user!.uid,
      name: name,
      email: email,
      password: password,
      role: role,
      avatarInitials: avatarInitials,
      completedModules: 0,
      totalModules: 0,
      streakDays: 0,
      overallProgress: 0.0,
    );

    await _db.collection('users').doc(result.user!.uid).set(user.toMap());
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;

    // Re-authenticate user (required for password change)
    final cred = EmailAuthProvider.credential(email: user.email!, password: currentPassword);
    await user.reauthenticateWithCredential(cred);

    // Update Firebase Auth
    await user.updatePassword(newPassword);

    // Update Firestore
    await _db.collection('users').doc(user.uid).update({'password': newPassword});
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
