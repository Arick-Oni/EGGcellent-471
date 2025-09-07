import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ESP32CameraStreamPage extends StatefulWidget {
  const ESP32CameraStreamPage({super.key});

  @override
  State<ESP32CameraStreamPage> createState() => _ESP32CameraStreamPageState();
}

class _ESP32CameraStreamPageState extends State<ESP32CameraStreamPage> {
  Uint8List? _currentImageBytes;
  String _status = "Connecting...";
  int _frameCount = 0;
  int _batchCount = 0;
  DateTime? _lastFrameTime;
  double _fps = 0.0;
  String? _deviceId;
  int? _imageWidth;
  int? _imageHeight;
  bool _isStreaming = false;
  StreamSubscription<QuerySnapshot>? _streamSubscription;

  // For handling batch frames
  List<FrameData> _currentBatch = [];
  int _currentFrameInBatch = 0;
  Timer? _frameDisplayTimer;

  @override
  void initState() {
    super.initState();
    _startStreaming();
  }

  void _startStreaming() {
    setState(() {
      _isStreaming = true;
      _status = "Starting stream...";
    });

    // Listen to the camera_batch collection, ordered by batch timestamp
    _streamSubscription = FirebaseFirestore.instance
        .collection('camera_batch') // Changed from camera_stream
        .orderBy('batch_timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen(
      (QuerySnapshot snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _processNewBatch(snapshot.docs.first);
        }
      },
      onError: (error) {
        setState(() {
          _status = "Error: $error";
          _isStreaming = false;
        });
      },
    );
  }

  void _stopStreaming() {
    _streamSubscription?.cancel();
    _frameDisplayTimer?.cancel();
    setState(() {
      _isStreaming = false;
      _status = "Stream stopped";
    });
  }

  void _processNewBatch(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      final frameCount =
          data['frame_count'] as int? ?? 10; // Changed default from 5 to 10

      // Extract batch metadata
      _deviceId = data['deviceId'] as String?;
      _imageWidth = int.tryParse(data['width']?.toString() ?? '');
      _imageHeight = int.tryParse(data['height']?.toString() ?? '');

      // Extract all frames from the batch
      List<FrameData> newBatch = [];
      for (int i = 1; i <= frameCount; i++) {
        final imageKey = 'frame_${i}_image';
        final timestampKey = 'frame_${i}_timestamp';

        final base64Image = data[imageKey] as String?;
        final timestamp = data[timestampKey] as int?;

        if (base64Image != null &&
            base64Image.isNotEmpty &&
            timestamp != null) {
          try {
            final imageBytes = base64Decode(base64Image);
            newBatch.add(FrameData(
              imageBytes: imageBytes,
              timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
            ));
          } catch (e) {
            print('Error decoding frame $i: $e');
          }
        }
      }

      if (newBatch.isNotEmpty) {
        _batchCount++;
        _currentBatch = newBatch;
        _currentFrameInBatch = 0;

        // Cancel existing timer
        _frameDisplayTimer?.cancel();

        // Start displaying frames from the batch sequentially
        _displayBatchFrames();

        setState(() {
          _status = "Streaming (Batch: $_batchCount, Frames: $_frameCount)";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Error processing batch: $e";
      });
    }
  }

  void _displayBatchFrames() {
    if (_currentBatch.isEmpty) return;

    // Display first frame immediately
    _displayFrame(_currentBatch[0]);

    if (_currentBatch.length > 1) {
      // Set up timer to display remaining frames at 5 FPS
      const frameInterval =
          Duration(milliseconds: 200); // 5fps (1000ms / 5 = 200ms)

      _frameDisplayTimer = Timer.periodic(frameInterval, (timer) {
        _currentFrameInBatch++;

        if (_currentFrameInBatch >= _currentBatch.length) {
          timer.cancel();
          return;
        }

        _displayFrame(_currentBatch[_currentFrameInBatch]);
      });
    }
  }

  void _displayFrame(FrameData frameData) {
    // Calculate FPS
    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final timeDiff = now.difference(_lastFrameTime!).inMilliseconds;
      if (timeDiff > 0) {
        _fps = 1000 / timeDiff;
      }
    }
    _lastFrameTime = now;
    _frameCount++;

    setState(() {
      _currentImageBytes = frameData.imageBytes;
    });
  }

  void _downloadCurrentFrame() {
    if (_currentImageBytes != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Download functionality is not implemented for mobile.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _frameDisplayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32 Camera Stream'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: Icon(_isStreaming ? Icons.stop : Icons.play_arrow),
            onPressed: _isStreaming ? _stopStreaming : _startStreaming,
            tooltip: _isStreaming ? 'Stop Stream' : 'Start Stream',
          ),
          if (_currentImageBytes != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadCurrentFrame,
              tooltip: 'Download Current Frame',
            ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey[800],
            child: Row(
              children: [
                Icon(
                  _isStreaming ? Icons.circle : Icons.circle_outlined,
                  color: _isStreaming ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _status,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (_fps > 0) ...[
                  Text(
                    'FPS: ${_fps.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (_deviceId != null) ...[
                  Text(
                    'Device: $_deviceId',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Video stream area
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: _currentImageBytes != null
                  ? InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 5.0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey[700]!, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Image.memory(
                            _currentImageBytes!,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.none,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam_off,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isStreaming
                                ? 'Waiting for first batch...'
                                : 'Stream not active',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[400],
                            ),
                          ),
                          if (_isStreaming) ...[
                            const SizedBox(height: 16),
                            const CircularProgressIndicator(),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
          // Info panel
          if (_currentImageBytes != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.grey[900],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoItem(
                    icon: Icons.photo_size_select_actual,
                    label: 'Resolution',
                    value: _imageWidth != null && _imageHeight != null
                        ? '${_imageWidth}x$_imageHeight'
                        : 'Unknown',
                  ),
                  _InfoItem(
                    icon: Icons.data_usage,
                    label: 'Size',
                    value:
                        '${(_currentImageBytes!.length / 1024).toStringAsFixed(1)} KB',
                  ),
                  _InfoItem(
                    icon: Icons.access_time,
                    label: 'Frames',
                    value: _frameCount.toString(),
                  ),
                  _InfoItem(
                    icon: Icons.batch_prediction,
                    label: 'Batches',
                    value: _batchCount.toString(),
                  ),
                  _InfoItem(
                    icon: Icons.speed,
                    label: 'FPS',
                    value: _fps > 0 ? _fps.toStringAsFixed(1) : '0.0',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class FrameData {
  final Uint8List imageBytes;
  final DateTime timestamp;

  FrameData({
    required this.imageBytes,
    required this.timestamp,
  });
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
