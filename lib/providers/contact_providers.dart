import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/contact_repository.dart';
import '../data/schemas/contact.dart';
import 'package:isar/isar.dart';

final contactRepositoryProvider = Provider((ref) => ContactRepository());

final contactsStreamProvider = StreamProvider<List<Contact>>((ref) {
  final repo = ref.watch(contactRepositoryProvider);
  return repo.watchAll();
});

final contactByIdStreamProvider =
    StreamProvider.family<Contact?, Id>((ref, id) {
  final repo = ref.watch(contactRepositoryProvider);
  return repo.watchById(id);
});

final searchProvider = StateProvider<String>((ref) => '');
final activeTabProvider = StateProvider<String>((ref) => 'favorites');
final viewModeProvider = StateProvider<String>((ref) => 'grid');

final filteredContactsProvider = Provider<List<Contact>>((ref) {
  final list = ref.watch(contactsStreamProvider).maybeWhen(
        data: (d) => d,
        orElse: () => <Contact>[],
      );
  final search = ref.watch(searchProvider).toLowerCase();
  final tab = ref.watch(activeTabProvider);
  return list.where((c) {
    final matches =
        c.name.toLowerCase().contains(search) || c.phone.contains(search);
    if (!matches) return false;
    if (tab == 'favorites') return c.isFavorite;
    if (tab == 'all') return true;
    return c.groupId == tab;
  }).toList();
});

class PanelState {
  final Contact? editingContact;
  final bool open;
  final bool editing;
  final String tab;
  final List<Map<String, dynamic>> tempNotes;
  PanelState({
    this.editingContact,
    this.open = false,
    this.editing = false,
    this.tab = 'info',
    this.tempNotes = const [],
  });

  PanelState copyWith({
    Contact? editingContact,
    bool? open,
    bool? editing,
    String? tab,
    List<Map<String, dynamic>>? tempNotes,
  }) {
    return PanelState(
      editingContact: editingContact ?? this.editingContact,
      open: open ?? this.open,
      editing: editing ?? this.editing,
      tab: tab ?? this.tab,
      tempNotes: tempNotes ?? this.tempNotes,
    );
  }
}

final panelStateProvider = StateProvider<PanelState>((ref) => PanelState());
final darkModeProvider = StateProvider<bool>((ref) => false);