import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/private_note_store.dart';

void main() {
  late Directory root;
  var changed = false;
  late PrivateNoteStore store;
  PrivateNoteStore open({int user = 7}) => PrivateNoteStore(
    root: root,
    userId: user,
    checkAccount: () async {
      if (changed) throw const PrivateNoteException('Account changed');
    },
  );
  Future<PrivateNote> save({
    String title = 'My study note',
    int bytes = 80,
  }) async {
    final prepared = await store.prepare(
      title: title,
      audioId: 9,
      position: const Duration(seconds: 25),
    );
    await File(prepared.path).writeAsBytes(List.filled(bytes, 1), flush: true);
    return store.finish(prepared.note.id, const Duration(seconds: 2));
  }

  setUp(() async {
    root = await Directory.systemTemp.createTemp('seeds-private-notes-test-');
    changed = false;
    store = open();
  });
  tearDown(() async => root.delete(recursive: true));
  test(
    'saved notes survive reopening with captured lesson timestamp, account identity and no token/URL',
    () async {
      final note = await save();
      final loaded = (await open().list()).single;
      expect(loaded.title, note.title);
      expect(loaded.audioId, 9);
      expect(loaded.position, const Duration(seconds: 25));
      expect(loaded.duration, const Duration(seconds: 2));
      expect(await File(await open().localPath(note.id)).length(), 80);
      final metadata = await File(
        '${store.directory.path}${Platform.pathSeparator}${note.id}.json',
      ).readAsString();
      expect(metadata, isNot(contains('token')));
      expect(metadata, isNot(contains('https:')));
      expect((jsonDecode(metadata) as Map)['account_id'], 7);
    },
  );
  test(
    'empty/incomplete/interrupted recordings cannot play or be marked saved',
    () async {
      final prepared = await store.prepare(title: 'Interrupted');
      expect((await store.list()).single.complete, isFalse);
      await expectLater(
        store.localPath(prepared.note.id),
        throwsA(isA<PrivateNoteException>()),
      );
      await expectLater(
        store.finish(prepared.note.id, const Duration(seconds: 1)),
        throwsA(isA<PrivateNoteException>()),
      );
      await File(prepared.path).writeAsBytes([1]);
      await expectLater(
        store.finish(prepared.note.id, Duration.zero),
        throwsA(isA<PrivateNoteException>()),
      );
      await expectLater(
        store.finish(prepared.note.id, const Duration(milliseconds: 300001)),
        throwsA(isA<PrivateNoteException>()),
      );
      expect((await store.list()).single.complete, isFalse);
      expect(await File(prepared.path).exists(), isTrue);
    },
  );
  test(
    'exact ten-million-byte and five-minute limits are accepted; one extra byte is rejected without eviction',
    () async {
      final prepared = await store.prepare(title: 'At limit');
      expect(prepared.allowance, 10000000);
      final output = await File(prepared.path).open(mode: FileMode.write);
      await output.truncate(10000000);
      await output.close();
      final note = await store.finish(
        prepared.note.id,
        const Duration(minutes: 5),
      );
      expect(note.complete, isTrue);
      await expectLater(
        store.prepare(title: 'No room'),
        throwsA(isA<PrivateNoteException>()),
      );
      expect(await store.usedBytes(), 10000000);
      final handle = await File(prepared.path).open(mode: FileMode.append);
      await handle.writeByte(1);
      await handle.close();
      await expectLater(
        store.finish(prepared.note.id, const Duration(minutes: 5)),
        throwsA(isA<PrivateNoteException>()),
      );
      expect(await File(prepared.path).length(), 10000001);
    },
  );
  test(
    'partial recordings count against note storage but not another account',
    () async {
      final prepared = await store.prepare(title: 'Partial');
      await File(prepared.path).writeAsBytes(List.filled(2000, 1));
      expect(await store.usedBytes(), 2000);
      expect((await store.prepare(title: 'Next')).allowance, 9998000);
      expect(await open(user: 8).list(), isEmpty);
      expect(await open(user: 8).usedBytes(), 0);
    },
  );
  test(
    'account change blocks pending writes and local reads without changing existing files',
    () async {
      final note = await save();
      changed = true;
      await expectLater(
        store.localPath(note.id),
        throwsA(isA<PrivateNoteException>()),
      );
      await expectLater(
        store.rename(note.id, 'Wrong account'),
        throwsA(isA<PrivateNoteException>()),
      );
      await expectLater(
        store.remove(note.id),
        throwsA(isA<PrivateNoteException>()),
      );
      changed = false;
      expect((await store.list()).single.title, 'My study note');
    },
  );
  test(
    'corrupt or foreign metadata is retained with a selected recovery entry, never overwritten by rename',
    () async {
      final note = await save();
      final metadata = File(
        '${store.directory.path}${Platform.pathSeparator}${note.id}.json',
      );
      await metadata.writeAsString('{broken');
      expect((await store.list()).single.issue, isNotNull);
      await expectLater(
        store.rename(note.id, 'Erase corruption'),
        throwsA(isA<PrivateNoteException>()),
      );
      expect(await metadata.readAsString(), '{broken');
      await store.remove(note.id);
      expect(await store.list(), isEmpty);
    },
  );
  test(
    'renaming and selected removal preserve timestamps, other notes, progress and downloads',
    () async {
      final first = await save();
      final second = await save(title: 'Second note');
      final account = store.directory.parent;
      final progress = File(
        '${account.path}${Platform.pathSeparator}lesson_9.json',
      );
      final download = File(
        '${account.path}${Platform.pathSeparator}downloads${Platform.pathSeparator}9.media',
      );
      await download.parent.create();
      await download.writeAsBytes([4, 5]);
      await progress.writeAsString('saved progress');
      await store.rename(first.id, 'Renamed note');
      expect(
        (await store.list()).firstWhere((note) => note.id == first.id).position,
        const Duration(seconds: 25),
      );
      await store.remove(first.id);
      expect((await store.list()).single.id, second.id);
      expect(await progress.readAsString(), 'saved progress');
      expect(await download.readAsBytes(), [4, 5]);
    },
  );
  test(
    'media without metadata remains visible for selected removal, not silently erased',
    () async {
      final prepared = await store.prepare(title: 'Lost metadata');
      await File(prepared.path).writeAsBytes([1]);
      await File(
        '${store.directory.path}${Platform.pathSeparator}${prepared.note.id}.json',
      ).delete();
      final note = (await store.list()).single;
      expect(note.complete, isFalse);
      expect(note.issue, isNotNull);
      expect(await store.usedBytes(), 1);
      await store.remove(note.id);
      expect(await store.usedBytes(), 0);
    },
  );
  test(
    'invalid names, timestamps and path identities fail explicitly',
    () async {
      await expectLater(
        store.prepare(title: ''),
        throwsA(isA<PrivateNoteException>()),
      );
      await expectLater(
        store.prepare(title: 'x' * 161),
        throwsA(isA<PrivateNoteException>()),
      );
      await expectLater(
        store.prepare(title: 'Note', position: const Duration(seconds: -1)),
        throwsA(isA<PrivateNoteException>()),
      );
      await expectLater(
        store.remove('..'),
        throwsA(isA<PrivateNoteException>()),
      );
    },
  );
}
