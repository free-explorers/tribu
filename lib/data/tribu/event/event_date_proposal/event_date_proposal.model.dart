import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_date_proposal.model.freezed.dart';
part 'event_date_proposal.model.g.dart';

@freezed
class EventDateProposal with _$EventDateProposal {
  factory EventDateProposal.punctual({
    required DateTime date,
    required bool isTimeDisplayed,
    required List<String> attendeeVoteList,
    required bool selected,
  }) = PunctualDateProposal;

  factory EventDateProposal.stay({
    required DateTime startDate,
    required DateTime endDate,
    required List<String> attendeeVoteList,
    required bool selected,
  }) = StayDateProposal;

  factory EventDateProposal.fromJson(Map<String, dynamic> json) =>
      _$EventDateProposalFromJson(json);
}
