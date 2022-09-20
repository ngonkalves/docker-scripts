FROM nodered/node-red:2.2.2-14-minimal

MAINTAINER Nuno Goncalves <@ngonkalves>

# run as root
USER root

RUN \
    apk add --no-cache ffmpeg

# switch to node-red user
USER node-red

RUN \
    # core
    #apk add --no-cache ffmpeg && \
    npm install -no-cache node-red-debugger && \
    npm install -no-cache node-red-dashboard && \
    npm install -no-cache node-red-node-tail && \
    npm install -no-cache node-red-node-base64 && \
    #npm install -no-cache node-red-node-rbe && \
    #npm install -no-cache node-red-node-ui-table && \
    # extensions
    npm install -no-cache node-red-contrib-home-assistant-websocket && \
    npm install -no-cache node-red-contrib-telegrambot && \
    #npm install -no-cache node-red-contrib-image-tools && \
    npm install -no-cache node-red-contrib-image-output && \
    npm install -no-cache node-red-contrib-moment && \
    npm install -no-cache node-red-contrib-influxdb 

