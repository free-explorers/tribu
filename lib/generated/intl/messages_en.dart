// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(size) => "A file is larger than the ${size}mb limit";

  static String m1(proposalLength) => "${proposalLength} propositions";

  static String m2(tribuName, tribuLink) =>
      "Join the Tribu \"${tribuName}\" at ${tribuLink}";

  static String m3(number) =>
      "Thanks to send ${number} files maximum per message";

  static String m4(newMemberName) => "${newMemberName} has joined the Tribu";

  static String m5(toolLength) => "With ${toolLength} tools";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "ChatPageTitle": MessageLookupByLibrary.simpleMessage("Chat"),
        "aFileIsLargerThanTheLimit": m0,
        "addExternalMemberAction":
            MessageLookupByLibrary.simpleMessage("Add external member"),
        "amount": MessageLookupByLibrary.simpleMessage("Amount"),
        "attendeesPlaceholder":
            MessageLookupByLibrary.simpleMessage("Attendees"),
        "attendeesPresencePageTitle": MessageLookupByLibrary.simpleMessage(
            "Attendees presence confirmed"),
        "balanceAction": MessageLookupByLibrary.simpleMessage("Smart balance"),
        "cancelAction": MessageLookupByLibrary.simpleMessage("Cancel"),
        "chatNotificationDescription":
            MessageLookupByLibrary.simpleMessage("Chat in the Tribu"),
        "chatNotificationTitle": MessageLookupByLibrary.simpleMessage("Chat"),
        "closeAction": MessageLookupByLibrary.simpleMessage("Close"),
        "confirmAction": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirmChangesAction":
            MessageLookupByLibrary.simpleMessage("Confirm changes"),
        "confirmDialogTitle":
            MessageLookupByLibrary.simpleMessage("Are you sure?"),
        "copyAction": MessageLookupByLibrary.simpleMessage("Copy content"),
        "createATribuAction":
            MessageLookupByLibrary.simpleMessage("Create a Tribu"),
        "createAction": MessageLookupByLibrary.simpleMessage("Create"),
        "createTheTribuAction":
            MessageLookupByLibrary.simpleMessage("Create the Tribu"),
        "currency": MessageLookupByLibrary.simpleMessage("Currency"),
        "dateProposalPageDescription": MessageLookupByLibrary.simpleMessage(
            "Vote for the best suited dates for you and when you are ready click a date to select it"),
        "dateProposalsPageTitle":
            MessageLookupByLibrary.simpleMessage("Date proposals"),
        "dateproposallistlengthPropositions": m1,
        "defaultPermanentEventName":
            MessageLookupByLibrary.simpleMessage("Daily routine"),
        "deleteAction": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteEventAction":
            MessageLookupByLibrary.simpleMessage("Delete Event"),
        "editAction": MessageLookupByLibrary.simpleMessage("Edit"),
        "editEventAction": MessageLookupByLibrary.simpleMessage("Edit Event"),
        "editExpenseAction":
            MessageLookupByLibrary.simpleMessage("Edit expense"),
        "editList": MessageLookupByLibrary.simpleMessage("Edit list"),
        "editToolDialogTitle":
            MessageLookupByLibrary.simpleMessage("Edit tool"),
        "eventDateVoteInProgress":
            MessageLookupByLibrary.simpleMessage("Vote in progress"),
        "eventInvitationDeclinedTitle": MessageLookupByLibrary.simpleMessage(
            "You won\'t attend to this event"),
        "eventInvitationTitle": MessageLookupByLibrary.simpleMessage(
            "You are invited to this event!"),
        "eventsPageTitle": MessageLookupByLibrary.simpleMessage("Events"),
        "everyone": MessageLookupByLibrary.simpleMessage("Everyone"),
        "expenseLabel": MessageLookupByLibrary.simpleMessage("Label"),
        "expenseToolDescription":
            MessageLookupByLibrary.simpleMessage("Balance debts automatically"),
        "expenseToolName":
            MessageLookupByLibrary.simpleMessage("Expenses manager"),
        "expensesSubHeader": MessageLookupByLibrary.simpleMessage("Expenses"),
        "expensesToolNamePlaceholder":
            MessageLookupByLibrary.simpleMessage("Name"),
        "externalMemberBlaming": MessageLookupByLibrary.simpleMessage(
            "When you want to add a profile for someone not currently using Tribu"),
        "hideAll": MessageLookupByLibrary.simpleMessage("Hide all"),
        "howShouldWeCallHim":
            MessageLookupByLibrary.simpleMessage("Pick a name"),
        "howShouldWeCallYou":
            MessageLookupByLibrary.simpleMessage("Pick your name in the tribe"),
        "imageSavedToGallery":
            MessageLookupByLibrary.simpleMessage("Image saved to gallery"),
        "inviteLinkText": m2,
        "joinATribeLinkInstruction": MessageLookupByLibrary.simpleMessage(
            "In order to join a Tribu you need to ask an invitation link from a member"),
        "joinATribuAction":
            MessageLookupByLibrary.simpleMessage("Join a Tribu"),
        "joinTheTribu": MessageLookupByLibrary.simpleMessage("Join the Tribu"),
        "leaveTribuAction":
            MessageLookupByLibrary.simpleMessage("Leave the Tribu"),
        "linkIsInvalid":
            MessageLookupByLibrary.simpleMessage("Link is invalid"),
        "listNamePlaceholder":
            MessageLookupByLibrary.simpleMessage("List name"),
        "listToolExamples": MessageLookupByLibrary.simpleMessage(
            "Shoppings, to-dos, reminders, etc.. "),
        "listToolIdeaListName":
            MessageLookupByLibrary.simpleMessage("Idea list"),
        "listToolLuggageListName":
            MessageLookupByLibrary.simpleMessage("Luggage list"),
        "listToolName": MessageLookupByLibrary.simpleMessage("Shared List"),
        "listToolShoppingListName":
            MessageLookupByLibrary.simpleMessage("Shopping list"),
        "listToolTodoListName":
            MessageLookupByLibrary.simpleMessage("To-do list"),
        "manageToolsAction":
            MessageLookupByLibrary.simpleMessage("Manage tools"),
        "maximumFilePerMessage": m3,
        "memberListPageTitle":
            MessageLookupByLibrary.simpleMessage("Member list"),
        "memberListTitle": MessageLookupByLibrary.simpleMessage("Member list"),
        "memberNameFormError":
            MessageLookupByLibrary.simpleMessage("Please enter a name"),
        "memberNameFormPlaceholder":
            MessageLookupByLibrary.simpleMessage("Ex : Angelo Stralopitecus"),
        "mergeProfilesAction":
            MessageLookupByLibrary.simpleMessage("Merge members"),
        "messageSelectedTitle":
            MessageLookupByLibrary.simpleMessage("Message selected"),
        "mostIndebted": MessageLookupByLibrary.simpleMessage("Most indebted"),
        "nameOfNewMembersNotifications":
            MessageLookupByLibrary.simpleMessage("New Members"),
        "newChatMessageAction":
            MessageLookupByLibrary.simpleMessage("Send a message"),
        "newEventAction": MessageLookupByLibrary.simpleMessage("Add an event"),
        "newExpenseAction":
            MessageLookupByLibrary.simpleMessage("Add an expense"),
        "newListItemPlaceholder":
            MessageLookupByLibrary.simpleMessage("Add an item"),
        "newMemberNotificationContent": m4,
        "newMemberNotificationDescription":
            MessageLookupByLibrary.simpleMessage(
                "Notification when new member joined the Tribu"),
        "newMemberNotificationTitle":
            MessageLookupByLibrary.simpleMessage("New members"),
        "newToolAction": MessageLookupByLibrary.simpleMessage("Add a tool"),
        "noExpenseSmartBalance": MessageLookupByLibrary.simpleMessage(
            "You need to have some expenses to use the Smart Balance feature!"),
        "paidBy": MessageLookupByLibrary.simpleMessage("Paid by"),
        "paidFor": MessageLookupByLibrary.simpleMessage("Paid for"),
        "pastAnInvitationLinkHere": MessageLookupByLibrary.simpleMessage(
            "Past an invitation link here"),
        "permanentEventTypeDescription": MessageLookupByLibrary.simpleMessage(
            "Recurring event or event that never expire"),
        "permanentEventTypeTitle":
            MessageLookupByLibrary.simpleMessage("Permanent"),
        "pickAdditionnalDate":
            MessageLookupByLibrary.simpleMessage("Add alternative date"),
        "pickAdditionnalDateRange":
            MessageLookupByLibrary.simpleMessage("Add alternative range"),
        "pickInitialDate": MessageLookupByLibrary.simpleMessage("Pick a date"),
        "pickInitialDateRange":
            MessageLookupByLibrary.simpleMessage("Pick a date range"),
        "profileToKeepAction":
            MessageLookupByLibrary.simpleMessage("Members to keep"),
        "punctualEventTypeDescription": MessageLookupByLibrary.simpleMessage(
            "Event that occur on a specific date"),
        "punctualEventTypeTitle":
            MessageLookupByLibrary.simpleMessage("Punctual"),
        "removeMessageAction":
            MessageLookupByLibrary.simpleMessage("Remove for me"),
        "removeProfilesAction":
            MessageLookupByLibrary.simpleMessage("Remove members"),
        "selectAProfileAction":
            MessageLookupByLibrary.simpleMessage("Select a member"),
        "selectProfilesAction":
            MessageLookupByLibrary.simpleMessage("Select members"),
        "selectionAction":
            MessageLookupByLibrary.simpleMessage("Confirm selection"),
        "stayEventTypeDescription": MessageLookupByLibrary.simpleMessage(
            "Event that last for a period of time"),
        "stayEventTypeTitle": MessageLookupByLibrary.simpleMessage("Stay"),
        "theLinkIsNotRecognized":
            MessageLookupByLibrary.simpleMessage("The link is not recognized"),
        "thisFieldIsRequired":
            MessageLookupByLibrary.simpleMessage("This field is required"),
        "titlePlaceholder": MessageLookupByLibrary.simpleMessage("Title"),
        "toolsLengthText": m5,
        "tribeNameInstruction": MessageLookupByLibrary.simpleMessage(
            "Pick a name for your future Tribu"),
        "tribuNameFormError": MessageLookupByLibrary.simpleMessage(
            "Please enter a name for your Tribu"),
        "tribuNameFormPlaceholder":
            MessageLookupByLibrary.simpleMessage("Ex: The Flintstones"),
        "updateAction": MessageLookupByLibrary.simpleMessage("Update"),
        "updateToViewTool": MessageLookupByLibrary.simpleMessage(
            "To view this tool you need to update Tribu"),
        "updateTribuAction":
            MessageLookupByLibrary.simpleMessage("Update Tribu application"),
        "upgradingAppRequired": MessageLookupByLibrary.simpleMessage(
            "Upgrading Tribu is required to continue"),
        "userBalance": MessageLookupByLibrary.simpleMessage("My balance"),
        "userTotalCost": MessageLookupByLibrary.simpleMessage("My total cost"),
        "viewAll": MessageLookupByLibrary.simpleMessage("View all"),
        "welcomeMessageFirstMember": MessageLookupByLibrary.simpleMessage(
            "Welcome in your Tribu !\nYou can now invite more members to join and get the benefit of convenient tools right now !"),
        "welcomeMessageWithExistingMembers": MessageLookupByLibrary.simpleMessage(
            "Welcome in your Tribu !\nYou can now say hello to others members and get the benefit of awesome tools right now !"),
        "willYouAttend":
            MessageLookupByLibrary.simpleMessage("Will you attend?"),
        "youAreAboutToJoinTheTribu": MessageLookupByLibrary.simpleMessage(
            "You are about to join the Tribu"),
        "youAreAlreadyInTheTribu":
            MessageLookupByLibrary.simpleMessage("You are already in the Tribu")
      };
}
