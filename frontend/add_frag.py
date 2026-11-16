import json,sys,os,re
F=r"c:\Users\t-akagrawal\.copilot\session-state\2ba6bb4f-577f-4fc1-943b-f1caaae70f39\files\fragments\dashboards.json"
frag=json.load(open(F,encoding="utf-8")) if os.path.exists(F) else {}
new=json.loads(sys.stdin.read())
for k,v in new.items():
    if k.startswith("@"): frag[k]=v; continue
    frag[k]=v
    names=re.findall(r"\{(\w+)\}",v)
    names=[n for n in dict.fromkeys(re.findall(r"\{(\w+)(?:,|\})",v))]
    if names and "@"+k not in new:
        frag["@"+k]={"placeholders":{n:{"type":"String"} for n in names}}
json.dump(frag,open(F,"w",encoding="utf-8"),ensure_ascii=False,indent=2)
print(len([k for k in frag if not k.startswith("@")]))
