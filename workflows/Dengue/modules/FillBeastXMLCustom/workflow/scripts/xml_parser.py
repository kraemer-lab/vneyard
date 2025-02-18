import re
import sys
from jinja2 import Environment, FileSystemLoader
import os

def parse_nexus_taxa(nexus_text):
    """
    Parses the taxa block from a Nexus file.
    Returns the number of taxa and a list of taxa with their IDs and dates.
    """
    taxa_block = re.search(r'Begin\s+taxa;(.+?)End;', nexus_text, re.DOTALL | re.IGNORECASE)
    if not taxa_block:
        raise ValueError("No taxa block found in the Nexus file.")

    taxa_text = taxa_block.group(1)

    # Extract ntax
    ntax_match = re.search(r'Dimensions\s+ntax\s*=\s*(\d+);', taxa_text, re.IGNORECASE)
    if not ntax_match:
        raise ValueError("Number of taxa (ntax) not found.")
    ntax = int(ntax_match.group(1))

    # Extract Taxlabels
    taxlabels_match = re.search(r'Taxlabels\s+(.+?);', taxa_text, re.DOTALL | re.IGNORECASE)
    if not taxlabels_match:
        raise ValueError("Taxlabels not found.")
    taxlabels_text = taxlabels_match.group(1)

    # Split by whitespace and filter out empty strings
    taxlabels = [label.strip() for label in taxlabels_text.strip().split() if label.strip()]
    if len(taxlabels) != ntax:
        raise ValueError(f"Number of taxlabels ({len(taxlabels)}) does not match ntax ({ntax}).")

    # Parse each taxon
    taxa = []
    for taxon in taxlabels:
        parts = taxon.split('|')
        if len(parts) < 7:
            raise ValueError(f"Taxon '{taxon}' does not have enough fields.")
        taxon_id = taxon
        date_value = parts[-1]  # Assuming the last part is the date in decimal years
        taxa.append({
            'id': taxon_id,
            'date': date_value
        })

    return ntax, taxa

def parse_nexus_tree(nexus_text):
    """
    Parses the first tree from the trees block in a Nexus file.
    Returns the Newick-formatted tree string.
    """
    trees_block = re.search(r'Begin\s+trees;(.+?)End;', nexus_text, re.DOTALL | re.IGNORECASE)
    if not trees_block:
        raise ValueError("No trees block found in the Nexus file.")

    trees_text = trees_block.group(1)

    # Extract the first tree
    tree_match = re.search(r'Tree\s+\w+\s*=\s*(.+?);', trees_text, re.DOTALL | re.IGNORECASE)
    if not tree_match:
        raise ValueError("No tree definition found in the trees block.")

    tree = tree_match.group(1).strip()

    return tree

def render_template(template_path, output_path, context):
    """
    Renders the Jinja2 template with the provided context and writes to the output file.
    """
    # Set up Jinja2 environment
    env = Environment(
        loader=FileSystemLoader(searchpath=os.path.dirname(template_path)),
        trim_blocks=True,
        lstrip_blocks=True
    )

    template_name = os.path.basename(template_path)
    template = env.get_template(template_name)

    # Render the template with the context
    rendered_xml = template.render(context)

    # Write the rendered XML to the output file
    with open(output_path, 'w') as file:
        file.write(rendered_xml)
    print(f"Filled XML written to '{output_path}'.")

def main():
    import argparse

    parser = argparse.ArgumentParser(description='Fill BEAST XML template with taxa and tree data from a Nexus file.')
    parser.add_argument('-n', '--nexus', required=True, help='Path to the Nexus file containing taxa and tree data.')
    parser.add_argument('-o', '--output_stem', required=True, help='Output stem for generated files.')
    parser.add_argument('-p', '--template', default='template.j2', help='Path to the Jinja2 XML template.')
    parser.add_argument('-c', '--chain_length', type=int, default=10000000, help='Chain length for MCMC (default: 10000000).')
    parser.add_argument('-f', '--filled_xml', default=None, help='Path for the output filled XML. If not provided, it will be derived from output_stem.')

    args = parser.parse_args()

    # Check if Nexus file exists
    if not os.path.exists(args.nexus):
        print(f"Error: Nexus file '{args.nexus}' not found.")
        sys.exit(1)

    # Read the Nexus file content
    with open(args.nexus, 'r') as file:
        nexus_text = file.read()

    try:
        # Parse taxa
        ntax, taxa = parse_nexus_taxa(nexus_text)
        print(f"Parsed {ntax} taxa from '{args.nexus}'.")
    except Exception as e:
        print(f"Error parsing taxa: {e}")
        sys.exit(1)

    try:
        # Parse tree
        tree = parse_nexus_tree(nexus_text)
        print(f"Parsed tree from '{args.nexus}'.")
    except Exception as e:
        print(f"Error parsing tree: {e}")
        sys.exit(1)

    # Determine the output XML filename
    if args.filled_xml:
        filled_xml = args.filled_xml
    else:
        filled_xml = f"{args.output_stem}.xml"

    # Prepare context for templating
    chain_length = args.chain_length

    # Adjusted settings based on user instructions:
    # logEvery should be 10,000 times less frequent than original (assumed original=1000 -> 10000)
    log_every = chain_length // 10000

    # checkpointEvery and checkpointFinal should be 10 times less frequent than original
    # Assuming original checkpointEvery=1000000, checkpointFinal=10000000
    checkpoint_every = chain_length // 10  # 100000
    checkpoint_final = chain_length // 10  # 1000000

    # Calculate ntax_div_100 as a floating-point number with six decimal places
    ntax_div_100 = "{0:.6f}".format(ntax / 100.0)

    context = {
        'ntax': ntax,
        'taxa': taxa,
        'tree': tree,
        'output_stem': args.output_stem,
        'ntax_div_100': ntax_div_100,
        'chain_length': chain_length,
        'log_every': log_every,
        'checkpoint_every': checkpoint_every,
        'checkpoint_final': checkpoint_final
    }

    # Render the template
    try:
        render_template(args.template, filled_xml, context)
    except Exception as e:
        print(f"Error rendering template: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

