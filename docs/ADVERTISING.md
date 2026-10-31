# Future ads support — disabled in this release

The app can later integrate a Flutter/native advertising provider. The current
`AdService` boundary has only `DisabledAdService`: no advertising SDK, network
initialization, ad request, placement, ad coin reward or live provider account.
The game and weekly gifts continue to work offline without advertising.

Before enabling ads for the ages 6–8 audience:

1. Choose a currently Google Play Families self-certified SDK version, including
   every mediated network. Verify that provider/format can meet children's ad
   rules, rather than assuming a standard rewarded video is acceptable.
2. Use child age treatment on all requests and suitable content restrictions.
   Current AdMob guidance describes TFAT CHILD and maximum content rating G;
   older TFCD/TFUA tags are deprecated. Check the actual Flutter plugin's supported
   API against the current native SDK when integration is implemented.
3. Do not use personalized/remarketing ads or advertising identifiers for
   children. Configure any required consent/privacy handling for launch regions.
4. No ads on launch, over gameplay taps or as surprise death/retry interruptions.
   Any considered optional reward placement needs a clear choice, no pressure,
   safe frequency limits and policy-compliant dismiss behavior. Play requires
   interfering ads, including rewarded/opt-in ads, to be closeable after 5 seconds.
5. Configure real account/app/ad-unit IDs outside test mode; test only with
   official test units/devices until ready. Audit offline/error/cancel paths.
   Future reward callbacks must be idempotent and never credit on mere display.
6. Update the public Notion policy, bundled policy, Data safety, Families/ads
   declarations and store descriptions before enabling an SDK. The current
   no-ad/no-tracking policy must not be reused unchanged for live advertising.

Sources checked November 1, 2026:
[Families policy](https://support.google.com/googleplay/android-developer/answer/9893335),
[AdMob Families configuration](https://support.google.com/admob/answer/6223431),
[age treatment](https://support.google.com/admob/answer/6219315).
