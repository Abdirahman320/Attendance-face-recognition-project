import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../app/controllers/student_controller.dart';
import '../../app/tables/student_table.dart';
import '../../app/widgets/main_layout.dart'; // Import MainLayout

class StudentView extends GetView<StudentController> {
  const StudentView({super.key});

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder customBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 232, 232, 232),
        width: 1,
      ),
    );

    return MainLayout(
      title: "All Students",
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔍 Search Field
            TextField(
              onChanged: controller.filterStudents,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                hintText: 'Search by name or ID...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(
                  Iconsax.search_normal,
                  color: Colors.black54,
                ),
                border: customBorder,
                enabledBorder: customBorder,
                focusedBorder: customBorder,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 📋 Student Table or Loader
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 🔧 Add UniqueKey to force refresh
                return StudentTable(
                  key: ValueKey(controller.filteredStudents.length),
                  students: controller.filteredStudents,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
