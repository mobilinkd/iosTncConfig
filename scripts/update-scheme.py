#!/usr/bin/env python3
"""Register UITest target in Xcode scheme."""

SCHEME_PATH = "/Users/rob/git/iosTncConfig/Mobilinkd TNC Config.xcodeproj/xcshareddata/xcschemes/Mobilinkd TNC Config.xcscheme"
TARGET_UUID = "AA3043AD332A4B0B8DA96DF6"

with open(SCHEME_PATH, "r") as f:
    content = f.read()

test_target_ref = """         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{}"
            BuildableName = "iosTncConfigUITests.bundle"
            BlueprintName = "iosTncConfigUITests"
            ReferencedContainer = "container:Mobilinkd TNC Config.xcodeproj">
         </BuildableReference>""".format(TARGET_UUID)

# Try both tab and space variants
content = content.replace(
    "\t\t</MacroExpansion>",
    test_target_ref + "\n      </MacroExpansion>"
)
if "iosTncConfigUITests" not in content:
    content = content.replace(
        "      </MacroExpansion>",
        test_target_ref + "\n      </MacroExpansion>"
    )

with open(SCHEME_PATH, "w") as f:
    f.write(content)

print("Scheme updated successfully.")
