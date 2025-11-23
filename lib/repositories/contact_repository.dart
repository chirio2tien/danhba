import 'package:isar/isar.dart';
import '../data/isar_service.dart';
import '../data/schemas/contact.dart';
import '../data/schemas/note.dart';

class ContactRepository {
  Future<List<Contact>> getAll() async {
    final isar = await IsarService.instance();
    return isar.contacts.where().sortByName().findAll();
  }

  Stream<List<Contact>> watchAll() async* {
    final isar = await IsarService.instance();
    yield* isar.contacts.where().sortByName().watch(fireImmediately: true);
  }

  Stream<Contact?> watchById(Id id) async* {
    final isar = await IsarService.instance();
    yield* isar.contacts.watchObject(id, fireImmediately: true);
  }

  Future<Contact?> getById(Id id) async {
    final isar = await IsarService.instance();
    return isar.contacts.get(id);
  }

  Future<void> add(Contact c) async {
    final isar = await IsarService.instance();
    await isar.writeTxn(() => isar.contacts.put(c));
  }

  Future<void> update(Contact c) async {
    final isar = await IsarService.instance();
    await isar.writeTxn(() => isar.contacts.put(c));
  }

  Future<void> delete(Id id) async {
    final isar = await IsarService.instance();
    await isar.writeTxn(() => isar.contacts.delete(id));
  }

  Future<void> toggleFavorite(Id id) async {
    final isar = await IsarService.instance();
    await isar.writeTxn(() async {
      final c = await isar.contacts.get(id);
      if (c != null) {
        c.isFavorite = !c.isFavorite;
        await isar.contacts.put(c);
      }
    });
  }

  Future<void> addNote(Id contactId, String text) async {
    final isar = await IsarService.instance();
    await isar.writeTxn(() async {
      final c = await isar.contacts.get(contactId);
      if (c != null) {
        final note = Note()
          ..id = DateTime.now().millisecondsSinceEpoch
          ..text = text
          ..date = DateTime.now();
        c.notes.insert(0, note);
        await isar.contacts.put(c);
      }
    });
  }

  Future<void> deleteNote(Id contactId, int noteId) async {
    final isar = await IsarService.instance();
    await isar.writeTxn(() async {
      final c = await isar.contacts.get(contactId);
      if (c != null) {
        c.notes.removeWhere((n) => n.id == noteId);
        await isar.contacts.put(c);
      }
    });
  }
}