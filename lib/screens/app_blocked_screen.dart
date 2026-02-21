import 'package:flutter/material.dart';
import 'package:smart_reserve_admin/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_reserve_admin/widgets/ui/background_shapes.dart';

enum AppBlockState { underMaintenance, updateRequired }

class AppBlockedScreen extends StatefulWidget {
  final AppBlockState state;
  final String? version;

  const AppBlockedScreen({Key? key, required this.state, this.version})
      : super(key: key);

  @override
  State<AppBlockedScreen> createState() => _AppBlockedScreenState();
}

class _AppBlockedScreenState extends State<AppBlockedScreen> {
  @override
  Widget build(BuildContext context) {
    final String title = widget.state == AppBlockState.underMaintenance
        ? Constants.UNDER_MAINTENANCE
        : '${Constants.NEW_VERSION_AVAILABLE}-v${widget.version}';

    final String subtitle = widget.state == AppBlockState.underMaintenance
        ? "We're working hard to bring everything back online. Please check back soon!"
        : "A newer version of the app is available. Please update to continue.";

    final IconData icon = widget.state == AppBlockState.underMaintenance
        ? Icons.construction
        : Icons.system_update;

    final Color iconColor = widget.state == AppBlockState.underMaintenance
        ? Colors.orangeAccent.shade700
        : Colors.blueAccent;

    final String? actionText =
        widget.state == AppBlockState.updateRequired ? "Update Now" : null;

    return BackgroundShapes(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 100, color: iconColor),
                  const SizedBox(height: 30),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 22.0,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (actionText != null)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final rawUrl =
                            Constants.APP_URL + (widget.version ?? '');
                        final uri = Uri.parse(rawUrl);

                        try {
                          final canLaunchExternal = await canLaunchUrl(uri);

                          if (canLaunchExternal) {
                            final success = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!success) throw 'external app failed';
                          } else {
                            throw 'no external app';
                          }
                        } catch (e) {
                          try {
                            final browserLaunchSuccess = await launchUrl(
                              uri,
                              mode: LaunchMode.inAppBrowserView,
                            );
                            if (!browserLaunchSuccess && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not open URL in browser',
                                  ),
                                ),
                              );
                            }
                          } catch (_) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to launch URL'),
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(actionText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iconColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    "v${Constants.APP_VERSION}",
                    style: TextStyle(
                      fontFamily: 'FiraSans',
                      fontWeight: FontWeight.w500,
                      fontSize: 12.0,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
