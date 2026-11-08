// YourMateDesk: salvamento automático das capturas de tela da conexão.
//
// As capturas vão para Imagens\YourMateDesk\<nome da conexão>\AAAA-MM-DD_HH-MM-SS.png.
// O nome é o apelido dado em "Minhas conexões" ou, sem apelido, o ID.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/platform_model.dart';

String _two(int n) => n.toString().padLeft(2, '0');

String _safeName(String name) {
  final cleaned = name
      .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .replaceAll(RegExp(r'[. ]+$'), '');
  return cleaned.isEmpty ? 'Sem nome' : cleaned;
}

String ymdScreenshotsRoot() {
  final home = Platform.environment['USERPROFILE'] ??
      Platform.environment['HOME'] ??
      Directory.systemTemp.path;
  return '$home${Platform.pathSeparator}Pictures${Platform.pathSeparator}YourMateDesk';
}

String ymdConnectionName(String peerId) {
  String alias = '';
  try {
    alias = bind.mainGetPeerOptionSync(id: peerId, key: 'alias').trim();
  } catch (_) {}
  return _safeName(alias.isNotEmpty ? '$alias ($peerId)' : peerId);
}

/// Grava a captura recebida e avisa com a opção de abrir a pasta.
Future<void> ymdAutoSaveScreenshot(
    SessionID sessionId, String peerId, OverlayDialogManager dialogManager) async {
  final now = DateTime.now();
  final dir = Directory(
      '${ymdScreenshotsRoot()}${Platform.pathSeparator}${ymdConnectionName(peerId)}');
  final fileName = '${now.year}-${_two(now.month)}-${_two(now.day)}_'
      '${_two(now.hour)}-${_two(now.minute)}-${_two(now.second)}.png';
  String error = '';
  try {
    await dir.create(recursive: true);
    error = await bind.sessionHandleScreenshot(
        sessionId: sessionId,
        action: '0:${dir.path}${Platform.pathSeparator}$fileName');
  } catch (e) {
    error = e.toString();
    bind.sessionHandleScreenshot(sessionId: sessionId, action: '2');
  }
  if (error.isNotEmpty) {
    msgBox(sessionId, 'custom-nook-nocancel-hasclose-error', 'Take screenshot',
        error, '', dialogManager);
    return;
  }
  dialogManager.show(
    (setState, close, context) => CustomAlertDialog(
      title: const Text('Captura salva'),
      content: SelectableText('${dir.path}${Platform.pathSeparator}$fileName'),
      actions: [
        dialogButton('Abrir pasta', onPressed: () {
          close();
          if (Platform.isWindows) {
            Process.run('explorer', [dir.path]);
          } else if (Platform.isMacOS) {
            Process.run('open', [dir.path]);
          } else {
            Process.run('xdg-open', [dir.path]);
          }
        }),
        dialogButton('OK', onPressed: close),
      ],
      onSubmit: close,
      onCancel: close,
    ),
    tag: 'ymd-screenshot-saved',
  );
}
