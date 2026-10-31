const publisherName = 'BlackAlpha-debug';
const supportEmail = String.fromEnvironment(
  'SUPPORT_EMAIL',
  defaultValue: 'muzammiljawad6@gmail.com',
);
const privacyPolicyUrl = String.fromEnvironment('PRIVACY_POLICY_URL');

const privacySummary = '''Little Dino works offline. It has no accounts, ads,
in-app purchases, analytics, social features or location tracking.

Best scores, collected stars, dinosaur colors and settings are saved on this
device. The game does not send them to the developer. Android cloud backup of
this app is disabled. Removing app data or uninstalling can remove progress.

Sound effects are included in the app. The game does not use the microphone,
camera, contacts or advertising ID.

You can erase local scores, stars and settings using Reset progress below.
The app store and device operating system have their own privacy practices.

If a parent or guardian emails us for support, we use the sender's email address
and message to handle the request. Please avoid sending a child's personal details.
You can request deletion of support correspondence by emailing us.''';
