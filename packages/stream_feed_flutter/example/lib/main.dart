import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:stream_feed_flutter/stream_feed_flutter.dart';

/// Defines sample users used to log into the sample application with.
///
/// You can "log in" to this sample application as any of these users.
class SampleUser {
  const SampleUser.groovinChip()
      : id = 'GroovinChip',
        firstName = 'Reuben',
        lastName = 'Turner',
        token =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiR3Jvb3ZpbkNoaXAifQ.IiCLY_1h3mNIuf_yIMSWYZefzsII5R1djNVYPZjcgXo',
        profileImage = 'https://avatars.githubusercontent.com/u/4250470?v=4',
        handle = '@GroovinChip';

  const SampleUser.sacha()
      : id = 'SachaArbonel',
        firstName = 'Sacha',
        lastName = 'Arbonel',
        token =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiU2FjaGFBcmJvbmVsIn0.xAhGqzgGa1wPuUF74aHTHcJnGRf_OljoAY2gy87ll88',
        profileImage = 'https://avatars.githubusercontent.com/u/18029834?v=4',
        handle = '@sachaarbonel';

  /// The user's id.
  final String id;

  /// The user's firstt name.
  final String firstName;

  /// The user's last name
  final String lastName;

  String get fullName => '$firstName $lastName';

  /// The user's login token.
  ///
  /// In a production application, this should be generated by a backend service.
  final String token;

  /// The user's avatar url.
  final String profileImage;

  /// The user's "@" handle.
  final String handle;

  Map<String, Object> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'handle': handle,
      'profile_image': profileImage,
    };
  }
}

const sampleUsers = [
  SampleUser.groovinChip(),
  SampleUser.sacha(),
];

/// A simple convenience mixin for shorter code.
mixin StreamFeedMixin<T extends StatefulWidget> on State<T> {
  FeedBloc get bloc => FeedProvider.of(context).bloc;
  StreamFeedClient get client => bloc.client;
}

/// The entrypoint of our application.
///
/// How to run and use this application:
/// 1. Create a run configuration with the following arguments for `flutter run`:
///    --dart-define=key=q4vr7jwek7a4 --dart-define=user_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiR3Jvb3ZpbkNoaXAifQ.IiCLY_1h3mNIuf_yIMSWYZefzsII5R1djNVYPZjcgXo.
///    Alternatively, you can run `flutter run` in your
///    terminal and pass the `--dart-define` arguments there.
/// 2. Select a user to log in by tapping the tile that represents them.
/// 3. Play around with the app!
void main() {
  const apiKey = String.fromEnvironment('key');
  const userToken = String.fromEnvironment('user_token');
  final client = StreamFeedClient(
    apiKey,
    token: const Token(userToken),
  );

  runApp(
    MobileApp(
      client: client,
    ),
  );
}

class MobileApp extends StatelessWidget {
  const MobileApp({
    Key? key,
    required this.client,
  }) : super(key: key);

  final StreamFeedClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stream Feed Flutter Sample',
      theme: ThemeData(
        primaryColor: const Color(0xff005fff),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff005fff),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xff005fff),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xff005fff),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xff005fff),
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xff005fff),
            ),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xff005fff),
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade300,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xff005fff),
          ),
        ),
      ),
      builder: (context, child) {
        return StreamFeed(
          bloc: FeedBloc(client: client),
          child: child!,
        );
      },
      themeMode: ThemeMode.system,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with StreamFeedMixin {
  bool _loggingIn = false;

  Future<void> login(SampleUser user) async {
    setState(() => _loggingIn = true);
    try {
      await client.setUser(
        User(
          id: user.id,
          data: user.toJson(),
        ),
        Token(user.token),
      );

      final timeline = client.flatFeed('timeline');
      final currentUserFeed = client.flatFeed('user', user.id);
      await timeline.follow(currentUserFeed);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MyHomePage(),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
      setState(() => _loggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/stream_logo.png',
              height: 50,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to the Stream Feed Flutter Sample App!',
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text('Please choose a user to sign in as'),
            const SizedBox(height: 8),
            for (final sampleUser in sampleUsers)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(sampleUser.profileImage),
                        ),
                        title: Text(sampleUser.fullName),
                        subtitle: Text(sampleUser.handle),
                        onTap: () => login(sampleUser),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              child: _loggingIn
                  ? const CircularProgressIndicator()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with StreamFeedMixin {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Builder(builder: (context) {
            return Avatar(
              user: User(
                data: bloc.currentUser?.data,
              ),
              onUserTap: (user) {
                Scaffold.of(context).openDrawer();
              },
            );
          }),
        ),
        title: const Text('Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: UserSearchDelegate(),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Avatar(
                  user: User(
                    data: bloc.currentUser?.data,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bloc.currentUser!.data!['full_name'].toString(),
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 4),
                Text('${bloc.currentUser?.data!['handle']}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FollowingScreen(),
                        ),
                      ),
                      child: Text(
                          '${bloc.currentUser?.followingCount ?? 0} Following'),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FollowersScreen(),
                        ),
                      ),
                      child: Text(
                          '${bloc.currentUser?.followersCount ?? 0} Followers'),
                    ),
                  ],
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  minLeadingWidth: 0,
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  minLeadingWidth: 0,
                  leading: const Icon(Icons.exit_to_app_outlined),
                  title: const Text('Log out'),
                  onTap: () {
                    bloc.clearAllActivities(['user', 'timeline']);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _pageIndex,
        children: [
          FlatFeedListView(
            flags: EnrichmentFlags()
                .withReactionCounts()
                .withOwnChildren()
                .withOwnReactions(),
            feedGroup: 'timeline',
            nameJsonKey: 'full_name',
            userId: bloc.currentUser?.id,
            onHashtagTap: (hashtag) => debugPrint('hashtag pressed: $hashtag'),
            onUserTap: (user) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  user: user!,
                ),
              ),
            ),
            onMentionTap: (mention) => debugPrint('hashtag pressed: $mention'),
          ),
          const Center(
            child: Text('Notifications'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.edit_outlined),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ComposeScreen(),
            fullscreenDialog: true,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() => _pageIndex = value);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Timeline',
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.bell),
            label: 'Notifications',
          ),
        ],
      ),
    );
  }
}

class UserSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<StreamUser>(
      future: FeedProvider.of(context).bloc.client.user(query).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                  snapshot.data!.data!['profile_image'].toString()),
            ),
            title: Text(snapshot.data!.id),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  user: User(
                    id: snapshot.data!.id,
                    data: snapshot.data!.data,
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<StreamUser>(
      future: FeedProvider.of(context).bloc.client.user(query).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child:
                Text('User not found. Type an exact username to find a user.'),
          );
        } else {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                  snapshot.data!.data!['profile_image'].toString()),
            ),
            title: Text(snapshot.data!.id),
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  user: User(
                    id: snapshot.data!.id,
                    data: snapshot.data!.data,
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({
    Key? key,
  }) : super(key: key);

  @override
  _ComposeScreenState createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> with StreamFeedMixin {
  final postController = TextEditingController();

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose'),
        actions: [
          ActionChip(
            label: const Text('Post'),
            backgroundColor: const Color(0xff76fff1),
            onPressed: () async {
              if (postController.text.isNotEmpty) {
                try {
                  bloc.onAddActivity(
                    feedGroup: 'user',
                    verb: 'post',
                    object: postController.text,
                    userId: bloc.currentUser!.id,
                  );

                  Navigator.of(context).pop();
                } catch (e) {
                  debugPrint(e.toString());
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Avatar(
                  user: User(
                    data: bloc.currentUser?.data,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: postController,
                      autofocus: true,
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        hintText: 'What\'s on your mind?',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    Key? key,
    this.user,
  }) : super(key: key);

  final User? user;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with StreamFeedMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.user?.id ?? bloc.currentUser!.id),
            Text(
              '${widget.user?.data?['handle'] ?? bloc.currentUser!.data!['handle']}',
              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
        actions: [
          // If the user matches the currentUser, do not show the
          // follow/unfollow button; you cannot follow your own feed.
          if (widget.user != null && widget.user!.id != bloc.currentUser!.id)
            FutureBuilder<bool>(
              future: bloc.isFollowingUser(widget.user!.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                } else {
                  return IconButton(
                    icon: Icon(snapshot.data!
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline),
                    onPressed: () async {
                      // If isFollowingUser is true, unfollow the user's feed.
                      // If isFollowingUser is not true, follow the
                      // user's feed.
                      if (snapshot.data!) {
                        await bloc.unfollowFlatFeed(widget.user!.id!);
                        setState(() {}); //TODO: make this reactive in core
                      } else {
                        await bloc.followFlatFeed(widget.user!.id!);
                        setState(() {});
                      }
                    },
                  );
                }
              },
            ),
        ],
      ),
      body: Scrollbar(
        child: FlatFeedListView(
          flags: EnrichmentFlags()
              .withReactionCounts()
              .withOwnChildren()
              .withOwnReactions(),
          feedGroup: 'user',
          nameJsonKey: 'full_name',
          userId: widget.user?.id ?? bloc.currentUser!.id,
          onHashtagTap: (hashtag) => debugPrint('hashtag pressed: $hashtag'),
          onUserTap: (user) => debugPrint('hashtag pressed: ${user!.toJson()}'),
          onMentionTap: (mention) => debugPrint('hashtag pressed: $mention'),
        ),
      ),
    );
  }
}

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({Key? key}) : super(key: key);

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen>
    with StreamFeedMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
      ),
      body: FutureBuilder<List<Follow>>(
        future: client.flatFeed('timeline', bloc.currentUser!.id).following(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].feedId),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class FollowersScreen extends StatefulWidget {
  const FollowersScreen({Key? key}) : super(key: key);

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen>
    with StreamFeedMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
      ),
      body: FutureBuilder<List<Follow>>(
        future: client.flatFeed('user', bloc.currentUser!.id).followers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final feedName = snapshot.data![index].feedId.split(':').last;
                return ListTile(
                  title: Text(feedName),
                );
              },
            );
          }
        },
      ),
    );
  }
}
