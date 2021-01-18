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
COPY coronavirus-tracker/mvnw mvnw
#COPY --chmod=+x coronavirus-tracker/mvnw mvnw
COPY coronavirus-tracker/.mvn .mvn
COPY coronavirus-tracker/pom.xml pom.xml
COPY coronavirus-tracker/src src
RUN chmod 777 ./mvnw
RUN ./mvnw package
ARG JAR_FILE=/home/corona/coronavirus-tracker/target/*.jar
RUN java -Djarmode=layertools -jar ${JAR_FILE} extract

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
