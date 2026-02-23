import 'package:flutter_dotenv/flutter_dotenv.dart';

String buildSessionWebSocketUrl({
  required int sessionId,
  required int userId,
}) {
  return buildSessionWebSocketUrls(
    sessionId: sessionId,
    userId: userId,
  ).first;
}

List<String> buildSessionWebSocketUrls({
  required int sessionId,
  required int userId,
}) {
  final rawWsBase = dotenv.env['WS_BASE_URL']?.trim();
  final rawApiBase = dotenv.env['API_BASE_URL']?.trim();

  final base = _normalizeBase(rawWsBase, rawApiBase);
  final parsedBase = Uri.parse(base);

  final primary = parsedBase.replace(
    path: '${_cleanPath(parsedBase.path)}/ws/sessions/$sessionId',
    queryParameters: {'user_id': '$userId'},
  );

  final urls = <String>[primary.toString()];

  // Fallback for deployments where HTTP APIs are prefixed (e.g. /seeds) but
  // WebSocket proxy is mounted at root /ws.
  if (_cleanPath(parsedBase.path).isNotEmpty) {
    final rootFallback = parsedBase.replace(
      path: '/ws/sessions/$sessionId',
      queryParameters: {'user_id': '$userId'},
    );
    urls.add(rootFallback.toString());
  }

  return urls;
}

String _normalizeBase(String? wsBase, String? apiBase) {
  if (wsBase != null && wsBase.isNotEmpty) {
    return _stripDocsPath(_ensureWsScheme(wsBase));
  }

  if (apiBase != null && apiBase.isNotEmpty) {
    return _stripDocsPath(_ensureWsScheme(apiBase));
  }

  throw StateError('WS_BASE_URL or API_BASE_URL must be configured');
}

String _ensureWsScheme(String url) {
  if (url.startsWith('ws://') || url.startsWith('wss://')) return url;
  if (url.startsWith('https://')) return url.replaceFirst('https://', 'wss://');
  if (url.startsWith('http://')) return url.replaceFirst('http://', 'ws://');
  return 'ws://$url';
}

String _stripDocsPath(String url) {
  final uri = Uri.parse(url);
  final path = _cleanPath(uri.path);
  if (path.endsWith('/docs')) {
    return uri.replace(path: path.substring(0, path.length - 5)).toString();
  }
  return uri.toString();
}

String _cleanPath(String path) {
  if (path.isEmpty || path == '/') return '';
  return path.endsWith('/') ? path.substring(0, path.length - 1) : path;
}