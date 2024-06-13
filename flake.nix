{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nur,
  }: let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      config.contentAddressedByDefault = true;
    };
    # TODO FUTURE clean up repo so that all related settings are set here
    # DNS? intercomputer connecty stuff?
    impure-info = {
      /*
      sudo ssh-keygen -t ed25519 -a 100 -N "" -C "ssh_key" -f ${ssh_key_path_string}
      sudo chown user:users ${ssh_key_path_string} ${ssh_key_path_string}.pub
      chmod 600 ${ssh_key_path_string}
      chmod 644 ${ssh_key_path_string}.pub
      */
      ssh_key_path_string = "/etc/nixos/ssh_key";

      /*
      sudo ssh-keygen -t ed25519 -a 100 -N "" -C "git_key" -f ${git_key_path_string}
      sudo chown user:users ${git_key_path_string} ${git_key_path_string}.pub
      chmod 600 ${git_key_path_string}
      chmod 644 ${git_key_path_string}.pub
      */
      git_key_path_string = "/etc/nixos/git_key";

      /*
      mkpasswd --method=scrypt | sudo tee ${impure-info.user_pass_hash_path_string}
      sudo chmod 400 ${impure-info.user_path_hash_path_string}
      */
      user_pass_hash_path_string = "/etc/nixos/user_pass_hash";

      /*
      https://www.duckdns.org/install.jsp?tab=hardware
      get the domain and token
      echo "https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&ip=" | sudo tee ${duckdns_url_file_path_string}
      sudo chmod 400 ${duckdns_url_file_path_string}
      */
      duckdns_url_file_path_string = "/etc/nixos/duckdns_url";

      /*
      sudo ssh-keygen -t ed25519 -a 100 -N "" -C "initrd_ssh_key" -f ${initrd_ssh_host_key_file_path_string}
      sudo chown user:users ${initrd_ssh_host_key_file_path_string} ${initrd_ssh_host_key_file_path_string}.pub
      chmod 600 ${initrd_ssh_host_key_file_path_string}
      chmod 644 ${initrd_ssh_host_key_file_path_string}.pub
      */
      initrd_ssh_host_key_file_path_string = "/etc/nixos/initrd_ssh_host_key";
    };
  in {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        specialArgs = {
          inherit home-manager impure-info;
        };

        modules = [
          ./systems/laptop.nix
          nur.nixosModules.nur
        ];
      };

      desktop = nixpkgs.lib.nixosSystem {
        inherit pkgs;
        specialArgs = {
          inherit home-manager impure-info;
        };

        modules = [
          ./systems/desktop.nix
          nur.nixosModules.nur
        ];
      };
    };
  };
}
