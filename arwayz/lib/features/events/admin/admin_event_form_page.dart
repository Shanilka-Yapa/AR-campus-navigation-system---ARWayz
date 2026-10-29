import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../event_theme.dart';
import '../models/event.dart';
import '../widgets/event_date_text.dart';
import 'admin_data_service.dart';

/// Ceiling for the stored base64 poster.
///
/// Firestore allows 1 MiB per document; 500 KB leaves room for the other
/// fields and Firestore's own overhead.
const int _maxPosterBytes = 500 * 1024;

/// Create or edit a campus event.
class AdminEventFormPage extends StatefulWidget {
  /// Null when creating a new event.
  final Event? event;

  const AdminEventFormPage({super.key, this.event});

  @override
  State<AdminEventFormPage> createState() => _AdminEventFormPageState();
}

class _AdminEventFormPageState extends State<AdminEventFormPage> {
  final AdminDataService _service = AdminDataService();

  final _titleController = TextEditingController();
  final _captionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  final _floorController = TextEditingController();
  final _pointController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  DateTime? _startAt;
  DateTime? _endAt;

  bool _outdoorOnly = false;
  String? _buildingId;
  List<_BuildingOption> _buildings = [];
  bool _loadingBuildings = true;

  Uint8List? _posterBytes;
  String? _posterBase64;
  bool _posterChanged = false;
  bool _pickingPoster = false;

  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.event != null;

  @override
  void initState() {
    super.initState();
    _loadBuildings();
    _prefill();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _captionController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _floorController.dispose();
    _pointController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _prefill() {
    final event = widget.event;
    if (event == null) return;

    _titleController.text = event.title;
    _captionController.text = event.caption ?? '';
    _descriptionController.text = event.description;
    _venueController.text = event.venueName;
    _floorController.text = event.floor?.toString() ?? '';
    _pointController.text = event.indoorPointId ?? '';
    _latController.text = event.venueLatitude?.toString() ?? '';
    _lngController.text = event.venueLongitude?.toString() ?? '';
    _startAt = event.startAt;
    _endAt = event.endAt;
    _buildingId = event.buildingId;
    _outdoorOnly = event.buildingId == null;

    if (event.hasPoster) {
      _service.loadPoster(event.id).then((bytes) {
        if (mounted && bytes != null) {
          setState(() => _posterBytes = bytes);
        }
      });
    }
  }

  Future<void> _loadBuildings() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('buildings').get();
      final options = snapshot.docs
          .map(
            (doc) => _BuildingOption(
              id: doc.id,
              name: doc.data()['name'] as String? ?? doc.id,
            ),
          )
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      if (mounted) {
        setState(() {
          _buildings = options;
          _loadingBuildings = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _loadingBuildings = false;
          _error = 'Could not load buildings: $error';
        });
      }
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initial = (isStart ? _startAt : _endAt) ??
        DateTime.now().add(const Duration(hours: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startAt = combined;
        // Keep the end sensible when the start moves past it.
        if (_endAt != null && !_endAt!.isAfter(combined)) {
          _endAt = combined.add(const Duration(hours: 1));
        }
      } else {
        _endAt = combined;
      }
    });
  }

  Future<void> _pickPoster() async {
    setState(() {
      _pickingPoster = true;
      _error = null;
    });

    try {
      // image_picker resizes and re-encodes to JPEG natively, so no extra
      // image-processing package is needed.
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final encoded = base64Encode(bytes);

      if (encoded.length > _maxPosterBytes) {
        setState(
          () => _error =
              'That image is still too large after compression '
              '(${(encoded.length / 1024).round()} KB). Pick a simpler image.',
        );
        return;
      }

      setState(() {
        _posterBytes = bytes;
        _posterBase64 = encoded;
        _posterChanged = true;
      });
    } catch (error) {
      setState(() => _error = 'Could not read that image: $error');
    } finally {
      if (mounted) setState(() => _pickingPoster = false);
    }
  }

  void _removePoster() {
    setState(() {
      _posterBytes = null;
      _posterBase64 = null;
      _posterChanged = true;
    });
  }

  String? _validate() {
    if (_titleController.text.trim().isEmpty) return 'Enter the event name.';
    if (_descriptionController.text.trim().isEmpty) {
      return 'Enter a description.';
    }
    if (_captionController.text.trim().length > 140) {
      return 'Keep the caption to 140 characters or fewer.';
    }
    if (_venueController.text.trim().isEmpty) return 'Enter the venue name.';
    if (_startAt == null) return 'Pick the start date and time.';
    if (_endAt == null) return 'Pick the end date and time.';
    if (!_endAt!.isAfter(_startAt!)) {
      return 'The end time must be later than the start time.';
    }

    if (_outdoorOnly) {
      final lat = double.tryParse(_latController.text.trim());
      final lng = double.tryParse(_lngController.text.trim());
      if (lat == null || lat < -90 || lat > 90) {
        return 'Enter a valid latitude (-90 to 90).';
      }
      if (lng == null || lng < -180 || lng > 180) {
        return 'Enter a valid longitude (-180 to 180).';
      }
    } else {
      if (_buildingId == null || _buildingId!.isEmpty) {
        return 'Pick a building, or switch to an outdoor venue.';
      }
      final floorText = _floorController.text.trim();
      if (floorText.isNotEmpty && int.tryParse(floorText) == null) {
        return 'Floor must be a whole number.';
      }
    }

    return null;
  }

  Future<void> _save() async {
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final floorText = _floorController.text.trim();
    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'caption': _captionController.text.trim().isEmpty
          ? null
          : _captionController.text.trim(),
      'description': _descriptionController.text.trim(),
      'startAt': Timestamp.fromDate(_startAt!),
      'endAt': Timestamp.fromDate(_endAt!),
      'venueName': _venueController.text.trim(),
      'buildingId': _outdoorOnly ? null : _buildingId,
      'floor': _outdoorOnly || floorText.isEmpty ? null : int.parse(floorText),
      'indoorPointId': _outdoorOnly || _pointController.text.trim().isEmpty
          ? null
          : _pointController.text.trim(),
      'venueLatitude':
          _outdoorOnly ? double.parse(_latController.text.trim()) : null,
      'venueLongitude':
          _outdoorOnly ? double.parse(_lngController.text.trim()) : null,
      if (!_posterChanged) 'hasPoster': widget.event?.hasPoster ?? false,
    };

    try {
      await _service.saveEvent(
        eventId: widget.event?.id,
        data: data,
        posterBase64: _posterBase64,
        posterChanged: _posterChanged,
      );
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error.toString().contains('permission-denied')
              ? 'Firestore rejected the write. Confirm you are signed in as '
                  'an administrator.'
              : 'Could not save the event: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kEventScaffoldBg,
      appBar: AppBar(
        backgroundColor: kEventPrimaryDark,
        foregroundColor: Colors.white,
        title: Text(_isEdit ? 'Edit event' : 'New event'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _error!,
                style: TextStyle(fontSize: 13.5, color: Colors.red.shade900),
              ),
            ),
            const SizedBox(height: 14),
          ],

          _field(_titleController, 'Event name', Icons.event),
          const SizedBox(height: 12),
          _field(
            _captionController,
            'Caption (optional)',
            Icons.short_text,
          ),
          const SizedBox(height: 12),
          _field(
            _descriptionController,
            'Description',
            Icons.notes,
            maxLines: 3,
          ),
          const SizedBox(height: 12),

          _DateTimeTile(
            label: 'Starts',
            value: _startAt,
            onTap: () => _pickDateTime(isStart: true),
          ),
          const SizedBox(height: 10),
          _DateTimeTile(
            label: 'Ends',
            value: _endAt,
            onTap: () => _pickDateTime(isStart: false),
          ),
          const SizedBox(height: 16),

          _field(_venueController, 'Venue name', Icons.place),
          const SizedBox(height: 12),

          _SectionLabel(text: 'Venue type'),
          const SizedBox(height: 6),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('In a building')),
              ButtonSegment(value: true, label: Text('Outdoor')),
            ],
            selected: {_outdoorOnly},
            onSelectionChanged: (selection) =>
                setState(() => _outdoorOnly = selection.first),
          ),
          const SizedBox(height: 12),

          if (_outdoorOnly) ...[
            _field(
              _latController,
              'Latitude',
              Icons.my_location,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
            const SizedBox(height: 12),
            _field(
              _lngController,
              'Longitude',
              Icons.my_location,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
          ] else ...[
            _loadingBuildings
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(color: kEventDeepTeal),
                  )
                : DropdownButtonFormField<String>(
                    initialValue: _buildings.any((b) => b.id == _buildingId)
                        ? _buildingId
                        : null,
                    isExpanded: true,
                    decoration: _decoration('Building', Icons.business),
                    items: _buildings
                        .map(
                          (building) => DropdownMenuItem(
                            value: building.id,
                            child: Text(
                              building.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      _buildingId = value;
                      if (_venueController.text.trim().isEmpty &&
                          value != null) {
                        _venueController.text = _buildings
                            .firstWhere((b) => b.id == value)
                            .name;
                      }
                    }),
                  ),
            const SizedBox(height: 12),
            _field(
              _floorController,
              'Floor (optional)',
              Icons.layers,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _field(
              _pointController,
              'Indoor point ID (optional)',
              Icons.qr_code,
            ),
          ],

          const SizedBox(height: 20),
          _SectionLabel(text: 'Event poster (optional)'),
          const SizedBox(height: 8),
          _PosterPicker(
            bytes: _posterBytes,
            busy: _pickingPoster,
            onPick: _pickPoster,
            onRemove: _removePoster,
          ),

          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: kEventPrimaryDark,
                disabledBackgroundColor: kEventLightGray,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEdit ? 'Save changes' : 'Create event',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: !_saving,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _decoration(label, icon),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: kEventMutedTeal),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kEventLightGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kEventLightGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kEventDeepTeal, width: 1.5),
      ),
    );
  }
}

class _BuildingOption {
  final String id;
  final String name;

  const _BuildingOption({required this.id, required this.name});
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: kEventMutedTeal,
      ),
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kEventLightGray),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule, color: kEventMutedTeal),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: kEventSteelBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value == null
                        ? 'Tap to choose'
                        : '${formatEventDate(value!)}  '
                            '${formatEventTime(value!)}',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: value == null
                          ? kEventSteelBlue
                          : kEventPrimaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_calendar, color: kEventSteelBlue, size: 19),
          ],
        ),
      ),
    );
  }
}

class _PosterPicker extends StatelessWidget {
  final Uint8List? bytes;
  final bool busy;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _PosterPicker({
    required this.bytes,
    required this.busy,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bytes != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(
              bytes!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: busy ? null : onPick,
                icon: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kEventDeepTeal,
                        ),
                      )
                    : const Icon(Icons.image_outlined, size: 18),
                label: Text(bytes == null ? 'Choose image' : 'Replace'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kEventDeepTeal,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (bytes != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : onRemove,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Remove'),
                ),
              ),
            ],
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
            'Resized to 800px and compressed automatically before saving.',
            style: TextStyle(fontSize: 11.5, color: kEventSteelBlue),
          ),
        ),
      ],
    );
  }
}
