import re

with open('/Users/hadiramdhani/Mobile Project/imphnen_tools/lib/screens/security_screen.dart', 'r') as f:
    content = f.read()

# Add imports if not present
imports = """
import 'security/api_mobile_screen.dart';
import 'security/network_scanner_screen.dart';
import 'security/recon_screen.dart';
import 'security/secrets_intel_screen.dart';
import 'security/security_report_screen.dart';
"""
if "import 'security/recon_screen.dart';" not in content:
    content = content.replace("import '../widgets/screen_header.dart';", f"import '../widgets/screen_header.dart';\n{imports}")

# Add _ActiveModuleTile if not present
active_module_tile = """
class _ActiveModuleTile extends StatelessWidget {
  const _ActiveModuleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _AnimeSticker(icon: icon, color: color, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Pixel.chevronright, size: 18, color: color.withValues(alpha: .7)),
          ],
        ),
      ),
    ),
  );
}
"""
if "_ActiveModuleTile" not in content:
    content = content.replace("class _SectionHeader extends StatelessWidget {", f"{active_module_tile}\nclass _SectionHeader extends StatelessWidget {{")


# Replace Planned modules with Active modules
old_modules = """
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Security modules',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const Text(
                          'Planned',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9187A9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const _ModuleTile(
                      icon: Pixel.search,
                      title: 'Recon & DNS',
                      subtitle: 'Domain, certificate, and HTTP metadata',
                    ),
                    const _ModuleTile(
                      icon: Pixel.radiotower,
                      title: 'Network & Web Scanner',
                      subtitle: 'Requires a scoped scan service',
                    ),
                    const _ModuleTile(
                      icon: Pixel.devicephone,
                      title: 'API & Mobile Security',
                      subtitle: 'OpenAPI, APK, IPA, and static analysis',
                    ),
                    const _ModuleTile(
                      icon: Pixel.lock,
                      title: 'Secrets & CVE Intelligence',
                      subtitle: 'Local repository and advisory analysis',
                    ),
                    const _ModuleTile(
                      icon: Pixel.analytics,
                      title: 'Security Copilot & Reports',
                      subtitle: 'Analysis and report generation',
                    ),
"""

new_modules = """
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Security modules',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF65B892).withValues(alpha: .15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF65B892),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _ActiveModuleTile(
                      icon: Pixel.search,
                      title: 'Recon & DNS',
                      subtitle: 'Domain analyzer, HTTP header audit, cert links',
                      color: const Color(0xFF5A9BD5),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => const ReconScreen()),
                      ),
                    ),
                    _ActiveModuleTile(
                      icon: Pixel.radiotower,
                      title: 'Network & Web Scanner',
                      subtitle: 'Port lookup, port reference, test payloads',
                      color: const Color(0xFF63B7C4),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => const NetworkScannerScreen()),
                      ),
                    ),
                    _ActiveModuleTile(
                      icon: Pixel.devicephone,
                      title: 'API & Mobile Security',
                      subtitle: 'JWT analyzer, API endpoint audit, Android permissions',
                      color: const Color(0xFF9B82D2),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => const ApiMobileSecurityScreen()),
                      ),
                    ),
                    _ActiveModuleTile(
                      icon: Pixel.lock,
                      title: 'Secrets & CVE Intelligence',
                      subtitle: 'Secrets scanner, CVE lookup & reference',
                      color: const Color(0xFFD25757),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(builder: (_) => const SecretsIntelScreen()),
                      ),
                    ),
                    _ActiveModuleTile(
                      icon: Pixel.analytics,
                      title: 'Copilot & Reports',
                      subtitle: 'Report generator & security checklists',
                      color: const Color(0xFFEA9A70),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => SecurityReportScreen(workspace: workspace),
                        ),
                      ),
                    ),
"""

import re
# Use regex to do a fuzzy replace because whitespace might differ slightly
pattern = re.compile(r'const SizedBox\(height: 20\),\s*Row\(\s*children: \[\s*Expanded\(\s*child: Text\(\s*\'Security modules\'.*?subtitle: \'Analysis and report generation\',\s*\),', re.DOTALL)
content = pattern.sub(new_modules.strip(), content)

with open('/Users/hadiramdhani/Mobile Project/imphnen_tools/lib/screens/security_screen.dart', 'w') as f:
    f.write(content)

print("Patch applied successfully.")
