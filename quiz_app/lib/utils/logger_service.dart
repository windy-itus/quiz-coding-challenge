import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:talker/talker.dart';

class LoggerService {
  factory LoggerService({
    Talker? talker,
    Level? level,
    PrettyPrinter? printer,
  }) {
    _talker ??= talker;
    _instance ??= LoggerService._internal(
      level: level,
      printer: printer,
    );
    return _instance!;
  }

  LoggerService._internal({
    Level? level,
    PrettyPrinter? printer,
  }) : _logger = Logger(
          level: level ?? (kDebugMode ? Level.all : Level.error),
          printer: printer ??
              PrettyPrinter(
                dateTimeFormat: DateTimeFormat.dateAndTime,
                printEmojis: true,
                noBoxingByDefault: true,
                methodCount: 2,
              ),
          output: _DebugOutput(),
        );

  static LoggerService? _instance;
  static Talker? _talker;
  final Logger _logger;

  void l(dynamic Function() messageBuilder) {
    _talker?.log(messageBuilder());
    _logger.log(Level.info, messageBuilder());
  }

  void d(dynamic Function() messageBuilder) {
    _talker?.debug(messageBuilder());
    _logger.log(Level.debug, messageBuilder());
  }

  void v(dynamic Function() messageBuilder) {
    _talker?.verbose(messageBuilder());
    _logger.log(Level.trace, messageBuilder());
  }

  void i(dynamic Function() messageBuilder) {
    _talker?.info(messageBuilder());
    _logger.log(Level.info, messageBuilder());
  }

  void w(dynamic Function() messageBuilder) {
    _talker?.warning(messageBuilder());
    _logger.log(Level.warning, messageBuilder());
  }

  void e(dynamic Function() messageBuilder) {
    _talker?.error(messageBuilder());
    _logger.log(Level.error, messageBuilder());
  }
}

class _LogOutput extends LogOutput {
  final Map<Level, String> logLevelMap = {
    Level.trace: '⬜️',
    Level.debug: '⬜️',
    Level.info: '🟩',
    Level.warning: '🟨',
    Level.error: '🟥',
    Level.fatal: '🟪',
  };

  final String resetColorCode = '\x1B[0m'; // Reset to default terminal color
  final String blackColorCode = '\x1B[30m'; //Black
  final String redColorCode = '\x1B[31m'; //Red
  final String greenColorCode = '\x1B[32m'; //Green
  final String yellowColorCode = '\x1B[33m'; //Yellow
  final String blueColorCode = '\x1B[34m'; //Blue
  final String magentaColorCode = '\x1B[35m'; //Magenta
  final String cyanColorCode = '\x1B[36m'; //Cyan
  final String whiteColorCode = '\x1B[37m'; //White
  final String grayColorCode = '\x1B[90m'; //Bright Black (Gray)
  final String brightRedColorCode = '\x1B[91m'; //Bright Red
  final String brightGreenColorCode = '\x1B[92m'; //Bright Green
  final String brightYellowColorCode = '\x1B[93m'; //Bright Yellow
  final String brightBlueColorCode = '\x1B[94m'; //Bright Blue
  final String brightMagnetaColorCode = '\x1B[95m'; //Bright Magenta
  final String brightCyanColorCode = '\x1B[96m'; //Bright Cyan
  final String brightWhiteColorCode = '\x1B[97m'; //Bright White

  @override
  void output(OutputEvent event) {
    log(buildLog(event).toString());
  }

  StringBuffer buildLog(OutputEvent event) {
    String fullPath = 'unknown';
    String fileName = 'unknown';
    int lineNumber = 0;

    // Try to extract file name and line number
    if (event.lines.isNotEmpty) {
      final RegExp exp = RegExp(r'#\d+\s+(.+)\s+\((.+):(\d+):(\d+)\)');
      final matches = exp.allMatches(event.lines[1]);

      if (matches.isNotEmpty) {
        // Assuming the first match is the relevant one
        final match = matches.first;

        fullPath = match.group(2) ?? 'unknown';
        lineNumber = int.tryParse(match.group(3) ?? '0') ?? 0;
        fileName = Uri.parse(fullPath).pathSegments.last;
      }
    }

    const fileLineWidth = 50;
    final StringBuffer buffer = StringBuffer();
    final String time = "$whiteColorCode${event.origin.time}$resetColorCode";
    final String fileLine = "$cyanColorCode$fileName:$lineNumber$resetColorCode".padRight(fileLineWidth, " ");
    final String message = "${event.origin.message}";

    buffer.writeln("${logLevelMap[event.level]} $time $fileLine $message");
    if (event.level == Level.error || event.level == Level.fatal) {
      buffer.writeln("$redColorCode${event.origin.stackTrace}$resetColorCode");
    }

    return buffer;
  }
}

class _DebugOutput extends LogOutput {
  final _LogOutput _consoleOutput = _LogOutput();
  // TODO: Add file output

  @override
  Future init() async {
    super.init();
    _consoleOutput.init();
    // TODO: Add file output
  }

  @override
  void output(OutputEvent event) {
    _consoleOutput.output(event);
    // TODO: Add file output
  }
}
