from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timedelta, UTC
import json
from pathlib import Path
import subprocess
from sys import stdout
from time import monotonic, sleep
from typing import Callable

CRITICAL_COLOR = "@criticalColor@"
POWER_SUPPLY_DIRECTORY = Path("/sys/class/power_supply")
SEPARATOR = " · "


@dataclass(frozen=True, kw_only=True)
class StatusMonitorEntry:
    command: Callable[[], str | None]
    interval: timedelta


@dataclass(frozen=True, kw_only=True)
class StatusMonitorOutput:
    content: str
    last_processed_at: float


class StatusMonitor:
    def __init__(self):
        self._entries = []
        self._outputs = []

    def register(
        self,
        *,
        command: Callable[[], str | None],
        interval: timedelta,
    ) -> None:
        self._entries.append(StatusMonitorEntry(
            command=command,
            interval=interval,
        ))
        self._outputs.append(StatusMonitorOutput(
            content="",
            last_processed_at=0.0,
        ))

    def tick(self) -> str:
        now = monotonic()
        for i, entry in enumerate(self._entries):
            elapsed = timedelta(
                seconds=now - self._outputs[i].last_processed_at,
            )
            if elapsed < entry.interval:
                continue
            content = entry.command() or ""
            self._outputs[i] = StatusMonitorOutput(
                content=content,
                last_processed_at=now,
            )

        return SEPARATOR.join(
            output.content for output in self._outputs if output.content
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
        return None
    summary = ", ".join(f"{count} {kind}" for kind, count in counts.items())
    return critical(f"Detected failed systemd units ({summary})")


def get_last_backup_status() -> str | None:
    path = Path("/var/run/naptime/backups/last-success")
    if not path.is_file():
        return None

    timestamp = datetime.fromisoformat(path.read_text().strip())
    now = datetime.now(tz=UTC).astimezone(timestamp.tzinfo)
    days_since_backup = (now.date() - timestamp.date()).days

    if days_since_backup == 0:
        return None

    if days_since_backup == 1:
        summary = "yesterday"
    else:
        summary = critical(f"{days_since_backup} days ago")
    return f"Last backup: {summary}"


def main() -> None:
    status = StatusMonitor()

    status.register(
        command=count_failed_systemd_units,
        interval=timedelta(seconds=30),
    )
    status.register(
        command=get_last_backup_status,
        interval=timedelta(minutes=1),
    )
    status.register(
        command=get_battery_percent,
        interval=timedelta(seconds=10),
    )
    status.register(
        command=format_current_time,
        interval=timedelta(seconds=0.9),
    )

    while True:
        stdout.write(status.tick())
        stdout.write("\n")
        stdout.flush()
        sleep(1)


if __name__ == "__main__":
    main()
