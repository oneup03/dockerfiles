# Run RetroArch Web Player in a container
#
# docker run --rm -it -p 8080:80 inglebard/retroarch-web
#
FROM debian:buster

LABEL maintainer "OneUp03 <oneup03@gmail.com>"

RUN apt-get update && apt-get install -y \
	ca-certificates \
	unzip \
	sed \
	p7zip-full \
	coffeescript \
	xz-utils \
	nginx \
	wget \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

# https://github.com/libretro/RetroArch/tree/master/pkg/emscripten
# https://buildbot.libretro.com/nightly/
ENV RETROARCH_VERSION 2020-11-18
ENV ROOT_WWW_PATH /var/www/html

ADD r189 ${ROOT_WWW_PATH}

RUN ls ${ROOT_WWW_PATH}

RUN cd ${ROOT_WWW_PATH} \
	&& chmod +x indexer \
	&& mkdir -p ${ROOT_WWW_PATH}/assets/frontend/bundle/shaders \
	&& mkdir -p ${ROOT_WWW_PATH}/assets/frontend/bundle/database \
	&& mkdir -p ${ROOT_WWW_PATH}/assets/cores \
	&& cd ${ROOT_WWW_PATH}/assets/frontend \
	&& wget https://buildbot.libretro.com/assets/frontend/assets.zip \
	&& unzip assets.zip -d bundle/assets \
	&& wget https://buildbot.libretro.com/assets/frontend/autoconfig.zip \
	&& unzip autoconfig.zip -d bundle/autoconfig \
	&& wget https://buildbot.libretro.com/assets/frontend/cheats.zip \
	&& unzip cheats.zip -d bundle/cheats \
	&& wget https://buildbot.libretro.com/assets/frontend/database-cursors.zip \
	&& unzip database-cursors.zip -d bundle/database/cursors \
	&& wget https://buildbot.libretro.com/assets/frontend/database-rdb.zip \
	&& unzip database-rdb.zip -d bundle/database/rdb \
	&& wget https://buildbot.libretro.com/assets/frontend/info.zip \
	&& unzip info.zip -d bundle/info \
	&& wget https://buildbot.libretro.com/assets/frontend/overlays.zip \
	&& unzip overlays.zip -d bundle/overlays \
	&& wget https://buildbot.libretro.com/assets/frontend/shaders_cg.zip \
	&& unzip shaders_cg.zip -d bundle/shaders/shaders_cg \
	&& wget https://buildbot.libretro.com/assets/frontend/shaders_glsl.zip \
	&& unzip shaders_glsl.zip -d bundle/shaders/shaders_glsl \
	&& wget https://buildbot.libretro.com/assets/frontend/shaders_slang.zip \
	&& unzip shaders_slang.zip -d bundle/shaders/shaders_slang \
	&& cd ${ROOT_WWW_PATH}/assets/frontend/bundle \
	&& ../../../indexer > .index-xhr \
	&& cd ${ROOT_WWW_PATH}/assets/cores \
	&& ../../indexer > .index-xhr \
	&& rm -rf ${ROOT_WWW_PATH}/assets/frontend/*.zip

WORKDIR ${ROOT_WWW_PATH}

EXPOSE 80

COPY entrypoint.sh /

CMD [ "sh", "/entrypoint.sh"]
