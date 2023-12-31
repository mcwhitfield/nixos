hosts := turvy
users := mark

: $$(hostname)

$(hosts): %: .update-git-%
	sudo nixos-rebuild switch --flake .#$(patsubst .switch-host-%,%,$@)
$(users): %: .update-git-%@$$(hostname)
	home-manager switch --flake .#$(patsubst .switch-user-%,%,$@)@$$(hostname)

.update-git-%: .build-%
	fish -c 'git add . && if test "$$(git log -1 --pretty=%B)" = "$$(date -I)"; git commit --amend --no-edit; else; git commit -m "$$(date -I)"; end && git push -f'

.build-%:
	sudo nixos-rebuild build --flake .#$(patsubst .build-%,%,$@)
