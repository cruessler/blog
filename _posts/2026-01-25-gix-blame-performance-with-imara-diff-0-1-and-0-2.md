---
layout: post
title: gix-blame performance with imara-diff 0.1 and 0.2
date: 2026-01-25 17:44 +0100
---
Recently, we started the process of upgrading `gitoxide`’s dependency on
`imara-diff` from 0.1.8 to 0.2.0 (tracked in [this issue][issue-2308]). Because
`imara-diff`’s API has changed significantly, the changes are currently behind
a feature flag. What I’ve been wondering, though, is whether this update has
any impact on `gix-blame`’s performance as `gix-blame` spends a lot of time
diffing two versions of a file.

[issue-2308]: https://github.com/GitoxideLabs/gitoxide/issues/2308

In order to collect some data, I compiled two versions of the `gix` binary via
`cargo build --release --features blame-experimental` and `cargo build
--release`. Then I used hyperfine to run `gix blame` on a couple of files in my
local copy of the `gitoxide` repo. The results are below.

It seems that the version using `imara-diff` 0.2 might have a slight advantage
when it comes to files that have changed a lot over the course of this repo’s
history, such as `CHANGELOG.md` or `Cargo.toml`, but it’s still rather close,
so I wouldn’t draw too many conclusions.

## Detailed results

```
❯ env GIT_DIR="$HOME/github/Byron/gitoxide/.git" BASELINE_EXECUTABLE="$HOME/bin/gix-blame-2026-01-25-3b6650a66" COMPARISON_EXECUTABLE="$HOME/bin/gix-blame-experimental-2026-01-25-3b6650a66" just benchmark-gix-blame
hyperfine "${BASELINE_EXECUTABLE} blame CHANGELOG.md" "${COMPARISON_EXECUTABLE} blame CHANGELOG.md"
Benchmark 1: /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame CHANGELOG.md
  Time (mean ± σ):     141.6 ms ±   3.3 ms    [User: 100.8 ms, System: 40.7 ms]
  Range (min … max):   133.7 ms … 146.6 ms    21 runs

Benchmark 2: /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame CHANGELOG.md
  Time (mean ± σ):     137.0 ms ±   3.4 ms    [User: 95.7 ms, System: 41.2 ms]
  Range (min … max):   126.5 ms … 142.3 ms    21 runs

Summary
  /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame CHANGELOG.md ran
    1.03 ± 0.04 times faster than /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame CHANGELOG.md

hyperfine "${BASELINE_EXECUTABLE} blame STABILITY.md" "${COMPARISON_EXECUTABLE} blame STABILITY.md"
Benchmark 1: /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame STABILITY.md
  Time (mean ± σ):      43.7 ms ±   2.2 ms    [User: 30.1 ms, System: 13.3 ms]
  Range (min … max):    40.8 ms …  52.5 ms    56 runs

Benchmark 2: /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame STABILITY.md
  Time (mean ± σ):      42.9 ms ±   1.4 ms    [User: 30.1 ms, System: 12.6 ms]
  Range (min … max):    40.8 ms …  47.2 ms    65 runs

Summary
  /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame STABILITY.md ran
    1.02 ± 0.06 times faster than /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame STABILITY.md

hyperfine "${BASELINE_EXECUTABLE} blame README.md" "${COMPARISON_EXECUTABLE} blame README.md"
Benchmark 1: /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame README.md
  Time (mean ± σ):     102.6 ms ±   3.9 ms    [User: 72.9 ms, System: 29.4 ms]
  Range (min … max):    95.0 ms … 109.6 ms    28 runs

Benchmark 2: /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame README.md
  Time (mean ± σ):     102.2 ms ±   2.1 ms    [User: 72.2 ms, System: 29.9 ms]
  Range (min … max):    98.8 ms … 106.7 ms    28 runs

Summary
  /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame README.md ran
    1.00 ± 0.04 times faster than /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame README.md

hyperfine "${BASELINE_EXECUTABLE} blame Cargo.toml" "${COMPARISON_EXECUTABLE} blame Cargo.toml"
Benchmark 1: /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame Cargo.toml
  Time (mean ± σ):      86.3 ms ±   2.7 ms    [User: 61.8 ms, System: 24.3 ms]
  Range (min … max):    81.8 ms …  91.9 ms    34 runs

Benchmark 2: /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame Cargo.toml
  Time (mean ± σ):      82.7 ms ±   2.3 ms    [User: 59.7 ms, System: 22.8 ms]
  Range (min … max):    79.7 ms …  90.2 ms    34 runs

Summary
  /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame Cargo.toml ran
    1.04 ± 0.04 times faster than /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame Cargo.toml

hyperfine "${BASELINE_EXECUTABLE} blame gix-blame/src/file/function.rs" "${COMPARISON_EXECUTABLE} blame gix-blame/src/file/function.rs"
Benchmark 1: /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame gix-blame/src/file/function.rs
  Time (mean ± σ):      31.6 ms ±   1.6 ms    [User: 21.7 ms, System: 9.7 ms]
  Range (min … max):    29.6 ms …  38.0 ms    77 runs

Benchmark 2: /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame gix-blame/src/file/function.rs
  Time (mean ± σ):      31.3 ms ±   0.9 ms    [User: 20.8 ms, System: 10.4 ms]
  Range (min … max):    29.6 ms …  34.6 ms    93 runs

Summary
  /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame gix-blame/src/file/function.rs ran
    1.01 ± 0.06 times faster than /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame gix-blame/src/file/function.rs

hyperfine "${BASELINE_EXECUTABLE} blame gix-path/src/env/mod.rs" "${COMPARISON_EXECUTABLE} blame gix-path/src/env/mod.rs"
Benchmark 1: /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame gix-path/src/env/mod.rs
  Time (mean ± σ):      35.7 ms ±   2.7 ms    [User: 25.3 ms, System: 10.0 ms]
  Range (min … max):    32.5 ms …  50.9 ms    58 runs

Benchmark 2: /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame gix-path/src/env/mod.rs
  Time (mean ± σ):      35.4 ms ±   2.0 ms    [User: 25.2 ms, System: 10.1 ms]
  Range (min … max):    32.6 ms …  43.4 ms    79 runs

Summary
  /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame gix-path/src/env/mod.rs ran
    1.01 ± 0.10 times faster than /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame gix-path/src/env/mod.rs

hyperfine "${BASELINE_EXECUTABLE} blame gix-index/tests/index/file/write.rs" "${COMPARISON_EXECUTABLE} blame gix-index/tests/index/file/write.rs"
Benchmark 1: /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame gix-index/tests/index/file/write.rs
  Time (mean ± σ):      53.2 ms ±   2.6 ms    [User: 40.1 ms, System: 12.8 ms]
  Range (min … max):    49.0 ms …  63.0 ms    47 runs

Benchmark 2: /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame gix-index/tests/index/file/write.rs
  Time (mean ± σ):      53.3 ms ±   2.5 ms    [User: 40.8 ms, System: 12.3 ms]
  Range (min … max):    49.1 ms …  60.5 ms    58 runs

Summary
  /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame gix-index/tests/index/file/write.rs ran
    1.00 ± 0.07 times faster than /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame gix-index/tests/index/file/write.rs

hyperfine "${BASELINE_EXECUTABLE} blame gix-object/src/lib.rs" "${COMPARISON_EXECUTABLE} blame gix-object/src/lib.rs"
Benchmark 1: /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame gix-object/src/lib.rs
  Time (mean ± σ):      75.6 ms ±   2.8 ms    [User: 56.9 ms, System: 18.4 ms]
  Range (min … max):    71.4 ms …  82.1 ms    37 runs

Benchmark 2: /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame gix-object/src/lib.rs
  Time (mean ± σ):      76.5 ms ±   2.9 ms    [User: 59.2 ms, System: 17.0 ms]
  Range (min … max):    71.6 ms …  82.7 ms    39 runs

Summary
  /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame gix-object/src/lib.rs ran
    1.01 ± 0.05 times faster than /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame gix-object/src/lib.rs

hyperfine "${BASELINE_EXECUTABLE} blame gix-odb/src/store_impls/loose/write.rs" "${COMPARISON_EXECUTABLE} blame gix-odb/src/store_impls/loose/write.rs"
Benchmark 1: /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame gix-odb/src/store_impls/loose/write.rs
  Time (mean ± σ):      75.1 ms ±   2.3 ms    [User: 58.8 ms, System: 16.0 ms]
  Range (min … max):    70.4 ms …  81.3 ms    36 runs

Benchmark 2: /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame gix-odb/src/store_impls/loose/write.rs
  Time (mean ± σ):      77.1 ms ±   3.2 ms    [User: 60.1 ms, System: 16.9 ms]
  Range (min … max):    70.8 ms …  82.3 ms    37 runs

Summary
  /home/christoph/bin/gix-blame-2026-01-25-3b6650a66 blame gix-odb/src/store_impls/loose/write.rs ran
    1.03 ± 0.05 times faster than /home/christoph/bin/gix-blame-experimental-2026-01-25-3b6650a66 blame gix-odb/src/store_impls/loose/write.rs
```
