#!/usr/bin/env python3
"""Fix Testable entry in Xcode scheme — add proper BuildableReference."""

SCHEME_PATH = "/Users/rob/git/iosTncConfig/Mobilinkd TNC Config.xcodeproj/xcshareddata/xcschemes/Mobilinkd TNC Config.xcscheme"
TARGET_UUID = "0DB8BE4A11074A9F80AF820E"

with open(SCHEME_PATH, "r") as f:
    content = f.read()

# Replace the broken TestableReference with a proper one containing BuildableReference
old_testable = """         <TestableReference
            skipped = "NO"
            compatiblePlatformIdentifier = "iphonesimulator">
         </TestableReference>"""

new_testable = """         <TestableReference
            skipped = "NO"
            friendlyName = "iosTncConfigUITests"
            targetBuildProductContainer = "container:Mobilinkd TNC Config.xcodeproj"
            blueprintAbsolutePath = "/Users/rob/git/iosTncConfig/Mobilinkd TNC Config.xcodeproj"
            blueprintIdentifier = "{}">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{}"
               BuildableName = "iosTncConfigUITests.bundle"
               BlueprintName = "iosTncConfigUITests"
               ReferencedContainer = "container:Mobilinkd TNC Config.xcodeproj">
            </BuildableReference>
         </TestableReference>""".format(TARGET_UUID, TARGET_UUID)

content = content.replace(old_testable, new_testable)

with open(SCHEME_PATH, "w") as f:
    f.write(content)

print("Scheme Testable entry fixed.")
