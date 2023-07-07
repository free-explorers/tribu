abstract class AppConfig {
  static String inviteLinkPrefix = 'trbu.app/?key';

  static String buildInvitationLink(String tribuId, String encryptionKey) {
    return 'https://invite.trbu.app/?link=https://get.trbu.app/?key=$tribuId$encryptionKey&apn=com.tribu.default&isi=1620848629&ibi=com.tribu.default';
  }
}
