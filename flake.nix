{
  description = "A (not so) basic robotnix configuration";

  nixConfig.extra-substituters = [ "https://robotnix.cachix.org" ];
  nixConfig.extra-trusted-public-keys = [ "robotnix.cachix.org-1:+y88eX6KTvkJyernp1knbpttlaLTboVp4vq/b24BIv0=" ];

  inputs = {
    robotnix.url = "github:Kranzes/robotnix-forklineageos";
    device_xiaomi_miatoll = { url = "github:sairam1411/device_xiaomi_miatoll"; flake = false; };
    device_xiaomi_sm6250-common = { url = "github:sairam1411/device_xiaomi_sm6250-common"; flake = false; };
    vendor_xiaomi_miatoll = { url = "github:sairam1411/vendor_xiaomi_miatoll"; flake = false; };
    vendor_xiaomi_sm6250-common = { url = "github:sairam1411/vendor_xiaomi_sm6250-common"; flake = false; };
    kernel_xiaomi_sm6250 = { url = "github:sairam1411/kernel_xiaomi_sm6250"; flake = false; };
    flake-compat-ci.url = "github:hercules-ci/flake-compat-ci";
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
  };

  outputs = { self, robotnix, flake-compat, flake-compat-ci, ... }@inputs: {
    robotnixConfigurations."miatoll" = robotnix.lib.robotnixSystem ({ config, pkgs, lib, ... }: {
      device = "miatoll";
      flavor = "lineageos";
      androidVersion = 11;

      signing.enable = true;
      signing.keyStorePath = "/home/1TB-HDD/Android/keys";

      apps.bromite.enable = false;
      apps.chromium.enable = false;

      webview = {
        chromium = {
          enable = false;
          availableByDefault = false;
        };
        bromite = {
          enable = true;
          availableByDefault = true;
        };
      };

      microg.enable = true;

      source.dirs = {
        # Needed for robotnix's microg module to work
        "frameworks/base".patches = [
          ./patches/revert-forklineageos-microg.patch
        ];
        # Re-enable building of OTA updater
        "vendor/lineage".patches = [
          (pkgs.fetchpatch {
            name = "re-enable-updater-building.patch";
            url = "https://github.com/ForkLineageOS/android_vendor_lineage/commit/55cad6d27fbd82b195a7cc85ade6ffd37a3c4fa6.patch";
            sha256 = "sha256-qwboQhbBEIOCwCCF4rGKe6nCdjhg9HHs9IKh6br4JyA=";
            revert = true;
          })
        ];
      };

      apps = {
        updater.enable = true;
        updater.url = "https://ilanjoselevich.com/android/";
      };

      source.dirs = {
        "device/xiaomi/miatoll".src = inputs.device_xiaomi_miatoll;
        "device/xiaomi/sm6250-common".src = inputs.device_xiaomi_sm6250-common;
        "vendor/xiaomi/miatoll".src = inputs.vendor_xiaomi_miatoll;
        "vendor/xiaomi/sm6250-common".src = inputs.vendor_xiaomi_sm6250-common;
        "kernel/xiaomi/sm6250".src = inputs.kernel_xiaomi_sm6250;
      };
    });
    defaultPackage.x86_64-linux = self.robotnixConfigurations."miatoll".otaDir;
    ciNix = flake-compat-ci.lib.recurseIntoFlakeWith { flake = self; systems = [ "x86_64-linux" ]; };
  };
}
