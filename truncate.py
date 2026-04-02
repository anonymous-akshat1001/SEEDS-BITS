import os

filepath = r'c:\flutter_projects\SEEDS-BITS latest\frontend\lib\screens\audio_library_screen.dart'

with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

print(f'Original line count: {len(lines)}')

# Keep only lines 1-1973 (index 0-1972)
keep = lines[:1973]

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(keep)

print(f'New line count: {len(keep)}')
print('Done!')
