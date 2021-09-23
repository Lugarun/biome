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

morph-build:
	morph build --keep-result ops/network.nix

morph-push:
	morph push ops/network.nix
	morph upload-secrets ops/network.nix

morph-deploy:
	morph deploy ops/network.nix switch

morph-overhaul:
	morph build --keep-result ops/network.nix
	morph push ops/network.nix
	morph upload-secrets ops/network.nix
	morph deploy ops/network.nix switch
	
morph-build/%:
	morph build --keep-result ops/network.nix

morph-push/%:
	morph push ops/network.nix
	morph upload-secrets ops/network.nix

morph-deploy/%:
	morph deploy ops/network.nix switch

morph-overhaul/%:
	morph build --keep-result ops/network.nix --on $(shell basename $@)
	morph push ops/network.nix --on $(shell basename $@)
	morph upload-secrets ops/network.nix --on $(shell basename $@)
	morph deploy ops/network.nix switch --on $(shell basename $@)

config/dnsmasqConfig.txt:
	curl https://raw.githubusercontent.com/notracking/hosts-blocklists/master/dnsmasq/dnsmasq.blacklist.txt > $@
