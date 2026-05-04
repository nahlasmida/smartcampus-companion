import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_campus_companion/core/constants/color_constants.dart';
import 'package:smart_campus_companion/data/models/event_model.dart';
import 'package:smart_campus_companion/services/notification_service.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  File? _selectedImage;
  final TextEditingController _notesController = TextEditingController();
  bool _isSavingNote = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedNote();
    _loadSavedImage();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedNote() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNote = prefs.getString('event_note_${widget.event.id}');
    if (savedNote != null && mounted) {
      setState(() {
        _notesController.text = savedNote;
      });
    }
  }

  Future<void> _saveNote() async {
    setState(() {
      _isSavingNote = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('event_note_${widget.event.id}', _notesController.text);

    setState(() {
      _isSavingNote = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Note saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _pickImage() async {
    final status = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();

    if (status.isGranted || storageStatus.isGranted) {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (image != null && mounted) {
          setState(() {
            _selectedImage = File(image.path);
          });

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('event_image_${widget.event.id}', image.path);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo added successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        print('Error picking image: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied. Cannot access gallery.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadSavedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('event_image_${widget.event.id}');
    if (imagePath != null && File(imagePath).existsSync() && mounted) {
      setState(() {
        _selectedImage = File(imagePath);
      });
    }
  }

  Future<void> _setReminder() async {
    setState(() {
      _isLoading = true;
    });

    final eventDate = widget.event.startTime;
    final reminderTime = eventDate.subtract(const Duration(minutes: 10));

    if (reminderTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot set reminder for past event!'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    await NotificationService.scheduleNotification(
      id: widget.event.id.hashCode,
      title: 'Event Reminder: ${widget.event.title}',
      body: 'Starts at ${_formatTime(widget.event.startTime.hour, widget.event.startTime.minute)} in ${widget.event.location}',
      scheduledTime: reminderTime,
      payload: 'event_${widget.event.id}',
    );

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for ${_formatDate(reminderTime)} at ${_formatTime(reminderTime.hour, reminderTime.minute)}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final category = _getCategory(widget.event.title);
    final categoryColor = _getCategoryColor(category);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.event.title.length > 25
              ? '${widget.event.title.substring(0, 25)}...'
              : widget.event.title,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [categoryColor, categoryColor.withOpacity(0.7)],
                ),
              ),
              child: Row(
                children: [
                  Icon(_getCategoryIcon(category), color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    iconColor: AppColors.primary,
                    text: _formatDate(widget.event.startTime),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.access_time,
                    iconColor: AppColors.secondary,
                    text: '${_formatTime(widget.event.startTime.hour, widget.event.startTime.minute)} - ${_formatTime(widget.event.endTime.hour, widget.event.endTime.minute)}',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.location_on,
                    iconColor: Colors.green,
                    text: widget.event.location,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.person_outline,
                    iconColor: Colors.purple,
                    text: 'Organized by: ${widget.event.organizer}',
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About this event',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description.isEmpty
                        ? 'No description available for this event.'
                        : widget.event.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Event Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add photo',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'My Event Note',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add your notes about this event...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSavingNote ? null : _saveNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isSavingNote
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text('Save Note'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _setReminder,
                      icon: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.notifications_outlined),
                      label: const Text('Set Reminder'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  String _getCategory(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('orientation')) return 'Orientation';
    if (lowerTitle.contains('workshop')) return 'Workshop';
    if (lowerTitle.contains('marathon')) return 'Sports';
    if (lowerTitle.contains('exam')) return 'Academic';
    if (lowerTitle.contains('career') || lowerTitle.contains('fair')) return 'Career';
    if (lowerTitle.contains('guest') || lowerTitle.contains('lecture')) return 'Lecture';
    return 'Event';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Orientation':
        return Colors.blue;
      case 'Workshop':
        return Colors.purple;
      case 'Sports':
        return Colors.green;
      case 'Academic':
        return Colors.orange;
      case 'Career':
        return Colors.teal;
      case 'Lecture':
        return Colors.indigo;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Orientation':
        return Icons.celebration;
      case 'Workshop':
        return Icons.computer;
      case 'Sports':
        return Icons.sports_basketball;
      case 'Academic':
        return Icons.school;
      case 'Career':
        return Icons.work;
      case 'Lecture':
        return Icons.mic;
      default:
        return Icons.event;
    }
  }
}