// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// Future<void> showAddTripDialog(BuildContext context) async {
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();

//   return showDialog(
//     context: context,
//     builder: (_) => AlertDialog(
//       title: const Text('Add Trip'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: titleController,
//             decoration: const InputDecoration(labelText: 'Title'),
//           ),
//           const SizedBox(height: 10),
//           TextField(
//             controller: descriptionController,
//             decoration: const InputDecoration(labelText: 'Description'),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             final uid = FirebaseAuth.instance.currentUser?.uid;
//             if (uid == null) return;

//             final title = titleController.text.trim();
//             final description = descriptionController.text.trim();
//             final now = DateTime.now();
//             final month = DateFormat('MMMM yyyy').format(now);

//             if (title.isEmpty || description.isEmpty) return;

//             await FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(uid)
//                 .collection('trips')
//                 .add({
//                   'title': title,
//                   'description': description,
//                   'createdAt': now,
//                   'month': month,
//                   'total': 0.0,
//                 });

// ignore_for_file: use_build_context_synchronously

//             // ignore: use_build_context_synchronously
//             Navigator.pop(context);
//           },
//           child: const Text('Save'),
//         ),
//       ],
//     ),
//   );
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

Future<void> showAddTripDialog(BuildContext context) async {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isSaving = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Trip',
                      style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,fontSize: 24)
                           
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                   style: GoogleFonts.nunitoSans(),
                  controller: titleController,
                  decoration: InputDecoration(
                    labelStyle: GoogleFonts.nunitoSans() ,
                    labelText: 'Trip Title',
                    border: OutlineInputBorder(
          
                      borderRadius: BorderRadius.circular(16),
                    ),
                    prefixIcon: const Icon(Icons.flag),
                    filled: true, // <-- Add this
                    fillColor: const Color.fromARGB(255, 246, 250, 255), 
                  ),
                  
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  style: GoogleFonts.nunitoSans(),
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: GoogleFonts.nunitoSans(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    prefixIcon: const Icon(Icons.description),
                     filled: true, // <-- Add this
                    fillColor: const Color.fromARGB(255, 246, 248, 252),                   ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: isSaving
                        ? null
                        : () async {
                            final title = titleController.text.trim();
                            if (title.isEmpty) return;

                            setState(() => isSaving = true);

                            try {
                              final uid =
                                  FirebaseAuth.instance.currentUser?.uid;
                              if (uid == null) return;

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .collection('trips')
                                  .add({
                                    'title': title,
                                    'description': descriptionController.text
                                        .trim(),
                                    'createdAt': DateTime.now(),
                                    'month': DateFormat(
                                      'MMMM yyyy',
                                    ).format(DateTime.now()),
                                    'total': 0.0,
                                  });

                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                ),
                              );
                            } finally {
                              setState(() => isSaving = false);
                            }
                          },
                    child: isSaving
                        ?  SizedBox(
                          height: 30,
                          width: 30,
                           child:   CircularProgressIndicator(color: Colors.white),
                          ) 
                        :  Text('Create Trip',style: GoogleFonts.nunitoSans(),),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
