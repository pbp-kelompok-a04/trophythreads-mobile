import 'package:flutter/material.dart';
import 'package:trophythreads_mobile/features/match_info/models/match_entry.dart';
import 'package:trophythreads_mobile/features/match_info/screens/match_detail.dart';
import 'package:trophythreads_mobile/features/match_info/widgets/match_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class MatchEntryListPage extends StatefulWidget {
  const MatchEntryListPage({super.key});

  @override
  State<MatchEntryListPage> createState() => _MatchEntryListPageState();
}

class _MatchEntryListPageState extends State<MatchEntryListPage> {
  Future<List<MatchEntry>> fetchMatch(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/informasi/json/');
    
    var data = response;
    
    List<MatchEntry> listMatch = [];
    for (var d in data) {
      if (d != null) {
        listMatch.add(MatchEntry.fromJson(d));
      }
    }
    return listMatch;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      body: FutureBuilder(
        future: fetchMatch(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    'There are no match in TrophyThreads yet.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) => MatchEntryCard(
                  match: snapshot.data![index],
                  onTap: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text("You clicked on ${snapshot.data![index].title}"),
                        ),
                      );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }
}