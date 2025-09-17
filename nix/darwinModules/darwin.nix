{ inputs, ... }@flakeContext:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.agenix.darwinModules.default
  ];

  options = {
    darwinModules.darwin.primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "bthode";
      description = "Primary user for the Darwin system";
    };
  };

  config = {
    age.secrets.example-secret = {
      file = "${inputs.nix-secrets}/example-secret.age";
      owner = config.darwinModules.darwin.primaryUser;
    };

    nix-homebrew = {
      enable = true;
      enableRosetta = true;
      user = config.darwinModules.darwin.primaryUser;
      taps = {
        "homebrew/homebrew-core" = inputs.homebrew-core;
        "homebrew/homebrew-cask" = inputs.homebrew-cask;
      };
      mutableTaps = false;
    };
    nix.settings = {
      experimental-features = "nix-command flakes";
    };
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
    environment = {
      systemPackages = [
        pkgs.neovim
        # pkgs.telegram-desktop
        pkgs.nixd
        pkgs.fd
        # pkgs.spotify Waiting for hash to be corrected
        # pkgs.ripgrep/
        pkgs.google-chrome # TODO: This should be only for non-work machines. Work already installs it.
        pkgs.lastpass-cli
        pkgs.age
        inputs.agenix.packages.${pkgs.system}.default
        # pkgs.zellij
        # pkgs.brave
        # pkgs.claude-code
      ];
    };
    homebrew = {
      enable = true;

      brews = [
        "displayplacer"
        "mas"
      ];

      casks = [
        "epic-games"
        "firefox"
        "ghidra"
        "ghostty"
        "sublime-text"
      ];

      taps = builtins.attrNames config.nix-homebrew.taps;

      onActivation = {
        autoUpdate = true;
        cleanup = "zap"; # Uninstall packages/casks not in Brewfile
        upgrade = true;
      };

      global = {
        brewfile = true;
      };

      # masApps = {
      #   # Xcode = 497799835;
      #   Magnet = 441258766;
      # };

      user = config.darwinModules.darwin.primaryUser;
    };
    nixpkgs = {
      config.allowUnfree = true;
      # config.allowBroken = true;
      hostPlatform = {
        system = "aarch64-darwin";
      };
    };
    power = {
      restartAfterFreeze = true;
      # restartAfterPowerFailure = true; # Not supported on laptops
    };
    programs = {
      direnv = {
        enable = true;
      };
      fish = {
        enable = true;
      };
    };
    fonts = {
      packages = [ pkgs.nerd-fonts.jetbrains-mono ];
    };

    security = {
      pam = {
        services = {
          sudo_local = {
            enable = true;
            # This may be required using DisplayLink
            # /usr/bin/defaults write ~/Library/Preferences/com.apple.security.authorization.plist ignoreArd -bool TRUE
            # https://discussions.apple.com/thread/255187302?sortBy=rank
            touchIdAuth = true;
          };
        };
      };
    };

    system = {
      activationScripts.extraActivation.text = ''
        # softwareupdate --install-rosetta --agree-to-license
        # sudo xcodebuild -license accept
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';
      defaults = {
        NSGlobalDomain = {
          "com.apple.keyboard.fnState" = true;
          "com.apple.swipescrolldirection" = false;
          AppleInterfaceStyle = "Dark";
          AppleKeyboardUIMode = 3;
          ApplePressAndHoldEnabled = false;
          InitialKeyRepeat = 15;
          KeyRepeat = 10;
          NSAutomaticCapitalizationEnabled = false;
          NSScrollAnimationEnabled = true;
        };

        WindowManager = {
          EnableStandardClickToShowDesktop = false;
        };
        controlcenter = {
          BatteryShowPercentage = true;
        };
        dock = {
          autohide = true;
          largesize = null;
          show-recents = false;
          magnification = false;
          mineffect = "genie";
          tilesize = 10;
          wvous-bl-corner = 1;
          wvous-br-corner = 1;
          wvous-tl-corner = 1;
          wvous-tr-corner = 1;
          persistent-apps = [
            "/Applications/ghostty.app"
          ];
        };
        finder = {
          CreateDesktop = false;
          FXDefaultSearchScope = "SCcf";
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "clmv";
          NewWindowTarget = "Home";
          ShowStatusBar = true;
          _FXSortFoldersFirst = true;
        };
        hitoolbox = {
          AppleFnUsageType = "Do Nothing";
        };
        loginwindow = {
          GuestEnabled = false;
        };
        menuExtraClock = {
          ShowDayOfMonth = true;
        };
        screensaver = {
          askForPasswordDelay = 5;
        };
      };
      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };
      primaryUser = config.darwinModules.darwin.primaryUser;
      startup = {
        chime = false;
      };
    };
  };
}
