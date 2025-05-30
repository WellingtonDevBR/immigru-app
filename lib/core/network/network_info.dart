import 'package:connectivity_plus/connectivity_plus.dart';

/// Interface for checking network connectivity
abstract class INetworkInfo {
  /// Returns true if the device is connected to the internet
  Future<bool> get isConnected;
}

/// Implementation of [INetworkInfo] using [Connectivity]
class NetworkInfo implements INetworkInfo {
  /// The connectivity instance
  final Connectivity connectivity;

  /// Constructor
  NetworkInfo(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
