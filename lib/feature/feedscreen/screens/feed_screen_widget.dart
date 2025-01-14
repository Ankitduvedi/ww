import 'package:com.while.while_app/feature/feedscreen/controller/categories_test_provider.dart';
import 'package:com.while.while_app/feature/feedscreen/screens/feed_video_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';
import 'package:flutter/material.dart';

class FeedScreenWidget extends ConsumerStatefulWidget {
  const FeedScreenWidget({Key? key, required this.category}) : super(key: key);
  final String category;
  @override
  FeedScreenWidgetState createState() => FeedScreenWidgetState();
}

class FeedScreenWidgetState extends ConsumerState<FeedScreenWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initial fetch
    Future.microtask(() => ref
        .read(allVideoProvider(widget.category).notifier)
        .fetchVideos(widget.category));

    _scrollController.addListener(() {
      // Check if we're at the bottom of the list
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Trigger loading more categories
        ref
            .read(allVideoProvider(widget.category).notifier)
            .fetchVideos(widget.category);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(allVideoProvider(widget.category));
    log('Total numbers of videos ${state.videos.length} category${widget.category}');
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: SizedBox(
        height: 160,
        child: GridView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 3.0,
            childAspectRatio: 9 / 14,
          ),
          itemCount: state.videos.length + (state.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.videos.length) {
              // Show a loading indicator at the bottom
              return const Center(child: CircularProgressIndicator());
            }
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        VideoScreen(video: state.videos[index]),
                  ),
                );
              },
              child: Card(
                color: Colors.black,
                elevation: 4.0,
                child: Stack(
                  alignment: AlignmentDirectional.bottomStart,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image:
                                  NetworkImage(state.videos[index].thumbnail),
                              fit: BoxFit.cover,
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        state.videos[index].title,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 16.0,
                            color: Color.fromARGB(255, 145, 145, 145)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
