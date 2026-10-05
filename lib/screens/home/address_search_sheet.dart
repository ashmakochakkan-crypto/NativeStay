import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/indian_place.dart';


// ==========================================
// ADDRESS SEARCH SHEET
// ==========================================
class AddressSearchSheet extends StatefulWidget {
  const AddressSearchSheet({super.key});

  @override
  State<AddressSearchSheet> createState() => _AddressSearchSheetState();
}

class _AddressSearchSheetState extends State<AddressSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<IndianPlace> _suggestions = [];
  bool _isLoading = false;
  bool _hasError = false;
  int _requestId = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSubmitted(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
        _hasError = false;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    await _search(trimmed);
  }

  Future<void> _search(String query) async {
    final myRequest = ++_requestId;
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': query,
        'countrycodes': 'in',
        'format': 'jsonv2',
        'addressdetails': '1',
        'limit': '15',
        'accept-language': 'en',
        'email': 'NativeStays@gmail.com',
      });
      final response = await http.get(uri, headers: {
        'User-Agent': 'TourTravelApp/1.0 (NativeStays@gmail.com)',
        'Accept': 'application/json',
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () =>
            throw Exception('Request timed out - check your internet'),
      );
      if (myRequest != _requestId || !mounted) return;
      if (response.statusCode != 200) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
          _hasError = true;
        });
        return;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
          _hasError = true;
        });
        return;
      }

      final List<dynamic> results = decoded;
      final List<IndianPlace> places = [];
      final Set<String> seen = {};

      for (final r in results) {
        final Map<String, dynamic> a =
            Map<String, dynamic>.from(r['address'] ?? {});
        final String country =
            (a['country'] ?? r['display_name'] ?? '').toString();
        final bool inIndia = country.toLowerCase().contains('india') ||
            (a['country_code']?.toString().toLowerCase() == 'in');
        if (!inIndia && country.isNotEmpty) continue;

        final String? state =
            a['state']?.toString() ?? a['union_territory']?.toString();
        final String? city = (a['city'] ??
                a['town'] ??
                a['village'] ??
                a['municipality'] ??
                a['city_district'] ??
                a['suburb'])
            ?.toString();
        final String name = (r['name'] ?? '').toString().isNotEmpty
            ? r['name'].toString()
            : (city ??
                state ??
                (r['display_name'] ?? '').toString().split(',').first);
        if (name.trim().isEmpty) continue;

        final key = '$name|${city ?? ''}|${state ?? ''}';
        if (!seen.add(key)) continue;

        places.add(IndianPlace(
          name: name,
          street: a['road']?.toString(),
          subLocality: (a['suburb'] ?? a['neighbourhood'])?.toString(),
          subAdministrativeArea:
              (a['county'] ?? a['state_district'])?.toString(),
          locality: city,
          administrativeArea: state,
          postalCode: a['postcode']?.toString(),
          country: a['country']?.toString() ?? 'India',
        ));
      }

      setState(() {
        _suggestions = places;
        _isLoading = false;
        _hasError = places.isEmpty && results.isEmpty;
      });
    } catch (e) {
      debugPrint('Sheet search error: $e');
      if (myRequest != _requestId || !mounted) return;
      setState(() {
        _suggestions = [];
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.black54, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _onSubmitted,
                    decoration: const InputDecoration(
                      hintText: 'Search city, town, or state in India',
                      hintStyle:
                          TextStyle(color: Colors.black38, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close,
                        size: 18, color: Colors.black54),
                    onPressed: () {
                      _searchController.clear();
                      _requestId++;
                      setState(() {
                        _suggestions = [];
                        _isLoading = false;
                        _hasError = false;
                      });
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Flexible(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFF3BDC3)),
                    ),
                  )
                : _hasError
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wifi_off_rounded,
                                size: 40, color: Colors.black26),
                            SizedBox(height: 12),
                            Text(
                              'Could not search right now.\nCheck your connection and try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black45, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : _suggestions.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'Type a city, town, or state in India',
                                style: TextStyle(
                                    color: Colors.black38, fontSize: 14),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: _suggestions.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, color: Colors.black12),
                            itemBuilder: (context, index) {
                              final place = _suggestions[index];
                              final name = place.name ?? '';
                              final locality = place.locality ??
                                  place.subAdministrativeArea ??
                                  '';
                              final state = place.administrativeArea ?? '';

                              return ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        vertical: 4),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0F3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                      Icons.location_on_outlined,
                                      color: Color(0xFFF3BDC3),
                                      size: 20),
                                ),
                                title: Text(
                                  name.isNotEmpty ? name : locality,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                subtitle: Text(
                                  [locality, state, place.country]
                                      .whereType<String>()
                                      .where((e) => e.isNotEmpty)
                                      .join(', '),
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 12),
                                ),
                                onTap: () {
                                  Navigator.pop(context, place);
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}