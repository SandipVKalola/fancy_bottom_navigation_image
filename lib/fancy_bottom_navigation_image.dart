library fancy_bottom_navigation_image;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'internal/tab_item.dart';
import 'paint/half_clipper.dart';
import 'paint/half_painter.dart';


const double CIRCLE_SIZE = 50;
const double ARC_HEIGHT = 70;
const double ARC_WIDTH = 90;
const double CIRCLE_OUTLINE = 5;
const double SHADOW_ALLOWANCE = 30;
const double BAR_HEIGHT = 60;

class FancyBottomNavigationImage extends StatefulWidget {
  FancyBottomNavigationImage(
      {@required this.tabs,
        @required this.onTabChangedListener,
        this.key,
        this.initialSelection = 0,
        this.circleColor,
        this.activeIconColor,
        this.inactiveIconColor,
        this.textColor,
        this.barBackgroundColor})
      : assert(onTabChangedListener != null),
        assert(tabs != null),
        assert(tabs.length > 1 && tabs.length < 5);

  final Function(int position) onTabChangedListener;
  final Color circleColor;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final Color textColor;
  final Color barBackgroundColor;
  final List<TabData> tabs;
  final int initialSelection;

  final Key key;

  @override
  FancyBottomNavigationImageState createState() => FancyBottomNavigationImageState();
}

class FancyBottomNavigationImageState extends State<FancyBottomNavigationImage>
    with TickerProviderStateMixin, RouteAware {
  String nextIcon;
  String activeIcon;

  int currentSelected = 0;
  double _circleAlignX = 0;
  double _circleIconAlpha = 1;

  Color circleColor;
  Color activeIconColor;
  Color inactiveIconColor;
  Color barBackgroundColor;
  Color textColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    activeIcon = widget.tabs[currentSelected].imageData;

    circleColor = (widget.circleColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
        ? Colors.white
        : circleColor
        : widget.circleColor;

    activeIconColor = (widget.activeIconColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
        ? Colors.black54
        : Colors.white
        : widget.activeIconColor;

    barBackgroundColor = (widget.barBackgroundColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
        ? Color(0xFF212121)
        : Colors.white
        : widget.barBackgroundColor;
    textColor = (widget.textColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
        ? Colors.white
        : Colors.black54
        : widget.textColor;
    inactiveIconColor = (widget.inactiveIconColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
        ? Colors.white
        : inactiveIconColor
        : widget.inactiveIconColor;
  }

  @override
  void initState() {
    super.initState();
    _setSelected(widget.tabs[widget.initialSelection].key);
  }

  _setSelected(UniqueKey key) {
    int selected = widget.tabs.indexWhere((tabData) => tabData.key == key);

    if (mounted) {
      setState(() {
        currentSelected = selected;
        _circleAlignX = -1 + (2 / (widget.tabs.length - 1) * selected);
        nextIcon = widget.tabs[selected].imageData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Container(
          height: BAR_HEIGHT,
          decoration: BoxDecoration(color: barBackgroundColor, boxShadow: [
            BoxShadow(
                color: Colors.black12, offset: Offset(0, -1), blurRadius: 8)
          ]),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widget.tabs
                .map((t) => TabItem(
                uniqueKey: t.key,
                selected: t.key == widget.tabs[currentSelected].key,
                imageData: t.imageData,
                title: t.title,
                iconColor: inactiveIconColor,
                textColor: textColor,
                callbackFunction: (uniqueKey) {
                  int selected = widget.tabs
                      .indexWhere((tabData) => tabData.key == uniqueKey);
                  widget.onTabChangedListener(selected);
                  _setSelected(uniqueKey);
                  _initAnimationAndStart(_circleAlignX, 1);
                }))
                .toList(),
          ),
        ),
        Positioned.fill(
          top: -(CIRCLE_SIZE + CIRCLE_OUTLINE + SHADOW_ALLOWANCE) / 2,
          child: Container(
            child: AnimatedAlign(
              duration: Duration(milliseconds: ANIM_DURATION),
              curve: Curves.easeOut,
              alignment: Alignment(_circleAlignX, 1),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: FractionallySizedBox(
                  widthFactor: 1 / widget.tabs.length,
                  child: GestureDetector(
                    onTap: widget.tabs[currentSelected].onclick,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SizedBox(
                          height:
                          CIRCLE_SIZE + CIRCLE_OUTLINE + SHADOW_ALLOWANCE,
                          width:
                          CIRCLE_SIZE + CIRCLE_OUTLINE + SHADOW_ALLOWANCE,
                          child: ClipRect(
                            clipper: HalfClipper(),
                            child: Container(
                              child: Center(
                                child: Container(
                                  width: CIRCLE_SIZE + CIRCLE_OUTLINE,
                                  height: CIRCLE_SIZE + CIRCLE_OUTLINE,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black12, blurRadius: 8)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ARC_HEIGHT,
                          width: ARC_WIDTH,
                          child: CustomPaint(
                            painter: HalfPainter(barBackgroundColor),
                          ),
                        ),
                        SizedBox(
                          height: CIRCLE_SIZE,
                          width: CIRCLE_SIZE,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: circleColor),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: AnimatedOpacity(
                                duration:
                                Duration(milliseconds: ANIM_DURATION ~/ 5),
                                opacity: _circleIconAlpha,
                                child: Image.asset(
                                  activeIcon,
                                  color: activeIconColor,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  _initAnimationAndStart(double from, double to) {
    _circleIconAlpha = 0;

    Future.delayed(Duration(milliseconds: ANIM_DURATION ~/ 5), () {
      setState(() {
        activeIcon = nextIcon;
      });
    }).then((_) {
      Future.delayed(Duration(milliseconds: (ANIM_DURATION ~/ 5 * 3)), () {
        setState(() {
          _circleIconAlpha = 1;
        });
      });
    });
  }

  void setPage(int page) {
    widget.onTabChangedListener(page);
    _setSelected(widget.tabs[page].key);
    _initAnimationAndStart(_circleAlignX, 1);

    setState(() {
      currentSelected = page;
    });
  }
}

class TabData {
  TabData({@required this.imageData, @required this.title, this.onclick});

  String imageData;
  String title;
  Function onclick;
  final UniqueKey key = UniqueKey();
}