"""Inspect universal-APK ABIs and 16 KB native alignment without an emulator.

Checks ELF PT_LOAD segments and ZIP offsets of uncompressed 64-bit libraries.
This is a packaging check; runtime tests on devices are still needed.
"""
import argparse
import json
import struct
import sys
import zipfile


def inspect(apk_path):
    failures, libraries, abis = [], [], set()
    with zipfile.ZipFile(apk_path) as apk:
        for entry in apk.infolist():
            parts = entry.filename.split('/')
            if len(parts) != 3 or parts[0] != 'lib' or not parts[2].endswith('.so'):
                continue
            abi = parts[1]
            abis.add(abi)
            if abi not in ('arm64-v8a', 'x86_64'):
                continue
            with apk.open(entry) as native:
                header = native.read(64)
                if header[:4] != b'\x7fELF' or header[4] != 2:
                    failures.append(f'{entry.filename}: expected ELF64')
                    continue
                endian = '<' if header[5] == 1 else '>'
                offset = struct.unpack_from(endian + 'Q', header, 32)[0]
                size, count = struct.unpack_from(endian + 'HH', header, 54)
                native.seek(offset)
                segments = native.read(size * count)
                alignments = []
                for i in range(count):
                    segment = segments[i * size:(i + 1) * size]
                    if struct.unpack_from(endian + 'I', segment)[0] != 1:
                        continue
                    file_offset, virtual_address = struct.unpack_from(endian + 'QQ', segment, 8)
                    alignment = struct.unpack_from(endian + 'Q', segment, 48)[0]
                    alignments.append(alignment)
                    if alignment < 16384 or (virtual_address - file_offset) % 16384:
                        failures.append(f'{entry.filename}: PT_LOAD is not 16 KB aligned')
                if not alignments:
                    failures.append(f'{entry.filename}: no PT_LOAD segments')
            apk.fp.seek(entry.header_offset)
            local_header = apk.fp.read(30)
            name_size, extra_size = struct.unpack_from('<HH', local_header, 26)
            data_offset = entry.header_offset + 30 + name_size + extra_size
            stored = entry.compress_type == zipfile.ZIP_STORED
            if stored and data_offset % 16384:
                failures.append(f'{entry.filename}: uncompressed ZIP data is not 16 KB aligned')
            libraries.append({'path': entry.filename, 'load_alignments': alignments,
                              'uncompressed': stored, 'zip_offset': data_offset})
    for required in ('armeabi-v7a', 'arm64-v8a', 'x86_64'):
        if required not in abis:
            failures.append(f'Missing expected universal-APK ABI: {required}')
    if not libraries:
        failures.append('No 64-bit native libraries found')
    return {'apk': str(apk_path), 'abis': sorted(abis),
            'native_64bit_libraries': libraries, 'failures': failures}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('apk')
    args = parser.parse_args()
    try:
        result = inspect(args.apk)
        print(json.dumps(result, indent=2))
        sys.exit(1 if result['failures'] else 0)
    except (OSError, ValueError, struct.error, zipfile.BadZipFile) as error:
        print(f'Cannot inspect APK: {error}', file=sys.stderr)
        sys.exit(1)
