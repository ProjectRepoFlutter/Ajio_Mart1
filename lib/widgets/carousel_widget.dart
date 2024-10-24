import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageCarouselWidget extends StatefulWidget {
  final List<String> imageUrls;
  final double height;

  const ImageCarouselWidget({
    Key? key,
    required this.imageUrls,
    required this.height,
  }) : super(key: key);

  @override
  _ImageCarouselWidgetState createState() => _ImageCarouselWidgetState();
}

class _ImageCarouselWidgetState extends State<ImageCarouselWidget> {
  int _currentIndex = 0; // To track the current index

  @override
  Widget build(BuildContext context) {
    // Filter out invalid image URLs (those that can't be displayed)
    List<String> validImageUrls = widget.imageUrls.where((url) => url.isNotEmpty).toList();

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: widget.height,
            autoPlay: true,
            aspectRatio: 16 / 9,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index; // Update current index on page change
              });
            },
          ),
          items: validImageUrls.map((item) {
            return GestureDetector(
              onTap: () {
                // Handle slide tap
                print('Tapped on slide: $item');
                // You can navigate or perform any action here
              },
              child: Container(
                child: Center(
                  child: Image.network(
                    item,
                    fit: BoxFit.cover,
                    width: 1000,
                    // Error handling for invalid image URLs
                    errorBuilder: (context, error, stackTrace) {
                      return Container(); // Return an empty container if the image fails to load
                    },
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: validImageUrls.asMap().entries.map((entry) {
            int index = entry.key;
            return GestureDetector(
              onTap: () {
                // Navigate to the tapped slide
                print('Tapped on dot: $index');
                // You can use the carousel controller to jump to the slide
              },
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index ? Colors.blue : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
