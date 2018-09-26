import importlib
import invoke
import requests

task_module_names = [
    'base.invoke.tasks.compile',
    'base.invoke.tasks.dependencies',
    'base.invoke.tasks.docker',
]

# Create our task collection
tasks = invoke.Collection()

# Populate it with the tasks in each module
for module_name_current in task_module_names:
    module_loaded = importlib.import_module(module_name_current)

    # Add each task from that module
    module_collection = invoke.Collection.from_module(module_loaded)
    for task_name_current in module_collection.task_names.keys():
        tasks.add_task(module_collection[task_name_current], task_name_current)

# Invoke expects the default collection to be named 'ns'
ns = tasks


@invoke.task()
def compile_download_base_dependencies():
    files_dependencies = [
        'Gemfile',
        'Gemfile.lock',
        'npm-shrinkwrap.json',
        'package.json',
        'requirements3.txt'
    ]

    for file_current in files_dependencies:
        response = requests.get(
            'https://raw.githubusercontent.com/fogies/web-jekyll-base/master/{}'.format(file_current)
        )

        with open('docker-jekyll-site/{}'.format(file_current), 'wb') as f:
            for chunk in response.iter_content(chunk_size=1024):
                f.write(chunk)


ns.add_task(compile_download_base_dependencies)
