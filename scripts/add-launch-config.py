#!/usr/bin/env python3
"""Add LaunchConfiguration to TestAction in Xcode scheme."""

SCHEME_PATH = "/Users/rob/git/iosTncConfig/Mobilinkd TNC Config.xcodeproj/xcshareddata/xcschemes/Mobilinkd TNC Config.xcscheme"
APP_UUID = "D5B24DD71DEE393B00D33B5A"

with open(SCHEME_PATH, "r") as f:
    content = f.read()

# Add LaunchConfiguration right after TestAction opening tag
old_test_action = """   <TestAction
      buildConfiguration = \"Debug\"
      selectedDebuggerIdentifier = \"Xcode.DebuggerFoundation.Debugger.LLDB\"
      selectedLauncherIdentifier = \"Xcode.DebuggerFoundation.Launcher.LLDB\"
      shouldUseLaunchSchemeArgsEnv = \"YES\">"""

new_test_action = """   <TestAction
      buildConfiguration = \"Debug\"
      selectedDebuggerIdentifier = \"Xcode.DebuggerFoundation.Debugger.LLDB\"
      selectedLauncherIdentifier = \"Xcode.DebuggerFoundation.Launcher.LLDB\"
      shouldUseLaunchSchemeArgsEnv = \"YES\">
      <Testables>"""

# We need to add LaunchConfiguration BEFORE Testables, and move Testables after it
old_testables_start = """   <TestAction
      buildConfiguration = \"Debug\"
      selectedDebuggerIdentifier = \"Xcode.DebuggerFoundation.Debugger.LLDB\"
      selectedLauncherIdentifier = \"Xcode.DebuggerFoundation.Launcher.LLDB\"
      shouldUseLaunchSchemeArgsEnv = \"YES\">
      <MacroExpansion>"""

new_testables_start = """   <TestAction
      buildConfiguration = \"Debug\"
      selectedDebuggerIdentifier = \"Xcode.DebuggerFoundation.Debugger.LLDB\"
      selectedLauncherIdentifier = \"Xcode.DebuggerFoundation.Launcher.LLDB\"
      shouldUseLaunchSchemeArgsEnv = \"YES\">
      <LaunchConfiguration>
         <BuildableReference
            BuildableIdentifier = \"primary\"
            BlueprintIdentifier = "{}"
            BuildableName = "Mobilinkd TNC Config.app"
            BlueprintName = "Mobilinkd TNC Config"
            ReferencedContainer = "container:Mobilinkd TNC Config.xcodeproj">
         </BuildableReference>
      </LaunchConfiguration>
      <MacroExpansion>""".format(APP_UUID)

content = content.replace(old_testables_start, new_testables_start)

with open(SCHEME_PATH, "w") as f:
    f.write(content)

print("Scheme updated with LaunchConfiguration.")
