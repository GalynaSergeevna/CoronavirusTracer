## Single Layer Dockefile
# FROM adoptopenjdk/openjdk11:alpine-jre
# ARG JAR_FILE=target/coronavirus-tracker-0.0.1-SNAPSHOT.jar
# WORKDIR /opt/app
# COPY ${JAR_FILE} app.jar
# ENTRYPOINT ["java","-jar","app.jar"]


## Multi-stage Dockerfile
# the first stage of our build will extract the layers
FROM adoptopenjdk/openjdk11:alpine-jre as builder
WORKDIR application
ARG JAR_FILE=target/coronavirus-tracker-0.0.1-SNAPSHOT.jar
COPY ${JAR_FILE} coronavirus-tracker.jar
RUN java -Djarmode=layertools -jar coronavirus-tracker.jar extract

# the second stage of our build will copy the extracted layers
FROM adoptopenjdk/openjdk11:alpine-jre
WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/application/ ./
EXPOSE 8080/tcp
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]