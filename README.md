This is a scaffold for projects that use Docker in their testing.

# Testing with Docker

This project uses Docker Toolbox to create virtual machines for testing with Docker.

## Installing Docker Toolbox

Development currently requires:

- Docker Toolbox 1.12.3

  Note we are using this version due to a potential bug in 1.12.5, which is unable to mount volumes on Windows.

  [https://github.com/docker/toolbox/issues/607](https://github.com/docker/toolbox/issues/607)

  Installation on Windows:

  [https://github.com/docker/toolbox/releases/download/v1.12.3/DockerToolbox-1.12.3.exe](https://github.com/docker/toolbox/releases/download/v1.12.3/DockerToolbox-1.12.3.exe)

  During installation:

  - On 'Select Destination Location':

  Set an installation path of c:/Program Files/Docker Toolbox.

  - On 'Select Components':

  Uncheck 'Kitematic for Windows'.

## Creating a Virtual Environment and Installing Dependencies

  All Python work should be done within a virtual environment, to avoid dependency conflicts.

Create the virtual environment. From the working directory of our project (e.g., `c:/devel/testwithdocker-base`):

    c:/Python35\python.exe -m venv env35

This will create a directory for the virtual environment (e.g., `c:/devel/testwithdocker-base\env35\`).

Next activate that virtual environment and install our Python dependencies:

    env35\Scripts\activate.bat
    pip install -r requirements3.txt

## Starting Docker Containers and Running Tests

If it is not already active, you need to re-activate the virtual environment.
From the working directory of our project (e.g., `c:/devel/testwithdocker-base`):

    env35\Scripts\activate.bat

To start Docker containers:

    invoke docker_start

To start a console in the Docker virtual machine:

    invoke docker_console

To run tests, assuming Docker containers have been started:

    nosetests
