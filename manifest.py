import os
import json

reject_list = [
    '.snakemake',
    '.git',
    '.github',
    'logs',
]


def create_folder_structure_json(path):
    # Initialize the result dictionary with
    # folder name, type, and an empty list for children
    result = {
        'name': os.path.basename(path),
        'type': 'folder',
        'children': [],
    }

    # Check if the path is a directory
    if not os.path.isdir(path):
        return result

    # Iterate over the entries in the directory
    for entry in os.listdir(path):
        entry_path = os.path.join(path, entry)
        if os.path.isdir(entry_path) and entry_path not in reject_list:
            result['children'].append(create_folder_structure_json(entry_path))
        else:
            result['children'].append({'name': entry, 'type': 'file'})

    return result


folder_json = create_folder_structure_json('.')
folder_json_str = json.dumps(folder_json)
output_file = 'manifest.json'

with open(output_file, 'w') as f:
    f.write(folder_json_str)
