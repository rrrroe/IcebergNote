import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'record_input.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:html/parser.dart';
import 'package:flutter/material.dart' hide Element;
import 'package:html/dom.dart' hide Text;

class RichEditorPage extends StatefulWidget {
  const RichEditorPage({super.key});

  @override
  RichEditorPageState createState() => RichEditorPageState();
}

class RichEditorPageState extends State<RichEditorPage> {
  final MyTextSelectionControls _myExtendedMaterialTextSelectionControls =
      MyTextSelectionControls();
  final MySpecialTextSpanBuilder _mySpecialTextSpanBuilder =
      MySpecialTextSpanBuilder();
  TextEditingController controller = TextEditingController()
    ..text =
        '[33]Extended text field help you to build rich text quickly. any special text you will have with extended text. this is demo to show how to create custom toolbar and handles.'
            '\n\nIt\'s my pleasure to invite you to join \$FlutterCandies\$ if you want to improve flutter .[36]'
            '\n\nif you meet any problem, please let me konw @zmtzawqlp .[44]';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('custom selection toolbar handles'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Center(
          child: ExtendedTextField(
            selectionControls: _myExtendedMaterialTextSelectionControls,
            specialTextSpanBuilder: _mySpecialTextSpanBuilder,
            extendedContextMenuBuilder:
                MyTextSelectionControls.defaultContextMenuBuilder,
            controller: controller,
            maxLines: null,
            // StrutStyle get strutStyle {
            //   if (_strutStyle == null) {
            //     return StrutStyle.fromTextStyle(style, forceStrutHeight: true);
            //   }
            //   return _strutStyle!.inheritFromTextStyle(style);
            // }
            // default strutStyle is not good for WidgetSpan
            strutStyle: const StrutStyle(),
            // shouldShowSelectionHandles: _shouldShowSelectionHandles,
            // textSelectionGestureDetectorBuilder: ({
            //   required ExtendedTextSelectionGestureDetectorBuilderDelegate
            //       delegate,
            //   required Function showToolbar,
            //   required Function hideToolbar,
            //   required Function? onTap,
            //   required BuildContext context,
            //   required Function? requestKeyboard,
            // }) {
            //   return MyCommonTextSelectionGestureDetectorBuilder(
            //     delegate: delegate,
            //     showToolbar: showToolbar,
            //     hideToolbar: hideToolbar,
            //     onTap: onTap,
            //     context: context,
            //     requestKeyboard: requestKeyboard,
            //   );
            // },
          ),
        ),
      ),
    );
  }
}

const double _kHandleSize = 22.0;

/// Android Material styled text selection controls.
class MyTextSelectionControls extends TextSelectionControls
    with TextSelectionHandleControls {
  static Widget defaultContextMenuBuilder(
      BuildContext context, ExtendedEditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar.buttonItems(
      buttonItems: <ContextMenuButtonItem>[
        ...editableTextState.contextMenuButtonItems,
        ContextMenuButtonItem(
          onPressed: () {
            launchUrl(
              Uri.parse(
                'mailto:zmtzawqlp@live.com?subject=extended_text_share&body=${editableTextState.textEditingValue.text}',
              ),
            );
            editableTextState.hideToolbar(true);
            editableTextState.textEditingValue
                .copyWith(selection: const TextSelection.collapsed(offset: 0));
          },
          type: ContextMenuButtonType.custom,
          label: 'like',
        ),
      ],
      anchors: editableTextState.contextMenuAnchors,
    );
    // return AdaptiveTextSelectionToolbar.editableText(
    //   editableTextState: editableTextState,
    // );
  }

  /// Returns the size of the Material handle.
  @override
  Size getHandleSize(double textLineHeight) =>
      const Size(_kHandleSize, _kHandleSize);

  /// Builder for material-style text selection handles.
  @override
  Widget buildHandle(
      BuildContext context, TextSelectionHandleType type, double textLineHeight,
      [VoidCallback? onTap, double? startGlyphHeight, double? endGlyphHeight]) {
    final Widget handle = SizedBox(
      width: _kHandleSize,
      height: _kHandleSize,
      child: Image.asset(
        'lib/assets/emoji/40.png',
      ),
    );

    // [handle] is a circle, with a rectangle in the top left quadrant of that
    // circle (an onion pointing to 10:30). We rotate [handle] to point
    // straight up or up-right depending on the handle type.
    switch (type) {
      case TextSelectionHandleType.left: // points up-right
        return Transform.rotate(
          angle: pi / 4.0,
          child: handle,
        );
      case TextSelectionHandleType.right: // points up-left
        return Transform.rotate(
          angle: -pi / 4.0,
          child: handle,
        );
      case TextSelectionHandleType.collapsed: // points up
        return handle;
    }
  }

  /// Gets anchor for material-style text selection handles.
  ///
  /// See [TextSelectionControls.getHandleAnchor].
  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight,
      [double? startGlyphHeight, double? endGlyphHeight]) {
    switch (type) {
      case TextSelectionHandleType.left:
        return const Offset(_kHandleSize, 0);
      case TextSelectionHandleType.right:
        return Offset.zero;
      default:
        return const Offset(_kHandleSize / 2, -4);
    }
  }

  @override
  bool canSelectAll(TextSelectionDelegate delegate) {
    // Android allows SelectAll when selection is not collapsed, unless
    // everything has already been selected.
    final TextEditingValue value = delegate.textEditingValue;
    return delegate.selectAllEnabled &&
        value.text.isNotEmpty &&
        !(value.selection.start == 0 &&
            value.selection.end == value.text.length);
  }
}

class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  MySpecialTextSpanBuilder({this.showAtBackground = false});

  /// whether show background for @somebody
  final bool showAtBackground;

  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle,
      SpecialTextGestureTapCallback? onTap,
      int? index}) {
    if (flag == '') {
      return null;
    }

    ///index is end index of start flag, so text start index should be index-(flag.length-1)
    if (isStart(flag, EmojiText.flag)) {
      return EmojiText(textStyle, start: index! - (EmojiText.flag.length - 1));
    } else if (isStart(flag, ImageText.flag)) {
      return ImageText(textStyle,
          start: index! - (ImageText.flag.length - 1), onTap: onTap);
    } else if (isStart(flag, AtText.flag)) {
      return AtText(
        textStyle,
        onTap,
        start: index! - (AtText.flag.length - 1),
        showAtBackground: showAtBackground,
      );
    } else if (isStart(flag, EmojiText.flag)) {
      return EmojiText(textStyle, start: index! - (EmojiText.flag.length - 1));
    } else if (isStart(flag, DollarText.flag)) {
      return DollarText(textStyle, onTap,
          start: index! - (DollarText.flag.length - 1));
    }
    return null;
  }
}

class EmojiText extends SpecialText {
  EmojiText(TextStyle? textStyle, {this.start})
      : super(EmojiText.flag, ']', textStyle);
  static const String flag = '[';
  final int? start;
  @override
  InlineSpan finishText() {
    final String key = toString();

    if (EmojiUitl.instance.emojiMap.containsKey(key)) {
      double size = 18;

      if (textStyle.fontSize != null) {
        size = textStyle.fontSize! * 1.15;
      }

      return ImageSpan(
          AssetImage(
            EmojiUitl.instance.emojiMap[key]!,
          ),
          actualText: key,
          imageWidth: size,
          imageHeight: size,
          start: start!,
          //fit: BoxFit.fill,
          margin: const EdgeInsets.all(2));
    }

    return TextSpan(text: toString(), style: textStyle);
  }
}

class EmojiUitl {
  EmojiUitl._() {
    for (int i = 1; i < 49; i++) {
      _emojiMap['[$i]'] = '$_emojiFilePath/$i.png';
    }
  }

  final Map<String, String> _emojiMap = <String, String>{};

  Map<String, String> get emojiMap => _emojiMap;

  final String _emojiFilePath = 'lib/assets/emoji';

  static EmojiUitl? _instance;
  static EmojiUitl get instance => _instance ??= EmojiUitl._();
}

class AtText extends SpecialText {
  AtText(TextStyle? textStyle, SpecialTextGestureTapCallback? onTap,
      {this.showAtBackground = false, this.start})
      : super(flag, ' ', textStyle, onTap: onTap);
  static const String flag = '@';
  final int? start;

  /// whether show background for @somebody
  final bool showAtBackground;

  @override
  InlineSpan finishText() {
    final TextStyle? textStyle =
        this.textStyle?.copyWith(color: Colors.blue, fontSize: 16.0);

    final String atText = toString();

    return showAtBackground
        ? BackgroundTextSpan(
            background: Paint()..color = Colors.blue.withOpacity(0.15),
            text: atText,
            actualText: atText,
            start: start!,

            ///caret can move into special text
            deleteAll: true,
            style: textStyle,
            recognizer: (TapGestureRecognizer()
              ..onTap = () {
                if (onTap != null) {
                  onTap!(atText);
                }
              }))
        : SpecialTextSpan(
            text: atText,
            actualText: atText,
            start: start!,
            style: textStyle,
            recognizer: (TapGestureRecognizer()
              ..onTap = () {
                if (onTap != null) {
                  onTap!(atText);
                }
              }));
  }
}

List<String> atList = <String>[
  '@Nevermore ',
  '@Dota2 ',
  '@Biglao ',
  '@艾莉亚·史塔克 ',
  '@丹妮莉丝 ',
  '@HandPulledNoodles ',
  '@Zmtzawqlp ',
  '@FaDeKongJian ',
  '@CaiJingLongDaLao ',
];

class ImageText extends SpecialText {
  ImageText(TextStyle? textStyle,
      {this.start, SpecialTextGestureTapCallback? onTap})
      : super(
          ImageText.flag,
          '/>',
          textStyle,
          onTap: onTap,
        );

  static const String flag = '<img';
  final int? start;
  String? _imageUrl;
  String? get imageUrl => _imageUrl;
  @override
  InlineSpan finishText() {
    ///content already has endflag '/'
    final String text = toString();

    ///'<img src='$url'/>'
//    var index1 = text.indexOf(''') + 1;
//    var index2 = text.indexOf(''', index1);
//
//    var url = text.substring(index1, index2);
//
    ////'<img src='$url' width='${item.imageSize.width}' height='${item.imageSize.height}'/>'
    final Document html = parse(text);

    final Element img = html.getElementsByTagName('img').first;
    final String url = img.attributes['src']!;
    _imageUrl = url;

    //fontsize id define image height
    //size = 30.0/26.0 * fontSize
    double? width = 60.0;
    double? height = 60.0;
    const BoxFit fit = BoxFit.cover;
    const double num300 = 60.0;
    const double num400 = 80.0;

    height = num300;
    width = num400;
    const bool knowImageSize = true;
    if (knowImageSize) {
      height = double.tryParse(img.attributes['height']!);
      width = double.tryParse(img.attributes['width']!);
      final double n = height! / width!;
      if (n >= 4 / 3) {
        width = num300;
        height = num400;
      } else if (4 / 3 > n && n > 3 / 4) {
        final double maxValue = max(width, height);
        height = num400 * height / maxValue;
        width = num400 * width / maxValue;
      } else if (n <= 3 / 4) {
        width = num400;
        height = num300;
      }
    }

    ///fontSize 26 and text height =30.0
    //final double fontSize = 26.0;

    return ExtendedWidgetSpan(
        start: start!,
        actualText: text,
        child: GestureDetector(
            onTap: () {
              onTap?.call(url);
            },
            child: Image.network(
              url,
              width: width,
              height: height,
              fit: fit,
            )));
  }
}

class DollarText extends SpecialText {
  DollarText(TextStyle? textStyle, SpecialTextGestureTapCallback? onTap,
      {this.start})
      : super(flag, flag, textStyle, onTap: onTap);
  static const String flag = '\$';
  final int? start;
  @override
  InlineSpan finishText() {
    final String text = getContent();

    return SpecialTextSpan(
        text: text,
        actualText: toString(),
        start: start!,

        ///caret can move into special text
        deleteAll: true,
        style: textStyle.copyWith(color: Colors.orange),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            if (onTap != null) {
              onTap!(toString());
            }
          });
  }
}

List<String> dollarList = <String>[
  '\$Dota2\$',
  '\$Dota2 Ti9\$',
  '\$CN dota best dota\$',
  '\$Flutter\$',
  '\$CN dev best dev\$',
  '\$UWP\$',
  '\$Nevermore\$',
  '\$FlutterCandies\$',
  '\$ExtendedImage\$',
  '\$ExtendedText\$',
];
