// import 'package:flutter_test/flutter_test.dart';
// import 'package:gym_app/api/api_config.dart';

// void main() {
//   test('Gym API URLs always target the Gym service', () {
//     expect(
//       ApiConfig.normalizeBaseUrl('http://10.0.2.2:3002/api/v1/physio'),
//       'http://10.0.2.2:3001/api/v1',
//     );
//     expect(
//       ApiConfig.normalizeBaseUrl('http://localhost:3001'),
//       'http://localhost:3001/api/v1',
//     );
//   });
// }



import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/api/api_config.dart';

void main() {
  test('Gym API URLs normalize paths and preserve ports', () {
    expect(
      ApiConfig.normalizeBaseUrl('http://localhost:3001'),
      'http://localhost:3001/api/v1',
    );

    expect(
      ApiConfig.normalizeBaseUrl(
        'https://began-think-decisions-plates.trycloudflare.com',
      ),
      'https://began-think-decisions-plates.trycloudflare.com/api/v1',
    );

    expect(
      ApiConfig.normalizeBaseUrl('http://localhost:3002/api/v1/physio'),
      'http://localhost:3002/api/v1',
    );
  });
}
