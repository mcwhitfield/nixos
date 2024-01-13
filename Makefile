hosts := turvy rpi-0-0 rpi-0-1 rpi-0-2
users := mark

: $$(hostname)
all: $(hosts)

$(hosts): %: .update-git-%
	# Setting RequestTTY=force is necessary for sudo, but causes nixos-rebuild to fail if certain
	# characters are present in store paths due to poor escaping. So we try without sudo first to
	# get everything copied over safely, then again with sudo.
	host="$(patsubst .switch-host-%,%,$@)"; \
	cmd="\
		nixos-rebuild \
			--target-host $${host} \
			--flake .#$${host} \
			switch" \
	; \
	$$cmd || \
	NIX_SSHOPTS="-o RequestTTY=force" $$cmd --use-remote-sudo

$(users): %: .update-git-%@$$(hostname)
	home-manager switch --flake .#$(patsubst .switch-user-%,%,$@)@$$(hostname)

.update-git-%: .build-%
	git commit && git push -f || true

.build-%:
	git add .
	nixos-rebuild build --flake .#$(patsubst .build-%,%,$@)
