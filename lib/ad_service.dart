/// Future provider boundary only. This release contains no advertising SDK.
enum AdOutcome { unavailable, dismissed, rewardEarned }

abstract interface class AdService {
  bool get enabled;
  Future<AdOutcome> showOptionalReward();
}

class DisabledAdService implements AdService {
  const DisabledAdService();
  @override
  bool get enabled => false;
  @override
  Future<AdOutcome> showOptionalReward() async => AdOutcome.unavailable;
}
