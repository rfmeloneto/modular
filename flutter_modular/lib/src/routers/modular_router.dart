import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../flutter_modular.dart';
import '../interfaces/child_module.dart';
import '../interfaces/route_guard.dart';
import '../transitions/transitions.dart';
import '../utils/modular_arguments.dart';

typedef RouteBuilder<T> = MaterialPageRoute<T> Function(
    WidgetBuilder, RouteSettings);

class ModularRouter<T> {
  final ChildModule currentModule;

  Completer<T> popRoute = Completer<T>();

  ModularArguments args;

  final String path;

  ///
  /// Paramenter name: [routerName]
  ///
  /// Name for your route
  ///
  /// Type: String
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  final String routerName;

  ///
  /// Paramenter name: [child]
  ///
  /// The widget will be displayed
  ///
  /// Type: Widget
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///

  final Widget Function(BuildContext context, ModularArguments args) child;

  ///
  /// Paramenter name: [module]
  ///
  /// The module will be loaded
  ///
  /// Type: ChildModule
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  final ChildModule module;

  ///
  /// Paramenter name: [params]
  ///
  /// The parameters that can be transferred to another screen
  ///
  /// Type: Map<String, String>
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  Map<String, String> params;

  ///
  /// Paramenter name: [guards]
  ///
  /// Route guards are middleware-like objects
  ///
  /// that allow you to control the access of a given route from other route.
  ///
  /// You can implement a route guard by making a class that implements RouteGuard.
  ///
  /// Type: List<RouteGuard>
  ///
  /// Example:
  /// ```dart
  ///class MyGuard implements RouteGuard {
  ///  @override
  ///  bool canActivate(String url) {
  ///    if (url != '/admin'){
  ///      // Return `true` to allow access
  ///      return true;
  ///    } else {
  ///      // Return `false` to disallow access
  ///      return false
  ///    }
  ///  }
  ///}
  ///To use your RouteGuard in a route, pass it to the guards parameter:
  ///
  ///@override
  ///List<ModularRouter> get routers => [
  ///  ModularRouter('/', module: HomeModule()),
  ///  ModularRouter(
  ///    '/admin',
  ///    module: AdminModule(),
  ///    guards: [MyGuard()],
  ///  ),
  ///];
  /// ```
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///

  final List<RouteGuard> guards;

  ///
  /// Paramenter name: [transition]
  ///
  /// Used to animate the transition from one screen to another
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  final TransitionType transition;

  ///
  /// Paramenter name: [customTransiton]
  ///
  /// PS: For [customTransition] to work,
  ///
  /// you must set the [transition] parameter for
  /// ```dart
  /// transition.custom,
  /// ```
  ///
  /// Example: Using just First Animation
  /// ```dart
  /// customTransition: CustomTransition(
  ///   transitionBuilder: (context, animation, secondaryAnimation, child) {
  ///     return SlideTransition(
  ///         transformHitTests: false,
  ///         position: Tween<Offset>(
  ///           begin: const Offset(0.0, 1.0),
  ///           end: Offset.zero,
  ///         ).chain(CurveTween(curve: Curves.ease)).animate(animation),
  ///         child: child);
  ///   },
  /// ),
  /// ```

  /// Example: Using just secondaryAnimation
  /// ```dart
  /// customTransition: CustomTransition(
  /// transitionBuilder: (context, animation, secondaryAnimation, child) {
  ///   return SlideTransition(
  ///     transformHitTests: false,
  ///     position: Tween<Offset>(
  ///       begin: const Offset(0.0, 1.0),
  ///       end: Offset.zero,
  ///     ).chain(CurveTween(curve: Curves.ease)).animate(animation),
  ///     child: SlideTransition(
  ///       transformHitTests: false,
  ///       position: Tween<Offset>(
  ///         begin: Offset.zero,
  ///         end: const Offset(0.0, -1.0),
  ///       ).chain(CurveTween(curve: Curves.ease)).animate(secondaryAnimation),
  ///       child: child,
  ///     ),
  ///   );
  ///   },
  /// ),
  /// ```
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  final CustomTransition customTransition;

  ///
  /// Paramenter name: [transition]
  ///
  /// Used to animate the transition from one screen to another
  ///
  /// For more example go to Modular page from gitHub [https://github.com/Flutterando/modular]
  ///
  final RouteBuilder<T> routeGenerator;
  final String modulePath;
  final Duration duration;

  ModularRouter(
    this.routerName, {
    this.path = '/',
    this.args = const ModularArguments(),
    this.module,
    this.child,
    this.guards,
    this.params,
    this.currentModule,
    this.transition = TransitionType.defaultTransition,
    this.routeGenerator,
    this.customTransition,
    this.popRoute,
    this.duration = const Duration(milliseconds: 300),
    this.modulePath = '/',
  }) {
    assert(routerName != null);

    popRoute = popRoute ?? Completer<T>();

    if (transition == null) throw ArgumentError('transition must not be null');
    if (transition == TransitionType.custom && customTransition == null) {
      throw ArgumentError(
          '[customTransition] required for transition type [TransitionType.custom]');
    }
    if (module == null && child == null) {
      throw ArgumentError('[module] or [child] must be provided');
    }
    if (module != null && child != null) {
      throw ArgumentError('You should provide only [module] or [child]');
    }
  }
  final Map<
      TransitionType,
      PageRouteBuilder<T> Function(
    Widget Function(BuildContext, ModularArguments) builder,
    ModularArguments args,
    Duration transitionDuration,
    RouteSettings settings,
  )> _transitions = {
    TransitionType.fadeIn: fadeInTransition,
    TransitionType.noTransition: noTransition,
    TransitionType.rightToLeft: rightToLeft,
    TransitionType.leftToRight: leftToRight,
    TransitionType.upToDown: upToDown,
    TransitionType.downToUp: downToUp,
    TransitionType.scale: scale,
    TransitionType.rotate: rotate,
    TransitionType.size: size,
    TransitionType.rightToLeftWithFade: rightToLeftWithFade,
    TransitionType.leftToRightWithFade: leftToRightWithFade,
  };

  ModularRouter<T> copyWith(
      {Widget Function(BuildContext context, ModularArguments args) child,
      String routerName,
      ChildModule module,
      ChildModule currentModule,
      Map<String, String> params,
      List<RouteGuard> guards,
      TransitionType transition,
      RouteBuilder routeGenerator,
      String modulePath,
      String path,
      String duration,
      Completer<T> popRoute,
      ModularArguments args,
      CustomTransition customTransition}) {
    return ModularRouter<T>(
      routerName ?? this.routerName,
      child: child ?? this.child,
      args: args ?? this.args,
      module: module ?? this.module,
      currentModule: currentModule ?? this.currentModule,
      params: params ?? this.params,
      modulePath: modulePath ?? this.modulePath,
      path: path ?? this.path,
      popRoute: popRoute ?? this.popRoute,
      guards: guards ?? this.guards,
      duration: duration ?? this.duration,
      routeGenerator: routeGenerator ?? this.routeGenerator,
      transition: transition ?? this.transition,
      customTransition: customTransition ?? this.customTransition,
    );
  }

  static List<ModularRouter> group({
    @required List<ModularRouter> routes,
    List<RouteGuard> guards,
    TransitionType transition,
    CustomTransition customTransition,
  }) {
    return routes.map((r) {
      return r.copyWith(
        guards: guards,
        transition: transition ?? r.transition,
        customTransition: customTransition ?? r.customTransition,
      );
    }).toList();
  }

  Route<T> getPageRoute(RouteSettings settings) {
    if (transition == TransitionType.custom && customTransition != null) {
      return PageRouteBuilder(
        pageBuilder: (context, _, __) {
          //return disposablePage;
          return child(context, args);
        },
        settings: settings,
        transitionsBuilder: customTransition.transitionBuilder,
        transitionDuration: customTransition.transitionDuration,
      );
    } else if (transition == TransitionType.defaultTransition) {
      // Helper function
      Widget widgetBuilder(BuildContext context) {
        //return disposablePage;
        return child(context, args);
      }

      if (routeGenerator != null) {
        return routeGenerator(widgetBuilder, settings);
      }
      return MaterialPageRoute<T>(
        settings: settings,
        builder: widgetBuilder,
      );
    } else {
      var selectTransition = _transitions[transition];
      return selectTransition(child, args, duration, settings);
    }
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ModularRouter<T> &&
        o.modulePath == modulePath &&
        o.routerName == routerName &&
        o.module == module;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode {
    return currentModule.hashCode ^ routerName.hashCode;
  }
}

enum TransitionType {
  defaultTransition,
  fadeIn,
  noTransition,
  rightToLeft,
  leftToRight,
  upToDown,
  downToUp,
  scale,
  rotate,
  size,
  rightToLeftWithFade,
  leftToRightWithFade,
  custom,
}

class CustomTransition {
  final Widget Function(
          BuildContext, Animation<double>, Animation<double>, Widget)
      transitionBuilder;
  final Duration transitionDuration;

  CustomTransition(
      {@required this.transitionBuilder,
      this.transitionDuration = const Duration(milliseconds: 300)});
}
