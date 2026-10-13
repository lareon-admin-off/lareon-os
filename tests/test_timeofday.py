#!/usr/bin/env python3
"""Checks that lareon-timeofday follows the Lareon schedule. Run: python3 tests/test_timeofday.py"""
import datetime as dt
import importlib.machinery
import importlib.util
import os
import sys
import tempfile

sys.dont_write_bytecode = True  # keep the package folder clean

HERE = os.path.dirname(os.path.abspath(__file__))
SCRIPT = os.path.join(HERE, "..", "packages", "lareon-timeofday", "usr", "bin", "lareon-timeofday")
loader = importlib.machinery.SourceFileLoader("lareon_timeofday", SCRIPT)
spec = importlib.util.spec_from_loader("lareon_timeofday", loader)
tod = importlib.util.module_from_spec(spec)
loader.exec_module(tod)
conf = os.path.join(tempfile.mkdtemp(), "timeofday.conf")
tod.CONF = conf

failures = 0


def check(zone, iso, expected, settings=""):
    global failures
    with open(conf, "w") as f:
        f.write(settings)
    os.environ["TZ"] = zone
    got, how = tod.frame_for(dt.datetime.fromisoformat(iso))
    ok = tod.describe(got).split(" ")[0] in expected if isinstance(expected, set) else got == expected
    failures += not ok
    print(f"{'ok  ' if ok else 'FAIL'} {zone:20} {iso}  -> f{got:02d} {tod.describe(got):22} {how}")


# Clock schedule (default)
check("America/Boise", "2026-10-12T03:00:00-06:00", 0)    # night
check("America/Boise", "2026-10-12T05:15:00-06:00", 4)    # halfway night -> dawn
check("America/Boise", "2026-10-12T06:30:00-06:00", 8)    # dawn
check("America/Boise", "2026-10-12T13:00:00-06:00", 16)   # day
check("America/Boise", "2026-10-12T18:30:00-06:00", 24)   # dusk
check("America/Boise", "2026-10-12T20:59:00-06:00", 31)   # last step before night
check("America/Boise", "2026-10-12T21:00:00-06:00", 0)    # night again
check("Asia/Tokyo", "2026-10-12T12:00:00+09:00", 16)      # same clock anywhere

# follow_sun: Boise sunrise ~07:54, sunset ~19:08 on 12 Oct 2026
sun = "follow_sun=true\n"
check("America/Boise", "2026-10-12T07:55:00-06:00", 8, sun)   # dawn at sunrise
check("America/Boise", "2026-10-12T06:30:00-06:00", {"night"}, sun)
check("America/Boise", "2026-10-12T19:08:00-06:00", 24, sun)  # dusk at sunset
# polar night: no sunrise, falls back to the clock
check("Arctic/Longyearbyen", "2026-12-21T12:00:00+01:00", 16, sun)

# every frame is reachable in one day
os.environ["TZ"] = "Europe/Paris"
open(conf, "w").close()
seen = {tod.frame_for(dt.datetime(2026, 10, 12, 0, 0).astimezone() + dt.timedelta(minutes=m))[0]
        for m in range(24 * 60)}
ok = seen == set(range(tod.FRAME_COUNT))
failures += not ok
print(("ok  " if ok else "FAIL") + f" all {tod.FRAME_COUNT} frames used in a day ({len(seen)} seen)")

print("all good" if not failures else f"{failures} failed")
sys.exit(1 if failures else 0)
