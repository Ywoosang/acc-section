FROM gradle:8.4-jdk17 AS build
WORKDIR /app
COPY . .
RUN gradle build -x test

FROM eclipse-temurin:17-jre
WORKDIR /app

ENV TZ=Asia/Seoul
RUN apt-get update && apt-get install -y tzdata

COPY --from=build /app/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]