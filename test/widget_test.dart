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
}
