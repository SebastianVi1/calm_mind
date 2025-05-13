import 'package:flutter/material.dart';

/// Manages content stacking for each tab in the application
/// Allows for sub-navigation within tabs while keeping the bottom navigation bar visible
class ContentViewModel extends ChangeNotifier {
  // Map of stacks for each tab index
  final Map<int, List<Widget>> _contentStacks = {};
  
  // Constructor - Initialize with the main screens as base content
  ContentViewModel() {
    // Initial stacks will be set by the MainScreen
  }
  
  // Initialize a tab's content stack if it doesn't exist yet
  void initTab(int tabIndex, Widget initialContent) {
    if (!_contentStacks.containsKey(tabIndex)) {
      _contentStacks[tabIndex] = [initialContent];
    }
  }
  
  // Get current content for a specific tab
  Widget getCurrentContent(int tabIndex) {
    final stack = _contentStacks[tabIndex] ?? [];
    return stack.isEmpty ? Container() : stack.last;
  }
  
  // Add new content to a tab's stack
  void pushContent(int tabIndex, Widget content) {
    _contentStacks.putIfAbsent(tabIndex, () => []);
    _contentStacks[tabIndex]!.add(content);
    notifyListeners();
  }
  
  // Remove the top content from a tab's stack
  bool popContent(int tabIndex) {
    final stack = _contentStacks[tabIndex];
    if (stack == null || stack.length <= 1) {
      return false; // Can't pop the base content
    }
    
    stack.removeLast();
    notifyListeners();
    return true;
  }
  
  // Clear all content except the base content for a specific tab
  void clearStack(int tabIndex) {
    final stack = _contentStacks[tabIndex];
    if (stack != null && stack.isNotEmpty) {
      final baseContent = stack.first;
      _contentStacks[tabIndex] = [baseContent];
      notifyListeners();
    }
  }
  
  // Reset all tabs to their base content
  void resetAllStacks() {
    for (var key in _contentStacks.keys) {
      if (_contentStacks[key]!.isNotEmpty) {
        final baseContent = _contentStacks[key]!.first;
        _contentStacks[key] = [baseContent];
      }
    }
    notifyListeners();
  }
}
