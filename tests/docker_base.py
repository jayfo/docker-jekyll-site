import jinja2
import os
import subprocess
import yaml


def _check_result(command, result):
    if result.returncode != 0:
        raise subprocess.CalledProcessError(
            result.returncode,
            command
        )


def _compose_localize(file_compose, file_compose_localized):
    # Compile our test compose configuration into a localized version
    jinja2_environment = jinja2.Environment(
        loader=jinja2.FileSystemLoader(searchpath='.'),
        undefined=jinja2.StrictUndefined
    )
    template = jinja2_environment.get_template(file_compose)
    with open(file_compose_localized, 'w') as f:
        f.write(template.render({
            'CWD': os.path.normpath(os.getcwd()).replace('\\', '/')
        }))


def compose_ensure_up(file_compose, service):
    machine_ensure()
    compose_run(file_compose, 'build {}'.format(service))
    compose_run(file_compose, 'up -d {}'.format(service))


def compose_run(file_compose, compose_command, check_result=True):
    # Parse our compile config
    with open('_compile-config.yml') as f:
        compile_config_yaml = yaml.safe_load(f)

    # Localize our compose file
    file_compose_localized = '{}{}{}'.format(
        os.path.splitext(file_compose)[0],
        '.localized',
        os.path.splitext(file_compose)[1]
    )
    _compose_localize(file_compose, file_compose_localized)

    # Assemble our command
    if 'BASE_DOCKER_ON_TRAVIS' in os.environ:
        command = 'docker-compose -f "{}" {}'.format(
            file_compose_localized,
            compose_command
        )
    else:
        command = '"{}" "{}" docker-compose -f "{}" {}'.format(
            compile_config_yaml['config']['local']['docker']['cmd_bash'],
            os.path.normpath(os.path.join(os.getcwd(), 'base/docker-machine/machine_bash.sh')).replace('\\', '/'),
            os.path.normpath(os.path.join(os.getcwd(), file_compose_localized)).replace('\\', '/'),
            compose_command
        )

    # Call the command
    result = subprocess.run(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    if check_result:
        _check_result(command, result)

    return result


def docker_run(docker_command, check_result=True):
    # Parse our compile config
    with open('_compile-config.yml') as f:
        compile_config_yaml = yaml.safe_load(f)

    # Assemble our command
    if 'BASE_DOCKER_ON_TRAVIS' in os.environ:
        command = 'docker {}'.format(
            docker_command
        )
    else:
        command = '"{}" "{}" docker {}'.format(
            compile_config_yaml['config']['local']['docker']['cmd_bash'],
            os.path.normpath(os.path.join(os.getcwd(), 'base/docker-machine/machine_bash.sh')).replace('\\', '/'),
            docker_command
        )

    # Call the command
    result = subprocess.run(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    if check_result:
        _check_result(command, result)

    return result


def machine_console():
    # Parse our compile config
    with open('_compile-config.yml') as f:
        compile_config_yaml = yaml.safe_load(f)

    # Assemble our command
    command = 'cmd /c start "{}" "{}"'.format(
        compile_config_yaml['config']['local']['docker']['cmd_bash'],
        os.path.normpath(os.path.join(os.getcwd(), 'base/docker-machine/machine_console.sh')).replace('\\', '/')
    )

    # Call the command, noting that this cannot be piped
    subprocess.run(
        command
    )


def machine_ensure():
    # On Travis, docker is already available
    if 'BASE_DOCKER_ON_TRAVIS' in os.environ:
        return

    # Parse our compile config
    with open('_compile-config.yml') as f:
        compile_config_yaml = yaml.safe_load(f)

    # Assemble our command
    command = '"{}" "{}"'.format(
        compile_config_yaml['config']['local']['docker']['cmd_bash'],
        os.path.normpath(os.path.join(os.getcwd(), 'base/docker-machine/machine_ensure.sh')).replace('\\', '/')
    )

    # Call the command
    result = subprocess.run(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    _check_result(command, result)


def ip():
    # On Travis, docker is already available
    if 'BASE_DOCKER_ON_TRAVIS' in os.environ:
        return 'localhost'

    # Parse our compile config
    with open('_compile-config.yml') as f:
        compile_config_yaml = yaml.safe_load(f)

    # Assemble our command
    command = '"{}" ip default'.format(
        compile_config_yaml['config']['local']['docker']['cmd_dockermachine']
    )

    # Call the command
    result = subprocess.run(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    _check_result(command, result)

    ip_address = result.stdout.decode('utf-8', 'backslashreplace').strip()

    return ip_address
