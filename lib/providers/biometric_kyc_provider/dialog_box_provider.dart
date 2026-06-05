import 'package:flutter/material.dart';

class DialogBoxProvider with ChangeNotifier {
  bool _isDialogVisible = false;

  bool get isDialogVisible => _isDialogVisible;

  bool _isDialogOpen = false;

  bool get isDialogOpen => _isDialogOpen;

  void openDialog() {
    _isDialogOpen = true;
    notifyListeners();
  }

  void closeDialog() {
    _isDialogOpen = false;
    notifyListeners();
  }

  void showDialogBox() {
    _isDialogVisible = true;
    notifyListeners();
  }

  void hideDialogBox() {
    _isDialogVisible = false;
    notifyListeners();
  }
}
