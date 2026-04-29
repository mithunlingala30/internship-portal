import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // users
  Stream<UserModel?> getUserModel(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) =>
        snap.exists ? UserModel.fromMap(snap.data()!, snap.id) : null);
  }

  // individual user (future)
  Future<UserModel?> getUserFuture(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    return snap.exists ? UserModel.fromMap(snap.data()!, snap.id) : null;
  }

  Future<void> updateUserModel(UserModel user) async {
    await _db.collection('users').doc(user.id).update(user.toMap());
  }

  Future<void> updateUserFcmToken(String uid, String token) async {
    await _db.collection('users').doc(uid).update({'fcmToken': token});
  }

  Stream<List<CourseModel>> get courses {
    return _db.collection('courses').snapshots().map((snap) => snap.docs
        .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Stream<List<CourseModel>> getMentorCourses(String mentorId) {
    return _db.collection('courses')
        .where('mentorId', isEqualTo: mentorId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<CourseModel?> getCourse(String courseId) {
    return _db.collection('courses').doc(courseId).snapshots().map((snap) =>
        snap.exists ? CourseModel.fromMap(snap.data()!, snap.id) : null);
  }

  Future<void> createCourse(CourseModel course) async {
    final docRef = _db.collection('courses').doc();
    
    // Generate course code
    final firstLetter = course.title.isNotEmpty ? course.title[0].toUpperCase() : 'C';
    final existingQuery = await _db.collection('courses')
        .where('courseCode', isGreaterThanOrEqualTo: firstLetter)
        .where('courseCode', isLessThan: String.fromCharCode(firstLetter.codeUnitAt(0) + 1))
        .get();
        
    final count = existingQuery.docs.length + 1;
    final courseCode = '$firstLetter${count.toString().padLeft(2, '0')}';

    final courseWithDate = CourseModel(
      id: docRef.id,
      courseCode: courseCode,
      title: course.title,
      instructor: course.instructor,
      duration: course.duration,
      totalLessons: course.totalLessons,
      completedLessons: course.completedLessons,
      rating: course.rating,
      category: course.category,
      difficulty: course.difficulty,
      isEnrolled: course.isEnrolled,
      gradientIndex: course.gradientIndex,
      lessons: course.lessons,
      liveSessions: course.liveSessions,
      enrolledStudentIds: course.enrolledStudentIds,
      enrollmentPendingIds: course.enrollmentPendingIds,
      mentorId: course.mentorId,
      status: course.status,
      createdAt: DateTime.now(),
    );
    await docRef.set(courseWithDate.toMap());
  }

  Future<void> updateCourse(CourseModel course) async {
    await _db.collection('courses').doc(course.id).update(course.toMap());
  }
  
  Future<void> deleteCourse(String courseId) async {
    await _db.collection('courses').doc(courseId).delete();
  }

  Future<void> finishCourse(String courseId) async {
    await _db.collection('courses').doc(courseId).update({'status': 'finished'});
  }

  // materials
  Stream<List<MaterialModel>> getCourseMaterials(String courseId) {
    return _db.collection('materials')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MaterialModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> createMaterial(MaterialModel material) async {
    await _db.collection('materials').doc().set(material.toMap());
  }

  // assignments
  Stream<List<AssignmentModel>> get assignments {
    return _db.collection('assignments').snapshots().map((snap) => snap.docs
        .map((doc) => AssignmentModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Stream<List<AssignmentModel>> getCourseAssignments(String courseId) {
    return _db.collection('assignments')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AssignmentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> createAssignment(AssignmentModel assignment) async {
    final docRef = _db.collection('assignments').doc();
    await docRef.set(assignment.toMap());
  }

  Stream<List<AnnouncementModel>> get announcements {
    return Stream.value([]);
  }

  // attendance
  Stream<AttendanceModel?> getAttendance(String courseId, String studentId) {
    return _db
        .collection('attendance')
        .where('courseId', isEqualTo: courseId)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) => snap.docs.isEmpty
            ? null
            : AttendanceModel.fromMap(snap.docs.first.data(), snap.docs.first.id));
  }

  Stream<List<AttendanceModel>> getCourseAttendance(String courseId) {
    return _db
        .collection('attendance')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AttendanceModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateAttendanceBatch(String courseId, String courseName, Map<String, bool> attendanceStatus) async {
    final batch = _db.batch();
    
    for (var entry in attendanceStatus.entries) {
      final studentId = entry.key;
      final isPresent = entry.value;

      final query = await _db.collection('attendance')
          .where('courseId', isEqualTo: courseId)
          .where('studentId', isEqualTo: studentId)
          .get();

      if (query.docs.isEmpty) {
        final docRef = _db.collection('attendance').doc();
        batch.set(docRef, {
          'courseId': courseId,
          'studentId': studentId,
          'courseName': courseName,
          'totalSessions': 1,
          'attendedSessions': isPresent ? 1 : 0,
        });
      } else {
        final docRef = query.docs.first.reference;
        final data = query.docs.first.data();
        batch.update(docRef, {
          'totalSessions': (data['totalSessions'] ?? 0) + 1,
          'attendedSessions': (data['attendedSessions'] ?? 0) + (isPresent ? 1 : 0),
        });
      }
    }
    await batch.commit();
  }

  // submissions
  Future<void> submitWork(SubmissionModel submission) async {
    await _db.collection('submissions').doc().set(submission.toMap());
  }

  Stream<List<SubmissionModel>> getAssignmentSubmissions(String assignmentId) {
    return _db.collection('submissions')
        .where('assignmentId', isEqualTo: assignmentId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => SubmissionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<SubmissionModel?> getUserSubmission(String assignmentId, String studentId) {
    return _db.collection('submissions')
        .where('assignmentId', isEqualTo: assignmentId)
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snap) => snap.docs.isEmpty 
            ? null 
            : SubmissionModel.fromMap(snap.docs.first.data(), snap.docs.first.id));
  }

  // chats
  Stream<List<MessageModel>> getMessages(String courseId, String studentId, String mentorId) {
    return _db.collection('messages')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snap) {
          final messages = snap.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .where((m) => 
                  (m.senderId == studentId && m.receiverId == mentorId) || 
                  (m.senderId == mentorId && m.receiverId == studentId))
              .toList();
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return messages;
        });
  }

  Future<void> sendMessage(MessageModel message) async {
    await _db.collection('messages').doc().set(message.toMap());
    
    // Create notification for recipient
    final sender = await getUserFuture(message.senderId);
    await createNotification(NotificationModel(
      id: '',
      receiverId: message.receiverId,
      senderId: message.senderId,
      senderName: sender?.name ?? 'Someone',
      title: 'New Message',
      message: message.text,
      courseId: message.courseId,
      type: 'chat',
      timestamp: DateTime.now(),
    ));
  }

  // enrollment records
  Stream<List<EnrollmentModel>> getUserEnrollments(String userId) {
    return _db.collection('enrollments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => EnrollmentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> createEnrollment(String userId, String courseId, String courseTitle) async {
    final docRef = _db.collection('enrollments').doc();
    final enrollment = EnrollmentModel(
      id: docRef.id,
      userId: userId,
      courseId: courseId,
      courseTitle: courseTitle,
      enrolledAt: DateTime.now(),
    );
    await docRef.set(enrollment.toMap());
  }

  // Notifications
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _db.collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        });
  }

  Future<void> createNotification(NotificationModel notification) async {
    await _db.collection('notifications').doc().set(notification.toMap());
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final query = await _db.collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    
    final batch = _db.batch();
    for (var doc in query.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteUserAndData(String userId) async {
    final batch = _db.batch();

    // 1. Delete user document
    batch.delete(_db.collection('users').doc(userId));

    // 2. Delete attendance records
    final attendanceQuery = await _db.collection('attendance')
        .where('studentId', isEqualTo: userId)
        .get();
    for (var doc in attendanceQuery.docs) {
      batch.delete(doc.reference);
    }

    // 3. Delete submissions
    final submissionQuery = await _db.collection('submissions')
        .where('studentId', isEqualTo: userId)
        .get();
    for (var doc in submissionQuery.docs) {
      batch.delete(doc.reference);
    }

    // 4. Delete messages
    final messagesSentQuery = await _db.collection('messages')
        .where('senderId', isEqualTo: userId)
        .get();
    for (var doc in messagesSentQuery.docs) {
      batch.delete(doc.reference);
    }
    final messagesReceivedQuery = await _db.collection('messages')
        .where('receiverId', isEqualTo: userId)
        .get();
    for (var doc in messagesReceivedQuery.docs) {
      batch.delete(doc.reference);
    }

    // 5. Remove from courses (enrolled & pending)
    final coursesQuery = await _db.collection('courses').get();
    for (var doc in coursesQuery.docs) {
      final data = doc.data();
      List<String> enrolled = List<String>.from(data['enrolledStudentIds'] ?? []);
      List<String> pending = List<String>.from(data['enrollmentPendingIds'] ?? []);
      
      bool changed = false;
      if (enrolled.contains(userId)) {
        enrolled.remove(userId);
        changed = true;
      }
      if (pending.contains(userId)) {
        pending.remove(userId);
        changed = true;
      }

      if (changed) {
        batch.update(doc.reference, {
          'enrolledStudentIds': enrolled,
          'enrollmentPendingIds': pending,
        });
      }
    }

    await batch.commit();
  }
}
