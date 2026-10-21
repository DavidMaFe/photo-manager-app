import 'package:photo_manager_app/features/legal/data/content/legal_provider.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_versions.dart';

// The Spanish text (legal_content_es.dart) is the reference one.
//
// When the terms or the policy change, raise their version in LegalVersions and in app.legal.* in the backend.

const String _controller = LegalProvider.name;
const String _contactEmail = LegalProvider.email;

final Map<LegalDocumentType, LegalDocument> legalDocumentsEn = {
  LegalDocumentType.protection: const LegalDocument(
    type: LegalDocumentType.protection,
    title: 'How we protect your photos',
    sections: [
      LegalSection(blocks: [
        LegalParagraph('Photo Manager encrypts your photos and videos end to end. They are encrypted on your phone '
            'before being uploaded and only decrypted on your devices. Nobody else can see them: not us, not the '
            'server administrator, not the providers where they are stored.'),
      ]),
      LegalSection(heading: 'How it works', blocks: [
        LegalBullets([
          'When you create your account, your phone generates a master key that protects all your files.',
          'That key is stored on the server encrypted with your password. The server never receives your password: '
              'your phone turns it into an access key that cannot decrypt anything.',
          'Your phone also generates a recovery key, shown to you as 24 words. It is the backup of your master key.',
          'Every device with an open session keeps the master key in its secure storage.',
        ]),
      ]),
      LegalSection(heading: 'What we cannot see', blocks: [
        LegalBullets([
          'The content of your photos and videos, or their thumbnails.',
          'The original names of the files.',
          'The EXIF data, such as the camera or the GPS location.',
          'Your password and your 24 words.',
        ]),
      ]),
      LegalSection(heading: 'What we do see', blocks: [
        LegalParagraph('For the app to work, the server needs some data unencrypted:'),
        LegalBullets([
          'Your email, name and surname, and your profile picture if you add one.',
          'For each file: whether it is a photo or a video, its size, the date it was taken and uploaded, its '
              'dimensions and the length of videos.',
          'How you organize them: albums and their names, favorites, trash and covers.',
          'An encrypted fingerprint of each file, used to detect duplicates without knowing their content.',
        ]),
      ]),
      LegalSection(heading: 'The other side of encryption', blocks: [
        LegalParagraph('Since we do not have your keys, we cannot recover your photos for you. If you forget your '
            'password, you will need your 24 words or a device with an open session. See "If you forget your '
            'password" and "The 24 words".'),
      ]),
    ],
  ),
  LegalDocumentType.forgotPassword: const LegalDocument(
    type: LegalDocumentType.forgotPassword,
    title: 'If you forget your password',
    sections: [
      LegalSection(blocks: [
        LegalParagraph('Your password protects the key that decrypts your photos. That is why changing it without '
            'knowing it depends on what you have at hand. There are three situations:'),
      ]),
      LegalSection(heading: '1. You have another device with an open session', blocks: [
        LegalParagraph('On that device, go to Profile > Security > "I forgot my password". It will ask for the '
            'fingerprint or PIN of the device and you can set a new password.'),
        LegalParagraph('You lose nothing: all your photos stay accessible.'),
      ]),
      LegalSection(heading: '2. You have your 24 words', blocks: [
        LegalParagraph('On the login screen, tap "Forgot your password?". You will get a code by email. Then type '
            'your 24 words and choose a new password.'),
        LegalParagraph('You lose nothing: all your photos stay accessible.'),
      ]),
      LegalSection(heading: '3. You have neither', blocks: [
        LegalParagraph('You can change the password with the emailed code, but the photos you already had become '
            'locked: nobody can decrypt them without the old key.'),
        LegalBullets([
          'Your locked photos are not deleted. They are kept as long as your account exists.',
          'You can keep using the app and upload new photos with a new key.',
          'If you later find your 24 words or a device with an open session, you can unlock them from Profile > '
              'Security > "Recover locked photos".',
        ]),
      ]),
      LegalSection(heading: 'To never reach situation 3', blocks: [
        LegalBullets([
          'Keep your 24 words somewhere safe as soon as you create your account.',
          'Answer the reminders that ask you to check them from time to time.',
          'If you can, keep a session open on more than one device.',
        ]),
      ]),
    ],
  ),
  LegalDocumentType.recoveryWords: const LegalDocument(
    type: LegalDocumentType.recoveryWords,
    title: 'The 24 words',
    sections: [
      LegalSection(heading: 'What they are', blocks: [
        LegalParagraph('They are your recovery key written as 24 words. They open the key that decrypts your photos '
            'without your password. Your phone generates them when you create your account and they never leave it '
            'unencrypted: we do not know them.'),
      ]),
      LegalSection(heading: 'Why they matter so much', blocks: [
        LegalParagraph('If you forget your password and have no other device with an open session, the 24 words are '
            'the only way to recover your photos. Neither we nor anyone else can generate them again or recover '
            'them for you.'),
      ]),
      LegalSection(heading: 'How to keep them', blocks: [
        LegalBullets([
          'In Google Password Manager, with the button we offer when you create your account.',
          'In the PDF you can download, kept somewhere safe or printed.',
          'Handwritten on paper, kept at home.',
          'Better in two different places.',
        ]),
        LegalParagraph('Avoid unprotected screenshots and do not give them to anyone. Whoever has your 24 words and '
            'access to your email could change your password.'),
      ]),
      LegalSection(heading: 'When they are used', blocks: [
        LegalBullets([
          'When you reset your password with the emailed code.',
          'To unlock photos that became locked after changing the password without them.',
        ]),
      ]),
      LegalSection(heading: 'Reminders', blocks: [
        LegalParagraph('2 days after creating your account, after 2 weeks and then every 3 months, the app asks you '
            'for some words to check that you still have them. On the phone where they were created you can also '
            'see them in Profile > Security > "My 24 words".'),
      ]),
    ],
  ),
  LegalDocumentType.terms: const LegalDocument(
    type: LegalDocumentType.terms,
    title: 'Terms of use',
    version: LegalVersions.terms,
    sections: [
      LegalSection(heading: '1. The service and who provides it', blocks: [
        LegalParagraph('Photo Manager is a service to keep a backup of your photos and videos and organize them. It '
            'is provided by $_controller ("we"). By creating an account you accept these terms and the Privacy '
            'policy.'),
        LegalBullets([
          'Provider: $_controller.',
          'Tax ID (NIF): ${LegalProvider.taxId}.',
          'Address: ${LegalProvider.address}.',
          'Contact email: $_contactEmail.',
        ]),
      ]),
      LegalSection(heading: '2. Your account', blocks: [
        LegalBullets([
          'You must be at least 14 years old. If you are a minor, you need the permission of your parents or '
              'guardians.',
          'The data of your account must be true and the email must be yours.',
          'The account is personal. You are responsible for what is done with it.',
        ]),
      ]),
      LegalSection(heading: '3. End-to-end encryption', blocks: [
        LegalParagraph('Your photos and videos are encrypted on your device before being uploaded. We do not know '
            'your password, your 24 words or the keys that decrypt your files, so we cannot see your files or '
            'recover them for you.'),
        LegalParagraph('You can only access your files with at least one of these three things: your password, your '
            '24 words or a device with an open session.'),
      ]),
      LegalSection(heading: '4. Your responsibilities', blocks: [
        LegalBullets([
          'Keep your 24 words somewhere safe and do not share them.',
          'Do not share your password and protect your devices with a screen lock.',
          'Keep another copy of the files you cannot afford to lose.',
        ]),
      ]),
      LegalSection(heading: '5. Locked files and disclaimer', blocks: [
        LegalParagraph('If you lose your password, your 24 words and access to all your devices with an open session '
            'at the same time, your files become locked and nobody, not even us, can decrypt them.'),
        LegalParagraph('Locked files are not deleted. They are kept as long as your account exists, and you can '
            'unlock them if you recover your 24 words or a device with an open session.'),
        LegalParagraph('To the extent permitted by law, we are not liable for the loss of access to your files or the '
            'impossibility of recovering them when it is because you do not have your password, your 24 words or a '
            'device with an open session.'),
      ]),
      LegalSection(heading: '6. Acceptable use', blocks: [
        LegalParagraph('Since we cannot see your files, you are solely responsible for their content. You may not use '
            'the service to store illegal content or content that infringes the rights of others, or to attack it, '
            'overload it or access other accounts. We may suspend accounts that break these terms.'),
      ]),
      LegalSection(heading: '7. Plans', blocks: [
        LegalParagraph('The storage space, the number of devices that back up, the maximum size of videos and how '
            'often the automatic backup runs depend on your plan. Prices include VAT:'),
        LegalBullets([
          'Free: 5 GB (10 GB for accounts created before the plans), 2 devices, videos up to 100 MB and a weekly '
              'automatic backup.',
          '100 GB: €1.99 per month or €19.99 per year. 3 devices.',
          '250 GB: €3.99 per month or €39.99 per year. 5 devices.',
          '1 TB: €9.99 per month or €99.99 per year. 10 devices.',
          'Paid plans allow videos up to 2 GB and back up automatically every day.',
        ]),
        LegalParagraph('In other countries, Google Play may show the price in your currency. Files you send to the '
            'trash are permanently deleted after 30 days.'),
      ]),
      LegalSection(heading: '8. Paid subscriptions', blocks: [
        LegalBullets([
          'Paid plans are bought in the app and paid with Google Play, which handles the payment. We never receive '
              'the details of your card or payment method.',
          'The plan starts as soon as the payment is confirmed and renews automatically at the end of each period '
              '(month or year) at the same price, until you cancel it.',
          'You can cancel it at any time in Google Play (Payments and subscriptions), also from the app with '
              '"Manage in Google Play". Once cancelled it no longer renews and you keep the plan until the end of the '
              'period you already paid. The amount of the current period is not refunded.',
          'You can change plans at any time. The new one starts at once and the time left on the previous one is '
              'credited to it.',
          'If we change the price, we will let you know at least 30 days in advance. If you do not agree, you can '
              'cancel before it applies.',
          'If a payment fails, Google Play retries it for a few days and you keep the plan meanwhile. If it cannot be '
              'charged, the subscription ends.',
        ]),
      ]),
      LegalSection(heading: '9. When a paid plan ends', blocks: [
        LegalParagraph('You go back to the free plan. We never delete your files because a subscription ends:'),
        LegalBullets([
          'If you store more than the free plan allows, your account becomes read only: you can view, download, move '
              'and delete your files, but not back up new ones until you free up space or subscribe again.',
          'If you have more linked devices than the plan allows, the ones that backed up most recently keep backing '
              'up and the others are paused, without being unlinked.',
          'The videos over 100 MB you already have are kept.',
        ]),
      ]),
      LegalSection(heading: '10. Right of withdrawal', blocks: [
        LegalParagraph('When you buy a paid plan you expressly ask for the service to start at once, without waiting '
            'for the 14-day withdrawal period to end, and you accept that once it has started you lose that right. '
            'If the law still granted you the withdrawal, only the proportional part of the period you have not used '
            'would be refunded.'),
        LegalParagraph('This does not affect the refunds Google Play grants under its own terms.'),
      ]),
      LegalSection(heading: '11. Availability', blocks: [
        LegalParagraph('We do our best to keep the service available and its data protected, with encrypted backups, '
            'but we cannot guarantee that it always works without interruptions or errors.'),
      ]),
      LegalSection(heading: '12. Closing your account', blocks: [
        LegalParagraph('You can delete your account at any time from the app, in Profile → Delete account. It is '
            'deleted at once, with your files, albums, keys and devices, and it cannot be undone. The photos and videos '
            'on your phones are not touched.'),
        LegalParagraph('If you have a subscription, deleting the account cancels its renewal in Google Play. The '
            'amount of the current period is not refunded.'),
        LegalParagraph('If you cannot use the app, write to $_contactEmail from the email of the account. We will '
            'delete it within 30 days.'),
        LegalParagraph('The encrypted backups keep deleted data for up to 5 weeks. Since your keys are deleted too, '
            'nobody can open it.'),
      ]),
      LegalSection(heading: '13. Changes to the terms', blocks: [
        LegalParagraph('If we change these terms, we will publish a new version and the app will ask you to accept it '
            'the next time you log in.'),
      ]),
      LegalSection(heading: '14. Your rights as a consumer', blocks: [
        LegalParagraph('Nothing above limits the rights granted to you by consumer law, or our liability in case of '
            'wilful misconduct or gross negligence.'),
      ]),
      LegalSection(heading: '15. Applicable law and contact', blocks: [
        LegalParagraph('These terms are governed by Spanish law. If you are a consumer, the courts of your place of '
            'residence have jurisdiction. For any question, write to $_contactEmail.'),
      ]),
    ],
  ),
  LegalDocumentType.privacy: const LegalDocument(
    type: LegalDocumentType.privacy,
    title: 'Privacy policy',
    version: LegalVersions.privacy,
    sections: [
      LegalSection(heading: '1. Controller', blocks: [
        LegalParagraph('The controller of your data is $_controller, with tax ID (NIF) ${LegalProvider.taxId} and '
            'address at ${LegalProvider.address}. You can get in touch by writing to $_contactEmail.'),
      ]),
      LegalSection(heading: '2. Data we process', blocks: [
        LegalBullets([
          'Account: email, name, surname and, if you add one, profile picture.',
          'Data of your files that is not encrypted: type (photo or video), size, date taken and uploaded, dimensions '
              'and length; albums and their names, favorites, trash and covers; and an encrypted fingerprint to '
              'detect duplicates.',
          'Devices: name, model, operating system, app version and identifier.',
          'Session and security: access dates, session tokens and the IP address of the requests.',
          'Error reports of the app: the type of error, the screen where it happened, the version of the app and the '
              'model and system of the device. They never carry your email, your files or their names, and they are '
              'kept on our own server.',
          'Your keys, always encrypted: the server cannot open them.',
          'The version of the terms and of this policy you accepted, and the date.',
          'Subscriptions: the identifier of the purchase in Google Play, the plan, its state, the dates of the period '
              'and whether it renews. We never receive the details of your card or payment method.',
        ]),
      ]),
      LegalSection(heading: '3. What we cannot see', blocks: [
        LegalParagraph('The content of your photos and videos, their thumbnails, the original names, the EXIF data and '
            'the GPS location are encrypted end to end. We do not receive your password or your 24 words either.'),
        LegalParagraph('When you share a photo or a video with another app, the original is sent unencrypted. If it '
            'is not in the gallery of your phone, the app decrypts it into a private temporary file, which is deleted '
            'when you come back to the app. What happens next depends on the app you share it with.'),
      ]),
      LegalSection(heading: '4. Purposes and legal basis', blocks: [
        LegalBullets([
          'Providing the service: storing, organizing and syncing your files, sending you the codes to reset your '
              'password and applying the plan you buy. Basis: performance of the contract (art. 6.1.b GDPR).',
          'Protecting the service and preventing abuse, for example by limiting attempts per IP address. Basis: our '
              'legitimate interest (art. 6.1.f).',
          'Finding and fixing errors, outages and performance problems, with the technical logs of the server and '
              'the error reports of the app. Basis: our legitimate interest (art. 6.1.f).',
          'Complying with legal obligations. Basis: legal obligation (art. 6.1.c).',
        ]),
        LegalParagraph('We do not use your data for advertising and we do not sell it.'),
      ]),
      LegalSection(heading: '5. Where your data is and who helps us', blocks: [
        LegalBullets([
          'Application server and encrypted files: our own server, in Spain.',
          'Encrypted backups: Backblaze B2, in a European Union region.',
          'Emails of the app (codes to reset your password and confirmation of the account deletion): Brevo, in the '
              'European Union.',
          'Support email ($_contactEmail): Zoho Mail, in its European Union data centre.',
          'Subscription payments: Google Play (Google Ireland Limited). Google processes the payment data as a '
              'controller, under its own privacy policy. With each purchase we send it a pseudonymous identifier of '
              'your account (never your email) to check that the purchase is yours.',
        ]),
        LegalParagraph('Backblaze is a United States company and Zoho is an Indian one. When they access data from '
            'outside the European Union, the transfer relies on the EU-US Data Privacy Framework or on the standard '
            'contractual clauses of the European Commission.'),
      ]),
      LegalSection(heading: '6. How long we keep it', blocks: [
        LegalBullets([
          'As long as you have the account.',
          'Files in the trash are deleted after 30 days.',
          'Session tokens expire after 30 days.',
          'The technical logs of the server and the error reports of the app are deleted after 30 days.',
          'The data of your subscriptions, as long as you have the account. Google Play keeps its own records of the '
              'payments.',
          'If you delete your account from the app, your data is deleted at once; if you ask by email, within 30 '
              'days.',
          'The encrypted backups keep deleted data for up to 5 weeks. Since your keys are deleted too, nobody can '
              'open it.',
        ]),
      ]),
      LegalSection(heading: '7. Your rights', blocks: [
        LegalParagraph('You can exercise your rights of access, rectification, erasure, objection, restriction of '
            'processing and portability by writing to $_contactEmail from the email of your account. You do not need '
            'to write to us to delete your account: you can do it from the app, in Profile → Delete account. We also '
            'explain it at photo-manager-pro.com/eliminar-cuenta.'),
        LegalParagraph('If you think we have not handled your data properly, you can file a complaint with the '
            'Spanish Data Protection Agency (www.aepd.es).'),
      ]),
      LegalSection(heading: '8. Security', blocks: [
        LegalParagraph('Besides end-to-end encryption, communications are encrypted (HTTPS) and access keys are stored '
            'as hashes that cannot be reversed.'),
      ]),
      LegalSection(heading: '9. Minors', blocks: [
        LegalParagraph('The service is not intended for children under 14.'),
      ]),
      LegalSection(heading: '10. Changes to this policy', blocks: [
        LegalParagraph('If we change this policy, we will publish a new version and the app will ask you to accept it '
            'the next time you log in.'),
      ]),
    ],
  ),
};
