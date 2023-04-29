FROM	ubuntu:kinetic AS java
ARG		PACKAGES																\
		APT_INST																\
		CURL="curl --location --progress-bar"
ENV		PATH="${PATH}:/usr/lib/jvm/jdk-20/bin/"
ENV		DEBIAN_FRONTEND=noninteractive
ENV		TZ=GMT+2
# ENV		PATH="${PATH}:/usr/local/go/bin"
WORKDIR	/run
# Copy java.deb
COPY	--chown=root:root ./packages/java.deb .
#  Update repo, upgrade package && Install package
RUN		apt update && apt upgrade -y && ${APT_INST} ${PACKAGES} ./java.deb		&& \
		rm -f ./java.deb
# Fix Date and Time
RUN		ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime					&& \
		dpkg-reconfigure --frontend noninteractive tzdata


FROM java AS paper
WORKDIR	/run/server
ENTRYPOINT [ "java" ]
CMD		[ "-Xms512M", "-Xmx512M", "-jar", "paper.jar" ]


FROM java as bungee
WORKDIR /run/bungee
ENTRYPOINT [ "java" ]
CMD [ "-Xms512M", "-Xmx512M", "-jar", "bungee.jar" ]
