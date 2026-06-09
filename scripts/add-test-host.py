#!/usr/bin/env python3
"""Add TEST_HOST build setting to UITest target."""

PBXPROJ_PATH = "/Users/rob/git/iosTncConfig/Mobilinkd TNC Config.xcodeproj/project.pbxproj"

with open(PBXPROJ_PATH, "r") as f:
    content = f.read()

# Find the two XCBuildConfiguration entries for the UITest target (UIDs 0DB8BE4B11074A9F80AF820E and 0DB8BE4C11074A9F80AF820E)
# They have SWIFT_VERSION = 5.0; followed by };

debug_config_marker = """		SWIFT_VERSION = 5.0;
		};
		name = Debug;
		0DB8BE4C11074A9F80AF820E /* Release */ = {"""

release_config_marker = """		SWIFT_VERSION = 5.0;
		};
		name = Release;
		/* End XCBuildConfiguration section */"""

# Add TEST_HOST to both configs
debug_new = """		SWIFT_VERSION = 5.0;
			TEST_HOST = "$(BUILT_PRODUCTS_DIR)/Mobilinkd TNC Config.app/Mobilinkd TNC Config";
		};
		name = Debug;
		0DB8BE4C11074A9F80AF820E /* Release */ = {"""

release_new = """		SWIFT_VERSION = 5.0;
			TEST_HOST = "$(BUILT_PRODUCTS_DIR)/Mobilinkd TNC Config.app/Mobilinkd TNC Config";
		};
		name = Release;
		/* End XCBuildConfiguration section */"""

content = content.replace(debug_config_marker, debug_new)
content = content.replace(release_config_marker, release_new)

with open(PBXPROJ_PATH, "w") as f:
    f.write(content)

print("TEST_HOST added to UITest configs.")
