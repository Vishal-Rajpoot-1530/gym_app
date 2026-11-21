import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/models/member.dart';

void main() {
  test('addMonths clamps to the end of shorter months', () {
    expect(addMonths(DateTime(2025, 1, 31), 1), DateTime(2025, 2, 28));
    expect(addMonths(DateTime(2025, 10, 24), 1), DateTime(2025, 11, 24));
    expect(addMonths(DateTime(2025, 11, 30), 3), DateTime(2026, 2, 28));
    expect(addMonths(DateTime(2025, 1, 15), -2), DateTime(2024, 11, 15));
  });

  test('member state reflects expiry', () {
    Member make(int daysFromNow, {String status = 'active'}) => Member(
      name: 'Test User',
      gender: 'Male',
      age: 25,
      plan: '1 Month',
      durationMonths: 1,
      fee: 65,
      joiningDate: DateTime.now(),
      expiryDate: DateTime.now().add(Duration(days: daysFromNow)),
      status: status,
    );
    expect(make(30).state, MStatus.active);
    expect(make(3).state, MStatus.dueSoon);
    expect(make(-2).state, MStatus.inactive);
    expect(make(30, status: 'inactive').state, MStatus.inactive);
  });

  test('member shift survives model serialization and defaults to morning', () {
    final member = Member(
      name: 'Test User',
      gender: 'Male',
      age: 25,
      plan: '1 Month',
      durationMonths: 1,
      fee: 65,
      shift: 'Evening',
      joiningDate: DateTime(2026, 11, 13),
      expiryDate: DateTime(2026, 12, 13),
    );
    final restored = Member.fromMap(member.toMap());
    final oldMap = member.toMap()..remove('shift');

    expect(restored.shift, 'Evening');
    expect(Member.fromMap(oldMap).shift, 'Morning');
  });

  test('member shift normalization recognizes Evening Shift variants', () {
    final map = <String, Object?>{
      'name': 'Test User',
      'gender': 'Male',
      'age': 25,
      'plan': '1 Month',
      'duration_months': 1,
      'fee': 65,
      'joining_date': DateTime(2026, 11, 13).toIso8601String(),
      'expiry_date': DateTime(2026, 12, 13).toIso8601String(),
      'shift': ' evening shift ',
    };

    expect(Member.fromMap(map).shift, 'Evening');
    expect(normalizeShift('EVENING'), 'Evening');
    expect(normalizeShift(' morning shift '), 'Morning');
  });

  test('shift filtering returns only members in the selected shift', () {
    Member make(String shift) => Member(
      name: shift,
      gender: 'Male',
      age: 25,
      plan: '1 Month',
      durationMonths: 1,
      fee: 65,
      shift: shift,
      joiningDate: DateTime(2026, 11, 13),
      expiryDate: DateTime(2026, 12, 13),
    );
    final members = [make('Morning'), make('Evening'), make('Evening Shift')];

    expect(membersForShift(members, 'Morning').map((member) => member.name), [
      'Morning',
    ]);
    expect(
      membersForShift(members, 'Evening Shift').map((member) => member.name),
      ['Evening', 'Evening Shift'],
    );
    expect(membersForShift(members, null), members);
  });

  test('discount is subtracted as a fixed amount and cannot go below zero', () {
    expect(feeAfterDiscount(500, 75), 425);
    expect(feeAfterDiscount(500, 0), 500);
    expect(feeAfterDiscount(500, 500), 0);
    expect(feeAfterDiscount(500, 600), 0);
  });
}
