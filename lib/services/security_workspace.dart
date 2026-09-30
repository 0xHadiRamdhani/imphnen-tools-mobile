import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityWorkspace extends ChangeNotifier {
  static const _storageKey = 'imphnen.mobile.security_workspace.v1';

  List<String> scopeTargets = [];
  List<String> excludedTargets = [];
  List<SecurityAsset> assets = [];
  List<SecurityFinding> findings = [];
  List<SecurityEvidence> evidence = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      scopeTargets = List<String>.from(data['scope'] as List? ?? const []);
      excludedTargets = List<String>.from(
        data['excluded'] as List? ?? const [],
      );
      assets = (data['assets'] as List? ?? const [])
          .map((item) => SecurityAsset.fromJson(item as Map<String, dynamic>))
          .toList();
      findings = (data['findings'] as List? ?? const [])
          .map((item) => SecurityFinding.fromJson(item as Map<String, dynamic>))
          .toList();
      evidence = (data['evidence'] as List? ?? const [])
          .map(
            (item) => SecurityEvidence.fromJson(item as Map<String, dynamic>),
          )
          .toList();
      notifyListeners();
    } on FormatException {
      // Keep the workspace available if a saved local record is malformed.
    } on TypeError {
      // Keep the workspace available if a saved local record is malformed.
    }
  }

  bool isAuthorized(String input) {
    final target = normalizeTarget(input);
    if (target == null) return false;
    final host = _host(target);
    if (host == null) return false;
    final excluded = excludedTargets.any((item) {
      final blocked = _host(item);
      return blocked != null && (host == blocked || host.endsWith('.$blocked'));
    });
    if (excluded) return false;
    return scopeTargets.any((item) {
      final allowed = _host(item);
      return allowed != null && (host == allowed || host.endsWith('.$allowed'));
    });
  }

  Future<bool> addScopeTarget(String input, {bool excluded = false}) async {
    final target = normalizeTarget(input);
    if (target == null) return false;
    final list = excluded ? excludedTargets : scopeTargets;
    if (list.contains(target)) return false;
    list.add(target);
    await _save();
    return true;
  }

  Future<bool> addAsset(String target, String type) async {
    final normalized = normalizeTarget(target);
    if (normalized == null || !isAuthorized(normalized)) return false;
    if (assets.any((asset) => asset.target == normalized)) return false;
    assets.insert(0, SecurityAsset(target: normalized, type: type));
    await _save();
    return true;
  }

  Future<void> addFinding({
    required String title,
    required String severity,
    required String asset,
    required String notes,
  }) async {
    findings.insert(
      0,
      SecurityFinding(
        id: 'F-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        severity: severity,
        asset: asset,
        notes: notes,
        status: 'Open',
        created: DateTime.now(),
      ),
    );
    await _save();
  }

  Future<void> addEvidence({
    required String title,
    required String content,
    String? findingId,
  }) async {
    evidence.insert(
      0,
      SecurityEvidence(
        title: title,
        content: content,
        findingId: findingId,
        created: DateTime.now(),
      ),
    );
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode({
        'scope': scopeTargets,
        'excluded': excludedTargets,
        'assets': assets.map((item) => item.toJson()).toList(),
        'findings': findings.map((item) => item.toJson()).toList(),
        'evidence': evidence.map((item) => item.toJson()).toList(),
      }),
    );
    notifyListeners();
  }

  static String? normalizeTarget(String input) {
    var value = input.trim().toLowerCase();
    if (value.isEmpty || value.contains(RegExp(r'\s'))) {
      return null;
    }
    if (value.contains('://')) {
      final uri = Uri.tryParse(value);
      if (uri == null ||
          !{'http', 'https'}.contains(uri.scheme) ||
          uri.userInfo.isNotEmpty) {
        return null;
      }
      value = uri.host;
    } else if (value.contains(RegExp(r'[/@?#:]'))) {
      return null;
    }
    if (value.endsWith('.')) value = value.substring(0, value.length - 1);
    if (InternetAddress.tryParse(value) != null) return value;
    if (value.length > 253 || value.startsWith('.') || value.contains('..')) {
      return null;
    }
    final labels = value.split('.');
    if (labels.length < 2 ||
        labels.any(
          (label) =>
              label.isEmpty ||
              label.length > 63 ||
              !RegExp(r'^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$').hasMatch(label),
        )) {
      return null;
    }
    return value;
  }

  static String? _host(String input) => normalizeTarget(input);
}

class SecurityAsset {
  const SecurityAsset({required this.target, required this.type});
  final String target;
  final String type;
  Map<String, dynamic> toJson() => {'target': target, 'type': type};
  factory SecurityAsset.fromJson(Map<String, dynamic> json) => SecurityAsset(
    target: json['target'] as String? ?? '',
    type: json['type'] as String? ?? 'Domain',
  );
}

class SecurityFinding {
  const SecurityFinding({
    required this.id,
    required this.title,
    required this.severity,
    required this.asset,
    required this.notes,
    required this.status,
    required this.created,
  });
  final String id, title, severity, asset, notes, status;
  final DateTime created;
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'severity': severity,
    'asset': asset,
    'notes': notes,
    'status': status,
    'created': created.toIso8601String(),
  };
  factory SecurityFinding.fromJson(Map<String, dynamic> json) =>
      SecurityFinding(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        severity: json['severity'] as String? ?? 'Informational',
        asset: json['asset'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        status: json['status'] as String? ?? 'Open',
        created:
            DateTime.tryParse(json['created'] as String? ?? '') ??
            DateTime.now(),
      );
}

class SecurityEvidence {
  const SecurityEvidence({
    required this.title,
    required this.content,
    this.findingId,
    required this.created,
  });
  final String title, content;
  final String? findingId;
  final DateTime created;
  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'findingId': findingId,
    'created': created.toIso8601String(),
  };
  factory SecurityEvidence.fromJson(Map<String, dynamic> json) =>
      SecurityEvidence(
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        findingId: json['findingId'] as String?,
        created:
            DateTime.tryParse(json['created'] as String? ?? '') ??
            DateTime.now(),
      );
}

class SecurityWorkspaceScope extends InheritedNotifier<SecurityWorkspace> {
  const SecurityWorkspaceScope({
    required SecurityWorkspace workspace,
    required super.child,
    super.key,
  }) : super(notifier: workspace);
  static SecurityWorkspace of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<SecurityWorkspaceScope>()!
      .notifier!;
}
