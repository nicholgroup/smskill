# sm-skill — Special Measure assistant for Claude Code

A Claude Code skill that turns Claude into a useful pair-programmer for **Special Measure**, the MATLAB measurement framework used in the Nichol group (and originally written by Hendrik Bluhm and Vivek Venkatachalam).

When this skill is loaded, Claude has the full SM wiki, the source tree, and a runnable mock-qdot example at hand. So you can ask it to write scans, debug a driver, or explain what `smabufconfig2` is doing, and it will reach for the right reference instead of guessing.

---

## Who this is for

You, if you:

- Run cooldowns and want to draft a 1D/2D/buffered scan without re-reading the wiki for the tenth time.
- Are bringing up a new instrument and need help writing or porting an `smc*.m` driver.
- Just inherited someone else's `scan` struct and want it explained line by line.
- Want to prototype a new measurement on the **mock quantum dot** before pushing buttons in the lab.
- Are tuning gates and need a quick `smset` / `smrestore` recipe.

You don't need to be an expert MATLAB programmer. You **do** need a working SM rack on your machine if you want to run the code Claude writes (the mock qdot example needs no hardware).

---

## Installing the skill

**Option A — Use it from this folder** (recommended while we're iterating):

1. Open Claude Code in the `sm-skill/` directory (or anywhere inside the `NG_llm_agent` workspace).
2. Claude Code will discover `SKILL.md` and load the skill automatically. You can confirm with `/skills`.

**Option B — Copy it to your personal skills directory** so it's always available:

```powershell
# Windows
Copy-Item -Recurse "c:\Users\<you>\Box\Nichol Group\NG_llm_agent\skills\sm-skill" `
                   "$env:USERPROFILE\.claude\skills\sm-skill"
```

```bash
# macOS / Linux
cp -r "/path/to/NG_llm_agent/skills/sm-skill" ~/.claude/skills/sm-skill
```

After copying, restart Claude Code (or run `/skills`) and `sm-skill` will be available in any session.

---

## Quick start: things to ask Claude

Drop into Claude Code in your experiment folder and try one of these:

- *"Write a 2D scan that sweeps `Vp` from −0.4 to −0.3 (101 points) on the inner loop and `Vt` from −0.5 to −0.45 (51 points) on the outer loop, reading `LockInX` and `LockInY`. Save with `smnext('coulomb_diamond')`."*
- *"Convert this scan to use buffered readout with the SR830 as the get channel."*
- *"Walk me through what each field of this scan struct does."* (then paste your scan)
- *"I'm getting `Operation not supported` on channel 4 of my Yoko driver — what would cause that?"*
- *"Add a `cleanupfn` that ramps the magnet back to zero at the end of the scan."*
- *"Set up the mock quantum dot example and show me a 1D turn-on scan."*

Claude will reach into [`references/special-measure.wiki/`](references/special-measure.wiki) and [`scripts/special-measure/examples/`](scripts/special-measure/examples) for the canonical answers.

---

## What it can help you do

| Task | Ask Claude something like… |
| --- | --- |
| **Author a scan** | "Write a 1D sweep of `B` from 0 to 1 T at 50 mT/min, reading `LockInX`." |
| **Explain a scan** | "Annotate this scan struct field by field." |
| **Buffered readout** | "Set up `smabufconfig2` for the DAQ in fast mode with 1000 points per pulse." |
| **procfn** | "Reshape my 8000-sample buffer into 80×100 and average to a 1×100." |
| **trafofn** | "Sweep `V1` from −1 to 1 mV while `V2` follows the opposite direction." |
| **Driver authoring** | "Port this Keithley manual command set into an `smc*.m` driver." |
| **Driver debug** | "My driver returns the wrong shape — explain what `datadim` should be." |
| **Rack hygiene** | "How do I close and reopen instrument 4 after a USB hiccup?" |
| **Plotting** | "Open the most recent `sm_*.mat` file and plot the two get channels side by side." |
| **Analysis** | "Use `fitwrap` to fit a Lorentzian to my Coulomb peak." |
| **Recover** | "Restore all `configch` channels to the values from `sm_chrg_0042.mat`." |
| **Pulsed scans** | "Configure a pulsed AWG scan with 75 pulses per point and a 4 µs pulse length." |
| **Tutorial** | "Explain the difference between `prefn`, `postfn`, `trigfn`, and `datafn`." |

---

## Mock quantum dot — try it without hardware

`scripts/special-measure/examples/` ships a **fake quantum dot** so you can prototype scans on a laptop with no instruments connected:

- `smcqdot.m` — driver simulating 7 gates + Vsd + I + buffered I_buf, modeled as a resistor network with sigmoid pinch-off.
- `smcqdot_setup.m` — registers the mock instrument and 11 channels in `smdata`.
- `dot_examples.m` — runs through global turn-on, channel scan (1D, 2D), buffered 2D, finger-gate shutoff.

To kick the tires, ask Claude:

- *"Set up the mock qdot and run the global turn-on scan from `dot_examples.m`."*

It'll add the right paths, init `smdata`, and walk you through the result.

---

## What's in this folder

```text
sm-skill/
├── SKILL.md                       # the skill itself — Claude reads this
├── README.md                      # you are here
├── references/
│   └── special-measure.wiki/      # the upstream SM wiki, mirrored as .md
└── scripts/
    └── special-measure/           # the SM source tree
        ├── src/
        │   ├── sm/                # smrun, smset, smget, ~40 helpers
        │   ├── drivers/           # smc*.m for ~120 instruments
        │   └── utils/{plotting,analysis}/
        ├── examples/              # mock qdot sandbox
        ├── tests/                 # smrun 1D/2D/buffered tests
        └── gui/                   # smgui (legacy GUIDE GUI)
```

If you want to read the SM wiki directly, [`references/special-measure.wiki/Home.md`](references/special-measure.wiki/Home.md) is the entry point. [`Overview.md`](references/special-measure.wiki/Overview.md) is the function index.

---

## Tips for getting good answers

- **Paste your `smprintchannels` / `smprintinst` output** when you ask for a scan — Claude can use your real channel names instead of placeholders.
- **Say what loop is fastest.** SM convention is `loops(1)` = innermost = fastest. If you describe "the outer loop sweeps B-field," Claude will put it in `loops(end)`.
- **Mention `rangeramp(4)` factors** if your channels have software multipliers. They surprise people; they'll surprise Claude too if it doesn't know.
- **For drivers, paste the manual snippet.** The instrument's SCPI command list is the source of truth — Claude can translate it into the ICO `[inst chan op]` dispatch.
- **If a scan misbehaves, paste the error and the scan struct.** SM errors are usually about `datadim`, `procfn.dim`, `type=1` semantics, or negative `ramptime` — all of which the skill knows.

---

## Halting a scan (worth memorizing)

While `smrun` is going:

- `Esc` — abort cleanly. Runs `cleanupfn`, saves the partial data, returns.
- `Space` — pause and drop into MATLAB's `keyboard` debugger. Type `return` to resume.

If you crashed something hard, `smclose(inst); smopen(inst);` usually brings the VISA / USB connection back; for DecaDACs run `smadacinit`.

---

## Troubleshooting the skill itself

- **Claude isn't using the skill.** Run `/skills` in Claude Code; you should see `sm-skill` listed. If not, check the install path above.
- **Claude is hallucinating function signatures.** Ask it to "open `references/special-measure.wiki/<name>.md` and quote the exact signature." The skill is designed to discourage paraphrasing.
- **Wiki references look stale** (e.g. `sm/channels`). The current source layout is `src/sm`, `src/drivers`, `src/utils/{plotting,analysis}`. Tell Claude when paths in the wiki don't match what's in `scripts/special-measure/src/`.

---

## Contributing

If you find a recipe Claude should know, a wiki page that's out of date, or an instrument we don't have a driver for:

1. Edit `SKILL.md` to add the recipe (keep it short — link to a longer reference).
2. Add or update files under `references/special-measure.wiki/` for canonical info.
3. Drop new examples into `scripts/special-measure/examples/`.

Special Measure proper is GPL-3.0; see [`scripts/special-measure/LICENSE`](scripts/special-measure/LICENSE).

---

## Quick links

- Skill body: [SKILL.md](SKILL.md)
- Scan struct reference: [Scans.md](references/special-measure.wiki/Scans.md)
- `smdata` reference: [smdata.md](references/special-measure.wiki/smdata.md)
- Function index: [Overview.md](references/special-measure.wiki/Overview.md)
- Writing drivers: [Writing-Drivers.md](references/special-measure.wiki/Writing-Drivers.md), [Example-of-a-Driver.md](references/special-measure.wiki/Example-of-a-Driver.md)
- Mock qdot example: [dot_examples.m](scripts/special-measure/examples/dot_examples.m)
