# Java Version
ARG JAVA_VERSION=17

################################
### We use a java base image ###
################################
FROM eclipse-temurin:${JAVA_VERSION}-alpine AS build


#####################################
### Maintained by kunihir0        ###
### Contact: kunihir0@tutanota.com###
#####################################
LABEL maintainer="kunihiro <kunihiro@tutanota.com>"

#################
### Arguments ###
#################
ARG PAPER_VERSION=1.18.2
ARG PAPER_BUILD=317
ARG PAPER_DOWNLOAD_URL="https://papermc.io/api/v2/projects/paper/versions/${PAPER_VERSION}/builds/${PAPER_BUILD}/downloads/paper-${PAPER_VERSION}-${PAPER_BUILD}.jar"
ENV MINECRAFT_BUILD_PATH=/opt/minecraft

#########################
### Working directory ###
#########################
WORKDIR ${MINECRAFT_BUILD_PATH}

##########################
### Download paperclip ###
##########################
ADD ${PAPER_DOWNLOAD_URL} paper.jar

############################################
### Run paperclip and obtain patched jar ###
############################################
RUN java -jar ${MINECRAFT_BUILD_PATH}/paper.jar; exit 0
RUN ls -al

# Copy built jar
#RUN mv ${MINECRAFT_BUILD_PATH}/cache/patched*.jar ${MINECRAFT_BUILD_PATH}/paper.jar

###########################
### Running environment ###
###########################
FROM eclipse-temurin:17-alpine AS runtime

##########################
### Environment & ARGS ###
##########################
ENV MINECRAFT_PATH=/opt/minecraft
ENV SERVER_PATH=${MINECRAFT_PATH}/server
ENV DATA_PATH=${MINECRAFT_PATH}/data
ENV LOGS_PATH=${MINECRAFT_PATH}/logs
ENV CONFIG_PATH=${MINECRAFT_PATH}/config
ENV WORLDS_PATH=${MINECRAFT_PATH}/worlds
ENV PLUGINS_PATH=${MINECRAFT_PATH}/plugins
ENV PROPERTIES_LOCATION=${CONFIG_PATH}/server.properties
ENV JAVA_HEAP_SIZE=4G
ENV JAVA_ARGS="-server -Dcom.mojang.eula.agree=true"
ENV SPIGOT_ARGS="--nojline"
ENV PAPER_ARGS=""

#########################
### Working directory ###
#########################
WORKDIR ${SERVER_PATH}

###########################################
### Obtain runable jar from build stage ###
###########################################
COPY --from=build /opt/minecraft/paper.jar ${SERVER_PATH}/

######################
### Obtain scripts ###
######################
ADD scripts/docker-entrypoint.sh docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh

############
### User ###
############
RUN mkdir ${LOGS_PATH} ${DATA_PATH} ${WORLDS_PATH} ${PLUGINS_PATH} ${CONFIG_PATH}

#########################
### Setup environment ###
#########################
# Create symlink for plugin volume as hotfix for some plugins who hard code their directories
RUN ln -s $PLUGINS_PATH $SERVER_PATH/plugins && \
    # Create symlink for persistent data
    ln -s $DATA_PATH/banned-ips.json $SERVER_PATH/banned-ips.json && \
    ln -s $DATA_PATH/banned-players.json $SERVER_PATH/banned-players.json && \
    ln -s $DATA_PATH/help.yml $SERVER_PATH/help.yml && \
    ln -s $DATA_PATH/ops.json $SERVER_PATH/ops.json && \
    ln -s $DATA_PATH/permissions.yml $SERVER_PATH/permissions.yml && \
    ln -s $DATA_PATH/whitelist.json $SERVER_PATH/whitelist.json && \
    # Create symlink for logs
    ln -s $LOGS_PATH $SERVER_PATH/logs

###############
### Volumes ###
###############
VOLUME "${CONFIG_PATH}"
VOLUME "${WORLDS_PATH}"
VOLUME "${PLUGINS_PATH}"
VOLUME "${DATA_PATH}"
VOLUME "${LOGS_PATH}"

#############################
### Expose minecraft port ###
#############################
EXPOSE 25565

######################################
### Entrypoint is the start script ###
######################################
ENTRYPOINT [ "./docker-entrypoint.sh" ]

# Run Command
CMD ["serve"]
