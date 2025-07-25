// Copyright 2021 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: use_build_context_synchronously

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebergnote/main.dart';
import 'package:icebergnote/postgresql/sync.dart';
import 'package:icebergnote/screen/habit_list_screen.dart';
import 'package:icebergnote/screen/login_screen.dart';
import 'package:icebergnote/screen/review_screen.dart';
import 'package:icebergnote/screen/star_screen.dart';
import 'package:icebergnote/system/device_id.dart';
import 'package:icebergnote/users.dart';
import 'screen/import_screen.dart';
import 'screen/noteslist_screen.dart';
import 'constants.dart';
import 'screen/record_report.dart';
import 'screen/todo_screen.dart';

int screenIndexGlobal = 0;

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.useLightMode,
    required this.useMaterial3,
    required this.colorSelected,
    required this.handleBrightnessChange,
    required this.handleMaterialVersionChange,
    required this.handleColorSelect,
  });

  final bool useLightMode;
  final bool useMaterial3;
  final ColorSeed colorSelected;
  final void Function(bool useLightMode) handleBrightnessChange;
  final void Function() handleMaterialVersionChange;
  final void Function(int value) handleColorSelect;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController controller;
  late final CurvedAnimation railAnimation;
  bool controllerInitialized = false;
  bool showMediumSizeLayout = false;
  bool showLargeSizeLayout = false;
  int screenIndex = ScreenSelected.star.index;
  final StarPage starPage = const StarPage(
    mod: 4,
    txt: '',
  );
  final SearchPage searchPage = SearchPage(
    mod: 0,
    txt: '',
  );
  @override
  initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: transitionLength.toInt() * 2),
      value: 0,
      vsync: this,
    );
    railAnimation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1.0),
    );
    // PermissionUtil.requestAll();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final double width = MediaQuery.of(context).size.width;
    final AnimationStatus status = controller.status;
    if (width > mediumWidthBreakpoint) {
      if (width > largeWidthBreakpoint) {
        showMediumSizeLayout = false;
        showLargeSizeLayout = true;
      } else {
        showMediumSizeLayout = true;
        showLargeSizeLayout = false;
      }
      if (status != AnimationStatus.forward &&
          status != AnimationStatus.completed) {
        controller.forward();
      }
    } else {
      showMediumSizeLayout = false;
      showLargeSizeLayout = false;
      if (status != AnimationStatus.reverse &&
          status != AnimationStatus.dismissed) {
        controller.reverse();
      }
    }
    if (!controllerInitialized) {
      controllerInitialized = true;
      controller.value = width > mediumWidthBreakpoint ? 1 : 0;
    }
  }

  void handleScreenChanged(int screenSelected) {
    setState(() {
      screenIndex = screenSelected;
    });
  }

  Widget createScreenFor(
      ScreenSelected screenSelected, bool showNavBarExample) {
    switch (screenSelected) {
      case ScreenSelected.star:
        return Expanded(
          child: OneTwoTransition(
            animation: railAnimation,
            one: starPage,
            two: SecondComponentList(
              scaffoldKey: scaffoldKey,
            ),
          ),
        );
      case ScreenSelected.component:
        return Expanded(
          child: OneTwoTransition(
            animation: railAnimation,
            one: searchPage,
            two: SecondComponentList(
              scaffoldKey: scaffoldKey,
            ),
          ),
        );
      case ScreenSelected.color:
        return Expanded(
          child: OneTwoTransition(
            animation: railAnimation,
            one: const ReportScreen(
              duration: '周报',
            ),
            two: SecondComponentList(
              scaffoldKey: scaffoldKey,
            ),
          ),
        );
      // case ScreenSelected.test:
      //   return const testPage();
      case ScreenSelected.todo:
        return Expanded(
          child: OneTwoTransition(
            animation: railAnimation,
            one: const TodoPage(
              mod: 3,
              txt: '',
            ),
            two: SecondComponentList(
              scaffoldKey: scaffoldKey,
            ),
          ),
        );
      case ScreenSelected.habit:
        return Expanded(
          child: OneTwoTransition(
            animation: railAnimation,
            one: const HabitListScreen(),
            two: SecondComponentList(
              scaffoldKey: scaffoldKey,
            ),
          ),
        );
    }
  }

  PreferredSizeWidget createAppBar() {
    return AppBar(
        title: Row(
          children: [
            Hero(
              tag: APPConstants.logoTag,
              child: Image.asset(
                'lib/assets/image/icebergicon.png',
                width: 35,
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
            const Text(
              APPConstants.appName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            // HeroText(
            //   APPConstants.appName,
            //   tag: APPConstants.titleTag,
            //   viewState: ViewState.shrunk,
            //   style: TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
          ],
        ),
        actions: [
          // _ColorSeedButton(
          //   handleColorSelect: widget.handleColorSelect,
          //   colorSelected: widget.colorSelected,
          // ),
          // _BrightnessButton(
          //   handleBrightnessChange: widget.handleBrightnessChange,
          //   showTooltipBelow: false,
          // ),

          IconButton(
            icon: const Icon(Icons.cloud_queue_rounded),
            onPressed: () async {
              bool result = await searchPage.state.syncDate();
              // searchPage.state.refreshListTotop();
              // Get.to(() => const SyncPage());
              if (result) {
                CherryToast(
                        icon: Icons.cloud_done_outlined,
                        iconColor: Colors.green,
                        themeColor: Colors.grey,
                        description: const Text('远程同步完成',
                            style: TextStyle(color: Colors.black)),
                        toastPosition: Position.top,
                        animationType: AnimationType.fromTop,
                        animationDuration: const Duration(milliseconds: 400),
                        toastDuration: const Duration(milliseconds: 1000),
                        autoDismiss: true)
                    .show(context);
              } else {
                CherryToast(
                        icon: Icons.error_outline_outlined,
                        iconColor: Colors.red,
                        themeColor: Colors.grey,
                        description: const Text('远程同步失败',
                            style: TextStyle(color: Colors.black)),
                        toastPosition: Position.top,
                        animationType: AnimationType.fromTop,
                        animationDuration: const Duration(milliseconds: 400),
                        toastDuration: const Duration(milliseconds: 1000),
                        autoDismiss: true)
                    .show(context);
              }
              mainnotesList.reinit(0);
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReviewPage()),
                  );
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ImportPage()),
                  );
                  break;
                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchPage(
                              mod: 1,
                              txt: '',
                            )),
                  );
                  break;
                case 4:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SyncPage()),
                  );
                  break;
                default:
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 1,
                  child: Text('复盘'),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Text("导入"),
                ),
                // const PopupMenuItem(
                //   value: 3,
                //   child: Text("搜索"),
                // ),
                const PopupMenuItem(
                  value: 4,
                  child: Text("同步"),
                ),
              ];
            },
          )
        ]);
  }

  Widget _expandedTrailingActions() => Container(
        constraints: const BoxConstraints.tightFor(width: 250),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text('Brightness'),
                Expanded(child: Container()),
                Switch(
                    value: widget.useLightMode,
                    onChanged: (value) {
                      widget.handleBrightnessChange(value);
                    })
              ],
            ),
            Row(
              children: [
                widget.useMaterial3
                    ? const Text('Material 3')
                    : const Text('Material 2'),
                Expanded(child: Container()),
                Switch(
                    value: widget.useMaterial3,
                    onChanged: (_) {
                      widget.handleMaterialVersionChange();
                    })
              ],
            ),
            const Divider(),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200.0),
              child: GridView.count(
                crossAxisCount: 3,
                children: List.generate(
                    ColorSeed.values.length,
                    (i) => IconButton(
                          icon: const Icon(Icons.radio_button_unchecked),
                          color: ColorSeed.values[i].color,
                          isSelected: widget.colorSelected.color ==
                              ColorSeed.values[i].color,
                          selectedIcon: const Icon(Icons.circle),
                          onPressed: () {
                            widget.handleColorSelect(i);
                          },
                        )),
              ),
            ),
          ],
        ),
      );

  Widget _trailingActions() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: _BrightnessButton(
              handleBrightnessChange: widget.handleBrightnessChange,
              showTooltipBelow: false,
            ),
          ),
          // Flexible(
          //   child: _Material3Button(
          //     handleMaterialVersionChange: widget.handleMaterialVersionChange,
          //     showTooltipBelow: false,
          //   ),
          // ),
          Flexible(
            child: _ColorSeedButton(
              handleColorSelect: widget.handleColorSelect,
              colorSelected: widget.colorSelected,
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return NavigationTransition(
          scaffoldKey: scaffoldKey,
          animationController: controller,
          railAnimation: railAnimation,
          appBar: createAppBar(),
          body: createScreenFor(
              ScreenSelected.values[screenIndex], controller.value == 1),
          navigationRail: NavigationRail(
            extended: showLargeSizeLayout,
            destinations: navRailDestinations,
            selectedIndex: screenIndex,
            onDestinationSelected: (index) {
              setState(() {
                screenIndex = index;
                screenIndexGlobal = index;
                handleScreenChanged(screenIndex);
              });
            },
            trailing: Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: showLargeSizeLayout
                    ? _expandedTrailingActions()
                    : _trailingActions(),
              ),
            ),
          ),
          navigationBar: NavigationBars(
            onSelectItem: (index) {
              setState(() {
                screenIndex = index;
                screenIndexGlobal = index;
                handleScreenChanged(screenIndex);
              });
            },
            selectedIndex: screenIndex,
            isExampleBar: false,
          ),
        );
      },
    );
  }
}

class _BrightnessButton extends StatelessWidget {
  const _BrightnessButton({
    required this.handleBrightnessChange,
    this.showTooltipBelow = true,
  });

  final Function handleBrightnessChange;
  final bool showTooltipBelow;

  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;
    return Tooltip(
      preferBelow: showTooltipBelow,
      message: 'Toggle brightness',
      child: IconButton(
        icon: isBright
            ? const Icon(Icons.dark_mode_outlined)
            : const Icon(Icons.light_mode_outlined),
        onPressed: () => handleBrightnessChange(!isBright),
      ),
    );
  }
}

class _ColorSeedButton extends StatelessWidget {
  const _ColorSeedButton({
    required this.handleColorSelect,
    required this.colorSelected,
  });

  final void Function(int) handleColorSelect;
  final ColorSeed colorSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.palette_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      tooltip: 'Select a seed color',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      itemBuilder: (context) {
        return List.generate(ColorSeed.values.length, (index) {
          ColorSeed currentColor = ColorSeed.values[index];

          return PopupMenuItem(
            value: index,
            enabled: currentColor != colorSelected,
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(
                    currentColor == colorSelected
                        ? Icons.color_lens
                        : Icons.color_lens_outlined,
                    color: currentColor.color,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(currentColor.label),
                ),
              ],
            ),
          );
        });
      },
      onSelected: handleColorSelect,
    );
  }
}

class NavigationTransition extends StatefulWidget {
  const NavigationTransition({
    super.key,
    required this.scaffoldKey,
    required this.animationController,
    required this.railAnimation,
    required this.navigationRail,
    required this.navigationBar,
    required this.appBar,
    required this.body,
  });

  final GlobalKey<ScaffoldState> scaffoldKey;
  final AnimationController animationController;
  final CurvedAnimation railAnimation;
  final Widget navigationRail;
  final Widget navigationBar;
  final PreferredSizeWidget appBar;
  final Widget body;

  @override
  State<NavigationTransition> createState() => _NavigationTransitionState();
}

class _NavigationTransitionState extends State<NavigationTransition> {
  late final AnimationController controller;
  late final CurvedAnimation railAnimation;
  late final ReverseAnimation barAnimation;
  bool controllerInitialized = false;
  bool showDivider = false;

  @override
  void initState() {
    super.initState();

    controller = widget.animationController;
    railAnimation = widget.railAnimation;

    barAnimation = ReverseAnimation(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      key: widget.scaffoldKey,
      appBar: widget.appBar,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'lib/assets/image/icebergicon.png',
                    width: 100,
                    height: 100,
                  ),
                  const Text(
                    APPConstants.appName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            GetBuilder<UserController>(
              init: UserController(), // 首次启动
              builder: (user) => ListTile(
                leading: user.name.value == '登录'
                    ? const Icon(Icons.login_rounded)
                    : const Icon(Icons.person, color: Colors.blueGrey),
                title: Text(
                  user.name.value,
                ),
                trailing: user.name.value == '登录'
                    ? const Text('')
                    : user.vipDate.value.isBefore(DateTime.now())
                        ? const Text('会员已过期')
                        : const Text('尊享会员',
                            style: TextStyle(
                                color: Color.fromARGB(255, 111, 102, 0))),
                onTap: () {
                  if (user.name.value == '登录') {
                    Get.to(const LoginScreen());
                  } else {
                    user.logout();
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.blueGrey),
              title: const Text('回收站'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(
                      mod: 2,
                      txt: '',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.devices_rounded, color: Colors.blueGrey),
              title: Text(
                deviceUniqueId,
                style: const TextStyle(fontSize: 8),
              ),
              onTap: () {
                getUniqueId();
                setState(() {});
              },
            ),
            GetBuilder<UserController>(
              init: UserController(), // 首次启动
              builder: (user) => ListTile(
                leading:
                    const Icon(Icons.devices_rounded, color: Colors.blueGrey),
                title: Text(
                  '#${user.deviceNO.value}',
                ),
                onTap: () {
                  user.refreshLocalUser();
                },
              ),
            ),
          ],
        ),
      ),
      body: Row(
        children: <Widget>[
          RailTransition(
            animation: railAnimation,
            backgroundColor: colorScheme.surface,
            child: widget.navigationRail,
          ),
          widget.body,
        ],
      ),
      // floatingActionButton: screenIndexGlobal == 0
      //     ? FloatingActionButton(
      //         child: const Icon(Icons.add),
      //         onPressed: () {
      //           showDialog(
      //             context: context,
      //             builder: (BuildContext context) {
      //               return NewNoteDialog(
      //                 onDialogClosed: () {},
      //               );
      //             },
      //           );
      //         },
      //       )
      //     : null,
      bottomNavigationBar: BarTransition(
        animation: barAnimation,
        backgroundColor: colorScheme.surface,
        child: widget.navigationBar,
      ),
      endDrawer: const NavigationDrawerSection(),
    );
  }
}

final List<NavigationRailDestination> navRailDestinations = appBarDestinations
    .map(
      (destination) => NavigationRailDestination(
        icon: Tooltip(
          message: destination.label,
          child: destination.icon,
        ),
        selectedIcon: Tooltip(
          message: destination.label,
          child: destination.selectedIcon,
        ),
        label: Text(destination.label),
      ),
    )
    .toList();

class SizeAnimation extends CurvedAnimation {
  SizeAnimation(Animation<double> parent)
      : super(
          parent: parent,
          curve: const Interval(
            0.2,
            0.8,
            curve: Curves.easeInOutCubicEmphasized,
          ),
          reverseCurve: Interval(
            0,
            0.2,
            curve: Curves.easeInOutCubicEmphasized.flipped,
          ),
        );
}

class OffsetAnimation extends CurvedAnimation {
  OffsetAnimation(Animation<double> parent)
      : super(
          parent: parent,
          curve: const Interval(
            0.4,
            1.0,
            curve: Curves.easeInOutCubicEmphasized,
          ),
          reverseCurve: Interval(
            0,
            0.2,
            curve: Curves.easeInOutCubicEmphasized.flipped,
          ),
        );
}

class RailTransition extends StatefulWidget {
  const RailTransition(
      {super.key,
      required this.animation,
      required this.backgroundColor,
      required this.child});

  final Animation<double> animation;
  final Widget child;
  final Color backgroundColor;

  @override
  State<RailTransition> createState() => _RailTransition();
}

class _RailTransition extends State<RailTransition> {
  late Animation<Offset> offsetAnimation;
  late Animation<double> widthAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // The animations are only rebuilt by this method when the text
    // direction changes because this widget only depends on Directionality.
    final bool ltr = Directionality.of(context) == TextDirection.ltr;

    widthAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(SizeAnimation(widget.animation));

    offsetAnimation = Tween<Offset>(
      begin: ltr ? const Offset(-1, 0) : const Offset(1, 0),
      end: Offset.zero,
    ).animate(OffsetAnimation(widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: Align(
          alignment: Alignment.topLeft,
          widthFactor: widthAnimation.value,
          child: FractionalTranslation(
            translation: offsetAnimation.value,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class BarTransition extends StatefulWidget {
  const BarTransition(
      {super.key,
      required this.animation,
      required this.backgroundColor,
      required this.child});

  final Animation<double> animation;
  final Color backgroundColor;
  final Widget child;

  @override
  State<BarTransition> createState() => _BarTransition();
}

class _BarTransition extends State<BarTransition> {
  late final Animation<Offset> offsetAnimation;
  late final Animation<double> heightAnimation;

  @override
  void initState() {
    super.initState();

    offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(OffsetAnimation(widget.animation));

    heightAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(SizeAnimation(widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: Align(
          alignment: Alignment.topLeft,
          heightFactor: heightAnimation.value,
          child: FractionalTranslation(
            translation: offsetAnimation.value,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class OneTwoTransition extends StatefulWidget {
  const OneTwoTransition({
    super.key,
    required this.animation,
    required this.one,
    required this.two,
  });

  final Animation<double> animation;
  final Widget one;
  final Widget two;

  @override
  State<OneTwoTransition> createState() => _OneTwoTransitionState();
}

class _OneTwoTransitionState extends State<OneTwoTransition> {
  late final Animation<Offset> offsetAnimation;
  late final Animation<double> widthAnimation;

  @override
  void initState() {
    super.initState();

    offsetAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(OffsetAnimation(widget.animation));

    widthAnimation = Tween<double>(
      begin: 0,
      end: mediumWidthBreakpoint,
    ).animate(SizeAnimation(widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          flex: mediumWidthBreakpoint.toInt(),
          child: widget.one,
        ),
        if (widthAnimation.value.toInt() > 0) ...[
          Flexible(
            flex: widthAnimation.value.toInt(),
            child: FractionalTranslation(
              translation: offsetAnimation.value,
              child: widget.two,
            ),
          )
        ],
      ],
    );
  }
}
