
MKDIR				= \
[ -f $(1) ] && sudo rm -rf $(1);												\
[ ! -d $(1) ] && mkdir -p $(1);

SRV_DIR			:= ./server

# BASH
SHELL				:= /usr/bin/bash
## set bash strict mode
.SHELLFLAGS			:= -eu -o pipefail -c -x

# Always use GNU Make.
ifeq ($(origin .RECIPEPREFIX), undefined)
	$(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif

## Use '>' to instead of tab.
.RECIPEPREFIX		= >

# DEFAULT TARGET
ifeq ($(TARGET),)
TARGET				:=
endif

ifeq ($(DEBUG),1)
COMPOSE_FILE		:= docker-compose.1.yml
else
COMPOSE_FILE		:= docker-compose.yml
endif

MAKE_PROXY			= \
$(call MKDIR,$(SRV_DIR)/$(1))														\
cp ./packages/bungee.jar $(SRV_DIR)/$(1)											; \
cp ./config/server/bungee/config.yml $(SRV_DIR)/$(1)								;

MAKE_SERVER			= \
$(call MKDIR,$(SRV_DIR)/$(1))													\
cp ./packages/paper.jar $(SRV_DIR)/$(1)											; \
cp ./config/server/eula.txt $(SRV_DIR)/$(1)										;
cp -r ./config/server/paper/$(1)/* $(SRV_DIR)/$(1)								; \

.SILENT:
.PHONY:				build clean clean_docker
.DEFAULT:			run

run:				packages
> docker compose -f $(COMPOSE_FILE) up --remove-orphans $(TARGET)

all:				packages
> docker compose -f $(COMPOSE_FILE) up --remove-orphans $(TARGET)

packages: ./packages/bungee.jar
> $(call MKDIR,$(SRV_DIR))
> $(call MAKE_PROXY,bungee)
> $(call MAKE_SERVER,lobby_01)
> $(call MAKE_SERVER,lobby_02)
> $(call MAKE_SERVER,adventure_01)

./packages/bungee.jar:
	./utils/download_package

re:			clean run

## CLEAN
clean:				clean_docker

clean_docker:
> sudo docker compose down
> sudo docker compose kill
> sudo docker network prune -f
> sudo docker volume prune -f
> sudo docker system prune -af
> sudo rm -rf $(SRV_DIR)
