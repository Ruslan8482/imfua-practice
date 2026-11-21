FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /src
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -q -DskipTests package

FROM eclipse-temurin:17-jre

COPY --from=build /src/target/hello-java-1.0.0.jar /app/hello-java.jar
ENTRYPOINT ["java", "-jar", "/app/hello-java.jar"]
