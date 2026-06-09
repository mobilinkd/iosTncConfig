#!/usr/bin/env python3
"""Add iosTncConfigUITest target to project.pbxproj — single-pass, correct."""

import uuid

PBXPROJ_PATH = "/Users/rob/git/iosTncConfig/Mobilinkd TNC Config.xcodeproj/project.pbxproj"
SCHEME_PATH = "/Users/rob/git/iosTncConfig/Mobilinkd TNC Config.xcodeproj/xcshareddata/xcschemes/Mobilinkd TNC Config.xcscheme"

def gen_uuid():
    return uuid.uuid4().hex[:24].upper()

# Generate all UUIDs
UUID_BUILDFILE_SWIFT   = gen_uuid()
UUID_FILEREF_SWIFT     = gen_uuid()
UUID_FILEREF_PLIST     = gen_uuid()
UUID_GROUP_FOLDER      = gen_uuid()
UUID_TARGET            = gen_uuid()
UUID_SOURCES_PHASE     = gen_uuid()
UUID_RESOURCES_PHASE   = gen_uuid()
UUID_CONFIG_DEBUG      = gen_uuid()
UUID_CONFIG_RELEASE    = gen_uuid()
UUID_CONFIG_LIST       = gen_uuid()
UUID_TARGET_DEP        = gen_uuid()

# Main app target UUID (constant in this project)
MAIN_APP_UUID = "D5B24DD71DEE393B00D33B5A"

# Read file as lines
with open(PBXPROJ_PATH, "r") as f:
    lines = f.readlines()

output_lines = []
i = 0
while i < len(lines):
    line = lines[i]
    
    # === PBXBuildFile section: insert before End marker ===
    if line.strip() == '/* End PBXBuildFile section */':
        bf_line = '\t\t' + UUID_BUILDFILE_SWIFT + ' /* iosTncConfigUITests.swift in Sources */ = {isa = PBXBuildFile; fileRef = ' + UUID_FILEREF_SWIFT + ' /* iosTncConfigUITests.swift */; };\n'
        output_lines.append(bf_line)
        output_lines.append(line)
        i += 1
        continue
    
    # === PBXFileReference section: insert before End marker ===
    if line.strip() == '/* End PBXFileReference section */':
        fr_swift = '\t\t' + UUID_FILEREF_SWIFT + ' /* iosTncConfigUITests.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = iosTncConfigUITests.swift; sourceTree = "<group>"; };\n'
        fr_plist = '\t\t' + UUID_FILEREF_PLIST + ' /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };\n'
        output_lines.append(fr_swift)
        output_lines.append(fr_plist)
        output_lines.append(line)
        i += 1
        continue
    
    # === PBXGroup section: add folder to root group children (after Products child) ===
    if 'D5B24DD91DEE393B00D33B5A /* Products */,' in line and '\t\t\t' in line:
        output_lines.append(line)
        child_line = '\t\t\t' + UUID_GROUP_FOLDER + ' /* iosTncConfigUITests */,\n'
        output_lines.append(child_line)
        i += 1
        continue
    
    # === PBXGroup section: insert new group def before End marker ===
    if line.strip() == '/* End PBXGroup section */':
        grp_def = [
            '\t\t' + UUID_GROUP_FOLDER + ' /* iosTncConfigUITests */ = {\n',
            '\t\t\tisa = PBXGroup;\n',
            '\t\t\tchildren = (\n',
            '\t\t\t\t' + UUID_FILEREF_SWIFT + ' /* iosTncConfigUITests.swift */,\n',
            '\t\t\t\t' + UUID_FILEREF_PLIST + ' /* Info.plist */,\n',
            '\t\t\t);\n',
            '\t\t\tpath = iosTncConfigUITests;\n',
            '\t\t\tsourceTree = "<group>";\n',
            '\t\t};\n',
        ]
        output_lines.extend(grp_def)
        output_lines.append(line)
        i += 1
        continue
    
    # === PBXNativeTarget section: insert new target before End marker ===
    if line.strip() == '/* End PBXNativeTarget section */':
        tgt_dep_line = '\t\t' + UUID_TARGET_DEP + ' /* Target dependency */ = {isa = PBXTargetDependency; target = ' + MAIN_APP_UUID + ' /* Mobilinkd TNC Config */; };\n'
        output_lines.append(tgt_dep_line)
        
        tgt_def = [
            '\t\t' + UUID_TARGET + ' /* iosTncConfigUITests */ = {\n',
            '\t\t\tisa = PBXNativeTarget;\n',
            '\t\t\tbuildConfigurationList = ' + UUID_CONFIG_LIST + ' /* Build configuration list for PBXNativeTarget "iosTncConfigUITests" */;\n',
            '\t\t\tbuildPhases = (\n',
            '\t\t\t\t' + UUID_SOURCES_PHASE + ' /* Sources */,\n',
            '\t\t\t\t' + UUID_RESOURCES_PHASE + ' /* Resources */,\n',
            '\t\t\t);\n',
            '\t\t\tbuildRules = (\n',
            '\t\t\t);\n',
            '\t\t\tdependencies = (\n',
            '\t\t\t\t' + UUID_TARGET_DEP + ' /* Target dependency */,\n',
            '\t\t\t);\n',
            '\t\t\tname = iosTncConfigUITests;\n',
            '\t\t\tproductName = iosTncConfigUITests;\n',
            '\t\t\tproductReference = ' + UUID_FILEREF_PLIST + ' /* Info.plist */;\n',
            '\t\t\tproductType = "com.apple.product-type.bundle.ui-testing";\n',
            '\t\t};\n',
        ]
        output_lines.extend(tgt_def)
        output_lines.append(line)
        i += 1
        continue
    
    # === PBXProject section: add target to targets list (after main app target) ===
    if 'D5B24DD71DEE393B00D33B5A /* Mobilinkd TNC Config */,' in line and '\t\t\t' in line:
        output_lines.append(line)
        tgt_add = '\t\t\t' + UUID_TARGET + ' /* iosTncConfigUITests */,\n'
        output_lines.append(tgt_add)
        i += 1
        continue
    
    # === Insert new Sources build phase before Begin PBXResourcesBuildPhase ===
    if line.strip() == '/* Begin PBXResourcesBuildPhase section */':
        src_phase = [
            '\t\t' + UUID_SOURCES_PHASE + ' /* Sources */ = {\n',
            '\t\t\tisa = PBXSourcesBuildPhase;\n',
            '\t\t\tbuildActionMask = 2147483647;\n',
            '\t\t\tfiles = (\n',
            '\t\t\t\t' + UUID_BUILDFILE_SWIFT + ' /* iosTncConfigUITests.swift in Sources */,\n',
            '\t\t\t);\n',
            '\t\t\trunOnlyForDeploymentPostprocessing = 0;\n',
            '\t\t};\n',
        ]
        output_lines.extend(src_phase)
        output_lines.append('\n')
        output_lines.append(line)
        i += 1
        continue
    
    # === Insert new Resources build phase before End PBXResourcesBuildPhase ===
    if line.strip() == '/* End PBXResourcesBuildPhase section */':
        res_phase = [
            '\t\t' + UUID_RESOURCES_PHASE + ' /* Resources */ = {\n',
            '\t\t\tisa = PBXResourcesBuildPhase;\n',
            '\t\t\tbuildActionMask = 2147483647;\n',
            '\t\t\tfiles = (\n',
            '\t\t\t);\n',
            '\t\t\trunOnlyForDeploymentPostprocessing = 0;\n',
            '\t\t};\n',
        ]
        output_lines.extend(res_phase)
        output_lines.append(line)
        i += 1
        continue
    
    # === XCBuildConfiguration: insert new configs before End marker ===
    if line.strip() == '/* End XCBuildConfiguration section */':
        cfg_debug = [
            '\t\t' + UUID_CONFIG_DEBUG + ' /* Debug */ = {\n',
            '\t\t\tisa = XCBuildConfiguration;\n',
            '\t\t\tbuildSettings = {\n',
            '\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\n',
            '\t\t\t\tCLANG_ANALYZER_NONNULL = YES;\n',
            '\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++0x";\n',
            '\t\t\t\tCLANG_CXX_LIBRARY = "libc++";\n',
            '\t\t\t\tCLANG_ENABLE_MODULES = YES;\n',
            '\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;\n',
            '\t\t\t\tCODE_SIGNING_ALLOWED = NO;\n',
            '\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;\n',
            '\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;\n',
            '\t\t\t\tFRAMEWORK_SEARCH_PATHS = "$(inherited) $(TARGET_BUILD_DIR)/Mobilinkd_TNC_Config";\n',
            '\t\t\t\tINFOPLIST_FILE = "$(SRCROOT)/iosTncConfigUITests/Info.plist";\n',
            '\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;\n',
            '\t\t\t\tLD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";\n',
            '\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.mobilinkd.iosConfigApp.uitests;\n',
            '\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";\n',
            '\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;\n',
            '\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";\n',
            '\t\t\t\tSWIFT_VERSION = 5.0;\n',
            '\t\t\t};\n',
            '\t\t\tname = Debug;\n',
            '\t\t};\n',
        ]
        cfg_release = [
            '\t\t' + UUID_CONFIG_RELEASE + ' /* Release */ = {\n',
            '\t\t\tisa = XCBuildConfiguration;\n',
            '\t\t\tbuildSettings = {\n',
            '\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\n',
            '\t\t\t\tCLANG_ANALYZER_NONNULL = YES;\n',
            '\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = "gnu++0x";\n',
            '\t\t\t\tCLANG_CXX_LIBRARY = "libc++";\n',
            '\t\t\t\tCLANG_ENABLE_MODULES = YES;\n',
            '\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;\n',
            '\t\t\t\tCODE_SIGNING_ALLOWED = NO;\n',
            '\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";\n',
            '\t\t\t\tENABLE_NS_ASSERTIONS = NO;\n',
            '\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;\n',
            '\t\t\t\tFRAMEWORK_SEARCH_PATHS = "$(inherited) $(TARGET_BUILD_DIR)/Mobilinkd_TNC_Config";\n',
            '\t\t\t\tINFOPLIST_FILE = "$(SRCROOT)/iosTncConfigUITests/Info.plist";\n',
            '\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 15.0;\n',
            '\t\t\t\tLD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";\n',
            '\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.mobilinkd.iosConfigApp.uitests;\n',
            '\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";\n',
            '\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Owholemodule";\n',
            '\t\t\t\tSWIFT_VERSION = 5.0;\n',
            '\t\t\t};\n',
            '\t\t\tname = Release;\n',
            '\t\t};\n',
        ]
        output_lines.extend(cfg_debug)
        output_lines.extend(cfg_release)
        output_lines.append(line)
        i += 1
        continue
    
    # === XCConfigurationList: insert new config list before End marker ===
    if line.strip() == '/* End XCConfigurationList section */':
        cl_def = [
            '\t\t' + UUID_CONFIG_LIST + ' /* Build configuration list for PBXNativeTarget "iosTncConfigUITests" */ = {\n',
            '\t\t\tisa = XCConfigurationList;\n',
            '\t\t\tbuildConfigurations = (\n',
            '\t\t\t\t' + UUID_CONFIG_DEBUG + ' /* Debug */,\n',
            '\t\t\t\t' + UUID_CONFIG_RELEASE + ' /* Release */,\n',
            '\t\t\t);\n',
            '\t\t\tdefaultConfigurationIsVisible = 0;\n',
            '\t\t\tdefaultConfigurationName = Release;\n',
            '\t\t};\n',
        ]
        output_lines.extend(cl_def)
        output_lines.append(line)
        i += 1
        continue
    
    # Default: pass through line unchanged
    output_lines.append(line)
    i += 1

# Write pbxproj back
with open(PBXPROJ_PATH, "w") as f:
    f.writelines(output_lines)

print("pbxproj updated successfully.")
for label, uid in [
    ("BuildFile (Swift)", UUID_BUILDFILE_SWIFT),
    ("FileRef (Swift)", UUID_FILEREF_SWIFT),
    ("FileRef (Plist)", UUID_FILEREF_PLIST),
    ("Group (Folder)", UUID_GROUP_FOLDER),
    ("Target", UUID_TARGET),
    ("Sources Phase", UUID_SOURCES_PHASE),
    ("Resources Phase", UUID_RESOURCES_PHASE),
    ("Config Debug", UUID_CONFIG_DEBUG),
    ("Config Release", UUID_CONFIG_RELEASE),
    ("Config List", UUID_CONFIG_LIST),
    ("Target Dep", UUID_TARGET_DEP),
]:
    print(f"  {label}: {uid}")

# === Update scheme ===
with open(SCHEME_PATH, "r") as f:
    content = f.read()

test_target_ref = """         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{}"
            BuildableName = "iosTncConfigUITests.bundle"
            BlueprintName = "iosTncConfigUITests"
            ReferencedContainer = "container:Mobilinkd TNC Config.xcodeproj">
         </BuildableReference>""".format(UUID_TARGET)

content = content.replace(
    "      </MacroExpansion>",
    test_target_ref + "\n      </MacroExpansion>"
)

with open(SCHEME_PATH, "w") as f:
    f.write(content)

print("Scheme updated successfully.")
