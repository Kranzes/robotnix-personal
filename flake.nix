{
  description = "A (not so) basic robotnix configuration";

  nixConfig.extra-substituters = [ "https://robotnix.cachix.org" ];
  nixConfig.extra-trusted-public-keys = [ "robotnix.cachix.org-1:+y88eX6KTvkJyernp1knbpttlaLTboVp4vq/b24BIv0=" ];

  inputs = {
    robotnix.url = "github:danielfullmer/robotnix";
    flos-robotnix.url = "github:Kranzes/robotnix";
    nixpkgs.follows = "robotnix/nixpkgs";
    device_xiaomi_miatoll = { url = "github:sairam1411/device_xiaomi_miatoll/eleven"; flake = false; };
    device_xiaomi_sm6250-common = { url = "github:sairam1411/device_xiaomi_sm6250-common/eleven"; flake = false; };
    vendor_xiaomi_miatoll = { url = "github:sairam1411/vendor_xiaomi_miatoll/eleven"; flake = false; };
    vendor_xiaomi_sm6250-common = { url = "github:sairam1411/vendor_xiaomi_sm6250-common/eleven"; flake = false; };
    kernel_xiaomi_sm6250 = { url = "github:sairam1411/kernel_xiaomi_sm6250"; flake = false; };
    hosts = { url = "github:StevenBlack/hosts"; flake = false; };
  };

  outputs = { self, robotnix, flos-robotnix, nixpkgs, ... }@inputs:
    let
      common = {
        signing.enable = true;
        signing.keyStorePath = "/home/1TB-HDD/Android/keys";

        apps = {
          bromite.enable = false;
          chromium.enable = false;
          updater.enable = true;
          updater.url = "https://android.ilanjoselevich.com";
        };

        webview = {
          chromium.enable = false;
          chromium.availableByDefault = false;
          bromite.enable = true;
          bromite.availableByDefault = true;
        };

        microg.enable = true;

        hosts = inputs.hosts + "/hosts";
      };
    in
    {
      robotnixConfigurations."miatoll" = flos-robotnix.lib.robotnixSystem ({ pkgs, ... }: {
        imports = [ common ];
        device = "miatoll";
        flavor = "lineageos";
        androidVersion = 11;

        source.dirs = {
          "frameworks/base".patches = [ ./patches/revert-forklineageos-microg.patch ]; # Needed for robotnix's microg module to work
          "device/xiaomi/miatoll".patches = [ ./patches/RKQ1-200826-002.patch ]; # Fingerprint
          "vendor/lineage".patches = [
            # Re-enable building of OTA updater
            (pkgs.fetchpatch {
              name = "re-enable-updater-building.patch";
              url = "https://github.com/ForkLineageOS/android_vendor_lineage/commit/55cad6d27fbd82b195a7cc85ade6ffd37a3c4fa6.patch";
              sha256 = "sha256-qwboQhbBEIOCwCCF4rGKe6nCdjhg9HHs9IKh6br4JyA=";
              revert = true;
            })
          ];
          "device/xiaomi/miatoll".src = inputs.device_xiaomi_miatoll;
          "device/xiaomi/sm6250-common".src = inputs.device_xiaomi_sm6250-common;
          "vendor/xiaomi/miatoll".src = inputs.vendor_xiaomi_miatoll;
          "vendor/xiaomi/sm6250-common".src = inputs.vendor_xiaomi_sm6250-common;
          "kernel/xiaomi/sm6250".src = inputs.kernel_xiaomi_sm6250;
        };
      });

      robotnixConfigurations."ginkgo" = robotnix.lib.robotnixSystem {
        imports = [ common ];
        device = "ginkgo";
        flavor = "lineageos";
        androidVersion = 11;
      };

      defaultPackage.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.symlinkJoin {
        name = "robotnix-ota";
        paths = (with self.robotnixConfigurations; map (c: c.otaDir) [
          miatoll
          ginkgo
        ]);
      };
    };
}
