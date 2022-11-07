# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./services/nixos-auto-update.nix
    ];



  boot.initrd.availableKernelModules = [
   "cryptd"
  ];
  
  fileSystems."/" = { options = [ "noatime" "nodiratime" ]; };

  boot = {
	kernelPackages = pkgs.linuxPackages_latest;
	loader = {
  		efi.canTouchEfiVariables = true;
		systemd-boot.enable = true;
  		grub = {
  		  useOSProber = true;
  		  enable = true;
  		  version = 2;
  		  efiSupport = true;
  		  enableCryptodisk = true;
  		  device = "nodev";
  		};
	};
  	initrd.luks.devices = { 
    		crypt = {
      			device = "/dev/nvme0n1p2";
      			preLVM = true;
    		};
  	};
  };

  networking = {
    useDHCP = false;
    interfaces.enp0s31f6.useDHCP = true;
    hostname = "tansper-3106";
    networkmanager.enable = true;
    # TODO check these.
    #proxy.default = "http://proxy2.cyber.ee:8080";
    #proxy.noProxy = "127.0.0.1,localhost";
  };


  # Set your time zone.

  time.timeZone = "Europe/Tallinn";

  # Select internationalisation properties.
   i18n = {
	defaultLocale = "en_US.UTF-8";
	supportedLocales = [ "en_US.UTF-8/UTF-8" ];
   }
   console = {
     font = "Lat2-Terminus16";
     keyMap = "us";
   };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      powerline-fonts
      nerdfonts
    ];
  };
  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
      enableOnBoot = true;
    };
  };

  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  services = {
 	nixos-auto-update.enable = true;
  	# Enable the X11 windowing system.
	xserver = {
		enable = true;
		displayManager = {
			gdm.enable = true;
			autologin = {
				enable = true;
				user = "tansper";
			};
		};
		desktopManager = {
			gnome.enable = true;
		};
		layout = "us";
	        libinput.enable = true;
	};
  	# Enable CUPS to print documents.
	printing = {
		enable = true;
	};
	openssh = {
	  enable = true;
	  permitRootLogin = "no";
	  passwordAuthentication = false;
	  forwardX11 = true;
	};
  };
  

  # Enable sound.
  sound = {
    enable = true;
  };
  
  hardware = {
    pulseaudio.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users  = {
     mutableUsers = false;
     users.tansper = {
       isNormalUser = true;
       home = "/home/tansper";
       description = "Taavi Ansper";
       shell = pkgs.zsh;
       extraGroups = [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
  };

  programs = {
    ssh.startAgent = false;
    vim.defaultEditor = true;
    zsh.enable = true;
  };
  
  environment = {
    systemPackages = with pkgs; [
      vim
      neovim
      firefox
      thunderbird
      rsync
      git
    ];
  }
  # Enable unfree packages
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };




#  # Open ports in the firewall.
#  networking.firewall = {
#    allowedTCPPorts = [ 17500 ];
#    allowedUDPPorts = [ 17500 ];
#  };

  # User service for dropbox
  #systemd.user.services.dropbox = {
  #  description = "Dropbox";
  #  wantedBy = [ "graphical-session.target" ];
  #  environment = {
  #    QT_PLUGIN_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtPluginPrefix;
  #    QML2_IMPORT_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtQmlPrefix;
  #  };
  #  serviceConfig = {
  #    ExecStart = "${pkgs.dropbox.out}/bin/dropbox";
  #    ExecReload = "${pkgs.coreutils.out}/bin/kill -HUP $MAINPID";
  #    KillMode = "control-group"; # upstream recommends process
  #    Restart = "on-failure";
  #    PrivateTmp = true;
  #    ProtectSystem = "full";
  #    Nice = 10;
  #  };
  #};
  
  # VPN service
 # {
 #   services = {
 #     openvpn.servers = {
 #       tafka-nixos= {
 #         config = ''
 #           dev tun
 #           client
 #           proto tcp
 #           ca /home/tafka/vpn/tafka-nixos/ca.crt
 #           cert /home/tafka/vpn/tafka-nixos/client.crt
 #           key /home/tafka/vpn/tafka-nixos/client.key
 #         '';
 #         autoStart = false;
 #         updateResolvConf = true;
 #       }
 #     }
 #   }
 # }
 
#services.udev.packages = [ pkgs.yubikey-personalization ];
#
## Depending on the details of your configuration, this section might be necessary or not;
## feel free to experiment
#environment.shellInit = ''
#  export GPG_TTY="$(tty)"
#  gpg-connect-agent /bye
#  export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
#'';
#
#programs = {
#  ssh.startAgent = false;
#  gnupg.agent = {
#    enable = true;
#    enableSSHSupport = true;
#  };
#};
#
#security.pam.yubico = {
#	enable = true;
#	debug = true;
#	mode = "challenge-response";
#};
#
#services.pcscd.enable = true;
  

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  nix = {
    package = pkgs.nixFlakes;
    useSandbox = true;
    autoOptimiseStore =true;
    readOnlyStore = false;
    allowedUsers = [ "@wheel" ];
    trustedUsers = [ "@wheel" ];
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d --max-freed $((64 * 1024**3))";
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  system = {
    stateVersion = "22.05"; # Did you read the comment?
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      flake = github:tafkamax/nixconf
      flags = [
        "--recreate-lock-file"
        "--no-write-lock-file"
        "-L"
      ];
      dates = "daily';
    };
  };

}
