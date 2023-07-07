// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'fr';

  static String m0(size) =>
      "La taille d\'un fichier dépasse la limite des ${size}mo";

  static String m1(proposalLength) => "${proposalLength} propositions";

  static String m2(tribuName, tribuLink) =>
      "Rejoins la Tribu \"${tribuName}\" à ${tribuLink}";

  static String m3(number) =>
      "Merci d\'envoyer au maximum ${number} fichiers par message";

  static String m4(newMemberName) => "${newMemberName} a rejoint la Tribu";

  static String m5(toolLength) => "Avec ${toolLength} outils";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "ChatPageTitle": MessageLookupByLibrary.simpleMessage("Chat"),
        "aFileIsLargerThanTheLimit": m0,
        "addExternalMemberAction":
            MessageLookupByLibrary.simpleMessage("Ajouter un membre externe"),
        "amount": MessageLookupByLibrary.simpleMessage("Montant"),
        "attendeesPlaceholder":
            MessageLookupByLibrary.simpleMessage("Participants"),
        "attendeesPresencePageTitle":
            MessageLookupByLibrary.simpleMessage("Participants confirmés"),
        "balanceAction":
            MessageLookupByLibrary.simpleMessage("Équilibrage malin"),
        "cancelAction": MessageLookupByLibrary.simpleMessage("Annuler"),
        "chatNotificationDescription": MessageLookupByLibrary.simpleMessage(
            "Conversations au sein de la Tribu"),
        "chatNotificationTitle":
            MessageLookupByLibrary.simpleMessage("Conversations"),
        "closeAction": MessageLookupByLibrary.simpleMessage("Fermer"),
        "confirmAction": MessageLookupByLibrary.simpleMessage("Confirmer"),
        "confirmChangesAction":
            MessageLookupByLibrary.simpleMessage("Confirmer les modifications"),
        "confirmDialogTitle":
            MessageLookupByLibrary.simpleMessage("Es-tu sûr(e) ?"),
        "copyAction": MessageLookupByLibrary.simpleMessage("Copier le contenu"),
        "createATribuAction":
            MessageLookupByLibrary.simpleMessage("Créer une Tribu"),
        "createAction": MessageLookupByLibrary.simpleMessage("Créer"),
        "createTheTribuAction":
            MessageLookupByLibrary.simpleMessage("Créer la Tribu"),
        "currency": MessageLookupByLibrary.simpleMessage("Devise"),
        "dateProposalPageDescription": MessageLookupByLibrary.simpleMessage(
            "Vote pour les dates où tu es disponible\nUne fois le vote effectué, clique sur la date choisie"),
        "dateProposalsPageTitle":
            MessageLookupByLibrary.simpleMessage("Propositions de dates"),
        "dateproposallistlengthPropositions": m1,
        "defaultPermanentEventName":
            MessageLookupByLibrary.simpleMessage("Vie quotidienne"),
        "deleteAction": MessageLookupByLibrary.simpleMessage("Supprimer"),
        "deleteEventAction":
            MessageLookupByLibrary.simpleMessage("Supprimer l\'événement"),
        "editAction": MessageLookupByLibrary.simpleMessage("Modifier"),
        "editEventAction":
            MessageLookupByLibrary.simpleMessage("Modifier l\'événement"),
        "editExpenseAction":
            MessageLookupByLibrary.simpleMessage("Modifier la dépense"),
        "editToolDialogTitle":
            MessageLookupByLibrary.simpleMessage("Modifier l\'outil"),
        "eventDateVoteInProgress":
            MessageLookupByLibrary.simpleMessage("Vote en cours"),
        "eventInvitationDeclinedTitle": MessageLookupByLibrary.simpleMessage(
            "Tu ne participeras pas à cet événement"),
        "eventInvitationTitle": MessageLookupByLibrary.simpleMessage(
            "Tu es invité à cet événement !"),
        "eventsPageTitle": MessageLookupByLibrary.simpleMessage("Événements"),
        "everyone": MessageLookupByLibrary.simpleMessage("Tout le monde"),
        "expenseLabel": MessageLookupByLibrary.simpleMessage("Titre"),
        "expenseToolDescription": MessageLookupByLibrary.simpleMessage(
            "Équilibre les dettes automatiquement"),
        "expenseToolName":
            MessageLookupByLibrary.simpleMessage("Gestionnaire de dépenses"),
        "expensesSubHeader": MessageLookupByLibrary.simpleMessage("Dépenses"),
        "expensesToolNamePlaceholder":
            MessageLookupByLibrary.simpleMessage("Nom"),
        "externalMemberBlaming": MessageLookupByLibrary.simpleMessage(
            "Pour assigner des tâches ou des dépenses à des personnes qui n\'ont pas encore installé Tribu"),
        "hideAll": MessageLookupByLibrary.simpleMessage("Voir moins"),
        "howShouldWeCallHim":
            MessageLookupByLibrary.simpleMessage("Choisis un nom"),
        "howShouldWeCallYou": MessageLookupByLibrary.simpleMessage(
            "Choisis ton nom au sein de la Tribu"),
        "imageSavedToGallery": MessageLookupByLibrary.simpleMessage(
            "Image sauvegardée dans la galerie"),
        "inviteLinkText": m2,
        "joinATribeLinkInstruction": MessageLookupByLibrary.simpleMessage(
            "Afin de rejoindre une Tribu tu dois demander un lien d\'invitation à un membre existant"),
        "joinATribuAction":
            MessageLookupByLibrary.simpleMessage("Rejoindre une Tribu"),
        "joinTheTribu":
            MessageLookupByLibrary.simpleMessage("Rejoindre la Tribu"),
        "leaveTribuAction":
            MessageLookupByLibrary.simpleMessage("Quitter la Tribu"),
        "linkIsInvalid":
            MessageLookupByLibrary.simpleMessage("Le lien est invalide"),
        "listNamePlaceholder":
            MessageLookupByLibrary.simpleMessage("Nom de la liste"),
        "listToolExamples": MessageLookupByLibrary.simpleMessage(
            "Courses, tâches, rappels, etc."),
        "listToolIdeaListName":
            MessageLookupByLibrary.simpleMessage("Liste d\'idées"),
        "listToolLuggageListName":
            MessageLookupByLibrary.simpleMessage("Liste de bagages"),
        "listToolName": MessageLookupByLibrary.simpleMessage("Liste partagée"),
        "listToolShoppingListName":
            MessageLookupByLibrary.simpleMessage("Liste de courses"),
        "listToolTodoListName":
            MessageLookupByLibrary.simpleMessage("Liste de tâches"),
        "manageToolsAction":
            MessageLookupByLibrary.simpleMessage("Gérer les outils"),
        "maximumFilePerMessage": m3,
        "memberListPageTitle":
            MessageLookupByLibrary.simpleMessage("Liste des membres"),
        "memberListTitle":
            MessageLookupByLibrary.simpleMessage("Liste des membres"),
        "memberNameFormError":
            MessageLookupByLibrary.simpleMessage("Merci de saisir un nom"),
        "memberNameFormPlaceholder":
            MessageLookupByLibrary.simpleMessage("Ex : Angelo Stralopitec"),
        "mergeProfilesAction":
            MessageLookupByLibrary.simpleMessage("Fusionner des profils"),
        "messageSelectedTitle":
            MessageLookupByLibrary.simpleMessage("Message sélectionné"),
        "mostIndebted": MessageLookupByLibrary.simpleMessage("Le plus endetté"),
        "nameOfNewMembersNotifications":
            MessageLookupByLibrary.simpleMessage("Nouveaux membres"),
        "newChatMessageAction":
            MessageLookupByLibrary.simpleMessage("Envoyer un message"),
        "newEventAction":
            MessageLookupByLibrary.simpleMessage("Ajouter un événement"),
        "newExpenseAction":
            MessageLookupByLibrary.simpleMessage("Nouvelle dépense"),
        "newListItemPlaceholder":
            MessageLookupByLibrary.simpleMessage("Ajouter un élément"),
        "newMemberNotificationContent": m4,
        "newMemberNotificationDescription":
            MessageLookupByLibrary.simpleMessage(
                "Notifications lorsqu\'un nouveau membre rejoint la Tribu"),
        "newMemberNotificationTitle":
            MessageLookupByLibrary.simpleMessage("Nouveaux membres"),
        "newToolAction":
            MessageLookupByLibrary.simpleMessage("Ajouter un outil"),
        "noExpenseSmartBalance": MessageLookupByLibrary.simpleMessage(
            "Pour pouvoir utiliser l\'Équilibrage malin vous devez avoir au moins une dépense!"),
        "paidBy": MessageLookupByLibrary.simpleMessage("Payé par"),
        "paidFor": MessageLookupByLibrary.simpleMessage("Payé pour"),
        "pastAnInvitationLinkHere": MessageLookupByLibrary.simpleMessage(
            "Colle un lien d\'invitation ici"),
        "permanentEventTypeDescription": MessageLookupByLibrary.simpleMessage(
            "Événement récurrent ou qui n\'expire jamais"),
        "permanentEventTypeTitle":
            MessageLookupByLibrary.simpleMessage("Permanent"),
        "pickAdditionnalDate":
            MessageLookupByLibrary.simpleMessage("Proposer une autre date"),
        "pickAdditionnalDateRange":
            MessageLookupByLibrary.simpleMessage("Proposer une autre période"),
        "pickInitialDate":
            MessageLookupByLibrary.simpleMessage("Choisir une date"),
        "pickInitialDateRange":
            MessageLookupByLibrary.simpleMessage("Choisir une période"),
        "profileToKeepAction":
            MessageLookupByLibrary.simpleMessage("Profile à garder"),
        "punctualEventTypeDescription": MessageLookupByLibrary.simpleMessage(
            "Événement à un moment précis"),
        "punctualEventTypeTitle":
            MessageLookupByLibrary.simpleMessage("Ponctuel"),
        "removeMessageAction":
            MessageLookupByLibrary.simpleMessage("Supprimer pour moi"),
        "removeProfilesAction":
            MessageLookupByLibrary.simpleMessage("Enlever des profils"),
        "selectAProfileAction":
            MessageLookupByLibrary.simpleMessage("Quel membre?"),
        "selectProfilesAction":
            MessageLookupByLibrary.simpleMessage("Quels membres?"),
        "selectionAction":
            MessageLookupByLibrary.simpleMessage("Confirmer la sélection"),
        "stayEventTypeDescription": MessageLookupByLibrary.simpleMessage(
            "Événement sur plusieurs jours"),
        "stayEventTypeTitle": MessageLookupByLibrary.simpleMessage("Séjour"),
        "theLinkIsNotRecognized":
            MessageLookupByLibrary.simpleMessage("Le lien n\'est pas reconnu"),
        "thisFieldIsRequired":
            MessageLookupByLibrary.simpleMessage("Ce champ est requis"),
        "titlePlaceholder": MessageLookupByLibrary.simpleMessage("Titre"),
        "toolsLengthText": m5,
        "tribeNameInstruction": MessageLookupByLibrary.simpleMessage(
            "Choisis un nom pour ta nouvelle Tribu"),
        "tribuNameFormError": MessageLookupByLibrary.simpleMessage(
            "Merci de saisir un nom pour la Tribu"),
        "tribuNameFormPlaceholder":
            MessageLookupByLibrary.simpleMessage("Ex : Tribu de Dana"),
        "updateAction": MessageLookupByLibrary.simpleMessage("Mettre à jour"),
        "updateToViewTool": MessageLookupByLibrary.simpleMessage(
            "Pour voir cet outil mettez à jour Tribu"),
        "updateTribuAction":
            MessageLookupByLibrary.simpleMessage("Mettre à jour Tribu"),
        "upgradingAppRequired": MessageLookupByLibrary.simpleMessage(
            "Une version plus récente de Tribu est nécessaire pour continuer"),
        "userBalance": MessageLookupByLibrary.simpleMessage("Mon équilibre"),
        "userTotalCost":
            MessageLookupByLibrary.simpleMessage("Mon coût global"),
        "viewAll": MessageLookupByLibrary.simpleMessage("Voir plus"),
        "welcomeMessageFirstMember": MessageLookupByLibrary.simpleMessage(
            "Bienvenue dans votre Tribu !\nVous pouvez inviter de nouveaux membres à vous rejoindre et bénéficier dés à présent d\'outils pratiques !"),
        "welcomeMessageWithExistingMembers": MessageLookupByLibrary.simpleMessage(
            "Bienvenue dans votre Tribu !\nVous pouvez saluer les autres membres et bénéficier dés à présent d\'outils pratiques !"),
        "willYouAttend":
            MessageLookupByLibrary.simpleMessage("Participeras-tu ?"),
        "youAreAboutToJoinTheTribu": MessageLookupByLibrary.simpleMessage(
            "Tu es sur le point de rejoindre la Tribu"),
        "youAreAlreadyInTheTribu": MessageLookupByLibrary.simpleMessage(
            "Tu es déjà membre de la Tribu")
      };
}
