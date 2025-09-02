.DEFAULT_GOAL = all

-include config.mak

SM_URL    = https://sm.alliedmods.net/smdrop/1.12/sourcemod-1.12.0-git7210-linux.tar.gz
PLUGIN    = sm_dod_map_manager
BUILD_DIR = build
DEPS_DIR  = deps

# Call `make V=1` in order to print commands verbosely.
ifeq ($(V),1)
    Q =
else
    Q = @
endif

.PHONY: all
all: build

deps:
	${Q}mkdir -p $(DEPS_DIR)
	${Q}curl --output - $(SM_URL) | tar zxf - -C $(DEPS_DIR)

.PHONY: build
build: deps
	${Q}mkdir -p $(BUILD_DIR)
	${Q}$(DEPS_DIR)/addons/sourcemod/scripting/spcomp $(PLUGIN).sp -o$(BUILD_DIR)/$(PLUGIN).smx

.PHONY: publish
publish: build
	${Q}echo "put $(BUILD_DIR)/$(PLUGIN).smx" | sftp -b - $(SFTP_DEST)

.PHONY: reload
reload: publish
	${Q}rcon -a $(RCON_HOST) -p $(RCON_PASS) "sm plugins reload $(PLUGIN)"

.PHONY: clean
clean:
	${Q}rm -rf $(BUILD_DIR)
