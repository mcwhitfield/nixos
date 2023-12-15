me:
	home-manager switch --flake .#$$(whoami)@$$(hostname)

this:
	sudo nixos-rebuild switch --flake .#$$(hostname)

turvy:
	sudo nixos-rebuild switch --flake .#turvy

mark:
	home-manager switch --flake .#mark@$$(hostname)
