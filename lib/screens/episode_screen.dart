import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';
import '../models/episode_model.dart';
import '../models/series_model.dart';
import '../utils/decryptor.dart';// Import your Series model

class EpisodeScreen extends StatefulWidget {
  final String seriesId;
  final Series series;

  EpisodeScreen({required this.seriesId, required this.series});

  @override
  _EpisodeScreenState createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  final ApiService apiService = ApiService();
  List<Episode> episodesList = [];
  int currentEpisodeIndex = 0;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    fetchEpisodes();
  }

  Future<void> fetchEpisodes() async {
    try {
      final fetchedEpisodes = await apiService.fetchEpisodes(widget.seriesId);
      setState(() {
        episodesList = fetchedEpisodes;
        if (episodesList.isNotEmpty) {
          _initializeAndPlayVideo(episodesList[currentEpisodeIndex].getDecryptedUrl());
        }
      });
    } catch (e) {
      print('Error fetching episodes: $e');
    }
  }

  void _initializeAndPlayVideo(String url) {
    _videoController?.removeListener(_videoEndListener);
    _videoController?.dispose();

    _videoController = VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {
          _videoController?.play();
        });
      });
    _videoController?.addListener(_videoEndListener);
  }

  void _videoEndListener() {
    if (_videoController?.value.position == _videoController?.value.duration) {
      _playNextEpisode();
    }
  }

  void _playNextEpisode() {
    if (currentEpisodeIndex < episodesList.length - 1) {
      setState(() {
        currentEpisodeIndex++;
        _initializeAndPlayVideo(episodesList[currentEpisodeIndex].getDecryptedUrl());
      });
    }
  }

  void _playPreviousEpisode() {
    if (currentEpisodeIndex > 0) {
      setState(() {
        currentEpisodeIndex--;
        _initializeAndPlayVideo(episodesList[currentEpisodeIndex].getDecryptedUrl());
      });
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoEndListener);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              _playNextEpisode();
            } else if (details.primaryVelocity! > 0) {
              _playPreviousEpisode();
            }
          }
        },
        child: Stack(
          children: [
            Center(
              child: _videoController != null && _videoController!.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
                  : CircularProgressIndicator(),
            ),
            Positioned(
              top: 40.0,
              left: 16.0,
              right: 16.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    "${widget.series.title} EP.${currentEpisodeIndex + 1}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 60.0,
              right: 16.0,
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.list, color: Colors.white, size: 32),
                    onPressed: () {
                      _showEpisodeList();
                    },
                  ),
                  SizedBox(height: 10),
                  Icon(Icons.bookmark, color: Colors.pinkAccent, size: 32),
                  SizedBox(height: 5),
                  Text(
                    "125K",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEpisodeList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('All Episodes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: episodesList.length,
                itemBuilder: (context, index) {
                  final episode = episodesList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        currentEpisodeIndex = index;
                        _initializeAndPlayVideo(episodesList[currentEpisodeIndex].getDecryptedUrl());
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: index == currentEpisodeIndex
                            ? Colors.redAccent
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${episode.episodeNumber}',
                        style: TextStyle(
                          fontSize: 16,
                          color: index == currentEpisodeIndex
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
