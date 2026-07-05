import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static Future<bool> checkInternet(BuildContext context) async {
    final results = await Connectivity().checkConnectivity();

    bool isOffline = false;

    if (results is List<ConnectivityResult>) {
      isOffline = results.isEmpty ||
          results.every((result) => result == ConnectivityResult.none);
    } else {
      isOffline = results == ConnectivityResult.none;
    }

    if (isOffline) {
      if (!context.mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "오프라인 상태입니다.\n"
                      "인터넷 연결을 확인해 주세요.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      return false;
    }

    return true;
  }
}