{
  description = "A (not so) basic robotnix configuration";

  inputs = {
    robotnix.url = "github:Kranzes/robotnix-forklineageos";

    device_xiaomi_miatoll = { url = "github:sairam1411/device_xiaomi_miatoll"; flake = false; };
    device_xiaomi_sm6250-common = { url = "github:sairam1411/device_xiaomi_sm6250-common"; flake = false; };
    vendor_xiaomi_miatoll = { url = "github:sairam1411/vendor_xiaomi_miatoll"; flake = false; };
    vendor_xiaomi_sm6250-common = { url = "github:sairam1411/vendor_xiaomi_sm6250-common"; flake = false; };
    kernel_xiaomi_sm6250 = { url = "github:sairam1411/kernel_xiaomi_sm6250"; flake = false; };
  };

  outputs = { self, robotnix, ... }@inputs: {
    robotnixConfigurations."miatoll" = robotnix.lib.robotnixSystem ({ config, pkgs, ... }: {
      device = "miatoll";
      flavor = "lineageos";
      androidVersion = 11;
      buildDateTime = 1630871265;

      #signing.enable = true;
      #signing.keyStorePath = "/home/1TB-HDD/Android/robotnix/keys";

      #envVars.TARGET_FLOS = "true";

      source.dirs = {
        "device/xiaomi/miatoll".src = inputs.device_xiaomi_miatoll;
        "device/xiaomi/sm6250-common".src = inputs.device_xiaomi_sm6250-common;
        "vendor/xiaomi/miatoll".src = inputs.vendor_xiaomi_miatoll;
        "vendor/xiaomi/sm6250-common".src = inputs.vendor_xiaomi_sm6250-common;
        "kernel/xiaomi/sm6250".src = inputs.kernel_xiaomi_sm6250;
      };
    });
    defaultPackage.x86_64-linux = self.robotnixConfigurations."miatoll".ota;
  };
}
