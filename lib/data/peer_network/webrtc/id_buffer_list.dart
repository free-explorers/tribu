class IdBufferList {
  final Set<String> idList = {};
  final bufferLength = 10;
  bool handle(String id) {
    final handle = idList.add(id);
    if (idList.length > bufferLength) {
      idList.remove(idList.first);
    }
    return handle;
  }
}
