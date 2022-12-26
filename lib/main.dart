import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Declare variables to store the selected platform, username, and statistics
  final String apiKey = "Lhb05x6TrJyBZWv8fS5qPKBXO";
  final String apiSecret = "bo9NGyJHnlBO8teAYZjj1TzMIkB9w418QxMq4XwPGtEVT2yJ0K";
  String? _selectedPlatform;
  String? _username;
  Map<String, dynamic> _stats = {};

  // Function to fetch the statistics for the selected platform
  Future<void> _fetchStats() async {
    if (_selectedPlatform == null || _username == null) return;

    // Make the HTTP request to the API and store the response
    var response;
    var resp;
    if (_selectedPlatform == 'GitHub') {
      resp =
          await http.get(Uri.parse('https://api.github.com/users/$_username'));
      response = json.decode(resp.body);
    } else if (_selectedPlatform == 'Twitter') {
      final String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$apiKey:$apiSecret'));

      // Make a request to the Twitter API to get a Bearer token
      final http.Response tokenResponse = await http.post(
        Uri.parse('https://api.twitter.com/oauth2/token'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
        },
        body: 'grant_type=client_credentials',
      );

      // If the request was successful, parse the Bearer token from the response
      if (tokenResponse.statusCode == 200) {
        final Map<String, dynamic> tokenData = json.decode(tokenResponse.body);
        final String bearerToken = tokenData['access_token'];

        // Make a request to the Twitter API v2 to get the user's statistics
        resp = await http.get(
          Uri.parse(
              'https://api.twitter.com/2/users/by/username/$_username?user.fields=created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld'),
          headers: {
            'Authorization': 'Bearer $bearerToken',
          },
        );
        response = json.decode(resp.body)["data"];
        print(json.decode(resp.body));
      }
      else {
        response = {
          "err":"Response code: ${tokenResponse.statusCode}"
        };
      }
    } else if (_selectedPlatform == 'Reddit') {
      resp = await http
          .get(Uri.parse('https://www.reddit.com/user/$_username/about.json'));
      response = json.decode(resp.body)["data"];
    }

    // Parse the response and extract the relevant statistics
    if (resp.statusCode == 200) {
      _stats = Map.from(response);
    } else {
      _stats = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Statisfy'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Form to select the platform and enter the username
              Form(
                child: Column(
                  children: [
// Radio buttons to select the platform
                    RadioListTile(
                      title: Text('GitHub'),
                      value: 'GitHub',
                      groupValue: _selectedPlatform,
                      onChanged: (value) {
                        setState(() {
                          _selectedPlatform = value;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('Twitter'),
                      value: 'Twitter',
                      groupValue: _selectedPlatform,
                      onChanged: (value) {
                        setState(() {
                          _selectedPlatform = value;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('Reddit'),
                      value: 'Reddit',
                      groupValue: _selectedPlatform,
                      onChanged: (value) {
                        setState(() {
                          _selectedPlatform = value;
                        });
                      },
                    ),
// Text field to enter the username
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Username',
                      ),
                      onChanged: (value) {
                        _username = value;
                      },
                    ),
// Button to fetch the statistics
                    ElevatedButton(
                      child: Text('Fetch Statistics'),
                      onPressed: _fetchStats,
                    ),
                  ],
                ),
              ),
// Display the statistics
              _stats == {}
                  ? Container()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _stats.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_stats.keys.toList()[index]),
                            subtitle:
                                Text(_stats.values.toList()[index].toString()),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twitter Statistics',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Replace YOUR_API_KEY and YOUR_API_SECRET with your own API key and secret
  final String apiKey = "Lhb05x6TrJyBZWv8fS5qPKBXO";
  final String apiSecret = "bo9NGyJHnlBO8teAYZjj1TzMIkB9w418QxMq4XwPGtEVT2yJ0K";
  String? username;
  int? followers;
  int? following;
  int? tweets;
  String? description;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Twitter Statistics'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter a Twitter username',
            ),
            onChanged: (value) {
              setState(() {
                username = value;
              });
            },
          ),
          ElevatedButton(
            child: Text('Get Statistics'),
            onPressed: () async {
              // Encode the API key and secret in base64
              final String basicAuth =
                  'Basic ' + base64Encode(utf8.encode('$apiKey:$apiSecret'));

              // Make a request to the Twitter API to get a Bearer token
              final http.Response tokenResponse = await http.post(
                Uri.parse('https://api.twitter.com/oauth2/token'),
                headers: {
                  'Authorization': basicAuth,
                  'Content-Type':
                      'application/x-www-form-urlencoded;charset=UTF-8',
                },
                body: 'grant_type=client_credentials',
              );

              // If the request was successful, parse the Bearer token from the response
              if (tokenResponse.statusCode == 200) {
                final Map<String, dynamic> tokenData =
                    json.decode(tokenResponse.body);
                final String bearerToken = tokenData['access_token'];

                // Make a request to the Twitter API v2 to get the user's statistics
                final http.Response userResponse = await http.get(
                  Uri.parse(
                      'https://api.twitter.com/2/users/by/username/$username?user.fields=created_at,description,entities,id,location,name,pinned_tweet_id,profile_image_url,protected,public_metrics,url,username,verified,withheld'),
                  headers: {
                    'Authorization': 'Bearer $bearerToken',
                  },
                );

                // If the request was successful, parse the user's statistics from the response
                if (userResponse.statusCode == 200) {
                  final Map<String, dynamic> userData =
                      json.decode(userResponse.body);
                  print(userResponse.body);
                  setState(() {
                    followers = userData["data"]['public_metrics']['followers_count'];
                    tweets = userData["data"]['public_metrics']['tweet_count'];
                    following = userData["data"]['public_metrics']['following_count'];
                    description = userData["data"]['description'];
                  });
                }
              }
            },
          ),
          Text('Followers: $followers'),
          Text('Following: $following'),
          Text('Tweets: $tweets'),
          Text('Description: $description')
        ],
      ),
    );
  }
}
*/
