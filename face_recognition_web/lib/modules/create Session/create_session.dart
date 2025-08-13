import 'package:flutter/material.dart';

import 'package:face_recognition_web/app/widgets/main_layout.dart'; // Import MainLayout
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateSession extends StatefulWidget {
  @override
  _CreateSessionState createState() => _CreateSessionState();
}

class _CreateSessionState extends State<CreateSession> {
  String? _facultyName;
  String? _departmentName;
  String? _className;
  String? _courseName;
  TextEditingController _durationController = TextEditingController();

  List<String> facultyList = [];
  List<String> departmentList = [];
  List<String> classList = [];
  List<String> courseList = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadFaculties();
  }

  Future<void> loadFaculties() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var faculties =
          await FirebaseFirestore.instance.collection('faculties').get();
      print("Faculties fetched: ${faculties.docs.length}");
      faculties.docs.forEach((doc) {
        print("Faculty: ${doc['Name']}");
      });

      setState(() {
        facultyList =
            faculties.docs.map((doc) => doc['Name'].toString()).toList();
        _facultyName = facultyList.isNotEmpty ? facultyList[0] : null;
        _isLoading = false;
      });

      if (_facultyName != null) {
        loadDepartments();
      }
    } catch (e) {
      print("Error loading faculties: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadDepartments() async {
    if (_facultyName == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var departments = await FirebaseFirestore.instance
          .collection('faculties')
          .where("Name", isEqualTo: _facultyName)
          .limit(1)
          .get()
          .then((querySnapshot) {
            return querySnapshot.docs.first.reference
                .collection('departments')
                .get();
          });

      setState(() {
        departmentList =
            departments.docs.map((doc) => doc['Name'].toString()).toList();
        _departmentName = departmentList.isNotEmpty ? departmentList[0] : null;
        _isLoading = false;
      });

      if (_departmentName != null) {
        loadClasses();
      }
    } catch (e) {
      print("Error loading departments: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadClasses() async {
    if (_departmentName == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var classes = await FirebaseFirestore.instance
          .collection('faculties')
          .where("Name", isEqualTo: _facultyName)
          .limit(1)
          .get()
          .then((querySnapshot) {
            return querySnapshot.docs.first.reference
                .collection('departments')
                .where("Name", isEqualTo: _departmentName)
                .limit(1)
                .get();
          })
          .then(
            (querySnapshot) =>
                querySnapshot.docs.first.reference.collection('classes').get(),
          );

      setState(() {
        classList = classes.docs.map((doc) => doc['Name'].toString()).toList();
        _className = classList.isNotEmpty ? classList[0] : null;
        _isLoading = false;
      });

      if (_className != null) {
        loadCourses();
      }
    } catch (e) {
      print("Error loading classes: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadCourses() async {
    if (_className == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var courses = await FirebaseFirestore.instance
          .collection('faculties')
          .where("Name", isEqualTo: _facultyName)
          .limit(1)
          .get()
          .then((querySnapshot) {
            return querySnapshot.docs.first.reference
                .collection('departments')
                .where("Name", isEqualTo: _departmentName)
                .limit(1)
                .get();
          })
          .then(
            (querySnapshot) =>
                querySnapshot.docs.first.reference
                    .collection('classes')
                    .where("Name", isEqualTo: _className)
                    .limit(1)
                    .get(),
          )
          .then(
            (querySnapshot) =>
                querySnapshot.docs.first.reference.collection('courses').get(),
          );

      setState(() {
        courseList = courses.docs.map((doc) => doc['Name'].toString()).toList();
        _courseName = courseList.isNotEmpty ? courseList[0] : null;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading courses: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void addSession() async {
    if (_facultyName == null ||
        _departmentName == null ||
        _className == null ||
        _courseName == null ||
        _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select all fields and enter the duration"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int duration =
        int.tryParse(_durationController.text) ??
        -1; // Get duration from text field

    if (duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Duration must be a positive value."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    _durationController.clear();
    DateTime now = DateTime.now();
    DateTime start = now;
    DateTime end = now.add(Duration(minutes: duration));

    try {
      var facultyDoc =
          await FirebaseFirestore.instance
              .collection('faculties')
              .where("Name", isEqualTo: _facultyName)
              .limit(1)
              .get();
      String facultyId = facultyDoc.docs.first.id;

      var departmentDoc =
          await FirebaseFirestore.instance
              .collection('faculties')
              .doc(facultyId)
              .collection('departments')
              .where("Name", isEqualTo: _departmentName)
              .limit(1)
              .get();
      String departmentId = departmentDoc.docs.first.id;

      var classDoc =
          await FirebaseFirestore.instance
              .collection('faculties')
              .doc(facultyId)
              .collection('departments')
              .doc(departmentId)
              .collection('classes')
              .where("Name", isEqualTo: _className)
              .limit(1)
              .get();
      String classId = classDoc.docs.first.id;

      var courseDoc =
          await FirebaseFirestore.instance
              .collection('faculties')
              .doc(facultyId)
              .collection('departments')
              .doc(departmentId)
              .collection('classes')
              .doc(classId)
              .collection('courses')
              .where("Name", isEqualTo: _courseName)
              .limit(1)
              .get();
      String courseId = courseDoc.docs.first.id;

      await FirebaseFirestore.instance
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('classes')
          .doc(classId)
          .collection('courses')
          .doc(courseId)
          .collection('sessions')
          .add({
            'subject': _courseName,
            'start_time': start,
            'end_time': end,
            'course_id': courseId,
            'class_id': classId,
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Session added successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Create Session',
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Show loading indicator while fetching data
            if (_isLoading) CircularProgressIndicator(),

            // 2x2 Grid Layout for dropdowns
            if (!_isLoading) ...[
              // First Row: Faculty and Department
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "Faculty",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 20),
                        DropdownButton<String>(
                          value: _facultyName,
                          onChanged: (newValue) {
                            setState(() {
                              _facultyName = newValue;
                              loadDepartments();
                            });
                          },
                          hint: Text('Select Faculty'),
                          items:
                              facultyList.map((faculty) {
                                return DropdownMenuItem(
                                  value: faculty,
                                  child: Text(faculty),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "Department",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 20),
                        DropdownButton<String>(
                          value: _departmentName,
                          onChanged: (newValue) {
                            setState(() {
                              _departmentName = newValue;
                              loadClasses();
                            });
                          },
                          hint: Text('Select Department'),
                          items:
                              departmentList.map((department) {
                                return DropdownMenuItem(
                                  value: department,
                                  child: Text(department),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Second Row: Class and Course
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "Class",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 20),
                        DropdownButton<String>(
                          value: _className,
                          onChanged: (newValue) {
                            setState(() {
                              _className = newValue;
                              loadCourses();
                            });
                          },
                          hint: Text('Select Class'),
                          items:
                              classList.map((className) {
                                return DropdownMenuItem(
                                  value: className,
                                  child: Text(className),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          "Course",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 25),
                        DropdownButton<String>(
                          value: _courseName,
                          onChanged: (newValue) {
                            setState(() {
                              _courseName = newValue;
                            });
                          },
                          hint: Text('Select Course'),
                          items:
                              courseList.map((course) {
                                return DropdownMenuItem(
                                  value: course,
                                  child: Text(course),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],

            // Duration TextField
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Duration (minutes):",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter Duration',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Add Session Button with custom color
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: addSession,
              child: Text('Add Session'),
            ),
          ],
        ),
      ),
    );
  }
}
