class LibraryItem {
  const LibraryItem({required this.id, required this.name, required this.path,
    required this.kind, required this.addedAt, this.isFavorite = false,
    this.isRecent = true});
  final String id, name, path, kind;
  final DateTime addedAt;
  final bool isFavorite;
  final bool isRecent;

  LibraryItem copyWith({DateTime? addedAt, bool? isFavorite, bool? isRecent}) => LibraryItem(
    id: id, name: name, path: path, kind: kind,
    addedAt: addedAt ?? this.addedAt, isFavorite: isFavorite ?? this.isFavorite,
    isRecent: isRecent ?? this.isRecent);

  Map<String, Object?> toJson() => {'id': id, 'name': name, 'path': path,
    'kind': kind, 'addedAt': addedAt.toIso8601String(), 'isFavorite': isFavorite,
    'isRecent': isRecent};
  factory LibraryItem.fromJson(Map<String, dynamic> json) => LibraryItem(
    id: json['id'] as String, name: json['name'] as String,
    path: json['path'] as String, kind: json['kind'] as String,
    addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ?? DateTime.now(),
    isFavorite: json['isFavorite'] as bool? ?? false,
    isRecent: json['isRecent'] as bool? ?? true);
}
