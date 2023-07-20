import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tribu/generated/l10n.dart';

class ChatTextInput extends HookWidget {
  const ChatTextInput({
    required this.onNewText,
    required this.onPlusButtonTapped,
    this.onFocusChanged,
    super.key,
  });
  static final _radiusTween = Tween<double>(begin: 16, end: 0);
  static final _marginTween = Tween<double>(begin: 16, end: 0);

  final void Function(String text) onNewText;
  final void Function() onPlusButtonTapped;

  final void Function({required bool hasFocus})? onFocusChanged;

  @override
  Widget build(BuildContext context) {
    final controller =
        useAnimationController(duration: const Duration(milliseconds: 200));
    final scrollController = useScrollController();
    final textEditingController = useTextEditingController();
    final focusNode = useFocusNode();

    useEffect(() {
      void cb() {
        onFocusChanged?.call(hasFocus: focusNode.hasPrimaryFocus);
      }

      focusNode.addListener(cb);

      return () {
        focusNode.removeListener(cb);
      };
    });

    final style = Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(color: Theme.of(context).colorScheme.onPrimary);

    final yOffset = useState<double>(0);
    final textField = TextField(
      textCapitalization: TextCapitalization.sentences,
      controller: textEditingController,
      scrollController: scrollController,
      style: style,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      focusNode: focusNode,
      scrollPadding: const EdgeInsets.symmetric(vertical: 6),
      decoration: InputDecoration(
        filled: false,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: const OutlineInputBorder(borderSide: BorderSide.none),
        focusColor: Theme.of(context).colorScheme.secondary,
        labelText: S.of(context).newChatMessageAction,
        labelStyle: style,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      cursorColor: Theme.of(context).colorScheme.secondary,
    );
    textEditingController.addListener(() {
      _updateCaretOffset(
        textEditingController,
        textField,
        style,
        textEditingController.text,
        yOffset,
      );
    });
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return KeyboardVisibilityBuilder(
          builder: (context, isKeyboardVisible) {
            if (isKeyboardVisible) {
              controller.forward();
            } else {
              controller.reverse();
              focusNode.unfocus();
              if (scrollController.hasClients) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  //scrollController.jumpTo(yOffset.value);
                });
              }
            }
            return Positioned(
              bottom: _marginTween.evaluate(controller),
              right: _marginTween.evaluate(controller),
              child: Row(
                children: [
                  FloatingActionButton(
                    //This is used to disable animation of the FAB when
                    // navigating to another screen with also a FAB
                    heroTag: null,
                    onPressed: onPlusButtonTapped,
                    elevation: 4,
                    child: Icon(MdiIcons.plus),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Container(
                    constraints: BoxConstraints(
                      //maxHeight: _maxHeightTween.evaluate(controller),
                      maxWidth: Tween<double>(
                        begin: MediaQuery.of(context).size.width - 100,
                        end: MediaQuery.of(context).size.width,
                      ).evaluate(controller),
                      minWidth: Tween<double>(
                        begin: 0,
                        end: MediaQuery.of(context).size.width,
                      ).evaluate(controller),
                      minHeight: 56,
                    ),
                    child: Material(
                      color: Theme.of(context).colorScheme.primary,
                      elevation: 4,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          _radiusTween.evaluate(controller),
                        ),
                        bottomLeft: Radius.circular(
                          _radiusTween.evaluate(controller),
                        ),
                        topRight: Radius.circular(
                          _radiusTween.evaluate(controller),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(child: textField),
                          ClipOval(
                            child: Material(
                              color: Colors.transparent,
                              child: IconButton(
                                icon: Icon(
                                  !isKeyboardVisible
                                      ? MdiIcons.messageText
                                      : MdiIcons.send,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                onPressed: () {
                                  if (!focusNode.hasFocus) {
                                    focusNode.requestFocus();
                                  } else {
                                    onNewText(
                                      textEditingController.value.text,
                                    );
                                    textEditingController.clear();
                                    //focusNode.unfocus();
                                  }
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updateCaretOffset(
    TextEditingController textFieldController,
    TextField textField,
    TextStyle textFieldStyle,
    String text,
    ValueNotifier<dynamic> notifier,
  ) {
    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: textFieldStyle,
        text: text,
      ),
    )..layout();

    final cursorTextPosition = textFieldController.selection.base;
    final caretPrototype = Rect.fromLTWH(
      0,
      0,
      textField.cursorWidth,
      textField.cursorHeight ?? 0,
    );
    final caretOffset =
        painter.getOffsetForCaret(cursorTextPosition, caretPrototype);

    if (caretOffset.dy != 0.0) {
      notifier.value = caretOffset.dy;
    }
    /* setState(() {
      xCaret = caretOffset.dx;
      yCaret = caretOffset.dy;
      painterWidth = painter.width;
      painterHeight = painter.height;
      preferredLineHeight = painter.preferredLineHeight;
    }); */
  }
}
