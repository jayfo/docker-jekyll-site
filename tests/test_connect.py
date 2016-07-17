import tests.docker_base as docker_base
import requests
import unittest


def setup():
    docker_base.compose_ensure_up(
        'tests/test-compose.yml',
        'tests_main'
    )


def teardown():
    pass


class TestConnect(unittest.TestCase):
    def test_connect(self):
        response = requests.get(
            'http://{}'.format(
                docker_base.ip()
            )
        )

        print(response.content)

        self.assertEqual(
            response.status_code,
            200
        )

