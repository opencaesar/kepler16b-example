# Grab gitpod image
FROM gitpod/workspace-full

# Set the user as gitpod
USER gitpod

# Set the version to Java 17
RUN bash -c ". /home/gitpod/.sdkman/bin/sdkman-init.sh && \
    sdk install java 17.0.3-ms && \
    sdk default java 17.0.3-ms"