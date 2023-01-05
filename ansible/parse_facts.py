import json

with open('ke5rcs.facts', 'r') as fin:
    lines = fin.readlines()
    lines[0] = '{\n'
with open('ke5rcs_facts.json', 'w') as fout:
    for l in lines:
        fout.write(l)

print("done")

with open('ke5rcs_facts.json','r') as fin:
    data = fin.read()
    data_dict = json.loads(data)

bloc = raw_data.find("{")
print(d

