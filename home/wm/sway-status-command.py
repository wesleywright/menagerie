from datetime import datetime, UTC
import json
from pathlib import Path
import subprocess
from sys import stdout
from time import sleep

CRITICAL_COLOR = "@criticalColor@"
POWER_SUPPLY_DIRECTORY = Path("/sys/class/power_supply")
SEPARATOR = " ⸱ "


def critical(text: str) -> str:
    return f'<span foreground="{CRITICAL_COLOR}">{text}</span>'


def find_battery_directory() -> Path | None:
    return next(POWER_SUPPLY_DIRECTORY.glob("BAT*"), None)


def read_battery_charge(path: Path) -> int:
    return int(path.read_text().strip())


def get_battery_percent(directory: Path) -> int:
    return int((directory / "capacity").read_text().strip())


def format_current_time() -> str:
    now = datetime.now(tz=UTC).astimezone()
    return now.strftime("%-H:%M:%S %Z on %A, %B %-d, %Y")


def count_failed_systemd_units() -> str | None:
    counts = {}
    for kind in "user", "system":
        try:
            raw = subprocess.check_output([
                "systemctl",
                f"--{kind}",
                "list-units",
                "--state=failed",
                "--output=json",
            ])
        except (FileNotFoundError, subprocess.CalledProcessError) as exception:
            return f"Failed to query systemd: {exception}"
        count = len(json.loads(raw))
        if count > 0:
            counts[kind] = count
    if len(counts) == 0:
        return None
    summary = ", ".join(f"{count} {kind}" for kind, count in counts.items())
    return f"Detected failed systemd units ({summary})"


def print_status(*, battery_directory: Path | None) -> None:
    systemd_failures = count_failed_systemd_units()
    if systemd_failures is not None:
        stdout.write(critical(systemd_failures))
        stdout.write(SEPARATOR)

    if battery_directory is not None:
        battery_percent = get_battery_percent(battery_directory)
        stdout.write(f"Battery: {battery_percent}%")
        stdout.write(SEPARATOR)

    stdout.write(format_current_time())
    stdout.write("\n")


def main() -> None:
    battery_directory = find_battery_directory()

    while True:
        print_status(battery_directory=battery_directory)
        stdout.flush()
        sleep(1)


if __name__ == "__main__":
    main()
