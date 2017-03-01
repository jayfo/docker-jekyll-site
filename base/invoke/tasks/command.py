import subprocess
import sys


def run(command, error_on_failure=True):
    # for line in process.stdout:
    #     flag_print = line.startswith('Step ')
    #
    #     if flag_print:
    #         print(line, end='', flush=True)

    # # Parameters to keep everything silent
    # params_silent = {
    #     # Some of the commands output characters that cause Unicode errors on Windows,
    #     # so we set an encoding that will help the command line behave
    #     'encoding': sys.stdout.encoding,
    #     'hide': 'both',
    #     'warn': True
    # }
    #
    #
    # result = invoke.run(command, **params_silent)
    #
    process = subprocess.Popen(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )
    process.wait()

    process.stdout = process.stdout.read()
    process.stderr = process.stderr.read()
    process.failed = process.returncode != 0

    if process.failed:
        if error_on_failure:
            print(
                (
                    '========================================\n'
                    'Command failed with error code: {}\n'
                    '========================================\n'
                    'COMMAND:\n'
                    '========================================\n'
                    '{}'
                    '\n'
                    '========================================\n'
                    'STDOUT:\n'
                    '========================================\n'
                    '{}'
                    '\n'
                    '========================================\n'
                    'STDERR:\n'
                    '========================================\n'
                    '{}'
                    '\n'
                    '========================================\n'
                ).format(
                    process.returncode,
                    command,
                    process.stdout,
                    process.stderr
                ),
                file=sys.stderr, flush=True
            )

            raise subprocess.CalledProcessError(
                process.returncode,
                command
            )

    return process
