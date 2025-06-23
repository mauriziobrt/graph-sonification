import json
import copy

def replicate_graph_clusters(original_data, num_clusters=4):
    """
    Replicate a force graph into multiple identical clusters with modified IDs.
    
    Args:
        original_data (dict): Original graph data with 'nodes' and 'links'
        num_clusters (int): Number of total clusters to create (including original)
    
    Returns:
        dict: New graph data with replicated clusters
    """
    
    # Initialize the result with empty nodes and links
    result_data = {
        "nodes": [],
        "links": []
    }
    
    # Process each cluster
    for cluster_idx in range(num_clusters):
        cluster_suffix = f"_cluster_{cluster_idx}"
        
        # Create ID mapping for this cluster
        id_mapping = {}
        
        # Process nodes for this cluster
        for node in original_data["nodes"]:
            # Create new node with modified ID
            new_node = copy.deepcopy(node)
            old_id = node["id"]
            new_id = old_id + cluster_suffix
            new_node["id"] = new_id
            new_node["cluster"] = cluster_idx + 1
            # Store the mapping for links processing
            id_mapping[old_id] = new_id
            
            # Add to result
            result_data["nodes"].append(new_node)
        
        # Process links for this cluster
        for link in original_data["links"]:
            # Create new link with modified source and target IDs
            new_link = copy.deepcopy(link)
            new_link["source"] = id_mapping[link["source"]]
            new_link["target"] = id_mapping[link["target"]]
            
            # Add to result
            result_data["links"].append(new_link)
    
    return result_data

def load_json_from_file(file_path):
    """Load JSON data from file."""
    with open(file_path, 'r', encoding='utf-8') as file:
        return json.load(file)

def save_json_to_file(data, file_path):
    """Save JSON data to file."""
    with open(file_path, 'w', encoding='utf-8') as file:
        json.dump(data, file, indent=2, ensure_ascii=False)

# Example usage
if __name__ == "__main__":
    # Your original data (can also be loaded from file)
   original_file = load_json_from_file("public/data/fake_son.json")
   save_json_to_file(replicate_graph_clusters(original_file, 4), "public/data/fab_son.json")