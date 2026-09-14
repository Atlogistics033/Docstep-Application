import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/models.dart';
import '../firebase_options.dart';

// =========================================================================
// TOP-LEVEL PARSING FUNCTIONS FOR BACKGROUND ISOLATE COMPUTATION (compute)
// =========================================================================

List<Job> parseJobs(List<Map<String, dynamic>> rawJobs) {
  return rawJobs.map((j) => Job.fromJson(j)).toList();
}

List<Course> parseCourses(List<Map<String, dynamic>> rawCourses) {
  return rawCourses.map((c) => Course.fromJson(c)).toList();
}

List<CommunityPost> parsePosts(List<Map<String, dynamic>> rawPosts) {
  return rawPosts.map((p) => CommunityPost.fromJson(p)).toList();
}

List<CommunityReply> parseReplies(List<Map<String, dynamic>> rawReplies) {
  return rawReplies.map((r) => CommunityReply.fromJson(r)).toList();
}

List<Appointment> parseAppointments(
  List<Map<String, dynamic>> rawAppointments,
) {
  return rawAppointments.map((a) => Appointment.fromJson(a)).toList();
}

List<Interview> parseInterviews(List<Map<String, dynamic>> rawInterviews) {
  return rawInterviews.map((i) => Interview.fromJson(i)).toList();
}

List<Credential> parseCredentials(List<Map<String, dynamic>> rawCredentials) {
  return rawCredentials.map((c) => Credential.fromJson(c)).toList();
}

class DataProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Public Data ---
  List<Job> _jobs = [];
  List<Course> _courses = [];
  List<Map<String, dynamic>> _stories = [];
  List<CommunityPost> _posts = [];
  CommunityPost? _selectedPost;
  List<CommunityReply> _replies = [];

  List<Job> get jobs => _jobs;
  List<Course> get courses => _courses;
  List<Map<String, dynamic>> get stories => _stories;
  List<CommunityPost> get posts => _posts;
  CommunityPost? get selectedPost => _selectedPost;
  List<CommunityReply> get replies => _replies;

  // --- Portals & Dashboards ---
  // Doctor Portal
  Map<String, dynamic>? _doctorDashboard;
  List<Appointment> _doctorAppointments = [];
  List<Map<String, dynamic>> _doctorApplications = [];
  List<Interview> _doctorInterviews = [];
  List<Credential> _doctorCredentials = [];
  Map<String, dynamic>? _doctorProfile;

  Map<String, dynamic>? get doctorDashboard => _doctorDashboard;
  List<Appointment> get doctorAppointments => _doctorAppointments;
  List<Map<String, dynamic>> get doctorApplications => _doctorApplications;
  List<Interview> get doctorInterviews => _doctorInterviews;
  List<Credential> get doctorCredentials => _doctorCredentials;
  Map<String, dynamic>? get doctorProfile => _doctorProfile;

  // Patient Portal
  Map<String, dynamic>? _patientDashboard;
  List<Appointment> _patientAppointments = [];
  Map<String, dynamic>? _patientProfile;
  List<Map<String, dynamic>> _registeredDoctors = [];

  Map<String, dynamic>? get patientDashboard => _patientDashboard;
  List<Appointment> get patientAppointments => _patientAppointments;
  Map<String, dynamic>? get patientProfile => _patientProfile;
  List<Map<String, dynamic>> get registeredDoctors => _registeredDoctors;

  // Employer Portal
  Map<String, dynamic>? _employerDashboard;
  List<Job> _employerJobs = [];
  List<Map<String, dynamic>> _employerApplications = [];
  List<Interview> _employerInterviews = [];
  List<Map<String, dynamic>> _employerPendingApps = [];
  List<Appointment> _employerAppointments = [];
  List<User> _candidates = [];
  List<String> _candidateSpecialties = [];
  List<String> _candidateCities = [];

  Map<String, dynamic>? get employerDashboard => _employerDashboard;
  List<Job> get employerJobs => _employerJobs;
  List<Map<String, dynamic>> get employerApplications => _employerApplications;
  List<Interview> get employerInterviews => _employerInterviews;
  List<Map<String, dynamic>> get employerPendingApps => _employerPendingApps;
  List<Appointment> get employerAppointments => _employerAppointments;
  List<User> get candidates => _candidates;
  List<String> get candidateSpecialties => _candidateSpecialties;
  List<String> get candidateCities => _candidateCities;

  // Admin Portal
  Map<String, dynamic>? _adminDashboard;
  List<Map<String, dynamic>> _adminUnverifiedDoctors = [];
  List<Map<String, dynamic>> _adminUnverifiedCredentials = [];
  List<Map<String, dynamic>> _adminContactMessages = [];

  Map<String, dynamic>? get adminDashboard => _adminDashboard;
  List<Map<String, dynamic>> get adminUnverifiedDoctors =>
      _adminUnverifiedDoctors;
  List<Map<String, dynamic>> get adminUnverifiedCredentials =>
      _adminUnverifiedCredentials;
  List<Map<String, dynamic>> get adminContactMessages => _adminContactMessages;

  Future<void> _ensureFirebase() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  void clearPortalData() {
    _doctorDashboard = null;
    _doctorAppointments = [];
    _doctorApplications = [];
    _doctorInterviews = [];
    _doctorCredentials = [];
    _doctorProfile = null;
    _patientDashboard = null;
    _patientAppointments = [];
    _patientProfile = null;
    _employerDashboard = null;
    _employerJobs = [];
    _employerApplications = [];
    _employerInterviews = [];
    _employerPendingApps = [];
    _employerAppointments = [];
    _adminDashboard = null;
    _adminUnverifiedDoctors = [];
    _adminUnverifiedCredentials = [];
    _adminContactMessages = [];
  }

  // =========================================================================
  // 1. PUBLIC ENDPOINTS
  // =========================================================================

  Future<void> fetchPublicJobs({
    String? specialty,
    String? mode,
    String? q,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ensureFirebase();
      Query query = FirebaseFirestore.instance
          .collection('jobs')
          .where('status', isEqualTo: 'open');

      if (specialty != null && specialty.isNotEmpty) {
        query = query.where('specialty', isEqualTo: specialty);
      }
      if (mode != null && mode.isNotEmpty) {
        query = query.where('mode', isEqualTo: mode);
      }

      final snapshot = await query.get();

      final profilesSnapshot = await FirebaseFirestore.instance
          .collection('employer_profiles')
          .get();
      final phoneMap = <String, String>{};
      for (final doc in profilesSnapshot.docs) {
        final pData = doc.data();
        final phone = pData['phone'] ?? pData['phoneNumber'] ?? pData['contact_phone'] ?? pData['contactPhone'] ?? '';
        if (phone.isNotEmpty) {
          phoneMap[doc.id] = phone;
          final uId = pData['user_id'] ?? pData['userId'] ?? '';
          if (uId.isNotEmpty) {
            phoneMap[uId] = phone;
          }
        }
      }

      final rawJobs = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        final empId = data['employer_id'] ?? data['employerId'] ?? '';
        if (data['employer_phone'] == null && data['employerPhone'] == null) {
          final phone = phoneMap[empId];
          if (phone != null) {
            data['employer_phone'] = phone;
            data['employerPhone'] = phone;
          }
        }
        return data;
      }).toList();

      var list = await compute(parseJobs, rawJobs);

      if (q != null && q.isNotEmpty) {
        final lowerQ = q.toLowerCase();
        list = list
            .where(
              (j) =>
                  j.title.toLowerCase().contains(lowerQ) ||
                  j.description.toLowerCase().contains(lowerQ) ||
                  j.organizationName.toLowerCase().contains(lowerQ),
            )
            .toList();
      }

      _jobs = list;
    } catch (e) {
      _errorMessage = 'Error fetching jobs';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Job?> fetchJobDetails(String jobId) async {
    try {
      await _ensureFirebase();
      final doc = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['id'] = doc.id;
        final empId = data['employer_id'] ?? data['employerId'] ?? '';
        if (empId.toString().isNotEmpty) {
          if (data['employer_phone'] == null && data['employerPhone'] == null) {
            final profileDoc = await FirebaseFirestore.instance
                .collection('employer_profiles')
                .doc(empId.toString())
                .get();
            if (profileDoc.exists && profileDoc.data() != null) {
              final pData = profileDoc.data()!;
              final phone = pData['phone'] ?? pData['phoneNumber'] ?? pData['contact_phone'] ?? pData['contactPhone'];
              if (phone != null) {
                data['employer_phone'] = phone;
                data['employerPhone'] = phone;
              }
            } else {
              final querySnapshot = await FirebaseFirestore.instance
                  .collection('employer_profiles')
                  .where('user_id', isEqualTo: empId.toString())
                  .limit(1)
                  .get();
              if (querySnapshot.docs.isNotEmpty) {
                final pData = querySnapshot.docs.first.data();
                final phone = pData['phone'] ?? pData['phoneNumber'] ?? pData['contact_phone'] ?? pData['contactPhone'];
                if (phone != null) {
                  data['employer_phone'] = phone;
                  data['employerPhone'] = phone;
                }
              }
            }
          }
        }
        return Job.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<void> fetchCourses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ensureFirebase();
      final snapshot = await FirebaseFirestore.instance
          .collection('courses')
          .get();

      if (snapshot.docs.isEmpty) {
        await _seedInitialCourses();
        final newSnapshot = await FirebaseFirestore.instance
            .collection('courses')
            .get();
        final rawCourses = newSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        _courses = await compute(parseCourses, rawCourses);
      } else {
        final rawCourses = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        _courses = await compute(parseCourses, rawCourses);
      }
    } catch (e) {
      _errorMessage = 'Error fetching courses';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _seedInitialCourses() async {
    final initialCourses = [
      {
        'title': 'Introduction to Telemedicine',
        'specialty': 'General Practice',
        'instructor': 'Dr. Sarah Malik',
        'duration': '6 hours',
        'duration_hours': 6.0,
        'lectures_count': 8,
        'description':
            'Learn the fundamentals of conducting remote consultations, clinical guidelines, and digital patient communication tools.',
        'enrolled_count': 142,
        'price': 'Free',
        'level': 'Beginner',
        'provider': 'DocStep Academy',
        'tags': ['telehealth', 'digital-health'],
      },
      {
        'title': 'Advanced Pediatrics Guidelines',
        'specialty': 'Pediatrics',
        'instructor': 'Dr. Arsalan Shah',
        'duration': '12 hours',
        'duration_hours': 12.0,
        'lectures_count': 15,
        'description':
            'Complete guide to pediatric emergency care, developmental milestones, and latest treatment protocols.',
        'enrolled_count': 98,
        'price': 'PKR 1,500',
        'level': 'Advanced',
        'provider': 'Pediatric Association',
        'tags': ['pediatrics', 'emergency'],
      },
    ];

    for (var course in initialCourses) {
      await FirebaseFirestore.instance.collection('courses').add(course);
    }
  }

  Future<void> fetchStories() async {
    try {
      await _ensureFirebase();
      final snapshot = await FirebaseFirestore.instance
          .collection('success_stories')
          .get();

      if (snapshot.docs.isEmpty) {
        await _seedInitialStories();
        final newSnapshot = await FirebaseFirestore.instance
            .collection('success_stories')
            .get();
        _stories = newSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      } else {
        _stories = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _seedInitialStories() async {
    final initialStories = [
      {
        'title': 'How Dr. Ayesha Transitioned to Telemedicine',
        'doctor_name': 'Dr. Ayesha Khan',
        'specialty': 'Gynecology',
        'quote':
            'DocStep enabled me to connect with remote clinics and manage flexible shifts smoothly.',
        'story':
            'After graduation, finding structured part-time GP/consultancy jobs was difficult. Through DocStep, I booked consistent remote consultation slots.',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 30))
            .toIso8601String(),
      },
      {
        'title': 'Securing a Senior Resident Position in 2 Weeks',
        'doctor_name': 'Dr. Zain Ali',
        'specialty': 'Internal Medicine',
        'quote':
            'The direct application process and automated interview scheduler cut down weeks of back-and-forth.',
        'story':
            'I verified my PMDC credentials on DocStep, built my resume, applied to three hospitals, and completed my interview via the platform scheduler.',
        'created_at': DateTime.now()
            .subtract(const Duration(days: 15))
            .toIso8601String(),
      },
    ];

    for (var story in initialStories) {
      await FirebaseFirestore.instance.collection('success_stories').add(story);
    }
  }

  Future<void> fetchCommunityPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ensureFirebase();
      final snapshot = await FirebaseFirestore.instance
          .collection('community_posts')
          .orderBy('created_at', descending: true)
          .get();

      final rawPosts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      _posts = await compute(parsePosts, rawPosts);
    } catch (e) {
      _errorMessage = 'Error fetching community posts';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPostDetails(String postId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ensureFirebase();
      final postDoc = await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(postId)
          .get();
      if (postDoc.exists && postDoc.data() != null) {
        final postData = postDoc.data()!;
        postData['id'] = postDoc.id;

        final repliesSnapshot = await FirebaseFirestore.instance
            .collection('community_replies')
            .where('post_id', isEqualTo: postId)
            .orderBy('created_at', descending: false)
            .get();

        final rawReplies = repliesSnapshot.docs.map((doc) {
          final rData = doc.data();
          rData['id'] = doc.id;
          return rData;
        }).toList();

        final replyList = await compute(parseReplies, rawReplies);

        postData['replies'] = replyList.map((r) => r.toJson()).toList();
        postData['replies_count'] = replyList.length;

        _selectedPost = CommunityPost.fromJson(postData);
        _replies = replyList;
      } else {
        _errorMessage = 'Post not found';
      }
    } catch (e) {
      _errorMessage = 'Error loading post details';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost(String title, String content, String category) async {
    try {
      await _ensureFirebase();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (fbUser == null) return false;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(fbUser.uid)
          .get();
      final userName = userDoc.data()?['full_name'] ?? 'Anonymous';
      final userRole = userDoc.data()?['role'] ?? 'doctor';

      final postDoc = {
        'title': title,
        'content': content,
        'category': category,
        'user_id': fbUser.uid,
        'user_name': userName,
        'user_role': userRole,
        'created_at': DateTime.now().toIso8601String(),
        'replies_count': 0,
      };

      await FirebaseFirestore.instance
          .collection('community_posts')
          .add(postDoc);
      await fetchCommunityPosts();
      return true;
    } catch (_) {}
    return false;
  }

  Future<bool> addReply(String postId, String content) async {
    try {
      await _ensureFirebase();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (fbUser == null) return false;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(fbUser.uid)
          .get();
      final userName = userDoc.data()?['full_name'] ?? 'Anonymous';
      final userRole = userDoc.data()?['role'] ?? 'doctor';

      final replyDoc = {
        'post_id': postId,
        'content': content,
        'user_id': fbUser.uid,
        'user_name': userName,
        'user_role': userRole,
        'created_at': DateTime.now().toIso8601String(),
      };

      await FirebaseFirestore.instance
          .collection('community_replies')
          .add(replyDoc);

      final postRef = FirebaseFirestore.instance
          .collection('community_posts')
          .doc(postId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(postRef);
        if (snapshot.exists) {
          final currentCount = snapshot.data()?['replies_count'] ?? 0;
          transaction.update(postRef, {'replies_count': currentCount + 1});
        }
      });

      await fetchPostDetails(postId);
      return true;
    } catch (_) {}
    return false;
  }

  Future<bool> submitContact(
    String name,
    String email,
    String subject,
    String message,
  ) async {
    try {
      await _ensureFirebase();
      final contactDoc = {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      };
      await FirebaseFirestore.instance
          .collection('contact_messages')
          .add(contactDoc);
      return true;
    } catch (_) {}
    return false;
  }

  Future<Map<String, dynamic>?> _findDoctorProfile(String doctorId) async {
    Future<Map<String, dynamic>> enrichDoctorProfile(
      Map<String, dynamic> data,
    ) async {
      final uid = (data['user_id'] ?? data['userId'] ?? data['doctor_id'] ?? data['doctorId'] ?? doctorId).toString();
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        data['name'] =
            data['name'] ??
            userData['name'] ??
            userData['full_name'] ??
            userData['fullName'];
        data['full_name'] =
            data['full_name'] ??
            userData['full_name'] ??
            userData['name'] ??
            userData['fullName'];
        data['fullName'] =
            data['fullName'] ??
            data['full_name'] ??
            userData['fullName'] ??
            userData['full_name'] ??
            userData['name'];
        data['email'] = data['email'] ?? userData['email'];
        data['phone'] = data['phone'] ?? userData['phone'];
        data['phoneNumber'] = data['phoneNumber'] ?? userData['phoneNumber'] ?? data['phone'];
      }
      data['user_id'] = uid;

      // Smart clinic location vs physical address normalizer
      final List<String> kClinicLocations = [
        'North Nazimabad', 'Nazimabad', 'FB area', 'FB Area', 'Gulshan-e-Iqbal',
        'Gulistan-e-Johar', 'PCHS', 'SADDAR', 'Saddar', 'Shah faisal', 'Shah Faisal',
        'shahrah-e-faisal', 'Shahrah-e-Faisal', 'Malir'
      ];

      final dbClinicAddr = data['clinic_address'] ?? data['clinicAddress'];
      final dbClinicLoc = data['clinic_location'] ?? data['clinicLocation'];
      final dbClinicHosp = data['clinic_hospital_address'] ?? data['clinicHospitalAddress'];

      String resolvedClinicLoc = '';
      String resolvedClinicHosp = '';

      if (dbClinicLoc != null && dbClinicLoc.toString().isNotEmpty) {
        resolvedClinicLoc = dbClinicLoc.toString();
      }
      if (dbClinicHosp != null && dbClinicHosp.toString().isNotEmpty) {
        resolvedClinicHosp = dbClinicHosp.toString();
      }

      if (dbClinicAddr != null && dbClinicAddr.toString().isNotEmpty) {
        final isLoc = kClinicLocations.any((loc) => loc.toLowerCase().trim() == dbClinicAddr.toString().toLowerCase().trim());
        if (isLoc) {
          if (resolvedClinicLoc.isEmpty) resolvedClinicLoc = dbClinicAddr.toString();
        } else {
          if (resolvedClinicHosp.isEmpty) resolvedClinicHosp = dbClinicAddr.toString();
        }
      }

      // Normalize doctor profile fields
      data['years_of_experience'] = data['experience_years'] ?? data['experienceYears'] ?? data['years_of_experience'] ?? data['yearsOfExperience'] ?? 0;
      data['yearsOfExperience'] = data['years_of_experience'];
      data['experience_years'] = data['years_of_experience'];
      data['experienceYears'] = data['years_of_experience'];

      data['short_bio'] = data['bio'] ?? data['short_bio'] ?? data['shortBio'] ?? '';
      data['shortBio'] = data['short_bio'];
      data['bio'] = data['short_bio'];

      data['clinic_name'] = data['clinic_name'] ?? data['clinicName'] ?? '';
      data['clinicName'] = data['clinic_name'];

      data['clinic_location'] = resolvedClinicLoc;
      data['clinicLocation'] = resolvedClinicLoc;
      data['clinic_address'] = resolvedClinicLoc;
      data['clinicAddress'] = resolvedClinicLoc;

      data['clinic_hospital_address'] = resolvedClinicHosp;
      data['clinicHospitalAddress'] = resolvedClinicHosp;

      return data;
    }

    final directDoc = await FirebaseFirestore.instance
        .collection('doctor_profiles')
        .doc(doctorId)
        .get();
    if (directDoc.exists && directDoc.data() != null) {
      final data = Map<String, dynamic>.from(directDoc.data()!);
      data['id'] = directDoc.id;
      return enrichDoctorProfile(data);
    }

    for (final field in ['user_id', 'userId', 'doctor_id', 'doctorId']) {
      final snapshot = await FirebaseFirestore.instance
          .collection('doctor_profiles')
          .where(field, isEqualTo: doctorId)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = Map<String, dynamic>.from(snapshot.docs.first.data());
        data['id'] = snapshot.docs.first.id;
        return enrichDoctorProfile(data);
      }
    }

    final currentEmail = fb_auth.FirebaseAuth.instance.currentUser?.email;
    if (currentEmail != null && currentEmail.isNotEmpty) {
      final snapshot = await FirebaseFirestore.instance
          .collection('doctor_profiles')
          .where('email', isEqualTo: currentEmail)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = Map<String, dynamic>.from(snapshot.docs.first.data());
        data['id'] = snapshot.docs.first.id;
        return enrichDoctorProfile(data);
      }
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(doctorId)
        .get();
    if (userDoc.exists && userDoc.data() != null) {
      final data = Map<String, dynamic>.from(userDoc.data()!);
      data['id'] = doctorId;
      data['user_id'] = doctorId;

      // Smart clinic location vs physical address normalizer
      final List<String> kClinicLocations = [
        'North Nazimabad', 'Nazimabad', 'FB area', 'FB Area', 'Gulshan-e-Iqbal',
        'Gulistan-e-Johar', 'PCHS', 'SADDAR', 'Saddar', 'Shah faisal', 'Shah Faisal',
        'shahrah-e-faisal', 'Shahrah-e-Faisal', 'Malir'
      ];

      final dbClinicAddr = data['clinic_address'] ?? data['clinicAddress'];
      final dbClinicLoc = data['clinic_location'] ?? data['clinicLocation'];
      final dbClinicHosp = data['clinic_hospital_address'] ?? data['clinicHospitalAddress'];

      String resolvedClinicLoc = '';
      String resolvedClinicHosp = '';

      if (dbClinicLoc != null && dbClinicLoc.toString().isNotEmpty) {
        resolvedClinicLoc = dbClinicLoc.toString();
      }
      if (dbClinicHosp != null && dbClinicHosp.toString().isNotEmpty) {
        resolvedClinicHosp = dbClinicHosp.toString();
      }

      if (dbClinicAddr != null && dbClinicAddr.toString().isNotEmpty) {
        final isLoc = kClinicLocations.any((loc) => loc.toLowerCase().trim() == dbClinicAddr.toString().toLowerCase().trim());
        if (isLoc) {
          if (resolvedClinicLoc.isEmpty) resolvedClinicLoc = dbClinicAddr.toString();
        } else {
          if (resolvedClinicHosp.isEmpty) resolvedClinicHosp = dbClinicAddr.toString();
        }
      }

      // Normalize doctor profile fields for fallback user document
      data['years_of_experience'] = data['experience_years'] ?? data['experienceYears'] ?? data['years_of_experience'] ?? data['yearsOfExperience'] ?? 0;
      data['yearsOfExperience'] = data['years_of_experience'];
      data['experience_years'] = data['years_of_experience'];
      data['experienceYears'] = data['years_of_experience'];

      data['short_bio'] = data['bio'] ?? data['short_bio'] ?? data['shortBio'] ?? '';
      data['shortBio'] = data['short_bio'];
      data['bio'] = data['short_bio'];

      data['clinic_name'] = data['clinic_name'] ?? data['clinicName'] ?? '';
      data['clinicName'] = data['clinic_name'];

      data['clinic_location'] = resolvedClinicLoc;
      data['clinicLocation'] = resolvedClinicLoc;
      data['clinic_address'] = resolvedClinicLoc;
      data['clinicAddress'] = resolvedClinicLoc;

      data['clinic_hospital_address'] = resolvedClinicHosp;
      data['clinicHospitalAddress'] = resolvedClinicHosp;

      return data;
    }

    return null;
  }

  Set<String> _doctorIdentitySet(
    String userId,
    Map<String, dynamic>? profile,
  ) {
    return {
      userId,
      profile?['id'],
      profile?['user_id'],
      profile?['userId'],
      profile?['doctor_id'],
      profile?['doctorId'],
      profile?['name'],
      profile?['fullName'],
      profile?['full_name'],
      profile?['email'],
      profile?['emailAddress'],
    }
        .whereType<Object>()
        .map((id) => id.toString().trim())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  bool _appointmentBelongsToDoctor(
    Map<String, dynamic> data,
    Set<String> doctorIds,
  ) {
    final appointmentIds = {
      data['doctor_id'],
      data['doctorId'],
      data['doctor_profile_id'],
      data['doctorProfileId'],
      data['profile_id'],
      data['profileId'],
      data['doctor_name'],
      data['doctorName'],
      data['email'],
      data['doctorEmail'],
    }
        .whereType<Object>()
        .map((id) => id.toString().trim())
        .where((id) => id.isNotEmpty);
    return appointmentIds.any((id) => doctorIds.any((docId) => docId.toLowerCase() == id.toLowerCase()));
  }

  bool _matchesOptionalAppointmentFilters(
    Map<String, dynamic> data, {
    String? filter,
    String? dateVal,
  }) {
    if (filter != null && filter != 'All') {
      final status = (data['status'] ?? '').toString().toLowerCase();
      if (status != filter.toLowerCase()) return false;
    }
    if (dateVal != null) {
      final date = (data['slot_date'] ?? data['slotDate'] ?? data['date'] ?? '')
          .toString();
      if (date != dateVal) return false;
    }
    return true;
  }

  bool _isCancelledStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'cancelled' || normalized == 'canceled';
  }

  List<String> _slotsFromAvailability(
    dynamic availabilityValue,
    String? dateStr,
  ) {
    final fallbackSlots = [
      '09:00 AM - 09:30 AM',
      '09:30 AM - 10:00 AM',
      '10:00 AM - 10:30 AM',
      '10:30 AM - 11:00 AM',
      '11:00 AM - 11:30 AM',
      '11:30 AM - 12:00 PM',
      '12:00 PM - 12:30 PM',
      '12:30 PM - 01:00 PM',
      '02:00 PM - 02:30 PM',
      '02:30 PM - 03:00 PM',
      '03:00 PM - 03:30 PM',
      '03:30 PM - 04:00 PM',
      '04:00 PM - 04:30 PM',
      '04:30 PM - 05:00 PM',
      '05:00 PM - 05:30 PM',
      '05:30 PM - 06:00 PM',
      '06:00 PM - 06:30 PM',
      '06:30 PM - 07:00 PM',
    ];

    if (availabilityValue is List) {
      final slots = availabilityValue
          .map((slot) => slot.toString().trim())
          .where((slot) => slot.isNotEmpty)
          .toList();
      if (slots.isNotEmpty) return slots;
    }

    if (availabilityValue is Map) {
      final weekday = _weekdayName(dateStr);
      final directDaySlots = weekday == null
          ? null
          : availabilityValue[weekday] ??
                availabilityValue[weekday.toLowerCase()];
      if (directDaySlots is List) {
        final slots = directDaySlots
            .map((slot) => slot.toString().trim())
            .where((slot) => slot.isNotEmpty)
            .toList();
        if (slots.isNotEmpty) return slots;
      }

      for (final key in [
        'availableSlots',
        'slots',
        'time_slots',
        'timeSlots',
      ]) {
        final rawSlots = availabilityValue[key];
        if (rawSlots is List) {
          final slots = rawSlots
              .map((slot) => slot.toString().trim())
              .where((slot) => slot.isNotEmpty)
              .toList();
          if (slots.isNotEmpty) return slots;
        }
      }
    }

    final availability = (availabilityValue ?? 'Flexible').toString();
    final availabilityLower = availability.toLowerCase();
    final weekday = _weekdayName(dateStr)?.toLowerCase();
    final weekdays = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final mentionedWeekdays = weekdays
        .where(availabilityLower.contains)
        .toList();
    if (weekday != null &&
        mentionedWeekdays.isNotEmpty &&
        !mentionedWeekdays.contains(weekday)) {
      return [];
    }

    final parsedSlots = _parseTimeRanges(availability);
    if (parsedSlots.isNotEmpty) return parsedSlots;

    if (availabilityLower.contains('morning')) {
      return fallbackSlots
          .where((s) => s.contains('AM') || s.startsWith('11:30'))
          .toList();
    } else if (availabilityLower.contains('10') &&
        availabilityLower.contains('2')) {
      return fallbackSlots.where((s) {
        return s.startsWith('10:') ||
            s.startsWith('11:') ||
            s.startsWith('12:') ||
            s.startsWith('01:');
      }).toList();
    } else if (availabilityLower.contains('evening') ||
        availabilityLower.contains('weekend')) {
      return fallbackSlots.where((s) {
        return s.startsWith('04:') ||
            s.startsWith('05:') ||
            s.startsWith('06:');
      }).toList();
    }

    return fallbackSlots;
  }

  String? _weekdayName(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      final date = DateTime.parse(dateStr);
      return const [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ][date.weekday - 1];
    } catch (_) {
      return null;
    }
  }

  List<String> _parseTimeRanges(String value) {
    final slots = <String>[];
    final pattern = RegExp(
      r'(\d{1,2})(?::(\d{2}))?\s*(am|pm|AM|PM)\s*[-–—]\s*(\d{1,2})(?::(\d{2}))?\s*(am|pm|AM|PM)',
    );

    for (final match in pattern.allMatches(value)) {
      final start = _minutesFromTime(
        match.group(1),
        match.group(2),
        match.group(3),
      );
      final end = _minutesFromTime(
        match.group(4),
        match.group(5),
        match.group(6),
      );
      if (start == null || end == null || end <= start) continue;

      for (var cursor = start; cursor + 30 <= end; cursor += 30) {
        slots.add('${_formatMinutes(cursor)} - ${_formatMinutes(cursor + 30)}');
      }
    }

    return slots.toSet().toList();
  }

  int? _minutesFromTime(String? hourRaw, String? minuteRaw, String? periodRaw) {
    final hour = int.tryParse(hourRaw ?? '');
    final minute = int.tryParse(minuteRaw ?? '0') ?? 0;
    if (hour == null || hour < 1 || hour > 12 || minute < 0 || minute > 59) {
      return null;
    }

    final period = (periodRaw ?? '').toUpperCase();
    var normalizedHour = hour % 12;
    if (period == 'PM') normalizedHour += 12;
    return normalizedHour * 60 + minute;
  }

  String _formatMinutes(int totalMinutes) {
    final hour24 = (totalMinutes ~/ 60) % 24;
    final minute = totalMinutes % 60;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<Map<String, dynamic>?> fetchDoctorAvailability(
    String doctorId,
    String? dateStr,
  ) async {
    try {
      await _ensureFirebase();

      final profile = await _findDoctorProfile(doctorId);

      final rawAvailability =
          profile?['availability'] ??
          profile?['availableSlots'] ??
          profile?['slots'] ??
          profile?['time_slots'] ??
          profile?['timeSlots'] ??
          profile?['schedule'] ??
          'Flexible';
      final availability = profile?['availability'] ?? rawAvailability;
      final specialty = profile?['specialty'] ?? 'General Practice';
      final defaultSlots = _slotsFromAvailability(rawAvailability, dateStr);

      List<String> bookedSlots = [];
      if (dateStr != null) {
        final validDoctorIds = _doctorIdentitySet(doctorId, profile);

        try {
          final appSnapshot = await FirebaseFirestore.instance
              .collection('appointments')
              .get();

          bookedSlots = appSnapshot.docs
              .map((aDoc) => aDoc.data())
              .where((data) {
                final appDate =
                    (data['slot_date'] ??
                            data['slotDate'] ??
                            data['date'] ??
                            '')
                        .toString();
                final status = (data['status'] ?? '').toString();
                return _appointmentBelongsToDoctor(data, validDoctorIds) &&
                    appDate == dateStr &&
                    !_isCancelledStatus(status);
              })
              .map(
                (data) =>
                    (data['slot_time'] ??
                            data['slotTime'] ??
                            data['time_slot'] ??
                            data['timeSlot'] ??
                            '')
                        .toString(),
              )
              .where((slot) => slot.isNotEmpty)
              .toList();
        } catch (_) {
          bookedSlots = [];
        }
      }

      final availableSlots = defaultSlots
          .where((slot) => !bookedSlots.contains(slot))
          .toList();

      return {
        'success': true,
        'availability': availability.toString(),
        'specialty': specialty,
        'availableSlots': availableSlots,
      };
    } catch (_) {}
    return null;
  }

  Future<bool> bookAppointment({
    required String doctorId,
    required String patientName,
    required String date,
    required String timeSlot,
  }) async {
    try {
      await _ensureFirebase();
      // Run the network fetch and document creation in the background
      _bookAppointmentInBackground(
        doctorId: doctorId,
        date: date,
        timeSlot: timeSlot,
        patientName: patientName,
      );
      return true;
    } catch (_) {}
    return false;
  }

  Future<void> _bookAppointmentInBackground({
    required String doctorId,
    required String date,
    required String timeSlot,
    required String patientName,
  }) async {
    try {
      final doctorProfile = await _findDoctorProfile(doctorId);
      final profileId = doctorProfile?['id']?.toString() ?? doctorId;
      final doctorUserId =
          (doctorProfile?['user_id'] ?? doctorProfile?['userId'] ?? doctorId)
              .toString();
      final docName =
          doctorProfile?['full_name'] ??
          doctorProfile?['fullName'] ??
          doctorProfile?['name'] ??
          'Doctor';
      final doctorOrgName = doctorProfile?['organization_name'] ?? doctorProfile?['organizationName'] ?? '';
      final doctorEmployerId = doctorProfile?['employer_id'] ?? doctorProfile?['employerId'] ?? '';

      final specialty =
          doctorProfile?['specialty'] ??
          doctorProfile?['primary_specialty'] ??
          doctorProfile?['primarySpecialty'] ??
          'General Practice';

      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      String pEmail = fbUser?.email ?? '';
      String pPhone = '';
      if (fbUser != null) {
        try {
          final profileDoc = await FirebaseFirestore.instance
              .collection('patient_profiles')
              .doc(fbUser.uid)
              .get();
          if (profileDoc.exists && profileDoc.data() != null) {
            pEmail = profileDoc.data()?['email'] ?? pEmail;
            pPhone =
                profileDoc.data()?['phone'] ??
                profileDoc.data()?['phoneNumber'] ??
                '';
          }
        } catch (_) {}
      }

      final now = DateTime.now().toIso8601String();
      final appDoc = {
        'doctor_id': doctorUserId,
        'doctorId': doctorUserId,
        'doctor_profile_id': profileId,
        'doctor_name': docName,
        'doctorName': docName,
        'specialty': specialty,
        'primary_specialty': specialty,
        'patient_name': patientName,
        'patientName': patientName,
        'patient_id': fbUser?.uid ?? '',
        'patientId': fbUser?.uid ?? '',
        'patient_email': pEmail,
        'patientEmail': pEmail,
        'patient_phone': pPhone,
        'patientPhone': pPhone,
        'slot_date': date,
        'slotDate': date,
        'date': date,
        'slot_time': timeSlot,
        'slotTime': timeSlot,
        'time_slot': timeSlot,
        'timeSlot': timeSlot,
        'status': 'pending',
        'notes': '',
        'created_at': now,
        'createdAt': now,
        'organization_name': doctorOrgName,
        'organizationName': doctorOrgName,
        'employer_id': doctorEmployerId,
        'employerId': doctorEmployerId,
      };

      await FirebaseFirestore.instance.collection('appointments').add(appDoc);
      await fetchDoctorDashboard();
      await fetchPatientDashboard();
      await fetchEmployerDashboard();
    } catch (e) {
      debugPrint("Error booking appointment in background: $e");
    }
  }

  Future<List<Appointment>> searchAppointments(String patientName) async {
    try {
      await _ensureFirebase();
      final query = patientName.trim();
      if (query.isEmpty) return [];

      final snapshot1 = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientName', isEqualTo: query)
          .get();
      final snapshot2 = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patient_name', isEqualTo: query)
          .get();
      
      final seenAppIds = <String>{};
      final matchedDocs = <DocumentSnapshot>[];
      for (final snap in [snapshot1, snapshot2]) {
        for (final doc in snap.docs) {
          if (seenAppIds.add(doc.id)) {
            matchedDocs.add(doc);
          }
        }
      }

      if (matchedDocs.isEmpty) {
        final prefixSnapshot = await FirebaseFirestore.instance
            .collection('appointments')
            .where('patientName', isGreaterThanOrEqualTo: query)
            .where('patientName', isLessThanOrEqualTo: '$query\uf8ff')
            .limit(50)
            .get();
        for (final doc in prefixSnapshot.docs) {
          if (seenAppIds.add(doc.id)) {
            matchedDocs.add(doc);
          }
        }
      }

      final rawApps = matchedDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      final list = await compute(parseAppointments, rawApps);
      return list;
    } catch (_) {}
    return [];
  }

  Future<bool> cancelAppointment(String id) async {
    try {
      _cancelAppointmentInBackground(id);
      return true;
    } catch (_) {}
    return false;
  }

  Future<void> _cancelAppointmentInBackground(String id) async {
    try {
      await _ensureFirebase();
      final now = DateTime.now().toIso8601String();
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(id)
          .update({
            'status': 'cancelled',
            'cancelled_at': now,
            'cancelledAt': now,
          });
      await fetchDoctorDashboard();
      await fetchPatientDashboard();
      await fetchEmployerDashboard();
    } catch (e) {
      debugPrint("Error cancelling appointment in background: $e");
    }
  }

  Future<bool> rescheduleAppointment(
    String id,
    String newDate,
    String newSlot, {
    String? newDoctorId,
    String? newDoctorName,
    String? newSpecialty,
  }) async {
    try {
      _rescheduleAppointmentInBackground(
        id: id,
        newDate: newDate,
        newSlot: newSlot,
        newDoctorId: newDoctorId,
        newDoctorName: newDoctorName,
        newSpecialty: newSpecialty,
      );
      return true;
    } catch (_) {}
    return false;
  }

  Future<void> _rescheduleAppointmentInBackground({
    required String id,
    required String newDate,
    required String newSlot,
    String? newDoctorId,
    String? newDoctorName,
    String? newSpecialty,
  }) async {
    try {
      await _ensureFirebase();
      final now = DateTime.now().toIso8601String();
      final updates = <String, dynamic>{
        'slot_date': newDate,
        'slotDate': newDate,
        'date': newDate,
        'slot_time': newSlot,
        'slotTime': newSlot,
        'time_slot': newSlot,
        'timeSlot': newSlot,
        'rescheduled_at': now,
        'rescheduledAt': now,
      };
      if (newDoctorId != null) {
        final doctorProfile = await _findDoctorProfile(newDoctorId);
        final profileId = doctorProfile?['id']?.toString() ?? newDoctorId;
        final doctorUserId =
            (doctorProfile?['user_id'] ?? doctorProfile?['userId'] ?? newDoctorId)
                .toString();
        updates['doctor_id'] = doctorUserId;
        updates['doctorId'] = doctorUserId;
        updates['doctor_profile_id'] = profileId;
      }
      if (newDoctorName != null) {
        updates['doctor_name'] = newDoctorName;
        updates['doctorName'] = newDoctorName;
      }
      if (newSpecialty != null) {
        updates['specialty'] = newSpecialty;
        updates['primary_specialty'] = newSpecialty;
      }
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(id)
          .update(updates);
      await fetchDoctorDashboard();
      await fetchPatientDashboard();
      await fetchEmployerDashboard();
    } catch (e) {
      debugPrint("Error rescheduling appointment in background: $e");
    }
  }

  Future<void> fetchPatientDashboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _ensureFirebase();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        // 1. Fetch patient profile details
        final profileDoc = await FirebaseFirestore.instance
            .collection('patient_profiles')
            .doc(fbUser.uid)
            .get();
        Map<String, dynamic>? profileData = profileDoc.data();
        if (profileData == null) {
          final querySnapshot = await FirebaseFirestore.instance
              .collection('patient_profiles')
              .where('user_id', isEqualTo: fbUser.uid)
              .limit(1)
              .get();
          if (querySnapshot.docs.isNotEmpty) {
            profileData = querySnapshot.docs.first.data();
            profileData['id'] = querySnapshot.docs.first.id;
          } else {
            final querySnapshot2 = await FirebaseFirestore.instance
                .collection('patient_profiles')
                .where('userId', isEqualTo: fbUser.uid)
                .limit(1)
                .get();
            if (querySnapshot2.docs.isNotEmpty) {
              profileData = querySnapshot2.docs.first.data();
            }
          }
        }
        _patientProfile = profileData;

        final patientName =
            _patientProfile?['name'] ??
            _patientProfile?['full_name'] ??
            'Patient';

        // 2. Fetch live patient appointments
        final appSnapshot1 = await FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: fbUser.uid)
            .get();
        final appSnapshot2 = await FirebaseFirestore.instance
            .collection('appointments')
            .where('patient_id', isEqualTo: fbUser.uid)
            .get();
        final appSnapshot3 = fbUser.email != null && fbUser.email!.isNotEmpty
            ? await FirebaseFirestore.instance
                .collection('appointments')
                .where('patientEmail', isEqualTo: fbUser.email)
                .get()
            : null;
        final appSnapshot4 = fbUser.email != null && fbUser.email!.isNotEmpty
            ? await FirebaseFirestore.instance
                .collection('appointments')
                .where('patient_email', isEqualTo: fbUser.email)
                .get()
            : null;

        final seenDocIds = <String>{};
        final combinedDocs = [
          ...appSnapshot1.docs,
          ...appSnapshot2.docs,
          if (appSnapshot3 != null) ...appSnapshot3.docs,
          if (appSnapshot4 != null) ...appSnapshot4.docs,
        ].where((doc) => seenDocIds.add(doc.id)).toList();

        final rawApps = combinedDocs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

        final allApps = await compute(parseAppointments, rawApps);
        _patientAppointments = allApps.where((app) {
          final pEmail = app.patientEmail.toLowerCase().trim();
          final userEmail = (fbUser.email ?? '').toLowerCase().trim();
          final pName = app.patientName.toLowerCase().trim();
          final profileName = patientName.toLowerCase().trim();
          final patientId = app.patientId;

          final isSameEmail =
              pEmail.isNotEmpty && userEmail.isNotEmpty && pEmail == userEmail;
          final isSamePatientId = patientId.isNotEmpty && patientId == fbUser.uid;
          final isSameName =
              pName.isNotEmpty &&
              profileName.isNotEmpty &&
              profileName != 'patient' &&
              (profileName.contains(pName) || pName.contains(profileName));

          return isSamePatientId || isSameEmail || isSameName;
        }).toList();

        // Sort by date (descending)
        _patientAppointments.sort((a, b) => b.slotDate.compareTo(a.slotDate));

        // 3. Get counts
        final activeDocSnapshot = await FirebaseFirestore.instance
            .collection('doctor_profiles')
            .get();
        final totalDoctors = activeDocSnapshot.docs.length;

        final postSnapshot = await FirebaseFirestore.instance
            .collection('community_posts')
            .where('user_id', isEqualTo: fbUser.uid)
            .get();
        final postCount = postSnapshot.docs.length;

        final courseSnapshot = await FirebaseFirestore.instance
            .collection('patient_courses')
            .where('user_id', isEqualTo: fbUser.uid)
            .get();
        final courseCount = courseSnapshot.docs.length;

        _patientDashboard = {
          'stats': {
            'appointments': _patientAppointments.length,
            'courses': courseCount,
            'posts': postCount,
            'activeDoctors': totalDoctors,
          },
        };
      }
    } catch (e) {
      debugPrint("Error fetching patient dashboard: \$e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllRegisteredDoctors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ensureFirebase();
      
      // Fetch all user accounts
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      final usersMap = <String, Map<String, dynamic>>{};
      for (var doc in usersSnapshot.docs) {
        final userData = doc.data();
        final role = (userData['role'] ?? '').toString().toLowerCase().trim();
        if (role == 'doctor') {
          usersMap[doc.id] = userData;
        }
      }

      // Fetch all doctor profiles and map by user id
      final profilesSnapshot = await FirebaseFirestore.instance
          .collection('doctor_profiles')
          .get();

      final profilesMap = <String, Map<String, dynamic>>{};
      for (var doc in profilesSnapshot.docs) {
        final profileData = Map<String, dynamic>.from(doc.data());
        final uid = (profileData['user_id'] ?? profileData['userId'] ?? profileData['doctor_id'] ?? profileData['doctorId'] ?? doc.id).toString().trim();
        profilesMap[uid] = profileData;
      }

      final List<Map<String, dynamic>> enriched = [];

      for (var entry in usersMap.entries) {
        final uid = entry.key;
        final userData = entry.value;
        final profileData = profilesMap[uid] ?? <String, dynamic>{};

        final merged = <String, dynamic>{
          ...profileData,
          'id': uid,
          'user_id': uid,
        };

        final fullName = merged['full_name'] ?? merged['fullName'] ?? merged['name'] ?? userData['full_name'] ?? userData['name'] ?? '';
        final phone = merged['phone'] ?? merged['phoneNumber'] ?? userData['phone'] ?? userData['phoneNumber'] ?? '';
        final email = merged['email'] ?? userData['email'] ?? '';

        if (fullName.toString().trim().isNotEmpty) {
          merged['full_name'] = fullName;
          merged['phone'] = phone;
          merged['email'] = email;
          merged['specialty'] = merged['specialty'] ?? merged['speciality'] ?? userData['specialty'] ?? 'General Practice';
          merged['city'] = merged['city'] ?? userData['city'] ?? 'Karachi';
          merged['availability'] = merged['availability'] ?? 'Flexible';

          // Smart clinic location vs physical address normalizer
          final List<String> kClinicLocations = [
            'North Nazimabad', 'Nazimabad', 'FB area', 'FB Area', 'Gulshan-e-Iqbal',
            'Gulistan-e-Johar', 'PCHS', 'SADDAR', 'Saddar', 'Shah faisal', 'Shah Faisal',
            'shahrah-e-faisal', 'Shahrah-e-Faisal', 'Malir'
          ];

          final dbClinicAddr = merged['clinic_address'] ?? merged['clinicAddress'];
          final dbClinicLoc = merged['clinic_location'] ?? merged['clinicLocation'];
          final dbClinicHosp = merged['clinic_hospital_address'] ?? merged['clinicHospitalAddress'];

          String resolvedClinicLoc = '';
          String resolvedClinicHosp = '';

          if (dbClinicLoc != null && dbClinicLoc.toString().isNotEmpty) {
            resolvedClinicLoc = dbClinicLoc.toString();
          }
          if (dbClinicHosp != null && dbClinicHosp.toString().isNotEmpty) {
            resolvedClinicHosp = dbClinicHosp.toString();
          }

          if (dbClinicAddr != null && dbClinicAddr.toString().isNotEmpty) {
            final isLoc = kClinicLocations.any((loc) => loc.toLowerCase().trim() == dbClinicAddr.toString().toLowerCase().trim());
            if (isLoc) {
              if (resolvedClinicLoc.isEmpty) resolvedClinicLoc = dbClinicAddr.toString();
            } else {
              if (resolvedClinicHosp.isEmpty) resolvedClinicHosp = dbClinicAddr.toString();
            }
          }

          // Normalize doctor profile fields
          merged['years_of_experience'] = merged['experience_years'] ?? merged['experienceYears'] ?? merged['years_of_experience'] ?? merged['yearsOfExperience'] ?? 0;
          merged['yearsOfExperience'] = merged['years_of_experience'];
          merged['experience_years'] = merged['years_of_experience'];
          merged['experienceYears'] = merged['years_of_experience'];

          merged['short_bio'] = merged['bio'] ?? merged['short_bio'] ?? merged['shortBio'] ?? '';
          merged['shortBio'] = merged['short_bio'];
          merged['bio'] = merged['short_bio'];

          merged['clinic_name'] = merged['clinic_name'] ?? merged['clinicName'] ?? '';
          merged['clinicName'] = merged['clinic_name'];

          merged['clinic_location'] = resolvedClinicLoc;
          merged['clinicLocation'] = resolvedClinicLoc;
          merged['clinic_address'] = resolvedClinicLoc;
          merged['clinicAddress'] = resolvedClinicLoc;

          merged['clinic_hospital_address'] = resolvedClinicHosp;
          merged['clinicHospitalAddress'] = resolvedClinicHosp;

          enriched.add(merged);
        }
      }

      _registeredDoctors = enriched;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error fetching registered doctors: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startCourse(String courseId, String courseTitle) async {
    try {
      await _ensureFirebase();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (fbUser == null) return;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(fbUser.uid)
          .get();
      final role = (userDoc.data()?['role'] ?? '').toString();
      final collectionName = role == 'doctor' ? 'doctor_courses' : 'patient_courses';

      final existing = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('user_id', isEqualTo: fbUser.uid)
          .where('course_id', isEqualTo: courseId)
          .get();

      if (existing.docs.isEmpty) {
        await FirebaseFirestore.instance.collection(collectionName).add({
          'user_id': fbUser.uid,
          'course_id': courseId,
          'courseId': courseId,
          'course_title': courseTitle,
          'courseTitle': courseTitle,
          'started_at': DateTime.now().toIso8601String(),
          'startedAt': DateTime.now().toIso8601String(),
        });
        if (role == 'doctor') {
          await fetchDoctorDashboard();
        } else {
          await fetchPatientDashboard();
        }
      }
    } catch (_) {}
  }

  // =========================================================================
  // 2. DOCTOR ENDPOINTS
  // =========================================================================

  Future<void> fetchDoctorDashboard({String? doctorId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _ensureFirebase();
      String? uid = doctorId;
      if (uid == null) {
        final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
        uid = fbUser?.uid;
      }
      if (uid != null) {
        _doctorProfile = await _findDoctorProfile(uid);
        final doctorIds = _doctorIdentitySet(uid, _doctorProfile);

        final List<Future<QuerySnapshot>> appQueries = [];
        for (final id in doctorIds) {
          appQueries.add(FirebaseFirestore.instance
              .collection('appointments')
              .where('doctor_id', isEqualTo: id)
              .get());
          appQueries.add(FirebaseFirestore.instance
              .collection('appointments')
              .where('doctorId', isEqualTo: id)
              .get());
          appQueries.add(FirebaseFirestore.instance
              .collection('appointments')
              .where('doctor_profile_id', isEqualTo: id)
              .get());
          appQueries.add(FirebaseFirestore.instance
              .collection('appointments')
              .where('doctorProfileId', isEqualTo: id)
              .get());
        }
        final appSnapshots = await Future.wait(appQueries);
        final seenAppIds = <String>{};
        final appointmentDocs = <DocumentSnapshot>[];
        for (final snap in appSnapshots) {
          for (final doc in snap.docs) {
            if (seenAppIds.add(doc.id)) {
              appointmentDocs.add(doc);
            }
          }
        }

        final rawApps = appointmentDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        _doctorAppointments = await compute(parseAppointments, rawApps);

        _doctorInterviews = [];

        final List<Future<QuerySnapshot>> credQueries = [];
        for (final id in doctorIds) {
          credQueries.add(FirebaseFirestore.instance
              .collection('credentials')
              .where('doctor_id', isEqualTo: id)
              .get());
          credQueries.add(FirebaseFirestore.instance
              .collection('credentials')
              .where('doctorId', isEqualTo: id)
              .get());
          credQueries.add(FirebaseFirestore.instance
              .collection('credentials')
              .where('doctor_profile_id', isEqualTo: id)
              .get());
          credQueries.add(FirebaseFirestore.instance
              .collection('credentials')
              .where('doctorProfileId', isEqualTo: id)
              .get());
        }
        final credSnapshots = await Future.wait(credQueries);
        final seenCredIds = <String>{};
        final credDocs = <DocumentSnapshot>[];
        for (final snap in credSnapshots) {
          for (final doc in snap.docs) {
            if (seenCredIds.add(doc.id)) {
              credDocs.add(doc);
            }
          }
        }

        final rawCreds = credDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        _doctorCredentials = await compute(parseCredentials, rawCreds);

        final verifiedCount = _doctorCredentials
            .where((c) => c.verified == 1)
            .length;

        final activeApps = _doctorAppointments
            .where((app) => app.status.toLowerCase() != 'cancelled')
            .toList();

        _doctorDashboard = {
          'success': true,
          'profile': _doctorProfile,
          'appointments': rawApps,
          'stats': {
            'appointments': activeApps.length,
            'credentials': _doctorCredentials.length,
            'verifiedCredentials': verifiedCount,
          },
        };

        final profilesSnapshot = await FirebaseFirestore.instance
            .collection('employer_profiles')
            .get();
        final phoneMap = <String, String>{};
        for (final doc in profilesSnapshot.docs) {
          final pData = doc.data();
          final phone = pData['phone'] ?? pData['phoneNumber'] ?? pData['contact_phone'] ?? pData['contactPhone'] ?? '';
          if (phone.isNotEmpty) {
            phoneMap[doc.id] = phone;
            final uId = pData['user_id'] ?? pData['userId'] ?? '';
            if (uId.isNotEmpty) {
              phoneMap[uId] = phone;
            }
          }
        }

        final jobsSnapshot = await FirebaseFirestore.instance
            .collection('jobs')
            .where('status', isEqualTo: 'open')
            .limit(10)
            .get();

        _doctorDashboard!['recommended'] = jobsSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          final empId = data['employer_id'] ?? data['employerId'] ?? '';
          if (data['employer_phone'] == null && data['employerPhone'] == null) {
            final phone = phoneMap[empId];
            if (phone != null) {
              data['employer_phone'] = phone;
              data['employerPhone'] = phone;
            }
          }
          return data;
        }).toList();
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchDoctorCredentials({String? doctorId}) async {
    try {
      await _ensureFirebase();
      String? uid = doctorId;
      if (uid == null) {
        final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
        uid = fbUser?.uid;
      }
      if (uid != null) {
        final profile = _doctorProfile ?? await _findDoctorProfile(uid);
        final doctorIds = _doctorIdentitySet(uid, profile);

        final List<Future<QuerySnapshot>> credQueries = [];
        for (final id in doctorIds) {
          credQueries.add(FirebaseFirestore.instance
              .collection('credentials')
              .where('doctor_id', isEqualTo: id)
              .get());
          credQueries.add(FirebaseFirestore.instance
              .collection('credentials')
              .where('doctorId', isEqualTo: id)
              .get());
          credQueries.add(FirebaseFirestore.instance
              .collection('credentials')
              .where('doctor_profile_id', isEqualTo: id)
              .get());
          credQueries.add(FirebaseFirestore.instance
              .collection('credentials')
              .where('doctorProfileId', isEqualTo: id)
              .get());
        }
        final credSnapshots = await Future.wait(credQueries);
        final seenCredIds = <String>{};
        final credDocs = <DocumentSnapshot>[];
        for (final snap in credSnapshots) {
          for (final doc in snap.docs) {
            if (seenCredIds.add(doc.id)) {
              credDocs.add(doc);
            }
          }
        }

        final rawCreds = credDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        _doctorCredentials = await compute(parseCredentials, rawCreds);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> uploadCredential(
    String type,
    String title,
    String filePath, {
    String? doctorId,
  }) async {
    try {
      await _ensureFirebase();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      final searchId = doctorId ?? fbUser?.uid;
      if (searchId == null) return false;
      final profile = _doctorProfile ?? await _findDoctorProfile(searchId);
      final profileId = profile?['id']?.toString() ?? searchId;

      final credDoc = {
        'doctor_id': searchId,
        'doctorId': searchId,
        'doctor_profile_id': profileId,
        'doctorProfileId': profileId,
        'cred_type': type,
        'credType': type,
        'title': title,
        'file_path': filePath,
        'filePath': filePath,
        'verified': 0,
        'uploaded_at': DateTime.now().toIso8601String(),
        'uploadedAt': DateTime.now().toIso8601String(),
      };

      await FirebaseFirestore.instance.collection('credentials').add(credDoc);
      await fetchDoctorCredentials(doctorId: searchId);
      await fetchDoctorDashboard(doctorId: searchId);
      return true;
    } catch (_) {}
    return false;
  }

  Future<bool> deleteCredential(String credentialId, {String? doctorId}) async {
    try {
      await _ensureFirebase();
      await FirebaseFirestore.instance
          .collection('credentials')
          .doc(credentialId)
          .delete();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      final searchId = doctorId ?? fbUser?.uid;
      await fetchDoctorCredentials(doctorId: searchId);
      await fetchDoctorDashboard(doctorId: searchId);
      return true;
    } catch (_) {}
    return false;
  }

  Future<bool> saveCv(Map<String, String> cvData, {String? doctorId}) async {
    try {
      await _ensureFirebase();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      final searchId = doctorId ?? fbUser?.uid;
      if (searchId == null) return false;
      final profile = _doctorProfile ?? await _findDoctorProfile(searchId);
      final profileId = profile?['id']?.toString() ?? searchId;
      final mergedCvData = <String, String>{
        ...cvData,
        'cvSummary': cvData['cv_summary'] ?? '',
        'cvSkills': cvData['cv_skills'] ?? '',
        'cvExperience': cvData['cv_experience'] ?? '',
        'cvEducation': cvData['cv_education'] ?? '',
        'cvCertifications': cvData['cv_certifications'] ?? '',
      };

      await FirebaseFirestore.instance
          .collection('doctor_profiles')
          .doc(profileId)
          .set(mergedCvData, SetOptions(merge: true));

      await fetchDoctorDashboard(doctorId: searchId);

      return true;
    } catch (_) {}
    return false;
  }

  Future<bool> saveAvailability({
    required String availability,
    required bool openToRemote,
    required double hourlyRate,
    String? doctorId,
  }) async {
    try {
      await _ensureFirebase();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      final searchId = doctorId ?? fbUser?.uid;
      if (searchId == null) return false;
      final profile = _doctorProfile ?? await _findDoctorProfile(searchId);
      final profileId = profile?['id']?.toString() ?? searchId;

      await FirebaseFirestore.instance
          .collection('doctor_profiles')
          .doc(profileId)
          .set({
            'availability': availability,
            'open_to_remote': openToRemote ? 1 : 0,
            'openToRemote': openToRemote,
            'hourly_rate': hourlyRate,
            'hourlyRate': hourlyRate,
          }, SetOptions(merge: true));

      await fetchDoctorDashboard(doctorId: searchId);

      return true;
    } catch (_) {}
    return false;
  }

  Future<void> fetchDoctorAppointments({
    String? filter,
    String? dateVal,
    String? doctorId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _ensureFirebase();
      String? uid = doctorId;
      if (uid == null) {
        final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
        uid = fbUser?.uid;
      }
      if (uid != null) {
        final profile = _doctorProfile ?? await _findDoctorProfile(uid);
        final doctorIds = _doctorIdentitySet(uid, profile);

        final List<Future<QuerySnapshot>> appQueries = [];
        for (final id in doctorIds) {
          appQueries.add(FirebaseFirestore.instance
              .collection('appointments')
              .where('doctor_id', isEqualTo: id)
              .get());
          appQueries.add(FirebaseFirestore.instance
              .collection('appointments')
              .where('doctorId', isEqualTo: id)
              .get());
          appQueries.add(FirebaseFirestore.instance
              .collection('appointments')
              .where('doctor_profile_id', isEqualTo: id)
              .get());
          appQueries.add(FirebaseFirestore.instance
              .collection('appointments')
              .where('doctorProfileId', isEqualTo: id)
              .get());
        }

        final appSnapshots = await Future.wait(appQueries);
        final seenAppIds = <String>{};
        final appointmentDocs = <DocumentSnapshot>[];
        for (final snap in appSnapshots) {
          for (final doc in snap.docs) {
            if (seenAppIds.add(doc.id)) {
              appointmentDocs.add(doc);
            }
          }
        }

        final rawApps = appointmentDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).where((data) {
          return _matchesOptionalAppointmentFilters(
            data,
            filter: filter,
            dateVal: dateVal,
          );
        }).toList();

        _doctorAppointments = await compute(parseAppointments, rawApps);
      }
    } catch (_) {} finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDoctorApplications({String? doctorId}) async {
    try {
      await _ensureFirebase();
      String? uid = doctorId;
      if (uid == null) {
        final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
        uid = fbUser?.uid;
      }
      if (uid != null) {
        final profile = _doctorProfile ?? await _findDoctorProfile(uid);
        final doctorIds = _doctorIdentitySet(uid, profile);
        final snapshot = await FirebaseFirestore.instance
            .collection('applications')
            .get();

        var apps = <Map<String, dynamic>>[];
        for (var doc in snapshot.docs.where((doc) {
          final data = doc.data();
          final applicationDoctorIds = {
            data['doctor_id'],
            data['doctorId'],
            data['doctor_profile_id'],
            data['doctorProfileId'],
          }.whereType<Object>().map((id) => id.toString());
          return applicationDoctorIds.any(doctorIds.contains);
        })) {
          final data = doc.data();
          data['id'] = doc.id;

          final jobId = data['job_id'] ?? data['jobId'];
          if (jobId != null) {
            final jobDoc = await FirebaseFirestore.instance
                .collection('jobs')
                .doc(jobId)
                .get();
            if (jobDoc.exists && jobDoc.data() != null) {
              final jobData = jobDoc.data()!;
              data['job_title'] = jobData['title'] ?? 'Job Position';
              data['organization_name'] =
                  jobData['organization_name'] ?? 'DocStep Partner';
              data['city'] = jobData['city'] ?? '';
            }
          }
          apps.add(data);
        }

        _doctorApplications = apps;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> applyToJob(String jobId, String coverLetter, {String? doctorId}) async {
    try {
      await _ensureFirebase();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      final searchId = doctorId ?? fbUser?.uid;
      if (searchId == null) return false;
      final profile = _doctorProfile ?? await _findDoctorProfile(searchId);
      final profileId = profile?['id']?.toString() ?? searchId;

      final appDoc = {
        'doctor_id': searchId,
        'doctorId': searchId,
        'doctor_profile_id': profileId,
        'doctorProfileId': profileId,
        'job_id': jobId,
        'jobId': jobId,
        'cover_letter': coverLetter,
        'coverLetter': coverLetter,
        'status': 'pending',
        'applied_at': DateTime.now().toIso8601String(),
        'appliedAt': DateTime.now().toIso8601String(),
      };

      await FirebaseFirestore.instance.collection('applications').add(appDoc);
      return true;
    } catch (_) {}
    return false;
  }

  Future<bool> updateDoctorProfile(Map<String, dynamic> profileData, {String? doctorId}) async {
    try {
      await _ensureFirebase();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      final searchId = doctorId ?? fbUser?.uid;
      if (searchId == null) return false;
      final profile = _doctorProfile ?? await _findDoctorProfile(searchId);
      final profileId = profile?['id']?.toString() ?? searchId;

      final finalFullName = profileData['full_name'] ?? profileData['fullName'] ?? profileData['name'] ?? '';
      final finalPhone = profileData['phone'] ?? profileData['phoneNumber'] ?? '';
      final finalYearsExp = profileData['experience_years'] ?? profileData['experienceYears'] ?? profileData['years_of_experience'] ?? profileData['yearsOfExperience'] ?? 0;
      final finalPmdc = profileData['pmdc_number'] ?? profileData['pmdcNumber'] ?? '';
      final finalBio = profileData['bio'] ?? profileData['short_bio'] ?? profileData['shortBio'] ?? '';
      final finalHourlyRate = profileData['hourly_rate'] ?? profileData['hourlyRate'] ?? 0.0;
      final finalClinicName = profileData['clinic_name'] ?? profileData['clinicName'] ?? '';
      final finalClinicLoc = profileData['clinic_address'] ?? profileData['clinicAddress'] ?? profileData['clinic_location'] ?? profileData['clinicLocation'] ?? '';
      final finalClinicAddr = profileData['clinic_hospital_address'] ?? profileData['clinicHospitalAddress'] ?? '';

      final doctorProfileFuture = FirebaseFirestore.instance
          .collection('doctor_profiles')
          .doc(profileId)
          .set({
            ...profileData,
            'name': finalFullName,
            'fullName': finalFullName,
            'full_name': finalFullName,
            'phone': finalPhone,
            'phoneNumber': finalPhone,
            'years_of_experience': finalYearsExp,
            'yearsOfExperience': finalYearsExp,
            'experience_years': finalYearsExp,
            'experienceYears': finalYearsExp,
            'pmdc_number': finalPmdc,
            'pmdcNumber': finalPmdc,
            'short_bio': finalBio,
            'shortBio': finalBio,
            'bio': finalBio,
            'hourly_rate': finalHourlyRate,
            'hourlyRate': finalHourlyRate,
            'clinic_name': finalClinicName,
            'clinicName': finalClinicName,
            'clinic_location': finalClinicLoc,
            'clinicLocation': finalClinicLoc,
            'clinic_address': finalClinicLoc,
            'clinicAddress': finalClinicLoc,
            'clinic_hospital_address': finalClinicAddr,
            'clinicHospitalAddress': finalClinicAddr,
            'open_to_remote': profileData['open_to_remote'] == 1 || profileData['openToRemote'] == true,
            'openToRemote': profileData['open_to_remote'] == 1 || profileData['openToRemote'] == true,
            'user_id': searchId,
            'email': profileData['email'] ?? fbUser?.email,
          }, SetOptions(merge: true));

      final userUpdates = <String, dynamic>{};
      if (profileData.containsKey('full_name') || profileData.containsKey('fullName')) {
        userUpdates['full_name'] = finalFullName;
      }
      if (profileData.containsKey('phone') || profileData.containsKey('phoneNumber')) {
        userUpdates['phone'] = finalPhone;
      }
      
      Future? userUpdatesFuture;
      if (userUpdates.isNotEmpty) {
        userUpdatesFuture = FirebaseFirestore.instance
            .collection('users')
            .doc(searchId)
            .update(userUpdates);
      }

      // Execute operations and refresh dashboard
      final List<Future> futures = [doctorProfileFuture];
      if (userUpdatesFuture != null) {
        futures.add(userUpdatesFuture);
      }
      await Future.wait(futures);
      await fetchDoctorDashboard(doctorId: searchId);

      return true;
    } catch (_) {}
    return false;
  }

  // =========================================================================
  // 3. EMPLOYER ENDPOINTS
  // =========================================================================

  Future<void> fetchEmployerDashboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _ensureFirebase();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        final profileDoc = await FirebaseFirestore.instance
            .collection('employer_profiles')
            .doc(fbUser.uid)
            .get();
        Map<String, dynamic>? profileData = profileDoc.data();
        if (profileData != null) {
          profileData['id'] = profileDoc.id;
        }
        if (profileData == null) {
          final querySnapshot = await FirebaseFirestore.instance
              .collection('employer_profiles')
              .where('user_id', isEqualTo: fbUser.uid)
              .limit(1)
              .get();
          if (querySnapshot.docs.isNotEmpty) {
            profileData = querySnapshot.docs.first.data();
            profileData['id'] = querySnapshot.docs.first.id;
          } else {
            final querySnapshot2 = await FirebaseFirestore.instance
                .collection('employer_profiles')
                .where('userId', isEqualTo: fbUser.uid)
                .limit(1)
                .get();
            if (querySnapshot2.docs.isNotEmpty) {
              profileData = querySnapshot2.docs.first.data();
              profileData['id'] = querySnapshot2.docs.first.id;
            } else {
              final querySnapshot3 = await FirebaseFirestore.instance
                  .collection('employer_profiles')
                  .where('employer_id', isEqualTo: fbUser.uid)
                  .limit(1)
                  .get();
              if (querySnapshot3.docs.isNotEmpty) {
                profileData = querySnapshot3.docs.first.data();
                profileData['id'] = querySnapshot3.docs.first.id;
              } else {
                final querySnapshot4 = await FirebaseFirestore.instance
                    .collection('employer_profiles')
                    .where('employerId', isEqualTo: fbUser.uid)
                    .limit(1)
                    .get();
                if (querySnapshot4.docs.isNotEmpty) {
                  profileData = querySnapshot4.docs.first.data();
                  profileData['id'] = querySnapshot4.docs.first.id;
                } else if (fbUser.email != null && fbUser.email!.isNotEmpty) {
                  final querySnapshot5 = await FirebaseFirestore.instance
                      .collection('employer_profiles')
                      .where('email', isEqualTo: fbUser.email)
                      .limit(1)
                      .get();
                  if (querySnapshot5.docs.isNotEmpty) {
                    profileData = querySnapshot5.docs.first.data();
                    profileData['id'] = querySnapshot5.docs.first.id;
                  }
                }
              }
            }
          }
        }
        _employerDashboard = profileData;

        final orgName =
            profileData?['organization_name'] ??
            profileData?['organizationName'] ??
            profileData?['name'] ??
            profileData?['company_name'] ??
            profileData?['companyName'] ??
            profileData?['company'] ??
            '';

        final Set<String> employerIds = {fbUser.uid};
        if (profileData != null) {
          final pDocId = profileData['id']?.toString() ?? '';
          if (pDocId.isNotEmpty) {
            employerIds.add(pDocId);
          }
          final pUserId = profileData['user_id']?.toString() ?? profileData['userId']?.toString() ?? '';
          if (pUserId.isNotEmpty) {
            employerIds.add(pUserId);
          }
          final pEmpId = profileData['employer_id']?.toString() ?? profileData['employerId']?.toString() ?? '';
          if (pEmpId.isNotEmpty) {
            employerIds.add(pEmpId);
          }
        }

        final List<QueryDocumentSnapshot<Map<String, dynamic>>> combinedJobsDocs = [];
        for (final empId in employerIds) {
          final snap1 = await FirebaseFirestore.instance
              .collection('jobs')
              .where('employer_id', isEqualTo: empId)
              .get();
          combinedJobsDocs.addAll(snap1.docs);

          final snap2 = await FirebaseFirestore.instance
              .collection('jobs')
              .where('employerId', isEqualTo: empId)
              .get();
          combinedJobsDocs.addAll(snap2.docs);
        }

        if (orgName.isNotEmpty) {
          final snap3 = await FirebaseFirestore.instance
              .collection('jobs')
              .where('organization_name', isEqualTo: orgName)
              .get();
          combinedJobsDocs.addAll(snap3.docs);

          final snap4 = await FirebaseFirestore.instance
              .collection('jobs')
              .where('organizationName', isEqualTo: orgName)
              .get();
          combinedJobsDocs.addAll(snap4.docs);
        }

        final seenJobIds = <String>{};
        final uniqueJobs = combinedJobsDocs
            .where((doc) => seenJobIds.add(doc.id))
            .toList();

        final rawJobs = uniqueJobs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();

        _employerJobs = await compute(parseJobs, rawJobs);

        final List<QueryDocumentSnapshot<Map<String, dynamic>>> combinedAppsDocs = [];
        for (final empId in employerIds) {
          final snap1 = await FirebaseFirestore.instance
              .collection('appointments')
              .where('employer_id', isEqualTo: empId)
              .get();
          combinedAppsDocs.addAll(snap1.docs);

          final snap2 = await FirebaseFirestore.instance
              .collection('appointments')
              .where('employerId', isEqualTo: empId)
              .get();
          combinedAppsDocs.addAll(snap2.docs);
        }

        final snap3 = await FirebaseFirestore.instance
            .collection('appointments')
            .limit(100)
            .get();
        combinedAppsDocs.addAll(snap3.docs);

        final seenEmployerAppIds = <String>{};
        final employerAppDocs = <DocumentSnapshot>[];
        for (final doc in combinedAppsDocs) {
          if (seenEmployerAppIds.add(doc.id)) {
            employerAppDocs.add(doc);
          }
        }

        final rawApps = employerAppDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        _employerAppointments = await compute(parseAppointments, rawApps);

        _employerInterviews = [];

        final activeEmployerApps = _employerAppointments
            .where((app) => app.status.toLowerCase() != 'cancelled')
            .toList();

        _employerDashboard = {
          'success': true,
          'profile': profileData,
          'jobs': _employerJobs.map((j) => j.id).toList(),
          'appointments': _employerAppointments.map((a) => a.id).toList(),
          'stats': {
            'jobs': _employerJobs.length,
            'appointments': activeEmployerApps.length,
            'pendingApplications': 0,
          },
        };
      }
    } catch (e, stack) {
      debugPrint("Error in fetchEmployerDashboard: $e");
      debugPrint(stack.toString());
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> postJob(Map<String, dynamic> jobData) async {
    try {
      _postJobInBackground(jobData);
    } catch (_) {}
  }

  Future<void> _postJobInBackground(Map<String, dynamic> jobData) async {
    try {
      await _ensureFirebase();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (fbUser == null) return;

      if (_employerDashboard == null) {
        await fetchEmployerDashboard();
      }
      final profileData = _employerDashboard?['profile'];
      final orgName =
          profileData?['organization_name'] ??
          profileData?['organizationName'] ??
          profileData?['name'] ??
          'DocStep Partner';
      final orgLogo =
          profileData?['organization_logo'] ?? profileData?['organizationLogo'] ?? '';
      final orgAbout =
          profileData?['organization_about'] ?? profileData?['organizationAbout'] ?? '';
      final orgPhone =
          profileData?['phone'] ??
          profileData?['phoneNumber'] ??
          profileData?['contact_phone'] ??
          profileData?['contactPhone'] ??
          jobData['employer_phone'] ??
          jobData['employerPhone'] ??
          '';

      final profileId = (profileData?['id'] ?? profileData?['user_id'] ?? profileData?['userId'] ?? fbUser.uid).toString();

      final jobDoc = Map<String, dynamic>.from(jobData);
      jobDoc['employer_id'] = profileId;
      jobDoc['employerId'] = profileId;
      jobDoc['status'] = 'open';
      jobDoc['posted_at'] = DateTime.now().toIso8601String();
      jobDoc['postedAt'] = jobDoc['posted_at'];
      jobDoc['organization_name'] = orgName;
      jobDoc['organizationName'] = orgName;
      jobDoc['organization_logo'] = orgLogo;
      jobDoc['organizationLogo'] = orgLogo;
      jobDoc['organization_about'] = orgAbout;
      jobDoc['organizationAbout'] = orgAbout;
      jobDoc['employer_phone'] = orgPhone;
      jobDoc['employerPhone'] = orgPhone;

      await FirebaseFirestore.instance.collection('jobs').add(jobDoc);
      await fetchEmployerDashboard();
    } catch (e) {
      debugPrint("Error in _postJobInBackground: $e");
    }
  }

  Future<void> editJob(String id, Map<String, dynamic> jobData) async {
    try {
      _editJobInBackground(id, jobData);
    } catch (_) {}
  }

  Future<void> _editJobInBackground(String id, Map<String, dynamic> jobData) async {
    try {
      await _ensureFirebase();
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(id)
          .update(jobData);
      await fetchEmployerDashboard();
    } catch (_) {}
  }

  Future<void> deleteJob(String id) async {
    try {
      _employerJobs.removeWhere((job) => job.id == id);
      notifyListeners();
      _deleteJobInBackground(id);
    } catch (e) {
      debugPrint("Error deleting job: $e");
    }
  }

  Future<void> _deleteJobInBackground(String id) async {
    try {
      await _ensureFirebase();
      await FirebaseFirestore.instance.collection('jobs').doc(id).delete();
      await fetchEmployerDashboard();
    } catch (_) {}
  }

  Future<void> searchCandidates({
    String? q,
    String? specialty,
    String? city,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _ensureFirebase();
      Query query = FirebaseFirestore.instance.collection('doctor_profiles');

      if (specialty != null && specialty.isNotEmpty) {
        query = query.where('specialty', isEqualTo: specialty);
      }
      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }

      final snapshot = await query.get();

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();

      final usersMap = <String, Map<String, dynamic>>{};
      for (var d in usersSnapshot.docs) {
        usersMap[d.id] = d.data();
      }

      var profiles = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final uid = data['user_id'] ?? data['userId'] ?? doc.id;
        data['user_id'] = uid;

        final userDoc = usersMap[uid];
        if (userDoc != null) {
          data['name'] =
              data['name'] ??
              userDoc['name'] ??
              userDoc['full_name'] ??
              userDoc['fullName'];
          data['full_name'] =
              data['full_name'] ??
              userDoc['full_name'] ??
              userDoc['name'] ??
              userDoc['fullName'];
          data['email'] = data['email'] ?? userDoc['email'];
          data['phone'] = data['phone'] ?? userDoc['phone'];
        }
        return data;
      }).toList();

      if (q != null && q.isNotEmpty) {
        final lowerQ = q.toLowerCase();
        profiles = profiles
            .where(
              (p) =>
                  (p['full_name'] ?? '').toString().toLowerCase().contains(
                    lowerQ,
                  ) ||
                  (p['specialty'] ?? '').toString().toLowerCase().contains(
                    lowerQ,
                  ),
            )
            .toList();
      }

      _candidates = profiles.map((p) {
        final uid = p['user_id'] ?? p['userId'] ?? '';
        final name = p['name'] ?? p['full_name'] ?? p['fullName'] ?? 'Doctor';
        final email = p['email'] ?? p['emailAddress'] ?? 'Not provided';
        final phone = p['phone'] ?? p['phoneNumber'] ?? 'Not provided';
        return User(
          userId: uid,
          fullName: name,
          email: email,
          role: 'doctor',
          phone: phone,
        );
      }).toList();

      final allDocsSnapshot = await FirebaseFirestore.instance
          .collection('doctor_profiles')
          .get();
      final allProfiles = allDocsSnapshot.docs.map((d) => d.data()).toList();

      _candidateSpecialties = allProfiles
          .map((p) => (p['specialty'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();

      _candidateCities = allProfiles
          .map((p) => (p['city'] ?? '').toString())
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getCandidateDetails(String doctorId) async {
    try {
      await _ensureFirebase();
      final profileDoc = await FirebaseFirestore.instance
          .collection('doctor_profiles')
          .doc(doctorId)
          .get();

      Map<String, dynamic>? profileData = profileDoc.data();
      if (profileData == null) {
        for (final field in ['user_id', 'userId', 'doctor_id', 'doctorId']) {
          final querySnapshot = await FirebaseFirestore.instance
              .collection('doctor_profiles')
              .where(field, isEqualTo: doctorId)
              .limit(1)
              .get();
          if (querySnapshot.docs.isNotEmpty) {
            profileData = querySnapshot.docs.first.data();
            break;
          }
        }
      }

      final credSnapshot1 = await FirebaseFirestore.instance
          .collection('credentials')
          .where('doctor_id', isEqualTo: doctorId)
          .get();
      final credSnapshot2 = await FirebaseFirestore.instance
          .collection('credentials')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      final combinedCredDocs = [...credSnapshot1.docs, ...credSnapshot2.docs];
      final seenCredIds = <String>{};
      final uniqueCredDocs = combinedCredDocs
          .where((doc) => seenCredIds.add(doc.id))
          .toList();

      if (profileData != null) {
        final uid = profileData['user_id'] ?? profileData['userId'] ?? doctorId;
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;
          profileData['name'] =
              profileData['name'] ??
              userData['name'] ??
              userData['full_name'] ??
              userData['fullName'];
          profileData['full_name'] =
              profileData['full_name'] ??
              userData['full_name'] ??
              userData['name'] ??
              userData['fullName'];
          profileData['email'] = profileData['email'] ?? userData['email'];
          profileData['phone'] = profileData['phone'] ?? userData['phone'];
        }

        // Smart clinic location vs physical address normalizer
        final List<String> kClinicLocations = [
          'North Nazimabad', 'Nazimabad', 'FB area', 'FB Area', 'Gulshan-e-Iqbal',
          'Gulistan-e-Johar', 'PCHS', 'SADDAR', 'Saddar', 'Shah faisal', 'Shah Faisal',
          'shahrah-e-faisal', 'Shahrah-e-Faisal', 'Malir'
        ];

        final dbClinicAddr = profileData['clinic_address'] ?? profileData['clinicAddress'];
        final dbClinicLoc = profileData['clinic_location'] ?? profileData['clinicLocation'];
        final dbClinicHosp = profileData['clinic_hospital_address'] ?? profileData['clinicHospitalAddress'];

        String resolvedClinicLoc = '';
        String resolvedClinicHosp = '';

        if (dbClinicLoc != null && dbClinicLoc.toString().isNotEmpty) {
          resolvedClinicLoc = dbClinicLoc.toString();
        }
        if (dbClinicHosp != null && dbClinicHosp.toString().isNotEmpty) {
          resolvedClinicHosp = dbClinicHosp.toString();
        }

        if (dbClinicAddr != null && dbClinicAddr.toString().isNotEmpty) {
          final isLoc = kClinicLocations.any((loc) => loc.toLowerCase().trim() == dbClinicAddr.toString().toLowerCase().trim());
          if (isLoc) {
            if (resolvedClinicLoc.isEmpty) resolvedClinicLoc = dbClinicAddr.toString();
          } else {
            if (resolvedClinicHosp.isEmpty) resolvedClinicHosp = dbClinicAddr.toString();
          }
        }

        // Normalize doctor profile fields
        profileData['years_of_experience'] = profileData['experience_years'] ?? profileData['experienceYears'] ?? profileData['years_of_experience'] ?? profileData['yearsOfExperience'] ?? 0;
        profileData['yearsOfExperience'] = profileData['years_of_experience'];
        profileData['experience_years'] = profileData['years_of_experience'];
        profileData['experienceYears'] = profileData['years_of_experience'];

        profileData['short_bio'] = profileData['bio'] ?? profileData['short_bio'] ?? profileData['shortBio'] ?? '';
        profileData['shortBio'] = profileData['short_bio'];
        profileData['bio'] = profileData['short_bio'];

        profileData['clinic_name'] = profileData['clinic_name'] ?? profileData['clinicName'] ?? '';
        profileData['clinicName'] = profileData['clinic_name'];

        profileData['clinic_location'] = resolvedClinicLoc;
        profileData['clinicLocation'] = resolvedClinicLoc;
        profileData['clinic_address'] = resolvedClinicLoc;
        profileData['clinicAddress'] = resolvedClinicLoc;

        profileData['clinic_hospital_address'] = resolvedClinicHosp;
        profileData['clinicHospitalAddress'] = resolvedClinicHosp;

        return {
          'success': true,
          'profile': profileData,
          'creds': uniqueCredDocs.map((d) {
            final cData = d.data();
            cData['id'] = d.id;
            return cData;
          }).toList(),
        };
      }
    } catch (_) {}
    return null;
  }

  Future<void> fetchEmployerApplications() async {
    try {
      await _ensureFirebase();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        if (_employerJobs.isEmpty) {
          await fetchEmployerDashboard();
        }
        final profileId = _employerDashboard?['profile']?['id']?.toString() ?? '';
        var employerJobDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        if (_employerJobs.isNotEmpty) {
          final ids = _employerJobs.map((job) => job.id).toSet();
          final allJobsSnapshot = await FirebaseFirestore.instance
              .collection('jobs')
              .get();
          employerJobDocs = allJobsSnapshot.docs
              .where((doc) => ids.contains(doc.id))
              .toList();
        } else {
          final allJobsSnapshot = await FirebaseFirestore.instance
              .collection('jobs')
              .get();
          employerJobDocs = allJobsSnapshot.docs.where((doc) {
            final data = doc.data();
            final eId = data['employer_id'] ?? data['employerId'];
            return eId == fbUser.uid || (profileId.isNotEmpty && eId == profileId);
          }).toList();
        }

        final jobIds = employerJobDocs.map((d) => d.id).toList();
        if (jobIds.isEmpty) {
          _employerApplications = [];
          notifyListeners();
          return;
        }

        final allAppsSnapshot = await FirebaseFirestore.instance
            .collection('applications')
            .get();
        final appsDocs = allAppsSnapshot.docs.where((doc) {
          final data = doc.data();
          final jobId = (data['job_id'] ?? data['jobId'] ?? '').toString();
          return jobIds.contains(jobId);
        }).toList();

        var apps = <Map<String, dynamic>>[];
        for (var doc in appsDocs) {
          final data = doc.data();
          data['id'] = doc.id;

          final jobDoc = employerJobDocs.firstWhere(
            (jDoc) => jDoc.id == (data['job_id'] ?? data['jobId']),
          );
          data['job_title'] = jobDoc.data()['title'] ?? 'Job Position';

          final doctorId = data['doctor_id'];
          if (doctorId != null) {
            final docProfile = await FirebaseFirestore.instance
                .collection('doctor_profiles')
                .doc(doctorId)
                .get();
            if (docProfile.exists && docProfile.data() != null) {
              final docData = docProfile.data()!;
              data['candidate_name'] = docData['full_name'] ?? 'Doctor';
              data['specialty'] = docData['specialty'] ?? 'General Practice';
              data['city'] = docData['city'] ?? '';
              data['pmdc_verified'] = docData['pmdc_verified'] ?? 0;
            }
          }
          apps.add(data);
        }

        _employerApplications = apps;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> updateApplicationStatus(String id, String status) async {
    try {
      await _ensureFirebase();
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(id)
          .update({'status': status});
      await fetchEmployerApplications();
      return true;
    } catch (_) {}
    return false;
  }

  Future<void> fetchEmployerInterviews() async {
    try {
      await _ensureFirebase();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        if (_employerJobs.isEmpty) {
          await fetchEmployerDashboard();
        }
        final allJobsSnapshot = await FirebaseFirestore.instance
            .collection('jobs')
            .get();
        final employerJobIds = _employerJobs.map((job) => job.id).toSet();
        final profileId = _employerDashboard?['profile']?['id']?.toString() ?? '';
        final employerJobDocs = allJobsSnapshot.docs.where((doc) {
          final data = doc.data();
          final eId = data['employer_id'] ?? data['employerId'];
          return employerJobIds.contains(doc.id) ||
              eId == fbUser.uid ||
              (profileId.isNotEmpty && eId == profileId);
        }).toList();

        final jobIds = employerJobDocs.map((d) => d.id).toList();
        if (jobIds.isEmpty) {
          _employerInterviews = [];
          _employerPendingApps = [];
          notifyListeners();
          return;
        }

        final allAppsSnapshot = await FirebaseFirestore.instance
            .collection('applications')
            .get();
        final appDocs = allAppsSnapshot.docs.where((doc) {
          final data = doc.data();
          final jobId = (data['job_id'] ?? data['jobId'] ?? '').toString();
          return jobIds.contains(jobId);
        }).toList();

        final appIds = appDocs.map((doc) => doc.id).toList();

        if (appIds.isNotEmpty) {
          final intSnapshot = await FirebaseFirestore.instance
              .collection('interviews')
              .where('application_id', whereIn: appIds)
              .get();

          final rawInts = intSnapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();

          _employerInterviews = await compute(parseInterviews, rawInts);
        } else {
          _employerInterviews = [];
        }

        var pendingApps = <Map<String, dynamic>>[];
        for (var doc in appDocs) {
          final appData = doc.data();
          appData['id'] = doc.id;
          if (appData['status'] == 'shortlisted') {
              final hasInterview = _employerInterviews.any(
                (i) => i.applicationId == doc.id,
              );
            if (!hasInterview) {
              final jobDoc = employerJobDocs.firstWhere(
                (j) => j.id == (appData['job_id'] ?? appData['jobId']),
              );
              appData['job_title'] = jobDoc.data()['title'] ?? 'Job Position';

              final docProfile = await FirebaseFirestore.instance
                  .collection('doctor_profiles')
                  .doc(appData['doctor_id'])
                  .get();
              appData['candidate_name'] =
                  docProfile.data()?['full_name'] ?? 'Doctor';
              pendingApps.add(appData);
            }
          }
        }
        _employerPendingApps = pendingApps;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> scheduleInterview({
    required String applicationId,
    required String scheduledAt,
    required String mode,
    String? location,
    String? notes,
  }) async {
    try {
      _scheduleInterviewInBackground(
        applicationId: applicationId,
        scheduledAt: scheduledAt,
        mode: mode,
        location: location,
        notes: notes,
      );
      return true;
    } catch (_) {}
    return false;
  }

  Future<void> _scheduleInterviewInBackground({
    required String applicationId,
    required String scheduledAt,
    required String mode,
    String? location,
    String? notes,
  }) async {
    try {
      await _ensureFirebase();
      final appDoc = await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .get();
      final jobId = appDoc.data()?['job_id'] ?? appDoc.data()?['jobId'];
      final doctorId = appDoc.data()?['doctor_id'] ?? appDoc.data()?['doctorId'];

      final jobDoc = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(jobId)
          .get();
      final jobTitle = jobDoc.data()?['title'] ?? 'Job Position';

      final docProfile = await FirebaseFirestore.instance
          .collection('doctor_profiles')
          .doc(doctorId)
          .get();
      final candidateName = docProfile.data()?['full_name'] ?? 'Doctor';

      final intDoc = {
        'application_id': applicationId,
        'applicationId': applicationId,
        'job_title': jobTitle,
        'jobTitle': jobTitle,
        'candidate_name': candidateName,
        'candidateName': candidateName,
        'scheduled_at': scheduledAt,
        'scheduledAt': scheduledAt,
        'mode': mode,
        'location': location ?? '',
        'notes': notes ?? '',
        'status': 'scheduled',
      };

      await FirebaseFirestore.instance.collection('interviews').add(intDoc);
      await fetchEmployerInterviews();
    } catch (e) {
      debugPrint("Error scheduling interview: $e");
    }
  }

  Future<bool> updateEmployerProfile(Map<String, dynamic> profileData) async {
    try {
      _updateEmployerProfileInBackground(profileData);
      return true;
    } catch (_) {}
    return false;
  }

  Future<void> _updateEmployerProfileInBackground(Map<String, dynamic> profileData) async {
    try {
      await _ensureFirebase();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      if (fbUser == null) return;

      var profileId = fbUser.uid;
      final currentProfile = _employerDashboard?['profile'];
      if (currentProfile is Map && currentProfile['id'] != null) {
        profileId = currentProfile['id'].toString();
      } else {
        for (final field in ['user_id', 'userId', 'employer_id', 'employerId']) {
          final snapshot = await FirebaseFirestore.instance
              .collection('employer_profiles')
              .where(field, isEqualTo: fbUser.uid)
              .limit(1)
              .get();
          if (snapshot.docs.isNotEmpty) {
            profileId = snapshot.docs.first.id;
            break;
          }
        }
      }

      await FirebaseFirestore.instance
          .collection('employer_profiles')
          .doc(profileId)
          .set({
            ...profileData,
            'user_id': fbUser.uid,
            'email': fbUser.email,
          }, SetOptions(merge: true));
      await fetchEmployerDashboard();
    } catch (e) {
      debugPrint("Error updating employer profile: $e");
    }
  }

  // =========================================================================
  // 4. ADMIN ENDPOINTS
  // =========================================================================

  Future<void> fetchAdminDashboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _ensureFirebase();
      final docsSnapshot = await FirebaseFirestore.instance
          .collection('doctor_profiles')
          .where('pmdc_verified', isEqualTo: 0)
          .get();
      _adminUnverifiedDoctors = docsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      final credSnapshot = await FirebaseFirestore.instance
          .collection('credentials')
          .where('verified', isEqualTo: 0)
          .get();

      var credList = <Map<String, dynamic>>[];
      for (var doc in credSnapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;

        final doctorId = data['doctor_id'];
        if (doctorId != null) {
          final docProfile = await FirebaseFirestore.instance
              .collection('doctor_profiles')
              .doc(doctorId)
              .get();
          data['doctor_name'] = docProfile.data()?['full_name'] ?? 'Doctor';
        }
        credList.add(data);
      }
      _adminUnverifiedCredentials = credList;

      final contactSnapshot = await FirebaseFirestore.instance
          .collection('contact_messages')
          .get();
      _adminContactMessages = contactSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      final jobsCount =
          (await FirebaseFirestore.instance.collection('jobs').get())
              .docs
              .length;
      final usersCount =
          (await FirebaseFirestore.instance.collection('users').get())
              .docs
              .length;

      _adminDashboard = {
        'totalUsers': usersCount,
        'unverifiedDoctors': _adminUnverifiedDoctors.length,
        'unverifiedCredentials': _adminUnverifiedCredentials.length,
        'openJobs': jobsCount,
      };
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> verifyDoctorPmdc(String doctorId) async {
    try {
      await _ensureFirebase();
      await FirebaseFirestore.instance
          .collection('doctor_profiles')
          .doc(doctorId)
          .update({'pmdc_verified': 1});
      await fetchAdminDashboard();
      return true;
    } catch (_) {}
    return false;
  }

  Future<bool> verifyCredential(String credentialId) async {
    try {
      await _ensureFirebase();
      await FirebaseFirestore.instance
          .collection('credentials')
          .doc(credentialId)
          .update({'verified': 1});
      await fetchAdminDashboard();
      return true;
    } catch (_) {}
    return false;
  }

  Future<bool> rejectCredential(String credentialId) async {
    try {
      await _ensureFirebase();
      await FirebaseFirestore.instance
          .collection('credentials')
          .doc(credentialId)
          .delete();
      await fetchAdminDashboard();
      return true;
    } catch (_) {}
    return false;
  }
}
