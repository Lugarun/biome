.PRECIOUS: secrets/wireguard/%

secrets/wireguard/%:
	umask 077 && wg genkey > $@
	
secrets/wireguard/%.pub: secrets/wireguard/%
	cat $< | wg pubkey | tr -d '\n' > $@
	echo "EDIT JSON FILE"

build/%.conf: secrets/wireguard/%.pub
	mkdir -p build
	bash ops/gen-wireguard-conf $(shell basename -s .conf $@) > $@

build/%.qr: build/%.conf
	qrencode -t ansiutf8 < $< | tee $@
	
ssh/%:
	bash ops/ssh-by-name $(shell basename -s .conf $@)
