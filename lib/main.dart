import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

@immutable
class Film {
  final String id;
  final String title;
  final String description;
  final bool isFavourite;
  const Film({
    required this.id,
    required this.title,
    required this.description,
    required this.isFavourite,
  });
  Film copyWith({required isFavourite}) {
    return Film(
      description: description,
      id: id,
      title: title,
      isFavourite: isFavourite,
    );
  }

  @override
  String toString() {
    return 'Film(id: $id, title: $title, description: $description, isFavourite: $isFavourite,)';
  }

  @override
  bool operator ==(covariant Film other) =>
      id == other.id && isFavourite == other.isFavourite;

  @override
  int get hashCode => Object.hashAll([
        id,
        isFavourite,
      ]);
}

const allFilms = [
  Film(
    id: '1',
    title: 'The ShawsShank Redemption',
    description: 'Description for the ShawsShank Redemption',
    isFavourite: false,
  ),
  Film(
    id: '2',
    title: 'The GodFather',
    description: 'Description for the GodFather',
    isFavourite: false,
  ),
  Film(
    id: '3',
    title: 'The Godfather: Part 2 ',
    description: 'Description for the godfather the second part',
    isFavourite: false,
  ),
  Film(
    id: '4',
    title: 'The Dark Knight',
    description: 'Description for the dark knight',
    isFavourite: false,
  ),
  Film(
    id: '5',
    title: 'The fellowship of the rings ',
    description: 'Description for the lord of the rings',
    isFavourite: false,
  ),
  Film(
    id: '6',
    title: 'The Two towers',
    description: 'Description for the lord of the ring part 2',
    isFavourite: false,
  ),
];

class FilmsNotifier extends StateNotifier<List<Film>> {
  FilmsNotifier() : super(allFilms);

  void updater(Film films, bool isFavourite) {
    state = state
        .map((thisFilm) => thisFilm.id == films.id
            ? thisFilm.copyWith(isFavourite: isFavourite)
            : thisFilm)
        .toList();
  }
}

enum FavoriteStatus {
  all,
  favourite,
  notFavourite,
}

//favourite status
final favouriteStateProvider = StateProvider<FavoriteStatus>((_) {
  return FavoriteStatus.all;
});

final allFilmsProvider =
    StateNotifierProvider<FilmsNotifier, List<Film>>((_) => FilmsNotifier());
//favourite films
final favouriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where((film) => film.isFavourite),
);
//favourite films
final notfavouriteFilmsProvider = Provider<Iterable<Film>>(
  (ref) => ref.watch(allFilmsProvider).where((film) => !film.isFavourite),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Films'),
        ),
        body: Column(
          children: [
            const FilterWidget(),
            Consumer(
              builder: (context, ref, child) {
                final filter = ref.watch(favouriteStateProvider);
                switch (filter) {
                  case FavoriteStatus.all:
                    return FilmsWidget(provider: allFilmsProvider);
                  case FavoriteStatus.favourite:
                    return FilmsWidget(provider: favouriteFilmsProvider);
                  case FavoriteStatus.notFavourite:
                    return FilmsWidget(provider: notfavouriteFilmsProvider);
                }
              },
            )
          ],
        ));
  }
}

class FilmsWidget extends ConsumerWidget {
  final AlwaysAliveProviderBase<Iterable<Film>> provider;
  const FilmsWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final films = ref.watch(provider);
    return Expanded(
      child: ListView.builder(
          itemCount: films.length,
          itemBuilder: (context, index) {
            final film = films.elementAt(index);
            final favouriteIcon = film.isFavourite
                ? const Icon(Icons.favorite)
                : const Icon(Icons.favorite_border);
            return ListTile(
              title: Text(film.title),
              subtitle: Text(film.description),
              trailing: IconButton(
                icon: favouriteIcon,
                onPressed: () {
                  final isFavourite = !film.isFavourite;
                  ref
                      .read(allFilmsProvider.notifier)
                      .updater(film, isFavourite);
                },
              ),
            );
          }),
    );
  }
}

class FilterWidget extends StatelessWidget {
  const FilterWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return DropdownButton(
          value: ref.watch(favouriteStateProvider),
          items: FavoriteStatus.values
              .map((fs) => DropdownMenuItem(
                  value: fs, child: Text(fs.toString().split('.').last)))
              .toList(),
          onChanged: (FavoriteStatus? fs) {
            // ignore: deprecated_member_use
            ref.read(favouriteStateProvider.notifier).state = fs!;
          });
    });
  }
}
