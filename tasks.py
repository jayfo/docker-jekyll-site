import tests.docker_base as docker_base
import invoke
import jinja2
import os
import sys
import yaml


def check_result(result, description):
    if result.failed:
        print('========================================')
        print('Failed to {}'.format(description))
        print('')
        print('========================================')
        print('STDOUT:')
        print('========================================')
        print(result.stdout)
        print('========================================')
        print('STDERR:')
        print('========================================')
        print(result.stderr)
        print('========================================')
        raise Exception('Failed to {}'.format(description))


@invoke.task()
def compile_config():
    # Parse our compile config
    with open('_compile-config.yml') as f:
        compile_config_yaml = yaml.safe_load(f)

    # Compile each jinja2 file
    for jinja2_entry in compile_config_yaml['jinja2']['entries']:
        jinja2_environment = jinja2.Environment(
            loader=jinja2.FileSystemLoader(searchpath='.'),
            undefined=jinja2.StrictUndefined
        )
        template = jinja2_environment.get_template(jinja2_entry['in'])
        with open(jinja2_entry['out'], 'w') as f:
            f.write(template.render(compile_config_yaml['config']))


@invoke.task()
def docker_machine_console():
    docker_base.machine_console()


@invoke.task()
def docker_machine_ensure():
    docker_base.machine_ensure()


@invoke.task()
def docker_machine_ip():
    print(docker_base.ip())


@invoke.task()
def docker_machine_start():
    docker_base.machine_ensure()
    docker_base.compose_run('tests/test-compose.yml', 'build')
    docker_base.compose_run('tests/test-compose.yml', 'up -d')


@invoke.task()
def docker_machine_stop():
    docker_base.compose_run('tests/test-compose.yml', 'stop')


@invoke.task
def update_base():
    invoke.run('git pull https://github.com/fogies/docker-base.git master', encoding=sys.stdout.encoding)
    invoke.run('git pull https://github.com/fogies/testwithdocker-base.git master', encoding=sys.stdout.encoding)
