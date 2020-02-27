# PythonidasDockerImage

This repository helps with setting up development environment for Pythonidas project.
To launch docker container with the development environment type:
```
./run_pythonidas_env.sh
```

it is not required to have FramsticksSDK nor Pythonidas. The script checks whether FramsticksSDK is located in the `framsticks` directory. If not found then, using subversion, [FramsticksSDK]('https://www.framsticks.com/svn/framsticks/') is being cloned to the `framsticks` directory. Then,  [Pythonias repository]('https://bitbucket.org/mack0/pythonidas/src/master/') is being cloned. If both repositories exist then docker image is being run. If the image has not been built from `Dockerfile` locally then docker tries to pull it from [DockerHub]('https://hub.docker.com/r/jakubtomczak/pythonidas_dev_image').

If pythonidas docker image has been already launched and there exists a container with `pythonidas_dev` name then docker runs it and doesn't run another instance of the pythonidas docker image.