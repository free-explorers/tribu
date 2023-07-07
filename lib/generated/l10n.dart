// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Create a Tribu`
  String get createATribuAction {
    return Intl.message(
      'Create a Tribu',
      name: 'createATribuAction',
      desc: '',
      args: [],
    );
  }

  /// `Join a Tribu`
  String get joinATribuAction {
    return Intl.message(
      'Join a Tribu',
      name: 'joinATribuAction',
      desc: '',
      args: [],
    );
  }

  /// `Pick a name for your future Tribu`
  String get tribeNameInstruction {
    return Intl.message(
      'Pick a name for your future Tribu',
      name: 'tribeNameInstruction',
      desc: '',
      args: [],
    );
  }

  /// `Member list`
  String get memberListPageTitle {
    return Intl.message(
      'Member list',
      name: 'memberListPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `New Members`
  String get nameOfNewMembersNotifications {
    return Intl.message(
      'New Members',
      name: 'nameOfNewMembersNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Past an invitation link here`
  String get pastAnInvitationLinkHere {
    return Intl.message(
      'Past an invitation link here',
      name: 'pastAnInvitationLinkHere',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get thisFieldIsRequired {
    return Intl.message(
      'This field is required',
      name: 'thisFieldIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `The link is not recognized`
  String get theLinkIsNotRecognized {
    return Intl.message(
      'The link is not recognized',
      name: 'theLinkIsNotRecognized',
      desc: '',
      args: [],
    );
  }

  /// `Link is invalid`
  String get linkIsInvalid {
    return Intl.message(
      'Link is invalid',
      name: 'linkIsInvalid',
      desc: '',
      args: [],
    );
  }

  /// `You are already in the Tribu`
  String get youAreAlreadyInTheTribu {
    return Intl.message(
      'You are already in the Tribu',
      name: 'youAreAlreadyInTheTribu',
      desc: '',
      args: [],
    );
  }

  /// `In order to join a Tribu you need to ask an invitation link from a member`
  String get joinATribeLinkInstruction {
    return Intl.message(
      'In order to join a Tribu you need to ask an invitation link from a member',
      name: 'joinATribeLinkInstruction',
      desc: '',
      args: [],
    );
  }

  /// `You are about to join the Tribu`
  String get youAreAboutToJoinTheTribu {
    return Intl.message(
      'You are about to join the Tribu',
      name: 'youAreAboutToJoinTheTribu',
      desc: '',
      args: [],
    );
  }

  /// `Join the Tribu`
  String get joinTheTribu {
    return Intl.message(
      'Join the Tribu',
      name: 'joinTheTribu',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a name for your Tribu`
  String get tribuNameFormError {
    return Intl.message(
      'Please enter a name for your Tribu',
      name: 'tribuNameFormError',
      desc: '',
      args: [],
    );
  }

  /// `Pick your name in the tribe`
  String get howShouldWeCallYou {
    return Intl.message(
      'Pick your name in the tribe',
      name: 'howShouldWeCallYou',
      desc: '',
      args: [],
    );
  }

  /// `Pick a name`
  String get howShouldWeCallHim {
    return Intl.message(
      'Pick a name',
      name: 'howShouldWeCallHim',
      desc: '',
      args: [],
    );
  }

  /// `Ex: The Flintstones`
  String get tribuNameFormPlaceholder {
    return Intl.message(
      'Ex: The Flintstones',
      name: 'tribuNameFormPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Ex : Angelo Stralopitecus`
  String get memberNameFormPlaceholder {
    return Intl.message(
      'Ex : Angelo Stralopitecus',
      name: 'memberNameFormPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a name`
  String get memberNameFormError {
    return Intl.message(
      'Please enter a name',
      name: 'memberNameFormError',
      desc: '',
      args: [],
    );
  }

  /// `Create the Tribu`
  String get createTheTribuAction {
    return Intl.message(
      'Create the Tribu',
      name: 'createTheTribuAction',
      desc: '',
      args: [],
    );
  }

  /// `Join the Tribu "{tribuName}" at {tribuLink}`
  String inviteLinkText(Object tribuName, Object tribuLink) {
    return Intl.message(
      'Join the Tribu "$tribuName" at $tribuLink',
      name: 'inviteLinkText',
      desc: '',
      args: [tribuName, tribuLink],
    );
  }

  /// `Add a tool`
  String get newToolAction {
    return Intl.message(
      'Add a tool',
      name: 'newToolAction',
      desc: '',
      args: [],
    );
  }

  /// `Shared List`
  String get listToolName {
    return Intl.message(
      'Shared List',
      name: 'listToolName',
      desc: '',
      args: [],
    );
  }

  /// `Shoppings, to-dos, reminders, etc.. `
  String get listToolExamples {
    return Intl.message(
      'Shoppings, to-dos, reminders, etc.. ',
      name: 'listToolExamples',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get createAction {
    return Intl.message(
      'Create',
      name: 'createAction',
      desc: '',
      args: [],
    );
  }

  /// `Expenses manager`
  String get expenseToolName {
    return Intl.message(
      'Expenses manager',
      name: 'expenseToolName',
      desc: '',
      args: [],
    );
  }

  /// `Balance debts automatically`
  String get expenseToolDescription {
    return Intl.message(
      'Balance debts automatically',
      name: 'expenseToolDescription',
      desc: '',
      args: [],
    );
  }

  /// `Shopping list`
  String get listToolShoppingListName {
    return Intl.message(
      'Shopping list',
      name: 'listToolShoppingListName',
      desc: '',
      args: [],
    );
  }

  /// `To-do list`
  String get listToolTodoListName {
    return Intl.message(
      'To-do list',
      name: 'listToolTodoListName',
      desc: '',
      args: [],
    );
  }

  /// `Idea list`
  String get listToolIdeaListName {
    return Intl.message(
      'Idea list',
      name: 'listToolIdeaListName',
      desc: '',
      args: [],
    );
  }

  /// `Luggage list`
  String get listToolLuggageListName {
    return Intl.message(
      'Luggage list',
      name: 'listToolLuggageListName',
      desc: '',
      args: [],
    );
  }

  /// `List name`
  String get listNamePlaceholder {
    return Intl.message(
      'List name',
      name: 'listNamePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get expensesToolNamePlaceholder {
    return Intl.message(
      'Name',
      name: 'expensesToolNamePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Currency`
  String get currency {
    return Intl.message(
      'Currency',
      name: 'currency',
      desc: '',
      args: [],
    );
  }

  /// `My total cost`
  String get userTotalCost {
    return Intl.message(
      'My total cost',
      name: 'userTotalCost',
      desc: '',
      args: [],
    );
  }

  /// `My balance`
  String get userBalance {
    return Intl.message(
      'My balance',
      name: 'userBalance',
      desc: '',
      args: [],
    );
  }

  /// `Most indebted`
  String get mostIndebted {
    return Intl.message(
      'Most indebted',
      name: 'mostIndebted',
      desc: '',
      args: [],
    );
  }

  /// `Hide all`
  String get hideAll {
    return Intl.message(
      'Hide all',
      name: 'hideAll',
      desc: '',
      args: [],
    );
  }

  /// `View all`
  String get viewAll {
    return Intl.message(
      'View all',
      name: 'viewAll',
      desc: '',
      args: [],
    );
  }

  /// `Smart balance`
  String get balanceAction {
    return Intl.message(
      'Smart balance',
      name: 'balanceAction',
      desc: '',
      args: [],
    );
  }

  /// `Add an expense`
  String get newExpenseAction {
    return Intl.message(
      'Add an expense',
      name: 'newExpenseAction',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get editAction {
    return Intl.message(
      'Edit',
      name: 'editAction',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get deleteAction {
    return Intl.message(
      'Delete',
      name: 'deleteAction',
      desc: '',
      args: [],
    );
  }

  /// `Expenses`
  String get expensesSubHeader {
    return Intl.message(
      'Expenses',
      name: 'expensesSubHeader',
      desc: '',
      args: [],
    );
  }

  /// `Edit expense`
  String get editExpenseAction {
    return Intl.message(
      'Edit expense',
      name: 'editExpenseAction',
      desc: '',
      args: [],
    );
  }

  /// `Label`
  String get expenseLabel {
    return Intl.message(
      'Label',
      name: 'expenseLabel',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get amount {
    return Intl.message(
      'Amount',
      name: 'amount',
      desc: '',
      args: [],
    );
  }

  /// `Paid by`
  String get paidBy {
    return Intl.message(
      'Paid by',
      name: 'paidBy',
      desc: '',
      args: [],
    );
  }

  /// `Paid for`
  String get paidFor {
    return Intl.message(
      'Paid for',
      name: 'paidFor',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancelAction {
    return Intl.message(
      'Cancel',
      name: 'cancelAction',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get updateAction {
    return Intl.message(
      'Update',
      name: 'updateAction',
      desc: '',
      args: [],
    );
  }

  /// `Everyone`
  String get everyone {
    return Intl.message(
      'Everyone',
      name: 'everyone',
      desc: '',
      args: [],
    );
  }

  /// `Add an item`
  String get newListItemPlaceholder {
    return Intl.message(
      'Add an item',
      name: 'newListItemPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Send a message`
  String get newChatMessageAction {
    return Intl.message(
      'Send a message',
      name: 'newChatMessageAction',
      desc: '',
      args: [],
    );
  }

  /// `Notification when new member joined the Tribu`
  String get newMemberNotificationDescription {
    return Intl.message(
      'Notification when new member joined the Tribu',
      name: 'newMemberNotificationDescription',
      desc: '',
      args: [],
    );
  }

  /// `New members`
  String get newMemberNotificationTitle {
    return Intl.message(
      'New members',
      name: 'newMemberNotificationTitle',
      desc: '',
      args: [],
    );
  }

  /// `{newMemberName} has joined the Tribu`
  String newMemberNotificationContent(Object newMemberName) {
    return Intl.message(
      '$newMemberName has joined the Tribu',
      name: 'newMemberNotificationContent',
      desc: '',
      args: [newMemberName],
    );
  }

  /// `Chat in the Tribu`
  String get chatNotificationDescription {
    return Intl.message(
      'Chat in the Tribu',
      name: 'chatNotificationDescription',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chatNotificationTitle {
    return Intl.message(
      'Chat',
      name: 'chatNotificationTitle',
      desc: '',
      args: [],
    );
  }

  /// `Welcome in your Tribu !\nYou can now invite more members to join and get the benefit of convenient tools right now !`
  String get welcomeMessageFirstMember {
    return Intl.message(
      'Welcome in your Tribu !\nYou can now invite more members to join and get the benefit of convenient tools right now !',
      name: 'welcomeMessageFirstMember',
      desc: '',
      args: [],
    );
  }

  /// `Welcome in your Tribu !\nYou can now say hello to others members and get the benefit of awesome tools right now !`
  String get welcomeMessageWithExistingMembers {
    return Intl.message(
      'Welcome in your Tribu !\nYou can now say hello to others members and get the benefit of awesome tools right now !',
      name: 'welcomeMessageWithExistingMembers',
      desc: '',
      args: [],
    );
  }

  /// `Confirm selection`
  String get selectionAction {
    return Intl.message(
      'Confirm selection',
      name: 'selectionAction',
      desc: '',
      args: [],
    );
  }

  /// `Member list`
  String get memberListTitle {
    return Intl.message(
      'Member list',
      name: 'memberListTitle',
      desc: '',
      args: [],
    );
  }

  /// `Edit list`
  String get editList {
    return Intl.message(
      'Edit list',
      name: 'editList',
      desc: '',
      args: [],
    );
  }

  /// `Edit tool`
  String get editToolDialogTitle {
    return Intl.message(
      'Edit tool',
      name: 'editToolDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure?`
  String get confirmDialogTitle {
    return Intl.message(
      'Are you sure?',
      name: 'confirmDialogTitle',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirmAction {
    return Intl.message(
      'Confirm',
      name: 'confirmAction',
      desc: '',
      args: [],
    );
  }

  /// `Leave the Tribu`
  String get leaveTribuAction {
    return Intl.message(
      'Leave the Tribu',
      name: 'leaveTribuAction',
      desc: '',
      args: [],
    );
  }

  /// `You need to have some expenses to use the Smart Balance feature!`
  String get noExpenseSmartBalance {
    return Intl.message(
      'You need to have some expenses to use the Smart Balance feature!',
      name: 'noExpenseSmartBalance',
      desc: '',
      args: [],
    );
  }

  /// `To view this tool you need to update Tribu`
  String get updateToViewTool {
    return Intl.message(
      'To view this tool you need to update Tribu',
      name: 'updateToViewTool',
      desc: '',
      args: [],
    );
  }

  /// `Upgrading Tribu is required to continue`
  String get upgradingAppRequired {
    return Intl.message(
      'Upgrading Tribu is required to continue',
      name: 'upgradingAppRequired',
      desc: '',
      args: [],
    );
  }

  /// `Update Tribu application`
  String get updateTribuAction {
    return Intl.message(
      'Update Tribu application',
      name: 'updateTribuAction',
      desc: '',
      args: [],
    );
  }

  /// `Thanks to send {number} files maximum per message`
  String maximumFilePerMessage(Object number) {
    return Intl.message(
      'Thanks to send $number files maximum per message',
      name: 'maximumFilePerMessage',
      desc: '',
      args: [number],
    );
  }

  /// `Image saved to gallery`
  String get imageSavedToGallery {
    return Intl.message(
      'Image saved to gallery',
      name: 'imageSavedToGallery',
      desc: '',
      args: [],
    );
  }

  /// `Merge members`
  String get mergeProfilesAction {
    return Intl.message(
      'Merge members',
      name: 'mergeProfilesAction',
      desc: '',
      args: [],
    );
  }

  /// `Remove members`
  String get removeProfilesAction {
    return Intl.message(
      'Remove members',
      name: 'removeProfilesAction',
      desc: '',
      args: [],
    );
  }

  /// `Select a member`
  String get selectAProfileAction {
    return Intl.message(
      'Select a member',
      name: 'selectAProfileAction',
      desc: '',
      args: [],
    );
  }

  /// `Select members`
  String get selectProfilesAction {
    return Intl.message(
      'Select members',
      name: 'selectProfilesAction',
      desc: '',
      args: [],
    );
  }

  /// `Members to keep`
  String get profileToKeepAction {
    return Intl.message(
      'Members to keep',
      name: 'profileToKeepAction',
      desc: '',
      args: [],
    );
  }

  /// `Add external member`
  String get addExternalMemberAction {
    return Intl.message(
      'Add external member',
      name: 'addExternalMemberAction',
      desc: '',
      args: [],
    );
  }

  /// `When you want to add a profile for someone not currently using Tribu`
  String get externalMemberBlaming {
    return Intl.message(
      'When you want to add a profile for someone not currently using Tribu',
      name: 'externalMemberBlaming',
      desc: '',
      args: [],
    );
  }

  /// `A file is larger than the {size}mb limit`
  String aFileIsLargerThanTheLimit(Object size) {
    return Intl.message(
      'A file is larger than the ${size}mb limit',
      name: 'aFileIsLargerThanTheLimit',
      desc: '',
      args: [size],
    );
  }

  /// `Copy content`
  String get copyAction {
    return Intl.message(
      'Copy content',
      name: 'copyAction',
      desc: '',
      args: [],
    );
  }

  /// `Remove for me`
  String get removeMessageAction {
    return Intl.message(
      'Remove for me',
      name: 'removeMessageAction',
      desc: '',
      args: [],
    );
  }

  /// `Message selected`
  String get messageSelectedTitle {
    return Intl.message(
      'Message selected',
      name: 'messageSelectedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Vote in progress`
  String get eventDateVoteInProgress {
    return Intl.message(
      'Vote in progress',
      name: 'eventDateVoteInProgress',
      desc: '',
      args: [],
    );
  }

  /// `Pick a date`
  String get pickInitialDate {
    return Intl.message(
      'Pick a date',
      name: 'pickInitialDate',
      desc: '',
      args: [],
    );
  }

  /// `Add alternative date`
  String get pickAdditionnalDate {
    return Intl.message(
      'Add alternative date',
      name: 'pickAdditionnalDate',
      desc: '',
      args: [],
    );
  }

  /// `Stay`
  String get stayEventTypeTitle {
    return Intl.message(
      'Stay',
      name: 'stayEventTypeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Event that last for a period of time`
  String get stayEventTypeDescription {
    return Intl.message(
      'Event that last for a period of time',
      name: 'stayEventTypeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Punctual`
  String get punctualEventTypeTitle {
    return Intl.message(
      'Punctual',
      name: 'punctualEventTypeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Event that occur on a specific date`
  String get punctualEventTypeDescription {
    return Intl.message(
      'Event that occur on a specific date',
      name: 'punctualEventTypeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Permanent`
  String get permanentEventTypeTitle {
    return Intl.message(
      'Permanent',
      name: 'permanentEventTypeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Recurring event or event that never expire`
  String get permanentEventTypeDescription {
    return Intl.message(
      'Recurring event or event that never expire',
      name: 'permanentEventTypeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Pick a date range`
  String get pickInitialDateRange {
    return Intl.message(
      'Pick a date range',
      name: 'pickInitialDateRange',
      desc: '',
      args: [],
    );
  }

  /// `Add alternative range`
  String get pickAdditionnalDateRange {
    return Intl.message(
      'Add alternative range',
      name: 'pickAdditionnalDateRange',
      desc: '',
      args: [],
    );
  }

  /// `Add an event`
  String get newEventAction {
    return Intl.message(
      'Add an event',
      name: 'newEventAction',
      desc: '',
      args: [],
    );
  }

  /// `Date proposals`
  String get dateProposalsPageTitle {
    return Intl.message(
      'Date proposals',
      name: 'dateProposalsPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get closeAction {
    return Intl.message(
      'Close',
      name: 'closeAction',
      desc: '',
      args: [],
    );
  }

  /// `Daily routine`
  String get defaultPermanentEventName {
    return Intl.message(
      'Daily routine',
      name: 'defaultPermanentEventName',
      desc: '',
      args: [],
    );
  }

  /// `Edit Event`
  String get editEventAction {
    return Intl.message(
      'Edit Event',
      name: 'editEventAction',
      desc: '',
      args: [],
    );
  }

  /// `Delete Event`
  String get deleteEventAction {
    return Intl.message(
      'Delete Event',
      name: 'deleteEventAction',
      desc: '',
      args: [],
    );
  }

  /// `Manage tools`
  String get manageToolsAction {
    return Intl.message(
      'Manage tools',
      name: 'manageToolsAction',
      desc: '',
      args: [],
    );
  }

  /// `You are invited to this event!`
  String get eventInvitationTitle {
    return Intl.message(
      'You are invited to this event!',
      name: 'eventInvitationTitle',
      desc: '',
      args: [],
    );
  }

  /// `You won't attend to this event`
  String get eventInvitationDeclinedTitle {
    return Intl.message(
      'You won\'t attend to this event',
      name: 'eventInvitationDeclinedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Will you attend?`
  String get willYouAttend {
    return Intl.message(
      'Will you attend?',
      name: 'willYouAttend',
      desc: '',
      args: [],
    );
  }

  /// `{proposalLength} propositions`
  String dateproposallistlengthPropositions(Object proposalLength) {
    return Intl.message(
      '$proposalLength propositions',
      name: 'dateproposallistlengthPropositions',
      desc: '',
      args: [proposalLength],
    );
  }

  /// `With {toolLength} tools`
  String toolsLengthText(Object toolLength) {
    return Intl.message(
      'With $toolLength tools',
      name: 'toolsLengthText',
      desc: '',
      args: [toolLength],
    );
  }

  /// `Vote for the best suited dates for you and when you are ready click a date to select it`
  String get dateProposalPageDescription {
    return Intl.message(
      'Vote for the best suited dates for you and when you are ready click a date to select it',
      name: 'dateProposalPageDescription',
      desc: '',
      args: [],
    );
  }

  /// `Attendees presence confirmed`
  String get attendeesPresencePageTitle {
    return Intl.message(
      'Attendees presence confirmed',
      name: 'attendeesPresencePageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get ChatPageTitle {
    return Intl.message(
      'Chat',
      name: 'ChatPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Events`
  String get eventsPageTitle {
    return Intl.message(
      'Events',
      name: 'eventsPageTitle',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get titlePlaceholder {
    return Intl.message(
      'Title',
      name: 'titlePlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Attendees`
  String get attendeesPlaceholder {
    return Intl.message(
      'Attendees',
      name: 'attendeesPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Confirm changes`
  String get confirmChangesAction {
    return Intl.message(
      'Confirm changes',
      name: 'confirmChangesAction',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
