from datetime import datetime, UTC
from pathlib import Path
from sys import stdout
from time import sleep

POWER_SUPPLY_DIRECTORY = Path("/sys/class/power_supply")


def find_battery_directory() -> Path | None:
    return next(POWER_SUPPLY_DIRECTORY.glob("BAT*"))


def read_battery_charge(path: Path) -> int:
    return int(path.read_text().strip())


def get_battery_percent(directory: Path) -> int:
    charge_now = read_battery_charge(directory / "charge_now")
    charge_full_design = read_battery_charge(directory / "charge_full_design")
    return 100 * charge_now // charge_full_design


def format_current_time() -> str:
    now = datetime.now(tz=UTC).astimezone()
    return now.strftime("%k:%M:%S %Z on %A, %B %-d, %Y")


def print_status(*, battery_directory: Path | None) -> None:
    if battery_directory is not None:
        battery_percent = get_battery_percent(battery_directory)
        stdout.write(f"Battery: {battery_percent}% ⸱ ")

    stdout.write(format_current_time())


def main() -> None:
    battery_directory = find_battery_directory()

    while True:
        print_status(battery_directory=battery_directory)
        stdout.flush()
        sleep(1)


if __name__ == "__main__":
    main()
