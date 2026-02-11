#!/usr/bin/env python3
"""
Script to add Swift files to Xcode project programmatically
"""
import os
import re
import uuid

# Files to add (relative to BarcodeScanner/)
FILES_TO_ADD = {
    'BarcodeScanner': [
        'BarcodeScanner/Models/QualityMetrics.swift',
        'BarcodeScanner/Models/ScanRecord.swift',
        'BarcodeScanner/Services/BarcodeScannerService.swift',
        'BarcodeScanner/Services/MockScannerService.swift',
        'BarcodeScanner/Services/QualityAssessmentService.swift',
        'BarcodeScanner/Utilities/CameraPermissionManager.swift',
        'BarcodeScanner/ViewModels/HistoryViewModel.swift',
        'BarcodeScanner/ViewModels/ScannerViewModel.swift',
        'BarcodeScanner/Views/CameraPreview.swift',
        'BarcodeScanner/Views/HistoryView.swift',
        'BarcodeScanner/Views/MultiBarcodeOverlay.swift',
        'BarcodeScanner/Views/ResultView.swift',
        'BarcodeScanner/Views/ScannerView.swift',
    ],
    'BarcodeScannerTests': [
        'BarcodeScannerTests/Models/QualityMetricsTests.swift',
        'BarcodeScannerTests/Models/ScanRecordTests.swift',
        'BarcodeScannerTests/Services/BarcodeScannerServiceTests.swift',
        'BarcodeScannerTests/Services/MockScannerServiceTests.swift',
        'BarcodeScannerTests/Services/QualityAssessmentServiceTests.swift',
        'BarcodeScannerTests/Utilities/CameraPermissionManagerTests.swift',
        'BarcodeScannerTests/Integration/ScanFlowTests.swift',
    ]
}

PROJECT_FILE = 'BarcodeScanner/BarcodeScanner.xcodeproj/project.pbxproj'

def generate_uuid():
    """Generate a 24-character hex UUID (Xcode style)"""
    return uuid.uuid4().hex[:24].upper()

def read_project():
    """Read the project.pbxproj file"""
    with open(PROJECT_FILE, 'r') as f:
        return f.read()

def write_project(content):
    """Write the project.pbxproj file"""
    with open(PROJECT_FILE, 'w') as f:
        f.write(content)

def add_files_to_project():
    """Add Swift files to the Xcode project"""
    content = read_project()

    print("🔍 Reading project.pbxproj...")

    # Track changes
    file_refs = []
    build_file_refs = []

    for target, files in FILES_TO_ADD.items():
        print(f"\n📁 Processing {len(files)} files for target: {target}")

        for file_path in files:
            filename = os.path.basename(file_path)

            # Check if file already exists in project
            if filename in content and file_path in content:
                print(f"  ⏭️  {filename} - already in project")
                continue

            # Generate UUIDs for this file
            file_ref_uuid = generate_uuid()
            build_file_uuid = generate_uuid()

            # Create PBXFileReference entry
            file_ref_entry = f'''\t\t{file_ref_uuid} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = "<group>"; }};'''

            # Create PBXBuildFile entry
            build_file_entry = f'''\t\t{build_file_uuid} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* {filename} */; }};'''

            file_refs.append((file_ref_uuid, filename, file_path, file_ref_entry))
            build_file_refs.append((build_file_uuid, file_ref_uuid, filename, build_file_entry))

            print(f"  ✅ {filename} - will be added")

    if not file_refs:
        print("\n✨ All files are already in the project!")
        return False

    # Add PBXBuildFile entries
    print(f"\n📝 Adding {len(build_file_refs)} build file entries...")
    build_files_section = re.search(r'(/\* Begin PBXBuildFile section \*/.*?/\* End PBXBuildFile section \*/)', content, re.DOTALL)
    if build_files_section:
        section_end = build_files_section.group(1).rfind('/* End PBXBuildFile section */')
        insert_pos = build_files_section.start(1) + section_end

        for _, _, _, entry in build_file_refs:
            content = content[:insert_pos] + entry + '\n' + content[insert_pos:]
            insert_pos += len(entry) + 1

    # Add PBXFileReference entries
    print(f"📝 Adding {len(file_refs)} file reference entries...")
    file_refs_section = re.search(r'(/\* Begin PBXFileReference section \*/.*?/\* End PBXFileReference section \*/)', content, re.DOTALL)
    if file_refs_section:
        section_end = file_refs_section.group(1).rfind('/* End PBXFileReference section */')
        insert_pos = file_refs_section.start(1) + section_end

        for _, _, _, entry in file_refs:
            content = content[:insert_pos] + entry + '\n' + content[insert_pos:]
            insert_pos += len(entry) + 1

    # Add files to PBXSourcesBuildPhase (compilation)
    print("📝 Adding files to build phases...")
    for target in FILES_TO_ADD.keys():
        # Find the sources build phase for this target
        sources_phase_pattern = rf'(.*?{target}.*?PBXSourcesBuildPhase.*?files = \()(.*?)(\);)'
        sources_match = re.search(sources_phase_pattern, content, re.DOTALL)

        if sources_match:
            files_section = sources_match.group(2)
            insert_pos = sources_match.end(2)

            target_files = [bf for bf in build_file_refs if any(f[1] in FILES_TO_ADD[target] for f in file_refs if f[0] == bf[1])]

            for build_uuid, file_uuid, filename, _ in target_files:
                file_entry = f'\n\t\t\t\t{build_uuid} /* {filename} in Sources */,'
                content = content[:insert_pos] + file_entry + content[insert_pos:]
                insert_pos += len(file_entry)

    print("💾 Writing updated project.pbxproj...")
    write_project(content)

    print(f"\n✅ Successfully added {len(file_refs)} files to the Xcode project!")
    return True

if __name__ == '__main__':
    print("🚀 Adding Swift files to Xcode project...\n")
    try:
        if add_files_to_project():
            print("\n🎉 Done! The project should now build successfully.")
            print("💡 You may need to open Xcode and clean build folder (Shift+Cmd+K) before building.")
        else:
            print("\n👍 Project is already up to date!")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
