import re

with open('/Users/hadiramdhani/Mobile Project/imphnen_tools/lib/screens/security/secrets_intel_screen.dart', 'r') as f:
    content = f.read()

# Replace RegExp(r'...') with RegExp(r'''...''')
def replacer(match):
    inner = match.group(1)
    # Be careful not to replace already fixed ones
    if inner.startswith("'''"): return match.group(0)
    return f"RegExp(r'''{inner}'''"

content = re.sub(r"RegExp\(r'(.*?)'", replacer, content)

with open('/Users/hadiramdhani/Mobile Project/imphnen_tools/lib/screens/security/secrets_intel_screen.dart', 'w') as f:
    f.write(content)

print("Regex patched.")
