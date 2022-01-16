{ lib, pkgs, config, ... }:

let
  cfg = config.biome.mail;
in {
  options.biome.mail = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
    services.davmail = {
      enable = true;
      url = "https://outlook.office365.com/EWS/Exchange.asmx";
      config = {
        davmail.smtpPort = "1025";
        davmail.enableKerberos = "false";
        davmail.forceActiveSyncUpdate = "false";
        davmail.imapAutoExpunge = "true";
        davmail.useSystemProxies = "false";
        davmail.caldavEditNotifications = "false";
        davmail.ssl.nosecuresmtp = "false";
        davmail.caldavPastDelay = "0";
        davmail.server = "true";
        davmail.popMarkReadOnRetr = "false";
        davmail.ssl.nosecureimap = "false";
        davmail.disableTrayActivitySwitch = "false";
        davmail.caldavAutoSchedule = "true";
        davmail.enableProxy = "false";
        davmail.logFileSize = "1MB";
        davmail.mode = "O365Manual";
        davmail.smtpSaveInSent = "true";
        davmail.ssl.nosecurepop = "false";
        log4j.rootLogger = "WARN";
        log4j.logger.davmail = "DEBUG";
        davmail.oauth."lfschmid@uwaterloo.ca".refreshToken = import ../secrets/davmail.nix;
        davmail.imapPort = "1143";
        davmail.url = "https://outlook.office365.com/EWS/Exchange.asmx";
        log4j.logger.org.apache.http.conn.ssl = "WARN";
        davmail.sentKeepDelay = "0";
        davmail.ssl.nosecureldap = "false";
        davmail.imapAlwaysApproxMsgSize = "false";
        davmail.ssl.nosecurecaldav = "false";
        davmail.popPort = "1110";
        davmail.showStartupBanner = "true";
        davmail.ldapPort = "1389";
        log4j.logger.org.apache.http.wire = "WARN";
        davmail.disableGuiNotifications = "false";
        davmail.allowRemote = "false";
        davmail.disableUpdateCheck = "true";
        davmail.caldavPort = "1080";
        davmail.enableKeepAlive = "false";
        davmail.logFilePath="/var/log/davmail/davmail.log";
        davmail.carddavReadPhoto = "true";
        davmail.keepDelay = "30";
      };
    };
  };
}
