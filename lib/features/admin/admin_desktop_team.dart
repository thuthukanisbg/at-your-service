import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'admin_team_service.dart';

/// Real admin users (`users` where `role == 'admin'`) — name/email only.
/// See admin_team_service.dart for exactly why: this app has no admin
/// sub-roles, no login-tracking field, and no invite mechanism, so Role/
/// Last Active/Status/row-actions from the original design mock are
/// dropped entirely rather than shown blank or fabricated. "Invite
/// teammate" stays as a disabled button — visual-only, same convention as
/// every other not-yet-wired action across this dashboard (Export, Add
/// category, New discount, Invite provider).
class AdminDesktopTeam extends StatefulWidget {
  const AdminDesktopTeam({super.key});

  @override
  State<AdminDesktopTeam> createState() => _AdminDesktopTeamState();
}

class _AdminDesktopTeamState extends State<AdminDesktopTeam> {
  late final Future<List<AdminTeamMember>> _teamFuture = fetchAdminTeamMembers();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Team & Roles', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: tokens.tx)),
                        const SizedBox(height: 3),
                        FutureBuilder<List<AdminTeamMember>>(
                          future: _teamFuture,
                          builder: (context, snapshot) => Text(
                            snapshot.hasData ? '${snapshot.data!.length} admin users' : 'Everyone with admin access.',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: tokens.mut),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(onPressed: null, icon: const Icon(LucideIcons.userPlus, size: 14), label: const Text('Invite teammate')),
                ],
              ),
              const SizedBox(height: 20),
              FutureBuilder<List<AdminTeamMember>>(
                future: _teamFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData && !snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text("Couldn't load admin users.", style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                      ),
                    );
                  }
                  final team = snapshot.data!;
                  if (team.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text('No admin users found.', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: tokens.mut)),
                      ),
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(color: tokens.card, border: Border.all(color: tokens.line), borderRadius: BorderRadius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (var i = 0; i < team.length; i++)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: i == team.length - 1
                                ? null
                                : BoxDecoration(border: Border(bottom: BorderSide(color: tokens.line))),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _initialsFor(team[i].name),
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(team[i].name, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: tokens.tx)),
                                      Text(team[i].email, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tokens.mut)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _initialsFor(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}
