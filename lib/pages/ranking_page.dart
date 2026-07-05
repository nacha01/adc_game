import 'package:flutter/material.dart';

import '../models/game_info.dart';
import '../services/api_service.dart';

class RankingPage extends StatefulWidget {
  final GameInfo gameInfo;

  const RankingPage({
    super.key,
    required this.gameInfo,
  });

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  bool loading = true;
  List<dynamic> ranking = [];

  @override
  void initState() {
    super.initState();
    loadRanking();
  }

  Future<void> loadRanking() async {
    final result = await ApiService.getRanking(
      gameCode: widget.gameInfo.id,
    );

    if (result["success"] == true) {
      ranking = result["ranking"] ?? [];
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: Text("${widget.gameInfo.title} 순위"),
        centerTitle: true,
        backgroundColor: const Color(0xFFE62D2D),
        foregroundColor: Colors.white,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ranking.isEmpty
              ? const Center(
                  child: Text("아직 등록된 점수가 없습니다."),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ranking.length,
                  itemBuilder: (context, index) {
                    final item = ranking[index];

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE62D2D),
                          foregroundColor: Colors.white,
                          child: Text("${index + 1}"),
                        ),
                        title: Text(
                          "${item["name"]}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          "${item["best_score"]}점",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE62D2D),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
