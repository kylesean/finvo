// CustomContentGenerator 回归测试：传输层是 GenUI 交互请求的唯一发送者。
//
// 覆盖 C1 回归：onUserMessageSent 必须始终携带 [GENUI_INTERNAL] 前缀（上层
// 只能展示、不得二次发送），且每个交互恰好发起一个 HTTP 请求，payload 完整
// （含 metadata/client_state，不得在二次发送中被丢弃）。

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart' as genui;

import 'package:finvo/core/storage/secure_storage_service.dart';
import 'package:finvo/features/chat/constants/genui_markers.dart';
import 'package:finvo/features/chat/services/custom_content_generator.dart';
import 'package:finvo/i18n/strings.g.dart';

class _FakeSecureStorageService extends SecureStorageService {
  _FakeSecureStorageService() : super(const FlutterSecureStorage());

  @override
  Future<String?> getToken() async => 'test-token';
}

/// Records every request and serves a fixed SSE body.
class _RecordingAdapter implements HttpClientAdapter {
  final List<({String url, String body})> requests = [];
  final String sseBody;

  _RecordingAdapter(this.sseBody);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = BytesBuilder();
    await for (final List<int> chunk in requestStream ?? const Stream.empty()) {
      bytes.add(chunk);
    }
    requests.add((
      url: options.uri.toString(),
      body: utf8.decode(bytes.takeBytes()),
    ));
    return ResponseBody.fromString(
      sseBody,
      200,
      headers: {
        Headers.contentTypeHeader: ['text/event-stream'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 构造一条携带 UI 交互的"空文本"user 消息（genui 0.10 按钮交互标准形态）。
genui.ChatMessage interactionMessage(Object interaction) {
  return genui.ChatMessage.user(
    '',
    parts: [
      genui.UiInteractionPart.create(
        interaction is String ? interaction : jsonEncode(interaction),
      ),
    ],
  );
}

void main() {
  // The SSE body carries only this unknown event type: it terminates the
  // stream cleanly without triggering the `done` handler, so the stream-close
  // path alone drives onStreamComplete (exactly once).
  const doneSseBody = 'data: {"type":"ping"}\n\n';

  setUp(() async {
    // Generated i18n accessors (used by GenUiEventRegistry handlers) require
    // an initialized locale before first use.
    await LocaleSettings.setLocale(AppLocale.zh);
  });

  late _RecordingAdapter adapter;
  late CustomContentGenerator generator;
  final userMessageSent = <String>[];
  var streamCompleteCount = 0;

  setAdapter(String sseBody) {
    adapter = _RecordingAdapter(sseBody);
    final dio = Dio(BaseOptions())..httpClientAdapter = adapter;
    generator = CustomContentGenerator(
      _FakeSecureStorageService(),
      dio: dio,
      sseBaseUrlResolver: () => 'http://localhost:8080',
    );
    userMessageSent.clear();
    streamCompleteCount = 0;
    generator.onUserMessageSent = userMessageSent.add;
    generator.onStreamComplete = () => streamCompleteCount++;
  }

  tearDown(() {
    generator.dispose();
    adapter.close();
  });

  test('clientState-less interaction: prefixed notification and EXACTLY ONE '
      'request carrying the full metadata payload', () async {
    setAdapter(doneSseBody);

    // account_selected 没有 atomic mutation（clientState == null），正是 C1 的
    // 触发路径：内容只走展示通知，请求由本传输层唯一发出。
    await generator.sendRequest(
      interactionMessage({
        'version': 'v0.9',
        'action': {
          'name': 'account_selected',
          'sourceComponentId': 'AccountSelector',
          'context': {
            'surface_id': 'surface_abc',
            'account_id': 'acc-1',
            'account_name': '现金钱包',
            'account_type': 'checking',
          },
        },
      }),
    );

    // 上层收到的展示内容必须始终带 [GENUI_INTERNAL] 前缀（不得再二次发送）。
    expect(userMessageSent, hasLength(1));
    expect(userMessageSent.first, startsWith(genuiInternalMarker));
    expect(userMessageSent.first, contains('acc-1'));

    // 恰好一次 HTTP 请求。
    expect(adapter.requests, hasLength(1));

    // 请求体必须保留完整元数据（account_id 上下文），不能被裸文本替代。
    final body =
        jsonDecode(adapter.requests.single.body) as Map<String, dynamic>;
    final messages = body['messages'] as List<dynamic>;
    expect(messages, hasLength(1));
    final message = messages.first as Map<String, dynamic>;
    expect(message['content'], contains('I selected account ID'));
    final metadata = message['metadata'] as Map<String, dynamic>;
    expect(metadata['event_type'], 'account_selected');
    expect(metadata['account_id'], 'acc-1');
    expect(metadata['account_name'], '现金钱包');

    // 正常终止信号（仅由流结束驱动一次）。
    expect(streamCompleteCount, 1);
  });

  test('atomic client_state interaction: prefixed display + client_state '
      'kept in the single request', () async {
    setAdapter(doneSseBody);

    await generator.sendRequest(
      interactionMessage({
        'version': 'v0.9',
        'action': {
          'name': 'space_selected',
          'sourceComponentId': 'SpaceSelector',
          'context': {
            'surface_id': 'surface_x',
            'space_id': 'space-9',
            'space_name': '家庭',
          },
        },
      }),
    );

    expect(userMessageSent, hasLength(1));
    expect(userMessageSent.first, startsWith(genuiInternalMarker));
    expect(adapter.requests, hasLength(1));

    final body =
        jsonDecode(adapter.requests.single.body) as Map<String, dynamic>;
    expect(body['client_state'], isNotNull);
    expect(streamCompleteCount, 1);
  });

  test('plain user text: prefixed display + one request', () async {
    setAdapter(doneSseBody);

    await generator.sendRequest(genui.ChatMessage.user('记一笔早餐 15 元'));

    expect(userMessageSent, hasLength(1));
    expect(userMessageSent.first, '[GENUI_INTERNAL]记一笔早餐 15 元');
    expect(adapter.requests, hasLength(1));

    final body =
        jsonDecode(adapter.requests.single.body) as Map<String, dynamic>;
    expect(body['messages'][0]['content'], '记一笔早餐 15 元');
    expect(streamCompleteCount, 1);
  });

  test('multiple sequential interactions do not cancel each other', () async {
    setAdapter(doneSseBody);

    await generator.sendRequest(genui.ChatMessage.user('第一条'));
    await generator.sendRequest(genui.ChatMessage.user('第二条'));

    expect(adapter.requests, hasLength(2));
    expect(streamCompleteCount, 2);
  });

  test('SSE base URL is resolved per request (server switch takes effect '
      'without service rebuild)', () async {
    setAdapter(doneSseBody);

    var baseUrl = 'http://old-server:8080';
    generator = CustomContentGenerator(
      _FakeSecureStorageService(),
      dio: Dio(BaseOptions())..httpClientAdapter = adapter,
      sseBaseUrlResolver: () => baseUrl,
    );

    await generator.sendRequest(genui.ChatMessage.user('第一条'));
    expect(adapter.requests.single.url, startsWith('http://old-server:8080'));

    // Simulate a server switch: the resolver now returns the new address and
    // the very next request must stream from it, without any re-initialization.
    baseUrl = 'http://new-server:9090';
    adapter.requests.clear();
    await generator.sendRequest(genui.ChatMessage.user('第二条'));

    expect(adapter.requests.single.url, startsWith('http://new-server:9090'));
  });
}
