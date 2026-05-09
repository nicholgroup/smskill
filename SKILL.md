---
name: sm-skill
description: >
    Special Measure (SM) — MATLAB framework for instrument control, scan
    automation, and data acquisition. Trigger when the user mentions Special
    Measure, smrun / smset / smget / smnext / smopen / smdata / smscan,
    scan structs (loops, setchan, getchan, ramptime, trafofn, prefn, postfn,
    procfn, datafn, configfn, cleanupfn, consts, disp), buffered readout
    (smabufconfig2, smatrigfn), instrument drivers (smc*.m, cntrlfn, ICO
    [inst chan op]), DecaDAC / Yoko / SR830 / AMI430 / Alazar / AWG control,
    or post-scan analysis with plotData / fitwrap / ana_*. Covers the full
    lab workflow: rack setup, scan authoring, run/debug, drivers, and
    plotting/analysis.
---

# Special Measure skill

Special Measure is a MATLAB measurement framework. Two things drive everything:

1. **`smdata`** — global struct holding the rack: `smdata.inst` (instruments + drivers) and `smdata.channels` (logical channels with rangeramp). Assume this is already loaded; cold-start setup lives in [references/special-measure.wiki/Installation.md](references/special-measure.wiki/Installation.md).
2. **`scan`** struct — describes loops, set/get channels, ramping, display, and pre/post hooks. Passed to `smrun(scan, smnext('label'))`.

Resources in this skill:

- `references/special-measure.wiki/` — full upstream wiki (read these before answering deep questions; do not paraphrase from memory).
- `scripts/special-measure/src/` — the MATLAB source: `sm/` (core), `drivers/` (smc*.m), `utils/{plotting,analysis}/`.
- `scripts/special-measure/examples/` — runnable mock quantum-dot sandbox (no hardware required).
- `scripts/special-measure/tests/` — `tSm*.m` unit tests covering smrun 1D/2D/buffered, smset/smget, smscanpar.

## Where to look first (task → file)

| Task | Reference | Source / example |
| --- | --- | --- |
| Build a scan struct | [Scans.md](references/special-measure.wiki/Scans.md) | `scripts/special-measure/examples/dot_examples.m` |
| Understand smdata layout | [smdata.md](references/special-measure.wiki/smdata.md) | `scripts/special-measure/src/sm/smaddchannel.m` |
| smrun execution order | [smrun.md](references/special-measure.wiki/smrun.md) | `scripts/special-measure/src/sm/smrun.m` |
| Set / read channels | [smset.md](references/special-measure.wiki/smset.md), [smget.md](references/special-measure.wiki/smget.md) | `src/sm/smset.m`, `src/sm/smget.m` |
| Buffered acquisition | [smabufconfig2.md](references/special-measure.wiki/smabufconfig2.md), [smatrigfn.md](references/special-measure.wiki/smatrigfn.md) | dot_examples.m §"Buffered channel scan" |
| procfn data processing | [procfn.md](references/special-measure.wiki/procfn.md) | `tests/tSmrunBuf.m` |
| Auto-numbered filenames | [smnext.md](references/special-measure.wiki/smnext.md) | — |
| Restore prior values | [smrestore.md](references/special-measure.wiki/smrestore.md) | — |
| DecaDAC bring-up | [smadacinit.md](references/special-measure.wiki/smadacinit.md), [smadachandshake.md](references/special-measure.wiki/smadachandshake.md) | — |
| Write a new driver | [Writing-Drivers.md](references/special-measure.wiki/Writing-Drivers.md), [Example-of-a-Driver.md](references/special-measure.wiki/Example-of-a-Driver.md), [ICO.md](references/special-measure.wiki/ICO.md) | `scripts/special-measure/examples/smcqdot.m` |
| Driver list | [Drivers-for-Instrument-Channels.md](references/special-measure.wiki/Drivers-for-Instrument-Channels.md) | `scripts/special-measure/src/drivers/` |
| Common errors | [Error-Messages.md](references/special-measure.wiki/Error-Messages.md) | — |
| Plotting / analysis | — | `scripts/special-measure/src/utils/plotting/` (plotData, pptplot), `utils/analysis/` (fitwrap, ana_*) |

## Scan struct cheatsheet

```matlab
scan.loops(1).setchan  = {'V1'};       % string, cell of strings, or numeric idx
scan.loops(1).getchan  = {'LockInX'};
scan.loops(1).rng      = [-0.5 0.5];   % or explicit linspace(...)
scan.loops(1).npoints  = 101;          % ignored if rng is a full vector
scan.loops(1).ramptime = 0.05;         % s/point. negative = self-ramp + trigger.
scan.loops(1).trafofn  = ...           % map loop coord -> channel value(s)
scan.loops(1).prefn    = ...           % run before set, each step
scan.loops(1).postfn   = ...           % run after read, each step
scan.loops(1).trigfn   = ...           % run once at first point (trigger ramp)
scan.loops(1).procfn   = ...           % per-channel data processing
scan.loops(1).datafn   = ...           % observe data, no return
scan.loops(1).waittime = 0;            % s after set, before get

scan.disp(k).loop = 1;  .dim = 1|2;  .channel = idx_among_getchans;
scan.consts(k).setchan = 'samprate';   .val = 1e5;
scan.configfn.fn   = @smabufconfig2;   .args = {'arm', 1};
scan.cleanupfn.fn  = @smaconfigwrap;   .args = {@smset, 'B', 0};
scan.saveloop = [loop stride];         % default [2 1]

data = smrun(scan, smnext('mylabel'));
```

`scan.loops(1)` is the **innermost / fastest** loop; the last entry is the outermost.

## Function specification format

User functions (`prefn`, `postfn`, `trigfn`, `datafn`, `configfn`, `cleanupfn`) use one of three formats — see [Scans.md §"specifying user functions"](references/special-measure.wiki/Scans.md):

- struct: `.fn = @handle; .args = {...}`
- string: `.fn = '@handle'` (avoids carrying the workspace into the saved file — preferred for archiving)
- cell: `prefn{k} = @handle` (no args allowed)

`configfn`/`cleanupfn` receive the `scan` itself and must return it; wrap non-conforming functions with `@smaconfigwrap`. Other in-loop fns receive the current loop coordinates.

## Common gotchas

- **rangeramp factor (4th element)**: `smset('1a', -0.4)` with rangeramp `[-0.6 0 0.07 11]` actually drives the hardware to **-4.4** (multiplier of 11). Reads are divided by the same factor. See [smdata.md §rangeramp](references/special-measure.wiki/smdata.md).
- **Negative ramptime / ramprate**: signals "self-ramping channel; program the ramp but don't wait — trigger separately." Required for buffered/triggered scans. See [smset.md](references/special-measure.wiki/smset.md).
- **`type=1` instruments** (selframping): `smset` calls the driver with the target value + ramprate and waits the expected time. `type=0`: SM steps the channel itself in 10 ms increments.
- **`getchan` empty in inner loop**: standard pattern when the outer loop's `getchan` returns one buffered array per inner sweep (datadim > 1).
- **`disp` is silent if missing**: figure 1000 will be blank if `scan.disp` is unset.
- **`scan.saveloop` defaults to `[2 1]`** — for a 1D scan you must set `scan.saveloop = 1` or data only saves at the end.
- **Channel names must be unique** across `smdata.channels`; instrument names should be unique among same-`device` instruments.
- **`smchanlookup` / `sminstlookup`** convert names to indices; use them when you need numeric ICs (e.g. for `smatrigfn`).
- **Halt during scan**: `Esc` ends cleanly (runs `cleanupfn`, saves), `Space` drops to `keyboard` debugger; type `return` to resume.

## Mock quantum-dot sandbox (no hardware needed)

For prototyping scans, demos, or testing skill output, point users at the runnable example:

- `scripts/special-measure/examples/smcqdot.m` — driver simulating 7 gates + Vsd + I + buffered I_buf.
- `scripts/special-measure/examples/smcqdot_setup.m` — registers the mock instrument and 11 channels.
- `scripts/special-measure/examples/dot_examples.m` — full workflow: 1D turn-on, 2D channel scan, buffered 2D channel scan, finger-gate shutoff loop. Read this when the user asks for "an example of X" — it likely has one.

`dot_examples.m` is the canonical reference for the SM call patterns: `smset`, `smchanlookup`, `smnext`, `smabufconfig2` configfn, `smaconfigwrap` for cleanup, and 1D vs 2D `disp` setup. Adapt from it rather than synthesising from scratch.

## Buffered readout pattern

```matlab
scan.configfn.fn   = @smabufconfig2;
scan.configfn.args = {'trig arm', [], [], 2};   % cntrl, getrng, setrng, loop
```

`cntrl` is some combination of `'fast' | 'arm' | 'trig' | 'end'`. See [smabufconfig2.md](references/special-measure.wiki/smabufconfig2.md) — the most subtle file in the wiki; read it carefully before advising on buffered scans. The driver must implement op=4 (arm) and op=5 (configure with `[npts, rate]`); see `smcqdot.m` for a minimal example.

## Driver authoring (smc*.m)

A driver is one MATLAB function `val = smc<name>(ico, val, rate)` where `ico = [inst chan op]`. Standard ops ([ICO.md](references/special-measure.wiki/ICO.md)):

- `0` read, `1` set, `3` trigger, `4` arm, `5` configure (instrument-specific)

Walkthroughs:

- [Example-of-a-Driver.md](references/special-measure.wiki/Example-of-a-Driver.md) — annotated DMM driver.
- [Writing-Drivers.md](references/special-measure.wiki/Writing-Drivers.md) — `smdata.inst` field reference, op semantics, ramping conventions.
- `scripts/special-measure/src/drivers/smctemplate.m` — starting template.
- `scripts/special-measure/examples/smcqdot.m` — complete driver with set/get/trigger/arm/configure.

After writing the driver, register the instrument by appending an entry to `smdata.inst` (set `name`, `device`, `cntrlfn=@smc<name>`, `channels`, `type`, `datadim`, `data`) and call `smaddchannel` for each logical channel.

## Plotting & analysis

- `plotData(file)` — auto-detects 1D/2D, file picker if no arg.
- `fitwrap(ctrl, x, y, beta0, model)` — wraps `nlinfit` with optional plot.
- `ana_avg`, and the `ana*.m` suite under `src/utils/analysis/` — domain analyses (charge noise, transport, T1, electron temp, etc.).
- `pptplot` — GUI export to PowerPoint.

`.mat` files saved by `smrun` contain `data` (cell array per getchan), `scan` (full definition), `configvals`/`configch` (snapshot of logged channels), and `smdata_novisa` (rack with VISA handles stripped).

## Debug helpers

- `smprintchannels`, `smprintinst`, `smprintrange`, `smprintscan(scan)` — print human-readable rack/scan info before running.
- `sminitdisp` — opens figure 1001 displaying live channel values; close the figure to disable.
- `smflush(inst)` — drain instrument buffer after an aborted scan.
- `smclose(inst); smopen(inst);` — recover a hung VISA/USB instrument.
- `smrestore(file)` — roll all `configch` channels back to their values at the time of a saved scan; useful after a tuning session goes off the rails.

## Style when answering

- Use exact channel/function names from the user's `smdata`; ask for the rack contents (`smprintchannels`) if you need them and they're not visible.
- For new scans, write the full struct literally (one field per line) — this is how lab code is read and reviewed.
- Prefer `smchanlookup('name')` over hard-coded numeric indices in answers, except inside hot loops or driver internals.
- When uncertain about a wiki detail (e.g. exact procfn dim semantics, buffered config args), open the relevant `references/special-measure.wiki/*.md` file and quote it — do not paraphrase from training data.
- Note that the wiki occasionally references old paths (e.g. `sm/channels`); the current layout is `src/sm`, `src/drivers`, `src/utils/{plotting,analysis}`. Adjust `addpath` calls accordingly.
