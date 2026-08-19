# Energy measurement instrumentation

## Purpose

This directory is not part of the upstream Orange3 repository. It was added to
measure the energy consumption of CI/CD pipeline commands on controlled
hardware, using Intel RAPL counters. The measured construct is the energy of
the CI commands on a controlled bench, not the energy of GitHub-hosted CI in
production.

## Non-invasiveness

No original project file is created or modified. The only additions are this
directory and `.github/workflows/energy-measurement.yml`. Verify with:

```bash
git remote add upstream https://github.com/biolab/orange3.git
git fetch upstream
git diff --name-only upstream/master...HEAD
```

## What is measured

Energy is read from the Intel RAPL counters under
`/sys/class/powercap/intel-rapl`, for four domains: package (`pkg`), cores,
uncore (reported as `gpu`, structurally zero on this bench) and DRAM (`ram`).
Counter deltas are overflow-corrected against `max_energy_range_uj`, read from
sysfs at run time rather than hardcoded.

Each run measures a 120 s idle baseline first and derives a per-second rate per
domain. Reported energy per stage is

```
net = max(raw_delta - baseline_rate * wall_time_s, 0)
```

The clamp at zero prevents a negative DRAM figure on light memory workloads;
the unclamped DRAM value is kept as the diagnostic column
`energy_ram_liquid_raw_j`.

`wall_time_s` covers the whole `docker run --rm` lifecycle, including container
setup and teardown, because the RAPL reading window covers the same interval.
`wall_time_container_s` is measured inside the container; the difference
isolates container overhead.

Per-stage CPU time is captured inside the container: file descriptor 3
preserves the workload's stderr while `time` writes to `/timing`, so the CPU
time of child processes is attributed to the stage.

Host paging is recorded per stage (`swap_in_pages`, `swap_out_pages`) from
`/proc/vmstat`, because paging during the measured window inflates wall time
without proportional energy.

## How to run

```bash
docker build -t orange3-medicao -f energy-measurement/Dockerfile .
bash energy-measurement/run_pipeline.sh 1
```

The workflow runs the same script on a self-hosted runner, dispatched manually:

```bash
gh workflow run energy-measurement.yml -f campaign=validation   # run 0 only
gh workflow run energy-measurement.yml -f campaign=full         # warm-up + 10 runs
```

## Stages

Orange3 is an inference-only project: the pipeline has no training stage. Each
stage runs in its own container.

| stage | corresponds to | command |
|---|---|---|
| `build` | environment provisioning performed by `tox` in the upstream `Run Tox` step | virtualenv creation, PyQt5/PyQtWebEngine install, `pip install /project`, `pip check` |
| `test` | the test invocation `tox` runs for `orange-released` | `catchsegv xvfb-run -a coverage run -m unittest -v Orange.tests Orange.widgets.tests`, followed by `coverage combine/report/xml` |

Reference cell: `test.yml`, `ubuntu-latest` / Python 3.11 /
`tox_env=orange-released` — cell 1 of 20.

## Deviations from the upstream pipeline

- **Datasets pre-baked.** The files the suite fetches from
  `datasets.biolab.si` are embedded in the image at build time, and the host is
  mapped to loopback with `--add-host datasets.biolab.si:127.0.0.1`. RAPL has no
  network domain, so a live download would inflate wall time without
  proportional energy.
- **`--network none`.** The measured containers have no network; the suite's
  needs are served from the image and from loopback.
- **Non-root user.** The container runs as `medicao`, uid 1000, because
  `xvfb-run` does not work under root in this image. The upstream runner
  executes as uid 1001; the difference is declared in the project's fidelity
  note.
- **Memory limit of 12 GiB** with `--memory-swap` equal to it, so
  `memory.swap.max` is zero and the container cannot page. The value was
  measured, not estimated, after an out-of-memory event on the bench.
- **Coverage instrumentation is part of the measured work**, because the
  reference cell runs it; it is not an addition of this setup.

## Output schema

One CSV per run, one row per stage plus a `total` row:

```
run, stage, energy_pkg_j, energy_cores_j, energy_gpu_j, energy_ram_j,
wall_time_s, user_time_s, sys_time_s, energy_ram_liquid_raw_j,
wall_time_container_s, swap_in_pages, swap_out_pages
```

The first nine columns are the official schema shared by every project in the
study; the last four are diagnostic. Exit codes are written to a sidecar
`exit_codes_run_NN.txt`, and the actual execution order to
`ordem_execucao.txt`.

A known non-zero exit code for this project is **134** (SIGABRT from PyQt5 in
`test_owscatterplotbase`), which truncates the suite and produces no coverage
report; runs with that code are rejected and replaced rather than analysed.

## Reproducibility notes

Bench: Intel Core i7-9700 (8 cores, no SMT), 16 GB RAM, Crucial BX500 SATA SSD,
Ubuntu 24.04 LTS, kernel 6.8.0, Docker 29.x.

Container flags: `--rm --privileged --network none --memory=12g
--memory-swap=12g`, plus `--add-host datasets.biolab.si:127.0.0.1`.

The test worker count is reduced relative to the upstream default to fit the
bench's memory; the value is documented in the project's fidelity note.
