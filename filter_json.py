import json
import csv

def filter_json(json_file, tsv_file, output_file, csv_file):
    # Load JSON data
    with open(json_file, "r", encoding="utf-8") as f:
        data = json.load(f)
    tmp_new = []
    with open(csv_file, "r", encoding="utf-8") as f:
        data_csv = csv.reader(f, delimiter=',')
        for row in data_csv:
            if row:
                if row[3]!= "weight":
                    # print(row[3])
                    tmp_new.append({"source": row[0],"target":row[1],"weight": int(row[3])})
            # valid_keys.add(row[0])
    # tmp_new = tmp_new[1:]
    # print(tmp_new)
    # Load TSV first column values
    valid_keys = set()
    valid_names = []
    tmp_nodes = []
    with open(tsv_file, "r", encoding="utf-8") as f:
        reader = csv.reader(f, delimiter="\t")
        for row in reader:
            if row:
                tmp_nodes.append({"id": row[0],"user":row[1],"description": row[2]})
                # valid_names.append([row[0],row[2]])
                valid_keys.add(row[0])
    tmp_nodes = tmp_nodes[1:]
    # Check if JSON values are lists or empty
    filtered_data = {}
    for key, value in data.items():
        if key in valid_keys:
            if isinstance(value, list):
                filtered_data[key] = [v for v in value if v in valid_keys]
            else:
                filtered_data[key] = value
    # tmp_links = []
    # print(data.items())
    result = [
        {"source": key, "target": value}
        for key, values in data.items()
        for value in values
        if key in valid_keys and value in valid_keys
    ]
    # result = [{"source": key, "target": value} for key, values in data.items() for value in values if key and value in valid_keys ]
    # print(result)
    # print(result)
    my_dict = {"nodes": tmp_nodes, "links": tmp_new}
    # for el, i in enumerate(filtered_data):
    #     print(i)
    # print(filtered_data)
#{"nodes":[{"id":"4062045","user":"mbostock","description":"Force-Directed Graph"}, {"id":"1341021","user":"mbostock","description":"Parallel Coordinates"}], 
# "links":[{"source":"950642","target":"4062045"}, {"source":"950642","target":"4062045"}]}
    # Save new JSON
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(my_dict, f, indent=4)
    print(f"Filtered JSON saved to {output_file}")

# Example usage
filter_json("6d. CitDict.json", "9. final_list.tsv", "correct_output.json", "out.csv")