hosts := turvy rpi-0-0 rpi-0-1 rpi-0-2

this:
	make $$(hostname)
all: $(hosts)

$(hosts): %: .update-git-%
	nixos-rebuild \
		--target-host $@ \
		--flake .#$@ \
		--use-remote-sudo \
		switch

.update-git-%: .build-%
	git commit; git push -f

.build-%:
	git add .
	nixos-rebuild build --flake .#$(patsubst .build-%,%,$@) --show-trace
