import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_versions.dart';

// DRAFT: the terms and the privacy policy must be reviewed by a lawyer before the app is opened to other users. The
// data in brackets is filled in then. The Spanish text (legal_content_es.dart) is the reference one.
//
// When the terms or the policy change, raise their version in LegalVersions and in app.legal.* in the backend.

const String _controller = '[NAME OF THE CONTROLLER]';
const String _contactEmail = '[CONTACT EMAIL]';
const String _serverProvider = '[SERVER PROVIDER]';

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
      LegalSection(heading: '1. The service', blocks: [
        LegalParagraph('Photo Manager is a service to keep a backup of your photos and videos and organize them. It '
            'is provided by $_controller ("we"). By creating an account you accept these terms and the Privacy '
            'policy.'),
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
      LegalSection(heading: '7. Storage and trash', blocks: [
        LegalBullets([
          'Each account has a maximum storage space, shown in the app.',
          'Files you send to the trash are permanently deleted after 30 days.',
        ]),
      ]),
      LegalSection(heading: '8. Availability', blocks: [
        LegalParagraph('We do our best to keep the service available and its data protected, with encrypted backups, '
            'but we cannot guarantee that it always works without interruptions or errors.'),
      ]),
      LegalSection(heading: '9. Closing your account', blocks: [
        LegalParagraph('You can ask us to delete your account by writing to $_contactEmail from the email of the '
            'account. We will delete it, with your files and keys, within 30 days. The encrypted backups may keep '
            'them for 30 more days.'),
      ]),
      LegalSection(heading: '10. Changes to the terms', blocks: [
        LegalParagraph('If we change these terms, we will publish a new version and the app will ask you to accept it '
            'the next time you log in.'),
      ]),
      LegalSection(heading: '11. Your rights as a consumer', blocks: [
        LegalParagraph('Nothing above limits the rights granted to you by consumer law, or our liability in case of '
            'wilful misconduct or gross negligence.'),
      ]),
      LegalSection(heading: '12. Applicable law and contact', blocks: [
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
        LegalParagraph('The controller of your data is $_controller. You can get in touch by writing to '
            '$_contactEmail.'),
      ]),
      LegalSection(heading: '2. Data we process', blocks: [
        LegalBullets([
          'Account: email, name, surname and, if you add one, profile picture.',
          'Data of your files that is not encrypted: type (photo or video), size, date taken and uploaded, dimensions '
              'and length; albums and their names, favorites, trash and covers; and an encrypted fingerprint to '
              'detect duplicates.',
          'Devices: name, model, operating system, app version and identifier.',
          'Session and security: access dates, session tokens and the IP address of the requests.',
          'Your keys, always encrypted: the server cannot open them.',
          'The version of the terms and of this policy you accepted, and the date.',
        ]),
      ]),
      LegalSection(heading: '3. What we cannot see', blocks: [
        LegalParagraph('The content of your photos and videos, their thumbnails, the original names, the EXIF data and '
            'the GPS location are encrypted end to end. We do not receive your password or your 24 words either.'),
      ]),
      LegalSection(heading: '4. Purposes and legal basis', blocks: [
        LegalBullets([
          'Providing the service: storing, organizing and syncing your files and sending you the codes to reset '
              'your password. Basis: performance of the contract (art. 6.1.b GDPR).',
          'Protecting the service and preventing abuse, for example by limiting attempts per IP address. Basis: our '
              'legitimate interest (art. 6.1.f).',
          'Complying with legal obligations. Basis: legal obligation (art. 6.1.c).',
        ]),
        LegalParagraph('We do not use your data for advertising and we do not sell it.'),
      ]),
      LegalSection(heading: '5. Where your data is and who helps us', blocks: [
        LegalBullets([
          'Application server: $_serverProvider, in the European Union.',
          'Encrypted files: Cloudflare R2, with the data in the European Union jurisdiction.',
          'Encrypted backups: Backblaze B2, in a European Union region.',
          'Emails (codes to reset your password): Google (Gmail).',
        ]),
        LegalParagraph('Cloudflare, Backblaze and Google are United States companies. When they access data from '
            'outside the European Union, the transfer relies on the EU-US Data Privacy Framework or on the standard '
            'contractual clauses of the European Commission.'),
      ]),
      LegalSection(heading: '6. How long we keep it', blocks: [
        LegalBullets([
          'As long as you have the account.',
          'Files in the trash are deleted after 30 days.',
          'Session tokens expire after 30 days.',
          'If you close your account, we delete your data within 30 days; the encrypted backups keep it for 30 more '
              'days.',
        ]),
      ]),
      LegalSection(heading: '7. Your rights', blocks: [
        LegalParagraph('You can exercise your rights of access, rectification, erasure, objection, restriction of '
            'processing and portability by writing to $_contactEmail from the email of your account.'),
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
