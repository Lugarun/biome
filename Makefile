.PRECIOUS: secrets/wireguard/%.pri secrets/wireguard/%.pub

secrets/wireguard/%.pri:
	umask 077 && wg genkey | tee $@
	
secrets/wireguard/%.pub: secrets/wireguard/%.pri
	cat $< | wg pubkey | tr -d '\n' > $@
	echo "EDIT JSON FILE"

build/%.conf: secrets/wireguard/%.pub
	mkdir -p build
	bash ops/gen-wireguard-conf $(shell basename -s .conf $@) > $@

build/%.qr: build/%.conf
	qrencode -t ansiutf8 < $< | tee $@
	
ssh/%:
	bash ops/ssh-by-name $(shell basename -s .conf $@)

deploy-rs:
	nix flake lock --update-input ecosystem
	morph upload-secrets ops/network.nix
	deploy
	
deploy-rs/%:
	nix flake lock --update-input ecosystem
	morph upload-secrets ops/network.nix --on $(shell basename $@)
	deploy .#$(shell basename $@)

config/dnsmasqConfig.txt:
	curl https://raw.githubusercontent.com/notracking/hosts-blocklists/master/dnsmasq/dnsmasq.blacklist.txt > $@
