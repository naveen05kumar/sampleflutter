//lib/presentation/database_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_drop_down.dart';
import '../../model/camera_user_detected.dart';
import '../../services/api_service.dart'; // Updated import path

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({Key? key}) : super(key: key); // Added const constructor

  @override
  _DatabaseScreenState createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen> {
  final ApiService apiService = ApiService();
  late DateTime selectedDate;
  List<Result> detectedFaces = [];
  // Removed _dateCheckTimer as it's not necessary

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    fetchDetectedFaces();
    // Removed _setupDateCheckTimer() call
  }

  // Removed _setupDateCheckTimer() method and dispose() override

  Future<void> fetchDetectedFaces() async {
    try {
      final faces = await apiService.getDetectedFaces(
        date: selectedDate.day.toString().padLeft(2, '0'),
        month: selectedDate.month.toString().padLeft(2, '0'),
        year: selectedDate.year.toString(),
      );
      setState(() {
        detectedFaces = faces.results ?? [];
      });
    } catch (e) {
      print('Error fetching faces: $e');
      // Consider showing an error message to the user
    }
  }

  void _renameFace(Result face) async {
    final TextEditingController controller = TextEditingController(text: face.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rename Face"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text("Save"),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      try {
        final success = await apiService.renameFace(face.id!, newName);
        if (success) {
          fetchDetectedFaces();
        }
      } catch (e) {
        print('Error renaming face: $e');
        // Consider showing an error message to the user
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            SizedBox(height: 39.v),
            _buildRowDatabase(context),
            SizedBox(height: 22.v),
            _buildDateSelection(),
            SizedBox(height: 24.v),
            _buildDetectedFacesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRowDatabase(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Database",
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notificationsScreen),
            icon: Icon(Icons.notifications_none, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDateDropdown(),
          _buildMonthDropdown(),
          _buildYearDropdown(),
        ],
      ),
    );
  }

  Widget _buildDateDropdown() {
    return CustomDropDown(
      width: 70.h,
      hintText: selectedDate.day.toString().padLeft(2, '0'),
      items: List.generate(31, (index) => (index + 1).toString().padLeft(2, '0')),
      onChanged: (value) {
        setState(() {
          selectedDate = DateTime(selectedDate.year, selectedDate.month, int.parse(value));
          fetchDetectedFaces();
        });
      },
    );
  }

  Widget _buildMonthDropdown() {
    return CustomDropDown(
      width: 140.h,
      hintText: DateFormat('MMMM').format(selectedDate),
      items: DateFormat.MMMM().dateSymbols.MONTHS,
      onChanged: (value) {
        setState(() {
          selectedDate = DateTime(selectedDate.year, DateFormat.MMMM().dateSymbols.MONTHS.indexOf(value) + 1, selectedDate.day);
          fetchDetectedFaces();
        });
      },
    );
  }

  Widget _buildYearDropdown() {
    return CustomDropDown(
      width: 95.h,
      hintText: selectedDate.year.toString(),
      items: List.generate(10, (index) => (DateTime.now().year - index).toString()),
      onChanged: (value) {
        setState(() {
          selectedDate = DateTime(int.parse(value), selectedDate.month, selectedDate.day);
          fetchDetectedFaces();
        });
      },
    );
  }

  Widget _buildDetectedFacesList() {
    return Expanded(
      child: detectedFaces.isEmpty
          ? Center(child: Text("No detected faces", style: TextStyle(color: Colors.white)))
          : ListView.builder(
        itemCount: detectedFaces.length,
        itemBuilder: (context, index) {
          final face = detectedFaces[index];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.v),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(face.embedding ?? ''),
              radius: 30.h,
            ),
            title: Text(
              face.name ?? "Unknown ${face.id}",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              face.createdAt ?? "",
              style: TextStyle(color: Colors.grey),
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () => _renameFace(face),
            ),
            tileColor: face.name != null ? Colors.grey[850] : Colors.red[900],
          );
        },
      ),
    );
  }
}