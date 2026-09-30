import re

with open('/Users/hadiramdhani/Mobile Project/imphnen_tools/lib/screens/security/secrets_intel_screen.dart', 'r') as f:
    content = f.read()

start_marker = "static final _secretPatterns = <(String, RegExp, String)>["
end_marker = "  ];\n"

new_patterns = """static final _secretPatterns = <(String, RegExp, String)>[
    (
      'AWS Access Key ID',
      RegExp(r'''AKIA[0-9A-Z]{16}'''),
      'Critical',
    ),
    (
      'AWS Secret Access Key',
      RegExp(r'''(?:aws[_\-]?secret|secret[_\-]?access[_\-]?key)["\s:=]+([A-Za-z0-9/+=]{40})''', caseSensitive: false),
      'Critical',
    ),
    (
      'Generic API Key',
      RegExp(r'''(?:api[_\-]?key|apikey)["\s:=]+([A-Za-z0-9_\-]{16,64})''', caseSensitive: false),
      'High',
    ),
    (
      'Bearer Token',
      RegExp(r'''Bearer\s+[A-Za-z0-9\-._~+/]+=*'''),
      'High',
    ),
    (
      'JWT Token',
      RegExp(r'''eyJ[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_.+/]*'''),
      'Medium',
    ),
    (
      'Google API Key',
      RegExp(r'''AIza[0-9A-Za-z\-_]{35}'''),
      'Critical',
    ),
    (
      'Private Key (PEM)',
      RegExp(r'''-----BEGIN (?:RSA |EC )?PRIVATE KEY-----'''),
      'Critical',
    ),
    (
      'Password in Config',
      RegExp(r'''(?:password|passwd|pwd)["\s:=]+["']?([^\s"']{6,})["']?''', caseSensitive: false),
      'High',
    ),
    (
      'Database Connection String',
      RegExp(r'''(?:mysql|postgres|mongodb|redis|mssql):\/\/[^\s]+''', caseSensitive: false),
      'Critical',
    ),
    (
      'GitHub Token',
      RegExp(r'''gh[pousr]_[A-Za-z0-9]{36}'''),
      'Critical',
    ),
    (
      'Slack Token',
      RegExp(r'''xox[baprs]-[0-9A-Za-z\-]+'''),
      'High',
    ),
    (
      'Stripe Key',
      RegExp(r'''sk_(?:live|test)_[0-9a-zA-Z]{24,}'''),
      'Critical',
    ),
    (
      'Firebase Config',
      RegExp(r'''"apiKey"\s*:\s*"AIza[0-9A-Za-z\-_]{35}"'''),
      'High',
    ),
    (
      'Generic Secret',
      RegExp(r'''(?:secret|SECRET)["\s:=]+["']?([A-Za-z0-9_\-]{16,})["']?'''),
      'Medium',
    ),
    (
      'SSH Private Key',
      RegExp(r'''-----BEGIN OPENSSH PRIVATE KEY-----'''),
      'Critical',
    ),
    (
      'Email Address',
      RegExp(r'''[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}'''),
      'Low',
    ),
    (
      'IP Address',
      RegExp(r'''\b(?:10|172\.(?:1[6-9]|2\d|3[01])|192\.168)\.\d{1,3}\.\d{1,3}\b'''),
      'Low',
    ),
  ];
"""

start_idx = content.find(start_marker)
end_idx = content.find(end_marker, start_idx) + len(end_marker)
if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + new_patterns + content[end_idx:]

with open('/Users/hadiramdhani/Mobile Project/imphnen_tools/lib/screens/security/secrets_intel_screen.dart', 'w') as f:
    f.write(content)

print("Regex manually patched.")
