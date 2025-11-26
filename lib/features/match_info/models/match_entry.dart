// To parse this JSON data, do
//
//     final matchEntry = matchEntryFromJson(jsonString);

import 'dart:convert';

List<MatchEntry> matchEntryFromJson(String str) => List<MatchEntry>.from(json.decode(str).map((x) => MatchEntry.fromJson(x)));

String matchEntryToJson(List<MatchEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MatchEntry {
    String id;
    String title;
    DateTime date;
    String city;
    String country;
    bool isInfoHot;
    Team homeTeam;
    Team awayTeam;
    int scoreHome;
    int scoreAway;
    int views;
    dynamic userId;

    MatchEntry({
        required this.id,
        required this.title,
        required this.date,
        required this.city,
        required this.country,
        required this.isInfoHot,
        required this.homeTeam,
        required this.awayTeam,
        required this.scoreHome,
        required this.scoreAway,
        required this.views,
        required this.userId,
    });

    factory MatchEntry.fromJson(Map<String, dynamic> json) => MatchEntry(
        id: json["id"],
        title: json["title"],
        date: DateTime.parse(json["date"]),
        city: json["city"],
        country: json["country"],
        isInfoHot: json["is_info_hot"],
        homeTeam: Team.fromJson(json["home_team"]),
        awayTeam: Team.fromJson(json["away_team"]),
        scoreHome: json["score_home"],
        scoreAway: json["score_away"],
        views: json["views"],
        userId: json["user_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "city": city,
        "country": country,
        "is_info_hot": isInfoHot,
        "home_team": homeTeam.toJson(),
        "away_team": awayTeam.toJson(),
        "score_home": scoreHome,
        "score_away": scoreAway,
        "views": views,
        "user_id": userId,
    };
}

class Team {
    String name;
    String flag;

    Team({
        required this.name,
        required this.flag,
    });

    factory Team.fromJson(Map<String, dynamic> json) => Team(
        name: json["name"],
        flag: json["flag"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "flag": flag,
    };
}