abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // For simplicity, we'll assume the network is always available
    // In a real app, you would use connectivity_plus or similar package
    return true;
  }
}