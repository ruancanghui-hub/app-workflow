import 'dart:convert';

import '../core/http/http_client.dart';
import 'sound_playback_resolver.dart';

class RemoteSoundItem {
  const RemoteSoundItem({
    required this.name,
    required this.size,
    required this.url,
    this.mtime,
  });

  final String name;
  final int size;
  final String url;
  final String? mtime;

  factory RemoteSoundItem.fromJson(Map<String, dynamic> json) => RemoteSoundItem(
        name: json['name'] as String,
        size: json['size'] as int,
        url: json['url'] as String,
        mtime: json['mtime'] as String?,
      );
}

class RemoteSoundListPage {
  const RemoteSoundListPage({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.list,
  });

  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final List<RemoteSoundItem> list;

  factory RemoteSoundListPage.fromJson(Map<String, dynamic> json) =>
      RemoteSoundListPage(
        total: json['total'] as int,
        page: json['page'] as int,
        pageSize: json['pageSize'] as int,
        totalPages: json['totalPages'] as int,
        list: (json['list'] as List<dynamic>)
            .map((e) => RemoteSoundItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class RemoteSoundApi {
  RemoteSoundApi(this._http);

  final HttpClient _http;

  Future<RemoteSoundListPage?> fetchPage({
    int page = 1,
    int pageSize = 20,
  }) async {
    final base = soundCdnBaseUrl;
    if (base.isEmpty) return null;

    final uri = Uri.parse('$base/api/list').replace(
      queryParameters: {
        'page': '$page',
        'pageSize': '$pageSize',
      },
    );
    final response = await _http.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'sound list request failed',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final code = decoded['code'] as int? ?? -1;
    if (code != 0) {
      throw HttpException(decoded['message'] as String? ?? 'sound list error');
    }

    final data = decoded['data'] as Map<String, dynamic>?;
    if (data == null) return null;
    return RemoteSoundListPage.fromJson(data);
  }

  Future<RemoteSoundListPage?> fetchAll({int pageSize = 50}) async {
    final first = await fetchPage(page: 1, pageSize: pageSize);
    if (first == null) return null;
    if (first.totalPages <= 1) return first;

    final merged = List<RemoteSoundItem>.from(first.list);
    for (var page = 2; page <= first.totalPages; page++) {
      final next = await fetchPage(page: page, pageSize: pageSize);
      if (next != null) merged.addAll(next.list);
    }

    return RemoteSoundListPage(
      total: first.total,
      page: 1,
      pageSize: pageSize,
      totalPages: first.totalPages,
      list: merged,
    );
  }
}
