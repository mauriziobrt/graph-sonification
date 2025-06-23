import json
import random
import string
from typing import List, Dict, Any

class NetworkGraphGenerator:
    def __init__(self):
        self.sample_users = [
            "Io", "MatinfarSalehi2023", "Chen2024", "Rodriguez2023", "Smith2024",
            "Johnson2023", "Williams2024", "Brown2023", "Davis2024", "Miller2023",
            "Wilson2024", "Moore2023", "Taylor2024", "Anderson2023", "Thomas2024"
        ]
        
        self.sample_descriptions = [
            "Sonification as a reliable alternative to conventional visual surgical navigation",
            "Machine learning approaches to medical data analysis",
            "Deep learning for image recognition in healthcare",
            "Natural language processing in clinical documentation",
            "Blockchain applications in healthcare data management",
            "IoT sensors for remote patient monitoring",
            "Artificial intelligence in drug discovery",
            "Computer vision for medical imaging analysis",
            "Federated learning in healthcare privacy",
            "Augmented reality in surgical procedures",
            "Robotic surgery optimization techniques",
            "Telemedicine platform development",
            "Wearable technology for health monitoring",
            "Big data analytics in population health",
            "Cybersecurity in medical device networks"
        ]
        
        self.open_access_types = ["gold", "green", "bronze", "hybrid", "closed"]
    
    def generate_node_id(self) -> str:
        """Generate a random node ID in the format like '21a' or '24b'"""
        number = random.randint(10, 99)
        letter = random.choice(string.ascii_lowercase)
        return f"{number}{letter}"
    
    def generate_node(self, cluster_id: int = 1) -> Dict[str, Any]:
        """Generate a single node with random data"""
        return {
            "id": self.generate_node_id(),
            "user": random.choice(self.sample_users),
            "cluster": cluster_id,
            "description": random.choice(self.sample_descriptions),
            "year": random.randint(2020, 2024),
            "openacces": random.choice(self.open_access_types),
            "citations": random.randint(1, 150)
        }
    
    def generate_cluster(self, cluster_size: int, cluster_id: int) -> List[Dict[str, Any]]:
        """Generate a cluster of connected nodes"""
        cluster_nodes = []
        for _ in range(cluster_size):
            cluster_nodes.append(self.generate_node(cluster_id))
        return cluster_nodes
    
    def generate_links_for_cluster(self, cluster_nodes: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Generate links within a cluster to ensure connectivity"""
        links = []
        node_ids = [node["id"] for node in cluster_nodes]
        
        # Ensure the cluster is connected by creating a spanning tree
        for i in range(1, len(node_ids)):
            # Connect each node to a random previous node
            source_idx = random.randint(0, i - 1)
            links.append({
                "source": node_ids[source_idx],
                "target": node_ids[i],
                "weight": random.randint(1, 10)
            })
        
        # Add some additional random connections within the cluster
        additional_connections = random.randint(0, len(node_ids) // 2)
        for _ in range(additional_connections):
            source = random.choice(node_ids)
            target = random.choice(node_ids)
            if source != target:
                # Check if link already exists
                existing_link = any(
                    (link["source"] == source and link["target"] == target) or
                    (link["source"] == target and link["target"] == source)
                    for link in links
                )
                if not existing_link:
                    links.append({
                        "source": source,
                        "target": target,
                        "weight": random.randint(1, 10)
                    })
        
        return links
    
    def generate_inter_cluster_links(self, all_nodes: List[Dict[str, Any]], 
                                   clusters: List[List[Dict[str, Any]]]) -> List[Dict[str, Any]]:
        """Generate sparse links between different clusters - DISABLED for identical clusters"""
        # For identical clusters, we don't want inter-cluster connections
        return []
    
    def generate_identical_clusters(self, num_clusters: int = 4, cluster_size: int = 5) -> Dict[str, Any]:
        """Generate identical clusters with different IDs and cluster numbers"""
        # First, generate a template cluster structure
        template_cluster = []
        for _ in range(cluster_size):
            template_node = {
                "user": random.choice(self.sample_users),
                "description": random.choice(self.sample_descriptions),
                "year": random.randint(2020, 2024),
                "openacces": random.choice(self.open_access_types),
                "citations": random.randint(1, 150)
            }
            template_cluster.append(template_node)
        
        # Generate template link structure (connectivity pattern)
        template_links = []
        # Create a connected structure within the cluster
        for i in range(1, cluster_size):
            # Connect each node to a random previous node
            source_idx = random.randint(0, i - 1)
            template_links.append({
                "source_idx": source_idx,
                "target_idx": i,
                "weight": random.randint(1, 10)
            })
        
        # Add some additional random connections within the cluster
        additional_connections = random.randint(0, cluster_size // 2)
        for _ in range(additional_connections):
            source_idx = random.randint(0, cluster_size - 1)
            target_idx = random.randint(0, cluster_size - 1)
            if source_idx != target_idx:
                # Check if link already exists
                existing_link = any(
                    (link["source_idx"] == source_idx and link["target_idx"] == target_idx) or
                    (link["source_idx"] == target_idx and link["target_idx"] == source_idx)
                    for link in template_links
                )
                if not existing_link:
                    template_links.append({
                        "source_idx": source_idx,
                        "target_idx": target_idx,
                        "weight": random.randint(1, 10)
                    })
        
        # Now create identical clusters with different IDs
        all_nodes = []
        all_links = []
        
        for cluster_id in range(1, num_clusters + 1):
            cluster_nodes = []
            
            # Create nodes based on template but with unique IDs and cluster numbers
            for template_node in template_cluster:
                node = template_node.copy()
                node["id"] = self.generate_node_id()
                node["cluster"] = cluster_id
                cluster_nodes.append(node)
            
            all_nodes.extend(cluster_nodes)
            
            # Create links based on template structure (only within this cluster)
            node_ids = [node["id"] for node in cluster_nodes]
            for template_link in template_links:
                all_links.append({
                    "source": node_ids[template_link["source_idx"]],
                    "target": node_ids[template_link["target_idx"]],
                    "weight": template_link["weight"]
                })
        
        # Ensure all node IDs are unique across all clusters
        used_ids = set()
        for node in all_nodes:
            original_id = node["id"]
            while node["id"] in used_ids:
                node["id"] = self.generate_node_id()
            used_ids.add(node["id"])
            
            # Update links if the ID changed
            if original_id != node["id"]:
                for link in all_links:
                    if link["source"] == original_id:
                        link["source"] = node["id"]
                    if link["target"] == original_id:
                        link["target"] = node["id"]
        
        return {
            "nodes": all_nodes,
            "links": all_links,
            "metadata": {
                "total_nodes": len(all_nodes),
                "total_clusters": num_clusters,
                "total_links": len(all_links),
                "cluster_size": cluster_size,
                "nodes_per_cluster": cluster_size
            }
        }

def main():
    """Main function to demonstrate the generator"""
    generator = NetworkGraphGenerator()
    
    # Generate network with identical clusters
    print("Generating network graph with 4 identical clusters...")
    print("Enter parameters (press Enter for defaults):")
    
    try:
        cluster_size = input("Size of each cluster (default: 5): ").strip()
        cluster_size = int(cluster_size) if cluster_size else 5
        
    except ValueError:
        print("Invalid input, using default cluster size of 5...")
        cluster_size = 5
    
    # Generate the network with identical clusters
    network = generator.generate_identical_clusters(num_clusters=4, cluster_size=cluster_size)
    
    # Print summary
    print(f"\nGenerated network with:")
    print(f"- {network['metadata']['total_clusters']} identical clusters")
    print(f"- {network['metadata']['cluster_size']} nodes per cluster")
    print(f"- {network['metadata']['total_nodes']} total nodes")
    print(f"- {network['metadata']['total_links']} total links")
    
    # Save to file
    output_file = "public/data/network_graph.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(network, f, indent=2, ensure_ascii=False)
    
    print(f"\nNetwork saved to {output_file}")
    
    # Display sample from each cluster
    print("\nPreview - One node from each cluster:")
    for cluster_id in range(1, 5):
        cluster_nodes = [node for node in network["nodes"] if node["cluster"] == cluster_id]
        if cluster_nodes:
            print(f"  Cluster {cluster_id}: {cluster_nodes[0]}")
    
    print("\nFirst 3 links:")
    for link in network["links"][:3]:
        print(f"  {link}")
    
    # Verify clusters are properly structured
    print("\nVerifying cluster structure...")
    clusters_by_id = {}
    for node in network["nodes"]:
        cluster_id = node["cluster"]
        if cluster_id not in clusters_by_id:
            clusters_by_id[cluster_id] = []
        clusters_by_id[cluster_id].append(node)
    
    print(f"✓ Cluster verification:")
    for cluster_id in sorted(clusters_by_id.keys()):
        print(f"  - Cluster {cluster_id}: {len(clusters_by_id[cluster_id])} nodes")
    
    # Verify no inter-cluster links
    inter_cluster_links = []
    for link in network["links"]:
        source_cluster = None
        target_cluster = None
        
        for node in network["nodes"]:
            if node["id"] == link["source"]:
                source_cluster = node["cluster"]
            if node["id"] == link["target"]:
                target_cluster = node["cluster"]
        
        if source_cluster != target_cluster:
            inter_cluster_links.append(link)
    
    if inter_cluster_links:
        print(f"⚠ Warning: Found {len(inter_cluster_links)} inter-cluster links")
        for link in inter_cluster_links:
            print(f"    {link}")
    else:
        print("✓ No inter-cluster connections found")
    
    # Check if all nodes belong to expected clusters
    expected_total = 4 * cluster_size
    if len(network["nodes"]) == expected_total:
        print(f"✓ Total nodes match expected: {expected_total}")
    else:
        print(f"⚠ Warning: Expected {expected_total} nodes, found {len(network['nodes'])}")

if __name__ == "__main__":
    main()