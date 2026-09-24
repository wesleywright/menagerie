{
  lib,
  pkgs,
  ...
}: let
  # Helper script to generate a list of files to backup, omitting things like
  # files ignored by .gitignore. See script doc comment for more.
  list-files-to-backup = pkgs.writers.writePython3 "list-files-to-backup" {
    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath [pkgs.git]}"
    ];
  } (builtins.readFile ./list-files-to-backup.py);

  # The list of directories to be backed up (subject to filtering by the
  # list-files-to-backup script).
  directoriesToBackup = [
    "/home/naptime/notes"
    "/home/naptime/src"
    "/mnt/audiobooks"
    "/mnt/music"
  ];

  backupTimestampPath = "/var/run/naptime/backups/last-success";
in {
  services.restic = {
    backups = {
      primary = {
        backupCleanupCommand = "${pkgs.writeShellScript "write-backup-timestamp" ''
          if [[ "$SERVICE_RESULT" == "success" ]]; then
            mkdir -p "$(dirname "${backupTimestampPath}")"
            date --rfc-3339=second >"${backupTimestampPath}"
          fi
        ''}";

        dynamicFilesFrom = lib.escapeShellArgs (["${list-files-to-backup}"] ++ directoriesToBackup);

        environmentFile = "/etc/naptime/backups/credentials.env";

        extraBackupArgs = [
          # Since we're using `--files-from` and listing files to backup
          # exhaustively, the set of paths associated with each restic snapshot
          # is prone to change whenever we add or remove files on the filesystem.
          # By default, this prevents restic from detecting a parent snapshot,
          # which can cause excessive file scanning. Grouping by host and tags
          # prevents this.
          "--group-by=host,tags"
        ];
        # Update backup status to journal once per minute
        progressFps = 0.016666;
      };
    };
  };
}
