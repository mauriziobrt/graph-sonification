import json

json_file = "public/data/5-co-cit-coupling.json"

with open(json_file, "r", encoding="utf-8") as f:
    data = json.load(f)

# print(data["links"])
# "2-s2.0-0027170085"
#"2-s2.0-84893070216"]#, 
# path [ "2-s2.0-84988378007", "2-s2.0-84910045825", "2-s2.0-0040844859", "2-s2.0-0027170085", "2-s2.0-0034037674", "2-s2.0-0036624731" ]
# bubbles ["2-s2.0-0040844859", "2-s2.0-0036988701", "2-s2.0-84860066607", "2-s2.0-84892889849", "2-s2.0-84865992559", "2-s2.0-84894138585", "2-s2.0-85021884138", "2-s2.0-84979792051"]
my_ids = [ "2-s2.0-84988378007", "2-s2.0-84910045825", "2-s2.0-0040844859", "2-s2.0-0027170085", "2-s2.0-0034037674", "2-s2.0-0036624731" ]

filtered_set = []
filtered_elements = []

counter = 0
for el in data["links"]:
    # print(el)
    if el["source"] in my_ids or el["target"] in my_ids:
        counter += 1
        # print(el)
        filtered_elements.append(el["target"])
        filtered_elements.append(el["source"])
        filtered_set.append(el)

print(counter)
print(filtered_set)

filtered_nodes = []

for el in data["nodes"]:
    if el["id"] in set(filtered_elements): 
        filtered_nodes.append(el)      
        # print(el)

new_dict = {"nodes": filtered_nodes, "links": filtered_set}

output_file = "public/data/fake_son.json"

with open(output_file, "w", encoding="utf-8") as f:
        json.dump(new_dict, f, indent=4)
print(f"Filtered JSON saved to {output_file}")
