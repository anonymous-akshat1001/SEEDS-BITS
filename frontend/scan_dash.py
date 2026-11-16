import re,sys
files=sys.argv[1:]
pat=re.compile(r"""(?<![A-Za-z])(r?)('(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*")""")
for f in files:
    print("=====",f)
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        s=l.strip()
        if s.startswith('import ') or s.startswith('//') or 'debugPrint' in s or s.startswith('export '): continue
        lits=[m.group(2) for m in pat.finditer(l)]
        lits=[x for x in lits if re.search(r'[A-Za-z]',x)]
        if lits: print(i, s[:220])
