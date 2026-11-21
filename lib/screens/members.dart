import 'package:flutter/material.dart';

import '../db/app_db.dart';
import '../models/member.dart';
import '../widgets/common.dart';
import '../widgets/live.dart';
import 'add_member.dart';
import 'profile.dart';

/// Lets other screens (dashboard) jump to the members tab with a filter applied.
final ValueNotifier<String> memberFilter = ValueNotifier<String>('All');

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  String q = '';
  String filter = memberFilter.value;
  String? shiftFilter;

  @override
  void initState() {
    super.initState();
    memberFilter.addListener(_sync);
  }

  @override
  void dispose() {
    memberFilter.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    if (mounted) setState(() => filter = memberFilter.value);
  }

  bool _matches(Member m) {
    switch (filter) {
      case 'Active':
        return m.state != MStatus.inactive;
      case 'Expiring':
        return m.state == MStatus.dueSoon;
      case 'Inactive':
        return m.state == MStatus.inactive;
      default:
        return true;
    }
  }

  bool _search(Member m) {
    if (q.isEmpty) return true;
    final s = q.toLowerCase();
    return m.name.toLowerCase().contains(s) || m.phone.contains(q);
  }

  Widget _chip(String label, int count, bool selected) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => memberFilter.value = label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? orange : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? orange : lineGrey),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: selected ? ink : muted,
          ),
        ),
      ),
    ),
  );

  Widget _shiftFilter(int morningCount, int eveningCount) {
    final selected = shiftFilter;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          PopupMenuButton<String>(
            tooltip: 'Filter by training shift',
            onSelected: (value) => setState(() => shiftFilter = value),
            itemBuilder: (context) => [
              _shiftMenuItem(
                'Morning',
                morningCount,
                Icons.wb_sunny_outlined,
                selected == 'Morning',
              ),
              _shiftMenuItem(
                'Evening',
                eveningCount,
                Icons.nights_stay_outlined,
                selected == 'Evening',
              ),
            ],
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                color: selected == null ? Colors.white : orangeSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected == null ? lineGrey : orange),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 17,
                    color: selected == null ? muted : ink,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    selected == null ? 'Shift filter' : '$selected Shift',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.expand_more_rounded, size: 18, color: muted),
                ],
              ),
            ),
          ),
          if (selected != null)
            IconButton(
              tooltip: 'Clear shift filter',
              visualDensity: VisualDensity.compact,
              onPressed: () => setState(() => shiftFilter = null),
              icon: const Icon(Icons.close_rounded, size: 19),
            ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _shiftMenuItem(
    String shift,
    int count,
    IconData icon,
    bool selected,
  ) => PopupMenuItem(
    value: shift,
    child: Row(
      children: [
        Icon(icon, size: 18, color: selected ? orange : muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$shift Shift',
            style: TextStyle(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        Text('$count', style: const TextStyle(color: muted)),
        if (selected) ...[
          const SizedBox(width: 8),
          const Icon(Icons.check_rounded, size: 17, color: orange),
        ],
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const TabHeader('Members'),
          Expanded(
            child: TopSheet(
              color: pageBg,
              child: Live<List<Member>>(
                load: AppDb.i.members,
                builder: (context, all) {
                  final list = membersForShift(
                    all,
                    shiftFilter,
                  ).where(_matches).where(_search).toList();
                  int count(bool Function(Member) f) => all.where(f).length;
                  int shiftCount(String shift) =>
                      all.where((m) => normalizeShift(m.shift) == shift).length;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                        child: TextField(
                          onChanged: (v) => setState(() => q = v.trim()),
                          decoration: fieldDeco(
                            hint: 'Search by name or phone...',
                            icon: Icons.search_rounded,
                          ).copyWith(fillColor: Colors.white),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _chip('All', all.length, filter == 'All'),
                            _chip(
                              'Active',
                              count((m) => m.state != MStatus.inactive),
                              filter == 'Active',
                            ),
                            _chip(
                              'Expiring',
                              count((m) => m.state == MStatus.dueSoon),
                              filter == 'Expiring',
                            ),
                            _chip(
                              'Inactive',
                              count((m) => m.state == MStatus.inactive),
                              filter == 'Inactive',
                            ),
                          ],
                        ),
                      ),
                      _shiftFilter(
                        shiftCount('Morning'),
                        shiftCount('Evening'),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: RefreshIndicator(
                          color: orange,
                          onRefresh: refreshAll,
                          child: list.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    const SizedBox(height: 90),
                                    Icon(
                                      Icons.groups_2_outlined,
                                      size: 56,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 10),
                                    Center(
                                      child: Text(
                                        all.isEmpty
                                            ? 'No members yet.\nTap "Add Member" to enroll your first athlete.'
                                            : 'No members found',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: muted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    4,
                                    16,
                                    8,
                                  ),
                                  itemCount: list.length,
                                  itemBuilder: (context, i) =>
                                      _MemberCard(list[i]),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                        child: PrimaryButton(
                          'Add Member',
                          icon: Icons.add_rounded,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddMember(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Member m;
  const _MemberCard(this.m);

  @override
  Widget build(BuildContext context) {
    final st = m.state;

    Widget status;
    switch (st) {
      case MStatus.active:
        status = const Pill(
          'Active',
          bg: okSoft,
          fg: okGreen,
          icon: Icons.circle,
        );
        break;
      case MStatus.dueSoon:
        final days = m.daysLeft;
        status = Pill(
          days == 0 ? 'Due today' : 'Due in $days days',
          bg: const Color(0xffffe9c7),
          fg: const Color(0xffb86e00),
          icon: Icons.shield_outlined,
        );
        break;
      case MStatus.inactive:
        status = const Pill(
          'Inactive',
          bg: Color(0xffe9ebef),
          fg: muted,
          icon: Icons.star_border_rounded,
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProfileScreen(id: m.id!)),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MemberAvatar(m, radius: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                m.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (st == MStatus.active) ...[
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.verified_rounded,
                                color: blue,
                                size: 17,
                              ),
                            ],
                            const SizedBox(width: 6),
                            Pill(m.gender),
                          ],
                        ),
                      ],
                    ),
                  ),
                  status,
                ],
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Pill(planTitle(m.durationMonths)),
                    const SizedBox(width: 6),
                    Pill('${m.shift} Shift', icon: Icons.schedule_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
