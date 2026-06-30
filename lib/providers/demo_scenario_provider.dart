import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock_data/demo_scenarios.dart';

final demoScenarioProvider =
    StateProvider<DemoScenarioId>((ref) => DemoScenarioId.s1Default);
