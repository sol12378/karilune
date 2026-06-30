import 'package:carilune/data/ad_repository.dart';
import 'package:carilune/mock_data/demo_scenarios.dart';
import 'package:carilune/providers/ad_list_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('S3 empty member scenario has no distributing ads', () {
    final container = ProviderContainer(
      overrides: [
        adRepositoryProvider.overrideWith(
          (ref) => AdRepository(
            ref: ref,
            scenario: DemoScenarioId.s3EmptyMember,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final memberAds = container.read(memberAdsProvider);
    expect(memberAds, isEmpty);
  });

  test('S1 default scenario has distributing ads', () {
    final container = ProviderContainer(
      overrides: [
        adRepositoryProvider.overrideWith(
          (ref) => AdRepository(
            ref: ref,
            scenario: DemoScenarioId.s1Default,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final memberAds = container.read(memberAdsProvider);
    expect(memberAds, isNotEmpty);
  });

  test('resetToScenario switches member feed count', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final repo = container.read(adRepositoryProvider.notifier);
    repo.resetToScenario(DemoScenarioId.s1Default);
    final defaultCount =
        repo.getAll().where((ad) => ad.isDistributing && ad.isActive).length;

    repo.resetToScenario(DemoScenarioId.s3EmptyMember);
    final emptyCount =
        repo.getAll().where((ad) => ad.isDistributing && ad.isActive).length;

    expect(defaultCount, greaterThan(0));
    expect(emptyCount, 0);
  });
}
