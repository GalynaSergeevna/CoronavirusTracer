# syntax = docker/dockerfile:experimental

## Multi-stage Dockerfile
# The first stage of our build will have dependency, user, timezone, folders, permission
FROM adoptopenjdk/openjdk11:alpine-jre as base
LABEL author = "GalynaSergeevna"

ARG TZ='Europe/Kiev'
ENV TZ ${TZ}
ARG UID='9999'
ENV UID ${UID}
ARG GID='9999'
ENV GID ${GID}

USER root
RUN apk add --no-cache shadow sudo tzdata \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/* && \
    if [ -z "`getent group $GID`" ]; then \
      addgroup -S -g $GID virus; \
    else \
      groupmod -n virus `getent group $GID | cut -d: -f1`; \
    fi && \
    if [ -z "`getent passwd $UID`" ]; then \
      adduser -S -u $UID -G virus -s /bin/sh corona; \
    else \
      usermod -l corona -g $GID -d /home/corona -m `getent passwd $UID | cut -d: -f1`; \
    fi && \
    echo "corona ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/corona && \
    chmod 0440 /etc/sudoers.d/corona

# The second stage of our build will extract the layers from jar file builded by with maven
FROM openjdk:11-jdk as builder
USER root
WORKDIR /home/corona/coronavirus-tracker
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src
RUN ./mvnw package
RUN ls -la target/
# @TODO: use wildcard intested 0.0.1
RUN java -Djarmode=layertools -jar target/coronavirus-tracker-0.0.1-SNAPSHOT.jar extract

# The third stage of our build will copy the extracted dependencies
# There is our running container image based on base from adoptopenjdk/openjdk11:alpine-jre
FROM base
USER root
WORKDIR /home/corona/coronavirus-tracker
COPY --from=builder --chown=corona:virus /home/corona/coronavirus-tracker/dependencies/ ./
COPY --from=builder --chown=corona:virus /home/corona/coronavirus-tracker/spring-boot-loader/ ./
COPY --from=builder --chown=corona:virus /home/corona/coronavirus-tracker/snapshot-dependencies/ ./
COPY --from=builder --chown=corona:virus /home/corona/coronavirus-tracker/application/ ./
USER corona
EXPOSE 8080/tcp
## TIPS: `EXPOSE 8080/tcp 8080/tcp` can be used for map port to host
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]


# @TODO: Register on gitlab.com or use one provided by isd
# @TODO: Create GitLab CI pipeline (checkout, get current git revision, docker build, docker tag image with revision, docker login, docker push, docker logout)
# @TODO: Read about `12 factor app`
# @TODO: Play with logging drivers, json appender, stdout/stderr. Log4j
# @TODO: ADD spring dependency: actuator & play with postman, enable actuator endpoints
# @TODO: Use spring profiles
# @TODO: Vizualize application metrics. Docker-compose with Graphana and Prometheus
# @TODO: Read about application security, code coverage, SonarQube Cloud integration
# DRAFT@TODO: Bugs hunting!
# DRAFT@TODO: Set heapsize for java
# DRAFT@TODO: Add health check to Dockerfile
# DRAFT@TODO: Convert datasource to PostgreSQL scheme
# DRAFT@TODO: Import database scheme to PostgreSQL
# DRAFT@TODO: Read about flyway or other database migration tools & add to application

# References for improvements:
# https://habr.com/ru/company/otus/blog/452624/ (actuator)
# https://habr.com/ru/post/457476/ (Spring Boot custom runtime)
# https://medium.com/hackernoon/crafting-perfect-java-docker-build-flow-740f71638d63 (maven image as a builder, ONBUILD,)
# https://hackernoon.com/5-tips-for-creating-docker-images-with-spring-boot-3e2n3umk (cache & copy jar with wildcard pattern)
# https://medium.com/codingfullstack/5-essential-docker-tips-for-your-spring-boot-images-8f570270d9ba (spring profiles & cache)
