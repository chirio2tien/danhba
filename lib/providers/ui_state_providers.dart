import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/schemas/contact.dart';

class PanelState {
  final Contact? editingContact;
  final bool isOpen;
  final String tab; // info | notes
  final bool isEditing;
  PanelState({this.editingContact, this.isOpen=false, this.tab='info', this.isEditing=false});

  PanelState copyWith({
    Contact? editingContact,
    bool? isOpen,
    String? tab,
    bool? isEditing,
  }) => PanelState(
    editingContact: editingContact ?? this.editingContact,
    isOpen: isOpen ?? this.isOpen,
    tab: tab ?? this.tab,
    isEditing: isEditing ?? this.isEditing,
  );
}

final panelStateProvider = StateProvider<PanelState>((ref) => PanelState());

final darkModeProvider = StateProvider<bool>((ref) => false);