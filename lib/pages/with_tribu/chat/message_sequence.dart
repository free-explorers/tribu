import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tribu/data/common.providers.dart';
import 'package:tribu/data/tribu/message/message.model.dart';
import 'package:tribu/data/tribu/message/message_map.notifier.dart';
import 'package:tribu/pages/media_viewer.page.dart';
import 'package:tribu/widgets/media/media_list_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageSequence extends HookConsumerWidget {
  const MessageSequence({
    required this.messageList,
    required this.backgroundColor,
    super.key,
    this.color,
    this.linkColor,
    this.flipHorizontal = false,
    this.header,
  });
  final List<Message> messageList;
  final Color backgroundColor;
  final Color? color;
  final Color? linkColor;

  final bool flipHorizontal;
  final Widget? header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment:
          flipHorizontal ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...messageList.map((message) {
          final isFirst = messageList.first == message;
          return Container(
            padding: !isFirst ? const EdgeInsets.only(top: 2) : EdgeInsets.zero,
            child: Material(
              color: backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: isFirst || flipHorizontal
                    ? const Radius.circular(16)
                    : Radius.zero,
                bottomRight:
                    flipHorizontal ? Radius.zero : const Radius.circular(16),
                bottomLeft:
                    !flipHorizontal ? Radius.zero : const Radius.circular(16),
                topRight: isFirst || !flipHorizontal
                    ? const Radius.circular(16)
                    : Radius.zero,
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                highlightColor: backgroundColor.withOpacity(0.2),
                onLongPress: () {
                  MessageMapNotifier.showSelectedMessageModal(
                    context,
                    ref,
                    message,
                  );
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 100,
                  ),
                  child: Column(
                    crossAxisAlignment: flipHorizontal
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (header != null && isFirst)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 16,
                            end: 16,
                            top: 8,
                          ),
                          child: header,
                        ),
                      if (message.mediaList != null)
                        Padding(
                          padding: EdgeInsets.only(
                            top: (header != null && isFirst) ? 8.0 : 0.0,
                          ),
                          child: message.status == 'processingMedia'
                              ? Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                )
                              : MediaListViewer(
                                  message.id!,
                                  message.mediaList!,
                                  onMediaTap: (index) {
                                    final mediaSelected =
                                        message.mediaList!.elementAt(index);
                                    final mediaDownloadedList =
                                        message.mediaList!
                                            .where(
                                              (element) =>
                                                  element.localPath != null,
                                            )
                                            .toList();
                                    ref.read(pageListProvider.notifier).push(
                                          MaterialPage(
                                            key: const ValueKey('mediaViewer'),
                                            child: MediaViewerPage(
                                              mediaDownloadedList,
                                              mediaDownloadedList.indexOf(
                                                mediaSelected,
                                              ),
                                            ),
                                          ),
                                        );
                                  },
                                ),
                        ),
                      if (message.mediaList == null && message.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 16,
                            end: 16,
                            top: 8,
                            bottom: 8,
                          ),
                          child: Linkify(
                            onOpen: (link) async {
                              final uri = Uri.parse(link.url);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                throw 'Could not launch $link';
                              }
                            },
                            text: message.text,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(color: color),
                            linkStyle: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: linkColor,
                                  decoration: TextDecoration.underline,
                                ),
                            linkifiers: const [
                              EmailLinkifier(),
                              UrlLinkifier()
                            ],
                          ),
                        ),
                      if (message.status == 'error')
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.red,
                          child: Text(
                            message.status,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(color: Colors.white),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
          );
        })
      ],
    );
  }
}
