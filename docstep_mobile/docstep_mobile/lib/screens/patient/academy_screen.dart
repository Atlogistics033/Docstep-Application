import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';

class AcademyScreen extends StatefulWidget {
  const AcademyScreen({super.key});

  @override
  State<AcademyScreen> createState() => _AcademyScreenState();
}

class _AcademyScreenState extends State<AcademyScreen> {
  final String _geminiApiKey = 'AQ.Ab8RN6JJQCF__fg1unzoBd0RvvUQ5BlimgrALrmZofELeDaJKQ';
  String? _selectedSpecialty;
  bool _loading = false;
  List<dynamic> _recommendedCourses = [];

  final List<String> _specialties = [
    'General Practice',
    'Gynecology',
    'Pediatrics',
    'Psychiatry',
    'Dermatology',
    'Internal Medicine',
    'Cardiology',
    'Other'
  ];

  void _openCourseLink(String? urlString, String title) async {
    String fallbackUrl = 'https://www.coursera.org/search?query=${Uri.encodeComponent(title)}';
    final targetUrl = (urlString != null && urlString.isNotEmpty) ? urlString : fallbackUrl;
    
    try {
      final Uri uri = Uri.parse(targetUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        final Uri fallbackUri = Uri.parse(fallbackUrl);
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open course link. Opening Coursera instead...'),
            backgroundColor: AppTheme.primary,
          ),
        );
        try {
          await launchUrl(Uri.parse('https://www.coursera.org'), mode: LaunchMode.externalApplication);
        } catch (_) {}
      }
    }
  }

  void _loadCoursesForSpecialty(String specialty) async {
    setState(() {
      _loading = true;
      _recommendedCourses = [];
    });

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_geminiApiKey',
    );

    final prompt = """
You are DocStep Medical AI, an expert medical tutor. 
Generate exactly 3 custom clinical course recommendations for the following medical specialty: "$specialty".
Return the response as a JSON array of objects. Do not include any explanation, markdown formatting, or backticks around the JSON. Fulfill this requirement strictly.

Each course object in the array must have the following keys:
- "title": A professional clinical course title.
- "description": A short summary of what is taught (1-2 sentences).
- "duration": Estimated completion time (e.g. "3 hours" or "5 hours").
- "lectures": Number of lectures (integer).
- "price": Price status (e.g. "Free").
- "url": A real, clickable URL to study this medical topic (e.g. from Coursera, WHO Academy, edX, or Harvard Online Medicine). Fulfill this requirement with realistic search links or homepage topics (e.g. 'https://www.coursera.org/search?query=pediatrics').
""";

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'responseMimeType': 'application/json'
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        if (text != null) {
          String cleanText = text.trim();
          if (cleanText.startsWith('```json')) {
            cleanText = cleanText.substring(7);
          }
          if (cleanText.endsWith('```')) {
            cleanText = cleanText.substring(0, cleanText.length - 3);
          }
          cleanText = cleanText.trim();
          
          final List<dynamic> parsedList = jsonDecode(cleanText);
          if (mounted) {
            setState(() {
              _loading = false;
              _recommendedCourses = parsedList;
            });
          }
        } else {
          throw Exception('Empty response from AI model');
        }
      } else {
        _loadFallbackCourses(specialty);
      }
    } catch (_) {
      _loadFallbackCourses(specialty);
    }
  }

  void _loadFallbackCourses(String specialty) {
    final fallback = [
      {
        'title': 'Essentials of Clinical $specialty',
        'description': 'A comprehensive overview of diagnostic guidelines and treatment protocols in modern clinical settings.',
        'duration': '4 hours',
        'lectures': 12,
        'price': 'Free',
        'url': 'https://www.coursera.org/search?query=${Uri.encodeComponent("Clinical $specialty")}',
      },
      {
        'title': 'Advanced Case Studies in $specialty',
        'description': 'Explore complex patient cases, differential diagnosis, and evidence-based management strategies.',
        'duration': '6 hours',
        'lectures': 18,
        'price': 'Free',
        'url': 'https://www.coursera.org/search?query=${Uri.encodeComponent("Advanced $specialty")}',
      },
      {
        'title': 'Telemedicine Practicum: $specialty',
        'description': 'Best practices for conducting remote consultations, history taking, and digital patient care.',
        'duration': '3 hours',
        'lectures': 9,
        'price': 'Free',
        'url': 'https://www.coursera.org/search?query=${Uri.encodeComponent("Telemedicine $specialty")}',
      }
    ];

    if (mounted) {
      setState(() {
        _loading = false;
        _recommendedCourses = fallback;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card 1: Course Recommendations Selector
            Container(
              decoration: AppTheme.cardDecoration(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.auto_awesome_outlined, color: AppTheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Course Recommendations',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.secondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select any doctor Primary Specialty, and our AI will dynamically recommend the most relevant learning courses.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SELECT PRIMARY SPECIALTY',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.textMedium),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSpecialty,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.secondary),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppTheme.primary),
                      ),
                    ),
                    hint: const Text('-- Choose Specialty --', style: TextStyle(fontSize: 14)),
                    items: _specialties.map((spec) {
                      return DropdownMenuItem<String>(
                        value: spec,
                        child: Text(spec, style: const TextStyle(fontSize: 14, color: AppTheme.textDark)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedSpecialty = val;
                        });
                        _loadCoursesForSpecialty(val);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card 2: Results / Placeholder Screen
            _loading
                ? Container(
                    height: 200,
                    decoration: AppTheme.cardDecoration(),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)),
                          SizedBox(height: 12),
                          Text('AI is generating recommendations...', style: TextStyle(color: AppTheme.textMedium, fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                : _selectedSpecialty == null
                    ? Container(
                        height: 260,
                        decoration: AppTheme.cardDecoration(),
                        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9), // soft light grey/lavender
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.menu_book_outlined,
                                color: Color(0xFF64748B), // Slate grey
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No courses loaded',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppTheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Please select a Primary Specialty from the dropdown to load courses.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: _recommendedCourses.map((course) {
                          final title = course['title'] ?? 'Course';
                          final courseUrl = course['url'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: AppTheme.cardDecoration(),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  course['description'] ?? '',
                                  style: const TextStyle(color: AppTheme.textMedium, fontSize: 12, height: 1.4),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_outlined, size: 14, color: AppTheme.textLight),
                                    const SizedBox(width: 4),
                                    Text(course['duration'] ?? 'Self-paced', style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.play_circle_outline, size: 14, color: AppTheme.textLight),
                                    const SizedBox(width: 4),
                                    Text('${course['lectures'] ?? 10} lectures', style: const TextStyle(color: AppTheme.textLight, fontSize: 11)),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        final dataProvider = Provider.of<DataProvider>(context, listen: false);
                                        dataProvider.startCourse(title, title);
                                        _openCourseLink(courseUrl, title);
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        child: Text(
                                          'Start course →',
                                          style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
            const SizedBox(height: 32),

            // Footer Section
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'DocStep Academy',
                      style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'More courses coming soon',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'course topic you\'d love to see — we partner with PMDC-accredited institutes to roll out new programs each quarter.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.secondary,
                      side: const BorderSide(color: AppTheme.borderLight),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Suggest a course', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
