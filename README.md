# Paper PDF

Flutter file manager for PDFs and photos, structured with an MVC-style separation:

- `lib/models/library_item.dart` defines library items and their persisted representation.
- `lib/controllers/library_controller.dart` handles file imports, local persistence, favorites, and opening/removing items.
- `lib/views/library_page.dart` contains the Files, Recents, Favorites, and Settings screens.
- PDF views each have their own file under `lib/views/`: `pdf_workspace_page.dart`, `pdf_ai_screen.dart`, `pdf_ai_chat_screen.dart`, `pdf_search_screen.dart`, `pdf_contents_screen.dart`, `pdf_bookmarks_screen.dart`, `pdf_annotations_screen.dart`, and `pdf_more_screen.dart`.
- The four editing screens each own their toolbar and mode UI (`pdf_annotate_screen.dart`, `pdf_edit_screen.dart`, `pdf_organize_pages_screen.dart`, and `pdf_fill_sign_screen.dart`). They share the small `pdf_editor_screen.dart` shell and `widgets/pdf_reader_canvas.dart` viewer.

Imported files are copied into the app's documents directory. Item metadata and favorite state are stored locally with shared preferences, so the library remains available after restarting the app. PDFs open in an in-app pinch-zoom viewer with page navigation and a workspace UI for Annotate, Edit, Organize Pages, and Fill & Sign.

## Run

```sh
flutter pub get
flutter run
```

The PDF workspace currently provides the viewer and editing tool interfaces. Applying annotations, editing page contents, organizing pages, signing, and conversion still need PDF editing operations wired to the corresponding controls.
