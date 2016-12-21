import os
import base.docker_base as docker_base
import unittest

#
# These tests currently do all file manipulation within containers using Docker exec:
#
# https://denibertovic.com/posts/handling-permissions-with-docker-volumes/
#


def setup():
    pass


def teardown():
    pass


class TestPublish(unittest.TestCase):
    TEST_FILE = 'css/base/bar/styles.css'

    def test_publish_local(self):
        # Ensure the target directory exists
        docker_base.docker_run(
            'exec test_destination_local '
            'mkdir -p /docker-jekyll-site/test_publish_local/site'
        )

        # Empty out the target directory
        docker_base.docker_run(
            'exec test_destination_local '
            'find /docker-jekyll-site/test_publish_local/site -mindepth 1 -delete'
        )

        # Ensure the file we expect is not already there
        result = docker_base.docker_run(
            'exec test_destination_local '
            'ls /docker-jekyll-site/test_publish_local/site/{}'.format(TestPublish.TEST_FILE),
            check_result=False
        )
        self.assertNotEqual(
            result.returncode,
            0,
            'Could not remove expected file'
        )

        # Put a junk file in the target, to confirm it is removed
        docker_base.docker_run(
            'exec test_destination_local '
            'touch /docker-jekyll-site/test_publish_local/site/junk'
        )

        # Ensure our junk is there
        result = docker_base.docker_run(
            'exec test_destination_local '
            'ls /docker-jekyll-site/test_publish_local/site/junk',
            check_result=False
        )
        self.assertEqual(
            result.returncode,
            0,
            'Could not create expected file'
        )

        # Do the build and publish
        docker_base.compose_run('tests/test-compose.localized.yml', 'build test_publish_local')
        docker_base.compose_run('tests/test-compose.localized.yml', 'up test_publish_local')

        # Ensure we find a file we expect
        result = docker_base.docker_run(
            'exec test_destination_local '
            'ls /docker-jekyll-site/test_publish_local/site/{}'.format(TestPublish.TEST_FILE),
            check_result=False
        )
        self.assertEqual(
            result.returncode,
            0,
            'Publish did not create expected file'
        )

        # Ensure we don't find the junk we created
        result = docker_base.docker_run(
            'exec test_destination_local '
            'ls /docker-jekyll-site/test_publish_local/site/junk',
            check_result=False
        )
        self.assertNotEqual(
            result.returncode,
            0,
            'Publish did not remove expected file'
        )

    def test_publish_ssh(self):
        # Ensure the target directory exists
        docker_base.docker_run(
            'exec test_destination_sshd '
            'mkdir -p /docker-jekyll-site/test_publish_ssh/site'
        )

        # Empty out the target directory
        docker_base.docker_run(
            'exec test_destination_sshd '
            'find /docker-jekyll-site/test_publish_ssh/site -mindepth 1 -delete'
        )

        # Ensure the file we expect is not already there
        self.assertFalse(
            os.path.exists('tests/test_destination_sshd/site/{}'.format(TestPublish.TEST_FILE)),
            'Could not remove expected file'
        )

        # Put a junk file in the target, to confirm it is removed
        docker_base.docker_run(
            'exec test_destination_sshd '
            'touch /docker-jekyll-site/test_publish_ssh/site/junk'
        )

        # Ensure our junk is there
        self.assertTrue(
            os.path.exists('tests/test_destination_sshd/site/junk'),
            'Could not create expected file'
        )

        # Do the build and publish
        docker_base.compose_run('tests/test-compose.localized.yml', 'build test_publish_ssh')
        docker_base.compose_run('tests/test-compose.localized.yml', 'up test_publish_ssh')

        # Ensure we find a file we expect
        self.assertTrue(
            os.path.exists('tests/test_destination_sshd/site/{}'.format(TestPublish.TEST_FILE)),
            'Publish did not create expected file'
        )

        # Ensure we don't find the junk we created
        self.assertFalse(
            os.path.exists('tests/test_destination_sshd/site/junk'),
            'Publish did not remove expected file'
        )
