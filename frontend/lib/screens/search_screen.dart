import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart'; // To access Theme/App info

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  
  List<dynamic> _results = [];
  bool _isLoading = false;
  String _error = '';

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    
    try {
      final results = await ApiService.searchLaw(
        keyword: _searchController.text.trim(),
      );
      
      setState(() {
        _results = results;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBengali = BDLawApp.of(context).isBengali;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: isBengali ? 'কীওয়ার্ড' : 'Keyword',
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _performSearch,
              icon: const Icon(Icons.search),
              label: Text(isBengali ? 'অনুসন্ধান করুন' : 'Search'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_error.isNotEmpty)
            Text(_error, style: TextStyle(color: Theme.of(context).colorScheme.error))
          else if (_results.isEmpty)
            Expanded(
              child: Center(
                child: Text(isBengali ? 'কোন ফলাফল পাওয়া যায়নি।' : 'No results found. Search above.'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final law = _results[index];
                  final lawName = law['law_name_en'] ?? law['act_title'] ?? 'Unknown Law';
                  final sectionNumber = law['section_no_en'] ?? 'N/A';
                  final sectionName = law['section_name_en'] ?? '';
                  final content = law['content'] ?? 'No text available';
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: ExpansionTile(
                      title: Text('$lawName - Sec $sectionNumber'),
                      subtitle: sectionName.isNotEmpty ? Text(sectionName) : null,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            content,
                            style: const TextStyle(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
