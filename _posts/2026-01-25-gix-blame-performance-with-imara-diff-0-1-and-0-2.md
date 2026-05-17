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

## Plots

Both `baseline` and `comparison` are referring to `gix` executables compiled
from [this commit][commit]. `comparison` was compiled with `--features
blame-experimental` while `baseline` was compiled without that flag. Here are
[the raw results.][benchmark-results] This is the script used to [run the
benchmark][run-benchmark]. This is the script used to [create the
plots][plot-benchmark].

[commit]: https://github.com/GitoxideLabs/gitoxide/commit/3b6650a66e957d124964c7f41cc9895d4292598b
[benchmark-results]: https://gist.github.com/cruessler/666ff15acf81d646a6b4cbb9809f2f99
[run-benchmark]: https://github.com/cruessler/gix-benchmarks/blob/6191179dcccee5dd50f7e7ce8482e29c2ed48d5d/run_benchmark.py
[plot-benchmark]: https://github.com/cruessler/gix-benchmarks/blob/6191179dcccee5dd50f7e7ce8482e29c2ed48d5d/plot_benchmark.py

<figure>
  <img
    src="{% link /assets/catplot-update-to-imara-diff-0-2.webp %}"
    alt="Catplot of running 2 versions of gix-blame on a set of files: baseline
        is the version using imara-diff 0.1.8, comparison is the one using
        imara-diff 0.2.0" />
  <figcaption>Catplot of running 2 versions of
    <code class="language-plaintext">gix-blame</code> on a set of files:
        baseline is the version using imara-diff 0.1.8, comparison is the one
        using imara-diff 0.2.0
  </figcaption>
</figure>

<figure>
  <img
    src="{% link /assets/boxplot-update-to-imara-diff-0-2.webp %}"
    alt="Boxplot of running 2 versions of gix-blame on a set of files: baseline
        is the version using imara-diff 0.1.8, comparison is the one using
        imara-diff 0.2.0" />
  <figcaption>Boxplot of running 2 versions of
    <code class="language-plaintext">gix-blame</code> on a set of files:
        baseline is the version using imara-diff 0.1.8, comparison is the one
        using imara-diff 0.2.0
  </figcaption>
</figure>

## Details for individual benchmark runs

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `baseline CHANGELOG.md` | 145.7 ± 3.1 | 138.3 | 149.7 | 1.05 ± 0.04 |
| `comparison CHANGELOG.md` | 139.4 ± 3.8 | 133.2 | 147.6 | 1.00 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `baseline STABILITY.md` | 46.1 ± 1.9 | 42.6 | 50.5 | 1.02 ± 0.06 |
| `comparison STABILITY.md` | 45.2 ± 1.7 | 42.9 | 50.3 | 1.00 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `baseline README.md` | 105.2 ± 2.9 | 100.1 | 111.8 | 1.02 ± 0.04 |
| `comparison README.md` | 102.9 ± 2.6 | 97.9 | 107.2 | 1.00 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `baseline Cargo.toml` | 88.0 ± 3.7 | 82.2 | 96.8 | 1.00 |
| `comparison Cargo.toml` | 88.5 ± 2.7 | 83.1 | 94.0 | 1.01 ± 0.05 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `baseline gix-blame/src/file/function.rs` | 35.0 ± 1.8 | 31.4 | 39.0 | 1.02 ± 0.07 |
| `comparison gix-blame/src/file/function.rs` | 34.4 ± 1.4 | 32.0 | 38.5 | 1.00 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `baseline gix-path/src/env/mod.rs` | 37.1 ± 1.6 | 34.2 | 40.5 | 1.00 |
| `comparison gix-path/src/env/mod.rs` | 37.2 ± 1.6 | 34.6 | 40.9 | 1.00 ± 0.06 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `baseline gix-index/tests/index/file/write.rs` | 55.3 ± 2.0 | 50.8 | 59.2 | 1.00 |
| `comparison gix-index/tests/index/file/write.rs` | 56.0 ± 2.4 | 51.0 | 60.1 | 1.01 ± 0.06 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `baseline gix-object/src/lib.rs` | 81.7 ± 2.2 | 78.0 | 86.5 | 1.03 ± 0.04 |
| `comparison gix-object/src/lib.rs` | 79.7 ± 2.6 | 74.3 | 84.3 | 1.00 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `baseline gix-odb/src/store_impls/loose/write.rs` | 79.5 ± 2.7 | 75.0 | 84.9 | 1.00 |
| `comparison gix-odb/src/store_impls/loose/write.rs` | 80.7 ± 2.3 | 75.8 | 86.1 | 1.02 ± 0.05 |
