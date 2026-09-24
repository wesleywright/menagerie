from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta, UTC
import json
from pathlib import Path
import subprocess
from sys import stdout
from time import sleep
from typing import Callable

CRITICAL_COLOR = "@criticalColor@"
POWER_SUPPLY_DIRECTORY = Path("/sys/class/power_supply")
SEPARATOR = " · "


@dataclass(frozen=True, kw_only=True)
class StatusMonitorEntry:
    command: Callable[[], str | None]
    tick_interval: int


class StatusMonitor:
    def __init__(self):
        self._entries = []
        self._ticks = 0
        self._items = []

    def register(
        self,
        *,
        command: Callable[[], str | None],
        tick_interval: int,
    ) -> None:
        self._entries.append(StatusMonitorEntry(
            command=command,
            tick_interval=tick_interval,
        ))
        self._items.append("")

    def tick(self) -> str:
        for i, entry in enumerate(self._entries):
            if self._ticks % entry.tick_interval != 0:
                continue
            result = entry.command()
            if result is None:
                continue
            self._items[i] = result

        self._ticks += 1

        return SEPARATOR.join(
            item
            for item in self._items
            if item is not None and len(item) > 0
        )


def critical(text: str) -> str:
    return f'<span foreground="{CRITICAL_COLOR}">{text}</span>'


def get_battery_percent() -> str | None:
    directory = next(POWER_SUPPLY_DIRECTORY.glob("BAT*"), None)
    if directory is None:
        return None
    percent = (directory / "capacity").read_text().strip()
    return f"Battery: {percent}%"


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
            return critical(f"Failed to query systemd: {exception}")
        count = len(json.loads(raw))
        if count > 0:
            counts[kind] = count
    if len(counts) == 0:
        return ""
    summary = ", ".join(f"{count} {kind}" for kind, count in counts.items())
    return critical(f"Detected failed systemd units ({summary})")


def get_last_backup_status() -> str | None:
    path = Path("/var/run/naptime/backups/last-success")
    if not path.is_file():
        return None

    timestamp = datetime.fromisoformat(path.read_text().strip())
    now = datetime.now(tz=UTC).astimezone(timestamp.tzinfo)
    day_difference = (now.date() - timestamp.date()).days

    if (now - timestamp) < timedelta(hours=1):
        summary = "just now"
    elif day_difference == 0:
        summary = "today"
    elif day_difference == 1:
        summary = "yesterday"
    else:
        summary = critical(f"{day_difference} days ago")
    return f"Last backup: {summary}"


def main() -> None:
    status = StatusMonitor()

    status.register(command=count_failed_systemd_units, tick_interval=30)
    status.register(command=get_last_backup_status, tick_interval=300)
    status.register(command=get_battery_percent, tick_interval=10)
    status.register(command=format_current_time, tick_interval=1)

    while True:
        stdout.write(status.tick())
        stdout.write("\n")
        stdout.flush()
        stdout.flush()
        sleep(1)


if __name__ == "__main__":
    main()
