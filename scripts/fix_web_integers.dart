#!/usr/bin/env dart

import 'dart:io';

/// Script to fix large integer literals in Isar generated files for web compatibility
///
/// JavaScript has a maximum safe integer value of 2^53 - 1 (9007199254740991).
/// Isar generates large integer IDs that exceed this limit, causing compilation
/// errors on web platforms.
///
/// This script replaces the large integers with smaller, web-safe values.
void main() async {
  final generatedFile = File('lib/services/agent_memory_service.g.dart');

  if (!await generatedFile.exists()) {
    print('Generated file not found: ${generatedFile.path}');
    print('Run "dart run build_runner build" first to generate the file.');
    exit(1);
  }

  print('Fixing web-incompatible integer literals in ${generatedFile.path}...');

  String content = await generatedFile.readAsString();
  bool modified = false;

  // Map of problematic large integers to web-safe replacements
  final replacements = {
    // Collection schema ID
    '1949420279504451454': '1001',
    // Content index ID
    '6193209363630369380': '1002',
    // Timestamp index ID
    '1852253767416892198': '1003',
  };

  // Apply replacements
  for (final entry in replacements.entries) {
    final oldValue = entry.key;
    final newValue = entry.value;

    if (content.contains(oldValue)) {
      content = content.replaceAll(oldValue, newValue);
      modified = true;
      print('  Replaced $oldValue with $newValue');
    }
  }

  if (modified) {
    // Write the fixed content back to the file
    await generatedFile.writeAsString(content);
    print('✅ Successfully fixed web-incompatible integers');
    print('   The app should now build successfully for web platforms');
  } else {
    print('ℹ️  No problematic integers found - file may already be fixed');
  }

  // Verify the fixes
  print('\nVerifying fixes...');
  final verifyContent = await generatedFile.readAsString();
  bool hasLargeIntegers = false;

  // Check for any remaining large integers (> 2^53 - 1)
  final largeIntPattern = RegExp(r'\b\d{16,}\b');
  final matches = largeIntPattern.allMatches(verifyContent);

  for (final match in matches) {
    final intStr = match.group(0)!;
    final intValue = BigInt.tryParse(intStr);
    if (intValue != null && intValue > BigInt.from(9007199254740991)) {
      print('⚠️  Warning: Large integer found: $intStr');
      hasLargeIntegers = true;
    }
  }

  if (!hasLargeIntegers) {
    print('✅ All integers are web-compatible');
  }

  print('\nTo test web compatibility, run:');
  print('  flutter build web --debug');
}
