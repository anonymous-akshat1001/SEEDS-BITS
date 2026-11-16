import json,sys
keys=json.load(open(r"lib\l10n\app_en.arb",encoding="utf-8"))
for s in sys.stdin.read().split("\n"):
    if not s: continue
    m=[k for k,v in keys.items() if not k.startswith("@") and v==s]
    print(repr(s),"->",m[:6])
