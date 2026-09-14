// =========================================================================
// 1. USER MODEL
// =========================================================================
class User {
  final String userId;
  final String fullName;
  final String email;
  final String role;
  final String? phone;
  final String? organizationName;

  String get id => userId;
  String get name => fullName;

  User({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.organizationName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final role = json['role'] ?? '';
    final orgName = json['organization_name'] ?? json['organizationName'];
    final rawFullName = json['full_name'] ?? json['name'] ?? json['fullName'] ?? '';
    return User(
      userId: json['user_id']?.toString() ?? json['id']?.toString() ?? json['_id']?.toString() ?? '',
      fullName: role == 'employer' ? (orgName ?? rawFullName) : rawFullName,
      email: json['email'] ?? '',
      role: role,
      phone: json['phone'] ?? json['phoneNumber'],
      organizationName: orgName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'id': userId,
      'full_name': fullName,
      'name': fullName,
      'email': email,
      'role': role,
      'phone': phone,
      'organization_name': organizationName,
      'organizationName': organizationName,
    };
  }
}

// =========================================================================
// 2. JOB MODEL
// =========================================================================
class Job {
  final String id;
  final String employerId;
  final String title;
  final String specialty;
  final String jobType;
  final String mode;
  final String city;
  final String salaryRange;
  final String description;
  final String requirements;
  final String postedAt;
  final String status;
  final String organizationName;
  final String? organizationLogo;
  final String? organizationAbout;
  final String? employerPhone;

  Job({
    required this.id,
    required this.employerId,
    required this.title,
    required this.specialty,
    required this.jobType,
    required this.mode,
    required this.city,
    required this.salaryRange,
    required this.description,
    required this.requirements,
    required this.postedAt,
    required this.status,
    required this.organizationName,
    this.organizationLogo,
    this.organizationAbout,
    this.employerPhone,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      employerId: json['employer_id']?.toString() ?? json['employerId']?.toString() ?? '',
      title: json['title'] ?? '',
      specialty: json['specialty'] ?? 'General Practice',
      jobType: json['job_type'] ?? json['jobType'] ?? 'Full-time',
      mode: json['mode'] ?? 'Remote',
      city: json['city'] ?? '',
      salaryRange: json['salary_range'] ?? json['salaryRange'] ?? 'Negotiable',
      description: json['description'] ?? '',
      requirements: json['requirements'] ?? '',
      postedAt: json['posted_at'] ?? json['postedAt'] ?? '',
      status: json['status'] ?? 'open',
      organizationName: json['organization_name'] ?? json['organizationName'] ?? 'DocStep Partner',
      organizationLogo: json['organization_logo'] ?? json['organizationLogo'],
      organizationAbout: json['organization_about'] ?? json['organizationAbout'],
      employerPhone: json['employer_phone']?.toString() ?? json['employerPhone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employer_id': employerId,
      'title': title,
      'specialty': specialty,
      'job_type': jobType,
      'mode': mode,
      'city': city,
      'salary_range': salaryRange,
      'description': description,
      'requirements': requirements,
      'posted_at': postedAt,
      'status': status,
      'organization_name': organizationName,
      'organization_logo': organizationLogo,
      'organization_about': organizationAbout,
      'employer_phone': employerPhone,
    };
  }
}

// =========================================================================
// 3. COURSE MODEL
// =========================================================================
class Course {
  final String id;
  final String title;
  final String specialty;
  final String instructor;
  final String duration;
  final double durationHours;
  final int lecturesCount;
  final String description;
  final int enrolledCount;
  final String price;
  final String? image;
  final String level;
  final String provider;
  final List<String> tags;

  Course({
    required this.id,
    required this.title,
    required this.specialty,
    required this.instructor,
    required this.duration,
    required this.durationHours,
    required this.lecturesCount,
    required this.description,
    required this.enrolledCount,
    required this.price,
    this.image,
    required this.level,
    required this.provider,
    required this.tags,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    if (json['tags'] != null) {
      if (json['tags'] is String) {
        parsedTags = (json['tags'] as String).split(',').map((t) => t.trim()).toList();
      } else if (json['tags'] is List) {
        parsedTags = List<String>.from(json['tags']);
      }
    }
    
    return Course(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      specialty: json['specialty'] ?? 'General Practice',
      instructor: json['instructor'] ?? 'Dr. Aruna Chandran',
      duration: json['duration'] ?? json['duration_hours']?.toString() ?? '10 hours',
      durationHours: (json['duration_hours'] as num?)?.toDouble() ?? 10.0,
      lecturesCount: json['lecturesCount'] ?? json['lectures_count'] ?? 12,
      description: json['description'] ?? '',
      enrolledCount: json['enrolled_count'] ?? json['enrolledCount'] ?? 0,
      price: json['price'] ?? 'Free',
      image: json['image'],
      level: json['level'] ?? 'Intermediate',
      provider: json['provider'] ?? 'DocStep Academy',
      tags: parsedTags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'specialty': specialty,
      'instructor': instructor,
      'duration': duration,
      'duration_hours': durationHours,
      'lectures_count': lecturesCount,
      'description': description,
      'enrolled_count': enrolledCount,
      'price': price,
      'image': image,
      'level': level,
      'provider': provider,
      'tags': tags,
    };
  }
}

// =========================================================================
// 4. COMMUNITY POST MODEL
// =========================================================================
class CommunityPost {
  final String id;
  final String title;
  final String category;
  final String content;
  final String userId;
  final String userName;
  final String userRole;
  final String createdAt;
  final int repliesCount;
  final List<CommunityReply> replies;

  CommunityPost({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.createdAt,
    required this.repliesCount,
    required this.replies,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    var list = json['replies'] as List?;
    List<CommunityReply> replyList = list != null 
        ? list.map((i) => CommunityReply.fromJson(i)).toList() 
        : [];
        
    return CommunityPost(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'General',
      content: json['content'] ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      userName: json['user_name'] ?? json['userName'] ?? 'Anonymous',
      userRole: json['user_role'] ?? json['userRole'] ?? 'doctor',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
      repliesCount: json['replies_count'] ?? json['repliesCount'] ?? replyList.length,
      replies: replyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'content': content,
      'user_id': userId,
      'user_name': userName,
      'user_role': userRole,
      'created_at': createdAt,
      'replies_count': repliesCount,
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }
}

// =========================================================================
// 5. COMMUNITY REPLY MODEL
// =========================================================================
class CommunityReply {
  final String id;
  final String postId;
  final String content;
  final String userId;
  final String userName;
  final String userRole;
  final String createdAt;

  CommunityReply({
    required this.id,
    required this.postId,
    required this.content,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.createdAt,
  });

  factory CommunityReply.fromJson(Map<String, dynamic> json) {
    return CommunityReply(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? json['postId']?.toString() ?? '',
      content: json['content'] ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      userName: json['user_name'] ?? json['userName'] ?? 'Anonymous',
      userRole: json['user_role'] ?? json['userRole'] ?? 'doctor',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'content': content,
      'user_id': userId,
      'user_name': userName,
      'user_role': userRole,
      'created_at': createdAt,
    };
  }
}

// =========================================================================
// 6. APPOINTMENT MODEL
// =========================================================================
class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final String patientName;
  final String patientId;
  final String patientPhone;
  final String patientEmail;
  final String slotDate;
  final String slotTime;
  final String status;
  final String notes;
  final String createdAt;
  final String? employerId;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.patientName,
    this.patientId = '',
    required this.patientPhone,
    required this.patientEmail,
    required this.slotDate,
    required this.slotTime,
    required this.status,
    required this.notes,
    required this.createdAt,
    this.employerId,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? json['doctorId']?.toString() ?? '',
      doctorName: json['doctor_name'] ?? json['doctorName'] ?? 'Doctor',
      specialty: json['specialty'] ?? json['primary_specialty'] ?? json['primarySpecialty'] ?? 'General Practice',
      patientName: json['patient_name'] ?? json['patientName'] ?? '',
      patientId: json['patient_id']?.toString() ?? json['patientId']?.toString() ?? '',
      patientPhone: json['patient_phone'] ?? json['patientPhone'] ?? json['phone'] ?? json['phoneNumber'] ?? '',
      patientEmail: json['patient_email'] ?? json['patientEmail'] ?? json['email'] ?? '',
      slotDate: json['slot_date'] ?? json['slotDate'] ?? json['date'] ?? '',
      slotTime: json['slot_time'] ?? json['slotTime'] ?? json['time_slot'] ?? json['timeSlot'] ?? '',
      status: json['status'] ?? 'pending',
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
      employerId: json['employer_id']?.toString() ?? json['employerId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'specialty': specialty,
      'patient_name': patientName,
      'patient_id': patientId,
      'patientId': patientId,
      'patient_phone': patientPhone,
      'patient_email': patientEmail,
      'slot_date': slotDate,
      'slot_time': slotTime,
      'status': status,
      'notes': notes,
      'created_at': createdAt,
    };
  }
}

// =========================================================================
// 7. INTERVIEW MODEL
// =========================================================================
class Interview {
  final String id;
  final String applicationId;
  final String jobTitle;
  final String candidateName;
  final String scheduledAt;
  final String mode;
  final String location;
  final String notes;
  final String status;

  Interview({
    required this.id,
    required this.applicationId,
    required this.jobTitle,
    required this.candidateName,
    required this.scheduledAt,
    required this.mode,
    required this.location,
    required this.notes,
    required this.status,
  });

  factory Interview.fromJson(Map<String, dynamic> json) {
    return Interview(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      applicationId: json['application_id']?.toString() ?? json['applicationId']?.toString() ?? '',
      jobTitle: json['job_title'] ?? json['jobTitle'] ?? 'Job Position',
      candidateName: json['candidate_name'] ?? json['candidateName'] ?? 'Doctor',
      scheduledAt: json['scheduled_at'] ?? json['scheduledAt'] ?? '',
      mode: json['mode'] ?? 'Remote',
      location: json['location'] ?? '',
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'scheduled',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'application_id': applicationId,
      'job_title': jobTitle,
      'candidate_name': candidateName,
      'scheduled_at': scheduledAt,
      'mode': mode,
      'location': location,
      'notes': notes,
      'status': status,
    };
  }
}

// =========================================================================
// 8. CREDENTIAL MODEL
// =========================================================================
class Credential {
  final String id;
  final String doctorId;
  final String credType;
  final String title;
  final String? filePath;
  final int verified;
  final String uploadedAt;

  Credential({
    required this.id,
    required this.doctorId,
    required this.credType,
    required this.title,
    this.filePath,
    required this.verified,
    required this.uploadedAt,
  });

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      doctorId: json['doctor_id']?.toString() ?? json['doctorId']?.toString() ?? '',
      credType: json['cred_type'] ?? json['credType'] ?? 'degree',
      title: json['title'] ?? '',
      filePath: json['file_path'] ?? json['filePath'],
      verified: (json['verified'] as num?)?.toInt() ?? 0,
      uploadedAt: json['uploaded_at'] ?? json['uploadedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'cred_type': credType,
      'title': title,
      'file_path': filePath,
      'verified': verified,
      'uploaded_at': uploadedAt,
    };
  }
}
