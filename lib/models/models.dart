// ─── User Model ───────────────────────────────────────────────────────────────
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // intern, mentor, admin
  final String avatarInitials;
  final int completedModules;
  final int totalModules;
  final int streakDays;
  final double overallProgress;
  final String phoneNumber;
  final String bio;
  final List<String> skills;
  final Map<String, String> socialLinks;
  final String password;
  final String? profileImageUrl;
  final bool isNotificationsEnabled;
  final String? fcmToken;
  final String address;
  final String yearOfStudy;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarInitials,
    required this.completedModules,
    required this.totalModules,
    required this.streakDays,
    required this.overallProgress,
    this.phoneNumber = '',
    this.bio = '',
    this.skills = const [],
    this.socialLinks = const {},
    this.password = '',
    this.profileImageUrl,
    this.isNotificationsEnabled = true,
    this.fcmToken,
    this.address = '',
    this.yearOfStudy = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'avatarInitials': avatarInitials,
      'completedModules': completedModules,
      'totalModules': totalModules,
      'streakDays': streakDays,
      'overallProgress': overallProgress,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'skills': skills,
      'socialLinks': socialLinks,
      'password': password,
      'profileImageUrl': profileImageUrl,
      'isNotificationsEnabled': isNotificationsEnabled,
      'fcmToken': fcmToken,
      'address': address,
      'yearOfStudy': yearOfStudy,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'intern',
      avatarInitials: map['avatarInitials'] ?? '',
      completedModules: map['completedModules'] ?? 0,
      totalModules: map['totalModules'] ?? 0,
      streakDays: map['streakDays'] ?? 0,
      overallProgress: (map['overallProgress'] ?? 0.0).toDouble(),
      phoneNumber: map['phoneNumber'] ?? '',
      bio: map['bio'] ?? '',
      skills: List<String>.from(map['skills'] ?? []),
      socialLinks: Map<String, String>.from(map['socialLinks'] ?? {}),
      password: map['password'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      isNotificationsEnabled: map['isNotificationsEnabled'] ?? true,
      fcmToken: map['fcmToken'],
      address: map['address'] ?? '',
      yearOfStudy: map['yearOfStudy'] ?? '',
    );
  }
}

// ─── Course Model ─────────────────────────────────────────────────────────────
class CourseModel {
  final String id;
  final String courseCode;
  final String title;
  final String instructor;
  final String duration;
  final int totalLessons;
  final int completedLessons;
  final double rating;
  final String category;
  final String difficulty;
  final bool isEnrolled;
  final int gradientIndex;
  final List<LessonModel> lessons;
  final List<LiveSessionModel> liveSessions;
  final List<String> enrolledStudentIds;
  final List<String> enrollmentPendingIds;
  final String? mentorId;
  final String status; // ongoing, finished
  final DateTime? createdAt;

  const CourseModel({
    required this.id,
    required this.courseCode,
    required this.title,
    required this.instructor,
    required this.duration,
    required this.totalLessons,
    required this.completedLessons,
    required this.rating,
    required this.category,
    required this.difficulty,
    required this.isEnrolled,
    required this.gradientIndex,
    required this.lessons,
    required this.liveSessions,
    required this.enrolledStudentIds,
    this.enrollmentPendingIds = const [],
    this.mentorId,
    this.status = 'ongoing',
    this.createdAt,
  });

  double get progress =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;

  Map<String, dynamic> toMap() {
    return {
      'courseCode': courseCode,
      'title': title,
      'instructor': instructor,
      'duration': duration,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'rating': rating,
      'category': category,
      'difficulty': difficulty,
      'isEnrolled': isEnrolled,
      'gradientIndex': gradientIndex,
      'lessons': lessons.map((x) => x.toMap()).toList(),
      'liveSessions': liveSessions.map((x) => x.toMap()).toList(),
      'enrolledStudentIds': enrolledStudentIds,
      'enrollmentPendingIds': enrollmentPendingIds,
      'mentorId': mentorId,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map, String id) {
    return CourseModel(
      id: id,
      courseCode: map['courseCode'] ?? '',
      title: map['title'] ?? '',
      instructor: map['instructor'] ?? '',
      duration: map['duration'] ?? '',
      totalLessons: map['totalLessons'] ?? 0,
      completedLessons: map['completedLessons'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? '',
      isEnrolled: map['isEnrolled'] ?? false,
      gradientIndex: map['gradientIndex'] ?? 0,
      lessons: List<LessonModel>.from((map['lessons'] ?? []).map((x) => LessonModel.fromMap(x))),
      liveSessions: List<LiveSessionModel>.from((map['liveSessions'] ?? []).map((x) => LiveSessionModel.fromMap(x))),
      enrolledStudentIds: List<String>.from(map['enrolledStudentIds'] ?? []),
      enrollmentPendingIds: List<String>.from(map['enrollmentPendingIds'] ?? []),
      mentorId: map['mentorId'],
      status: map['status'] ?? 'ongoing',
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
    );
  }
}

class EnrollmentModel {
  final String id;
  final String userId;
  final String courseId;
  final String courseTitle;
  final DateTime enrolledAt;

  const EnrollmentModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.courseTitle,
    required this.enrolledAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'courseId': courseId,
      'courseTitle': courseTitle,
      'enrolledAt': enrolledAt.toIso8601String(),
    };
  }

  factory EnrollmentModel.fromMap(Map<String, dynamic> map, String id) {
    return EnrollmentModel(
      id: id,
      userId: map['userId'] ?? '',
      courseId: map['courseId'] ?? '',
      courseTitle: map['courseTitle'] ?? '',
      enrolledAt: DateTime.tryParse(map['enrolledAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// ─── Lesson Model ─────────────────────────────────────────────────────────────
class LessonModel {
  final String id;
  final String title;
  final String duration;
  final String type; // video, quiz, reading, assignment
  final bool isCompleted;
  final bool isLocked;

  const LessonModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.type,
    required this.isCompleted,
    required this.isLocked,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'type': type,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
    };
  }

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      duration: map['duration'] ?? '',
      type: map['type'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      isLocked: map['isLocked'] ?? false,
    );
  }
}

// ─── Live Session Model ────────────────────────────────────────────────────────
class LiveSessionModel {
  final String title;
  final String time;
  final String link;

  const LiveSessionModel({required this.title, required this.time, required this.link});

  Map<String, dynamic> toMap() => {'title': title, 'time': time, 'link': link};

  factory LiveSessionModel.fromMap(Map<String, dynamic> map) => LiveSessionModel(
        title: map['title'] ?? '',
        time: map['time'] ?? '',
        link: map['link'] ?? '',
      );
}

// ─── Material Model ────────────────────────────────────────────────────────────
class MaterialModel {
  final String id;
  final String courseId;
  final String title;
  final String url;
  final DateTime createdAt;

  const MaterialModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.url,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'courseId': courseId,
    'title': title,
    'url': url,
    'createdAt': createdAt.toIso8601String(),
  };

  factory MaterialModel.fromMap(Map<String, dynamic> map, String id) => MaterialModel(
        id: id,
        courseId: map['courseId'] ?? '',
        title: map['title'] ?? '',
        url: map['url'] ?? '',
        createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      );
}

// ─── Assignment Model ─────────────────────────────────────────────────────────
class AssignmentModel {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final String courseName;
  final String dueDate;
  final String status; // pending, submitted, graded, overdue
  final int? score;
  final int maxScore;
  final String priority; // high, medium, low
  final String? attachmentUrl;

  const AssignmentModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.courseName,
    required this.dueDate,
    required this.status,
    this.score,
    required this.maxScore,
    required this.priority,
    this.attachmentUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'title': title,
      'description': description,
      'courseName': courseName,
      'dueDate': dueDate,
      'status': status,
      'score': score,
      'maxScore': maxScore,
      'priority': priority,
      'attachmentUrl': attachmentUrl,
    };
  }

  factory AssignmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AssignmentModel(
      id: id,
      courseId: map['courseId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      courseName: map['courseName'] ?? '',
      dueDate: map['dueDate'] ?? '',
      status: map['status'] ?? 'pending',
      score: map['score'],
      maxScore: map['maxScore'] ?? 100,
      priority: map['priority'] ?? 'medium',
      attachmentUrl: map['attachmentUrl'],
    );
  }
}

// ─── Announcement Model ───────────────────────────────────────────────────────
class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String author;
  final String timeAgo;
  final bool isRead;
  final String type; // info, warning, success, urgent

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.author,
    required this.timeAgo,
    required this.isRead,
    required this.type,
  });
}

// ─── Attendance Model ──────────────────────────────────────────────────────────
class AttendanceModel {
  final String? id;
  final String studentId;
  final String courseId;
  final String courseName;
  final int totalSessions;
  final int attendedSessions;

  AttendanceModel({
    this.id,
    required this.studentId,
    required this.courseId,
    required this.courseName,
    required this.totalSessions,
    required this.attendedSessions,
  });

  double get percentage =>
      totalSessions == 0 ? 0 : (attendedSessions / totalSessions) * 100;

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'courseName': courseName,
      'totalSessions': totalSessions,
      'attendedSessions': attendedSessions,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map, String id) {
    return AttendanceModel(
      id: id,
      studentId: map['studentId'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      totalSessions: map['totalSessions'] ?? 0,
      attendedSessions: map['attendedSessions'] ?? 0,
    );
  }
}

// ─── Submission Model ───────────────────────────────────────────────────────────
class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final String fileUrl;
  final String fileName;
  final DateTime submittedAt;
  final int? grade;
  final String? feedback;

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.fileUrl,
    required this.fileName,
    required this.submittedAt,
    this.grade,
    this.feedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'studentName': studentName,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'submittedAt': submittedAt.toIso8601String(),
      'grade': grade,
      'feedback': feedback,
    };
  }

  factory SubmissionModel.fromMap(Map<String, dynamic> map, String id) {
    return SubmissionModel(
      id: id,
      assignmentId: map['assignmentId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      submittedAt: map['submittedAt'] != null 
          ? DateTime.parse(map['submittedAt']) 
          : DateTime.now(),
      grade: map['grade'],
      feedback: map['feedback'],
    );
  }
}

// ─── Message Model ───────────────────────────────────────────────────────
class MessageModel {
  final String id;
  final String courseId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;

  const MessageModel({
    required this.id,
    required this.courseId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      courseId: map['courseId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
    );
  }
}

class NotificationModel {
  final String id;
  final String receiverId;
  final String senderId;
  final String senderName;
  final String title;
  final String message;
  final String? courseId;
  final String type; // enrollment_request, enrollment_response, chat
  final DateTime timestamp;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.receiverId,
    required this.senderId,
    required this.senderName,
    required this.title,
    required this.message,
    this.courseId,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'receiverId': receiverId,
      'senderId': senderId,
      'senderName': senderName,
      'title': title,
      'message': message,
      'courseId': courseId,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      receiverId: map['receiverId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      courseId: map['courseId'],
      type: map['type'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}
