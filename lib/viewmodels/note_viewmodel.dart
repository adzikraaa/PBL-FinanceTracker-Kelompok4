import 'package:flutter/material.dart';
import '../models/note_model.dart';

class NoteViewModel extends ChangeNotifier {
  final List<Note> _notes = [
    Note(
      id: '1',
      title: 'Compound Interest Strategy',
      content: 'Consider increasing the monthly contribution by 5% every quarter to maximize long-term yield. This strategy assumes an average annual return of 8%.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Note(
      id: '2',
      title: 'Emergency Fund Target',
      content: 'Goal: 6 months of expenses. Current progress is at 4.2 months. Need to adjust the savings rate to hit the target by December.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Note(
      id: '3',
      title: 'Tax Optimization 2024',
      content: 'Review potential deductions for the solar panel installation and the home office upgrade. Consult with the tax advisor by mid-October.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Note(
      id: '4',
      title: 'Portfolio Rebalancing',
      content: 'Shift 2% from growth stocks to fixed income to maintain the 80/20 risk profile during market volatility.',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  List<Note> get notes => _notes;

  void addNote(String title, String content) {
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
    );
    _notes.insert(0, newNote);
    notifyListeners();
  }

  void updateNote(String id, String title, String content) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notes[index].title = title;
      _notes[index].content = content;
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
