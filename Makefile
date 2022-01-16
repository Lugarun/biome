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
