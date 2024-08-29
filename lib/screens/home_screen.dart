// screens/home_screen.dart

import 'dart:ui'; // Import for BackdropFilter
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Import the carousel_slider package
import '../services/api_service.dart';
import '../models/series_model.dart';
import 'episode_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  List<Series> seriesList = [];
  List<Series> filteredSeriesList = [];
  String searchQuery = '';
  int _selectedIndex = 0; // Track selected bottom navigation item
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    fetchSeries();
    _tabController = TabController(
        length: 4, vsync: this); // Initialize TabController with 4 tabs
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> fetchSeries() async {
    try {
      final fetchedSeries = await apiService.fetchSeries();
      setState(() {
        seriesList = fetchedSeries;
        filteredSeriesList = fetchedSeries;

        // Sort the series by the createdAt field in descending order
        filteredSeriesList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      });
    } catch (e) {
      print('Error fetching series: $e');
    }
  }


  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      filteredSeriesList = seriesList
          .where((series) =>
          series.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation or different actions for each tab
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          onChanged: updateSearchQuery,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.white,
          tabs: const [
            Tab(text: 'Popular'),
            Tab(text: 'New'),
            Tab(text: 'Original+'),
            Tab(text: 'Trending'),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: TabBarView(
        controller: _tabController,
        children: [
          buildSeriesGrid(filteredSeriesList), // Content for 'Popular'
          buildSeriesGrid(filteredSeriesList), // Content for 'New'
          buildSeriesGrid(filteredSeriesList), // Content for 'Original+'
          buildSeriesGrid(filteredSeriesList), // Content for 'Trending'
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur effect
          child: BottomNavigationBar(
            backgroundColor: Colors.black.withOpacity(0.5),
            // Semi-transparent black with glass effect
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'For You',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark),
                label: 'My List',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build a grid of series
  // Helper method to build a grid of series
  Widget buildSeriesGrid(List<Series> seriesList) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slider for Featured Series
          CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
            ),
            items: seriesList.take(5).map((series) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EpisodeScreen(seriesId: series.id, series: series),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    image: DecorationImage(
                      image: NetworkImage(series.poster),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        series.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 5.0,
                              color: Colors.black,
                              offset: Offset(0.5, 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          // "Latest" Text
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 16.0, horizontal: 8.0),
            child: Text(
              'Latest',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Grid for Series List
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 2 / 3,
              ),
              itemCount: seriesList.length,
              itemBuilder: (context, index) {
                final series = seriesList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EpisodeScreen(seriesId: series.id,
                                series: series),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: NetworkImage(series.poster),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.4),
                              // Semi-transparent dark gradient
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.black.withOpacity(0.5),
                            // Glass effect
                            backgroundBlendMode: BlendMode.overlay,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              series.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 5.0,
                                    color: Colors.black,
                                    offset: Offset(0.5, 0.5),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
