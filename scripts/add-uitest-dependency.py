#!/usr/bin/env python3
"""Add target dependency and fix build settings for UITest."""

PBXPROJ_PATH = "/Users/rob/git/iosTncConfig/Mobilinkd TNC Config.xcodeproj/project.pbxproj"

# Read current pbxproj
with open(PBXPROJ_PATH, "r") as f:
    content = f.read()

# UUIDs from the previous run — we need to find them dynamically
# Find the UITest target UUID
import re

target_match = re.search(r'(AA3043AD332A4B0B8DA96DF6|EB6573F8253144BA84939E4C|D6C81A50F8FF43F8A1BF93FD)', content)
if not target_match:
    # Try to find any iosTncConfigUITests target UUID
    target_match = re.search(r'(\w{24}) \/\* iosTncConfigUITests \*\/ = \{\n\t\t\tisa = PBXNativeTarget;', content)

target_uuid = target_match.group(1) if target_match else None
print(f"Found UITest target UUID: {target_uuid}")

# Find the main app target UUID (it's always D5B24DD71DEE393B00D33B5A in this project)
main_target_uuid = "D5B24DD71DEE393B00D33B5A"

# Find the UITest config list UUID
config_list_match = re.search(r'(\w{24}) \/\* Build configuration list for PBXNativeTarget "iosTncConfigUITests" \*\/', content)
config_list_uuid = config_list_match.group(1) if config_list_match else None
print(f"Found UITest config list UUID: {config_list_uuid}")

# Find the Debug and Release config UUIDs for UITest
debug_config_match = re.search(r'(\w{24}) \/\* Debug \*\/ = \{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = \{\n.*?INFOPLIST_FILE = "\$\(SRCROOT\)/iosTncConfigUITests/Info.plist"', content, re.DOTALL)
debug_uuid = debug_config_match.group(1) if debug_config_match else None
print(f"Found UITest Debug config UUID: {debug_uuid}")

release_config_match = re.search(r'(\w{24}) \/\* Release \*\/ = \{\n\t\t\tisa = XCBuildConfiguration;\n\t\t\tbuildSettings = \{\n.*?INFOPLIST_FILE = "\$\(SRCROOT\)/iosTncConfigUITests/Info.plist"', content, re.DOTALL)
release_uuid = release_config_match.group(1) if release_config_match else None
print(f"Found UITest Release config UUID: {release_uuid}")

# Generate target dependency UUID
import uuid
dep_uuid = uuid.uuid4().hex[:24].upper()
print(f"Generated target dep UUID: {dep_uuid}")

# 1. Add PBXTargetDependency entry (before End PBXNativeTarget section)
target_dep_line = '\t\t' + dep_uuid + ' /* Target dependency */ = {isa = PBXTargetDependency; target = ' + main_target_uuid + ' /* Mobilinkd TNC Config */; };\n'

# 2. Add it to the UITest target's dependencies list
old_deps = """\t\t\tdependencies = (
\t\t\t);"""
new_deps = """\t\t\tdependencies = (
\t\t\t\t{dep_uuid} /* Target dependency */,
\t\t\t);""".format(dep_uuid=dep_uuid)

# 3. Update build settings to add FRAMEWORK_SEARCH_PATHS and LD_RUNPATH_SEARCH_PATHS
# For Debug config: add after SWIFT_VERSION = 5.0;
debug_settings_add = '\t\t\t\tFRAMEWORK_SEARCH_PATHS = "$(inherited) $(TARGET_BUILD_DIR)/Mobilinkd_TNC_Config"\\n\t\t\t\tLD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";\n'

# Actually, let me take a different approach. Instead of patching the configs after they're written,
# let me modify the config generation in add-uitest-target.py to include these settings from the start.
# But since we already ran it, let's just do targeted patches now.

# Patch: Add target dependency reference before End PBXNativeTarget section
content = content.replace(
    '\t/* End PBXNativeTarget section */',
    target_dep_line + '\t/* End PBXNativeTarget section */'
)

# Patch: Add dep to UITest target's dependencies list  
content = content.replace(
    old_deps,
    new_deps
)

# Now update the build settings in both Debug and Release configs for UITest.
# We need to add FRAMEWORK_SEARCH_PATHS and LD_RUNPATH_SEARCH_PATHS after SWIFT_VERSION line.
# Find the pattern: SWIFT_VERSION = 5.0; followed by }; (end of buildSettings)

# For Debug config
debug_pattern = 'SWIFT_VERSION = 5.0;\n\t\t\t};\n\t\t\tname = Debug;'
debug_replacement = 'SWIFT_VERSION = 5.0;\n\t\t\t\tFRAMEWORK_SEARCH_PATHS = "$(inherited) $(TARGET_BUILD_DIR)/Mobilinkd_TNC_Config";\n\t\t\t\tLD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";\n\t\t\t};\n\t\t\tname = Debug;'
content = content.replace(debug_pattern, debug_replacement)

# For Release config  
release_pattern = 'SWIFT_VERSION = 5.0;\n\t\t\t};\n\t\t\tname = Release;'
release_replacement = 'SWIFT_VERSION = 5.0;\n\t\t\t\tFRAMEWORK_SEARCH_PATHS = "$(inherited) $(TARGET_BUILD_DIR)/Mobilinkd_TNC_Config";\n\t\t\t\tLD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";\n\t\t\t};\n\t\t\tname = Release;'
content = content.replace(release_pattern, release_replacement)

with open(PBXPROJ_PATH, "w") as f:
    f.write(content)

print("Target dependency and build settings added.")
print(f"  Target dep UUID: {dep_uuid}")
