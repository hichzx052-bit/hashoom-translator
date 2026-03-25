import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/language.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final String title;
  final bool showAutoDetect;

  LanguageSelectionScreen({
    this.title = 'اختر اللغة',
    this.showAutoDetect = false,
  });

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = Language.all.where((l) {
      if (_search.isEmpty) return true;
      return l.name.toLowerCase().contains(_search.toLowerCase()) ||
          l.code.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              style: TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'ابحث عن لغة...',
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.bgCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          // Auto detect option
          if (widget.showAutoDetect)
            ListTile(
              leading: Text('🔍', style: TextStyle(fontSize: 28)),
              title: Text('تعرف تلقائي', style: TextStyle(color: AppTheme.textPrimary)),
              subtitle: Text('التطبيق يكتشف اللغة', style: TextStyle(color: AppTheme.textSecondary)),
              onTap: () => Navigator.pop(context, Language(code: 'auto', name: 'تلقائي', speechLocale: '')),
            ),
          // Language list
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final lang = filtered[index];
                return ListTile(
                  leading: Text(lang.flag, style: TextStyle(fontSize: 28)),
                  title: Text(lang.name, style: TextStyle(color: AppTheme.textPrimary)),
                  subtitle: Text(lang.code.toUpperCase(), style: TextStyle(color: AppTheme.textSecondary)),
                  onTap: () => Navigator.pop(context, lang),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
