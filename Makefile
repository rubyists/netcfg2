PREFIX = /usr
DATA = /share
BIN = /bin
LIB = /lib
LIBEXEC = /lib
SYSTEMD_LIB = $(LIBEXEC)/systemd
LICENSES = $(DATA)/licenses
DOC = $(DATA)/doc
SYSCONF = /etc
INITHOOKS = $(SYSCONF)/rc.d
INITHOOKS_LIB = $(INITHOOKS)/functions.d
PKGNAME = netcfg



SCRIPTS     = scripts/netcfg                     \
	      scripts/wifi-menu                  \
	      scripts/netcfg-daemon              \
	      scripts/netcfg-menu                \
	      scripts/netcfg-wpa_actiond         \
	      scripts/netcfg-wpa_actiond-action

HOOKS       = src/hooks/fancy        \
              src/hooks/initscripts

CONNECTIONS = src/connections/bond      \
              src/connections/bridge    \
              src/connections/ethernet  \
              src/connections/openvpn   \
              src/connections/ppp       \
              src/connections/pppoe     \
              src/connections/tunnel    \
              src/connections/tuntap    \
              src/connections/vlan      \
              src/connections/wireless

NETWORK     = src/network  \
              src/rfkill   \
              src/8021x    \
              src/globals

CONTRIB     = contrib/iptables.hook     \
              contrib/logging.hook      \
              contrib/pm-utils.handler

EXAMPLES    = doc/examples/bonding                     \
              doc/examples/ethernet-dhcp               \
              doc/examples/ethernet-static             \
              doc/examples/ethernet-iproute            \
              doc/examples/ppp                         \
              doc/examples/pppoe                       \
              doc/examples/wireless-open               \
              doc/examples/wireless-wep                \
              doc/examples/wireless-wpa                \
              doc/examples/wireless-wpa-static         \
              doc/examples/wireless-wpa-configsection  \
              doc/examples/wireless-wpa-config         \
              doc/examples/tunnel-he-ipv6              \
              doc/examples/vlan-dhcp                   \
              doc/examples/vlan-static                 \
              doc/examples/bridge                      \
              doc/examples/openvpn                     \
              doc/examples/tuntap                      \
              doc/examples/wireless-open               \
              doc/examples/wireless-wep                \
              doc/examples/wireless-wep-string-key     \
              doc/examples/wireless-wpa-config

RCD         = rc.d/net-profiles       \
              rc.d/net-rename         \
              rc.d/net-auto-wired     \
              rc.d/net-auto-wireless

SYSTEMD     = systemd/net-auto-wired.service     \
              systemd/net-auto-wireless.service  \
              systemd/netcfg.service             \
              systemd/netcfg@.service            \
              systemd/netcfg-sleep.service



.PHONY: doc shell
all:    doc shell

.PHONY: man info
doc:    man info

man: netcfg.8.gz
netcfg.8.gz: doc/netcfg.texman
	texman < "$<" | gzip -9 > "$@"

info: netcfg.info.gz
netcfg.info: doc/netcfg.texinfo
	makeinfo "$<"
netcfg.info.gz: netcfg.info
	gzip -9 < netcfg.info > netcfg.info.gz

.PHONY: bash zsh
shell:  bash zsh

bash: netcfg.bash-completion
zsh: netcfg.zsh-completion

netcfg.%sh-completion: netcfg.auto-completion
	auto-auto-complete "$*sh" --output "$@" --source "$<"




.PHONY:  install-core install-doc install-license install-changelog install-systemd install-bash install-zsh
install: install-core install-doc install-license install-changelog install-systemd install-bash install-zsh

install-license:
	install -d     -- "$(DESTDIR)$(PREFIX)$(LICENSES)/$(PKGNAME)"
	install -m644  LICENSE                -- "$(DESTDIR)$(PREFIX)$(LICENSES)/$(PKGNAME)/"

install-changelog:
	install -d     -- "$(DESTDIR)$(PREFIX)$(DATA)/changelogs"
	install -m644  CHANGELOG              -- "$(DESTDIR)$(PREFIX)$(DATA)/changelogs/$(PKGNAME)"

install-systemd:
	install -d     -- "$(DESTDIR)$(PREFIX)$(LIB)/systemd/system"
	install -m644  $(SYSTEMD)             -- "$(DESTDIR)$(PREFIX)$(SYSTEMD_LIB)/system/"

install-bash: bash
	install -d     -- "$(DESTDIR)$(PREFIX)$(DATA)/bash-completion/completions"
	install -m644  netcfg.bash-completion -- "$(DESTDIR)$(PREFIX)$(DATA)/bash-completion/completions"/netcfg

install-zsh: zsh
	install -d     -- "$(DESTDIR)$(PREFIX)$(DATA)/zsh/site-functions"
	install -m644  netcfg.zsh-completion  -- "$(DESTDIR)$(PREFIX)$(DATA)/zsh/site-functions"/_netcfg



.PHONY:      install-man install-info install-contrib
install-doc: install-man install-info install-contrib

install-man: man
	install -d     -- "$(DESTDIR)$(PREFIX)$(DATA)/man/man8"
	install -m644  netcfg.8.gz            -- "$(DESTDIR)$(PREFIX)$(DATA)/man/man8/"

install-info: info
	install -d     -- "$(DESTDIR)$(PREFIX)$(DATA)/info"
	install -m644  netcfg.info.gz         -- "$(DESTDIR)$(PREFIX)$(DATA)/info/"

install-contrib:
	install -d     -- "$(DESTDIR)$(PREFIX)$(DOC)/$(PKGNAME)/contrib"
	install -m644  $(CONTRIB)             -- "$(DESTDIR)$(PREFIX)$(DOC)/$(PKGNAME)/contrib/"



.PHONY:       install-conf install-lib install-hook install-script install-daemon
install-core: install-conf install-lib install-hook install-script install-daemon

install-conf:
	install -d     -- "$(DESTDIR)$(SYSCONF)/network.d"/{examples,interfaces}
	install -Dm644 config/netcfg          -- "$(DESTDIR)$(SYSCONF)/conf.d/"netcfg
	install -m644  config/iftab           -- "$(DESTDIR)$(SYSCONF)/"iftab
	install -m644  $(EXAMPLES)            -- "$(DESTDIR)$(SYSCONF)/network.d/examples/"

install-lib:
	install -d     -- "$(DESTDIR)$(PREFIX)$(LIB)/network/connections"
	install -m644  $(NETWORK)             -- "$(DESTDIR)$(PREFIX)$(LIB)/network/"
	install -m755  $(CONNECTIONS)         -- "$(DESTDIR)$(PREFIX)$(LIB)/network/connections/"

install-hook:
	install -d     -- "$(DESTDIR)$(PREFIX)$(LIB)/network/hooks"
	install -m755  $(HOOKS)               -- "$(DESTDIR)$(PREFIX)$(LIB)/network/hooks/"

install-script:
	install -d                            -- "$(DESTDIR)$(PREFIX)$(BIN)"
	install -m755  $(SCRIPTS)             -- "$(DESTDIR)$(PREFIX)$(BIN)/"
	install -Dm755 scripts/ifplugd.action -- "$(DESTDIR)$(SYSCONF)/ifplugd/"netcfg.action
	install -Dm755 scripts/pm-utils       -- "$(DESTDIR)$(PREFIX)$(LIB)/pm-utils/sleep.d/"50netcfg

install-daemon:
	install -d     -- "$(DESTDIR)$(INITHOOKS_LIB)"
	install -m755  rc.d/net-set-variable  -- "$(DESTDIR)$(INITHOOKS_LIB)/"net-set-variable
	install -d     -- "$(DESTDIR)$(INITHOOKS)"
	install -m755  $(RCD)                 -- "$(DESTDIR)$(INITHOOKS)/"



uninstall:
	-rm    -- "$(DESTDIR)$(PREFIX)$(LICENSES)/$(PKGNAME)"/LICENSE
	-rmdir -- "$(DESTDIR)$(PREFIX)$(LICENSES)/$(PKGNAME)"
	-rm    -- $(foreach F, $(SYSTEMD), "$(DESTDIR)$(PREFIX)$(SYSTEMD_LIB/system/$$(basename "$(F)")")
	-rm    -- "$(DESTDIR)$(PREFIX)$(DATA)/bash-completion/completions"/netcfg
	-rm    -- "$(DESTDIR)$(PREFIX)$(DATA)/zsh/site-functions"/_netcfg
	-rm    -- "$(DESTDIR)$(PREFIX)$(DATA)/man/man8"/netcfg.8.gz
	-rm    -- "$(DESTDIR)$(PREFIX)$(DATA)/info/"netcfg.info.gz
	-rm    -- $(foreach F, $(CONTRIB), "$(DESTDIR)$(PREFIX)$(DOC)/$(PKGNAME)/contrib/$$(basename "$(F)")")
	-rmdir -- "$(DESTDIR)$(PREFIX)$(DOC)/$(PKGNAME)/contrib"
	-rmdir -- "$(DESTDIR)$(PREFIX)$(DOC)/$(PKGNAME)"
	-rm    -- "$(DESTDIR)$(SYSCONF)/conf.d"/netcfg
	-rm    -- "$(DESTDIR)$(SYSCONF)"/iftab
	-rm    -- $(foreach F, $(EXAMPLES), "$(DESTDIR)$(SYSCONF)/network.d/examples/$$(basename "$(F)")")
	-rmdir -- "$(DESTDIR)$(SYSCONF)/network.d/examples"
	-rmdir -- "$(DESTDIR)$(SYSCONF)/network.d"
	-rm    -- $(foreach F, $(NETWORK), "$(DESTDIR)$(PREFIX)$(LIB)/network/$$(basename "$(F)")")
	-rm    -- $(foreach F, $(CONNECTIONS), "$(DESTDIR)$(PREFIX)$(LIB)/network/connections/$$(basename "$(F)")")
	-rmdir -- "$(DESTDIR)$(PREFIX)$(LIB)/network/connections"
	-rm    -- $(foreach F, $(HOOKS), "$(DESTDIR)$(PREFIX)$(LIB)/network/hooks/$$(basename "$(F)")")
	-rmdir -- "$(DESTDIR)$(PREFIX)$(LIB)/network/hooks"
	-rmdir -- "$(DESTDIR)$(SYSCONF)/network"
	-rm    -- "$(DESTDIR)$(SYSCONF)/ifplugd"/netcfg.action
	-rmdir -- "$(DESTDIR)$(SYSCONF)/ifplugd"
	-rm    -- "$(DESTDIR)$(PREFIX)$(LIB)/pm-utils/sleep.d"/50netcfg
	-rmdir -- "$(DESTDIR)$(PREFIX)$(LIB)/pm-utils/sleep.d"
	-rmdir -- "$(DESTDIR)$(PREFIX)$(LIB)/pm-utils"
	-rm    -- $(foreach F, $(SCRIPTS), "$(DESTDIR)$(PREFIX)$(BIN)/$$(basename "$(F)")")
	-rm    -- "$(DESTDIR)$(INITHOOKS_LIB)"/net-set-variable
	-rm    -- $(foreach F, $(RCD), "$(DESTDIR)$(INITHOOKS)/$$(basename "$(F)")")
	-rm    -- "$(DESTDIR)$(PREFIX)$(DATA)/changelogs/$(PKGNAME)"



clean:
	-rm netcfg.{8.gz,info.gz,info,{bash,zsh}-completion} 2>/dev/null



.PHONY: all install uninstall clean

