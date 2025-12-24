
class SyncSession {

  final String id;
  final DateTime? lastCompletedAt;

  SyncSession({
    required this.id,
    this.lastCompletedAt,
  });

  factory SyncSession.empty() {
    return SyncSession(
      id: '',
      lastCompletedAt: null,
    );
  }

  bool get isValid => id.isNotEmpty;
  bool get isFirstSync => lastCompletedAt == null;

  SyncSession copyWith({String? id, DateTime? lastCompletedAt}) {
    return SyncSession(
      id: id ?? this.id,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if(identical(this, other)) return true;
    return other is SyncSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}