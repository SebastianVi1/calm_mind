import 'package:flutter/material.dart';
import 'package:calm_mind/models/emergency_contact.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EmergencyViewModel extends ChangeNotifier {
  List<EmergencyContact> _personalContacts = [];
  final List<EmergencyContact> _defaultContacts = [
    EmergencyContact(
      id: '1',
      name: 'Emergencias',
      phoneNumber: '911',
      isPersonal: false,
    ),
    EmergencyContact(
      id: '2',
      name: 'Cruz Roja',
      phoneNumber: '065',
      isPersonal: false,
    ),
    EmergencyContact(
      id: '3',
      name: 'Atencion linea de vida.',
      phoneNumber: '800 911 2000',
      isPersonal: false,
    ),
    EmergencyContact(
      id: '4',
      name: 'Unidad psicologica de intervencion primaria (emergencia por riesgo suicida)',
      phoneNumber: '800 227 4747',
      isPersonal: false,
    )
  ];

  List<EmergencyContact> get allContacts => [..._defaultContacts, ..._personalContacts];

  Future<void> loadPersonalContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getStringList('emergency_contacts') ?? [];
    _personalContacts = contactsJson
        .map((json) => EmergencyContact.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> addPersonalContact(EmergencyContact contact) async {
    _personalContacts.add(contact);
    await _savePersonalContacts();
    notifyListeners();
  }

  Future<void> removePersonalContact(String id) async {
    _personalContacts.removeWhere((contact) => contact.id == id);
    await _savePersonalContacts();
    notifyListeners();
  }

  Future<void> _savePersonalContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = _personalContacts
        .map((contact) => jsonEncode(contact.toJson()))
        .toList();
    await prefs.setStringList('emergency_contacts', contactsJson);
  }
} 