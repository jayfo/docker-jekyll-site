import requests
import unittest

import base.docker_base as docker_base


def setup():
    pass


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
