me: update-commit
	home-manager switch --flake .#$$(whoami)@$$(hostname)

this: update-commit
	sudo nixos-rebuild switch --flake .#$$(hostname)

turvy: update-commit
	sudo nixos-rebuild switch --flake .#turvy

mark: update-commit
	home-manager switch --flake .#mark@$$(hostname)

update-commit:
	fish -c 'git add .; if test "$(git log -1 --pretty=%B)" = "$(date -I)"; git commit --amend --no-edit; else; git commit -m "$(date -I)"; end'
