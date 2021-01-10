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

# The second stage of our build will extract the layers
FROM openjdk:11-jdk as builder
#@REF: https://hackernoon.com/5-tips-for-creating-docker-images-with-spring-boot-3e2n3umk
#@REF: https://medium.com/codingfullstack/5-essential-docker-tips-for-your-spring-boot-images-8f570270d9ba
USER root
WORKDIR /home/corona/coronavirus-tracker
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src
RUN ./mvnw package
RUN ls -la target/
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
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]

# @TODO: `12 factor app` | ADD spring dependency: actuator https://habr.com/ru/company/otus/blog/452624/ & play with postman
# DRAFT@TODO: add health check
# DRAFT@TODO: application security, sonarqube cloud integration
# DRAFT@TODO: play with logging drivers, json appender, stdout/stderr
