---
layout: post
title: gix-blame performance improved by a change in gix-diff
date: 2026-03-14 10:45 +0100
---
In February 2026, we got a [PR in `gitoxide`][pr-2438] that substantially
improved `gix-diff`’s tree diff performance. Since `gix-blame`’s algorithm uses
a lot of tree diffs under the hood, I wanted to know what the impact on
`gix-blame`’s performance was.

I set up a benchmark using `hyperfine` in [this script][run-benchmark] and,
with the help of [seaborn], plotted the results using [another
script][plot-benchmark]. And the results are quite impressive: speedups of up
to 25 % in some scenarios, with no noticeable performance degradation in any
scenario.

The comparison was run between [this commit that contained the
optimization][commit-e63d487fb] and [its parent][commit-29040a827]. The full
results can also be found as [`json` files in this gist][benchmark-results].

**Update 2026-03-14**: I’ve changed the plots to use shades of blue instead of
variants of magenta and green.

[pr-2438]: https://github.com/GitoxideLabs/gitoxide/pull/2438
[run-benchmark]: https://github.com/cruessler/gix-benchmarks/blob/16fb1087c834322464b855e9e5fbd11e2dbe17db/run_benchmark.py
[plot-benchmark]: https://github.com/cruessler/gix-benchmarks/blob/45979d7098d39615ebdfe4ef1d5031ce2864f3de/plot_benchmark.py
[seaborn]: https://seaborn.pydata.org/index.html
[benchmark-results]: https://gist.github.com/cruessler/6f0858b862a0442d0904758742d74446
[commit-e63d487fb]: https://github.com/GitoxideLabs/gitoxide/commit/e63d487fb1b1425a9458fc7400517ad2c0280fd2
[commit-29040a827]: https://github.com/GitoxideLabs/gitoxide/commit/29040a8277735cbc9fcd0d80626c75d710d3da2a

## Plots

<figure>
  <img
    src="{% link /assets/catplot.webp %}"
    alt="Catplot of running 2 versions of gix-blame on a set of files" />
  <figcaption>Catplot of running 2 versions of
    <code class="language-plaintext">gix-blame</code> on a set of files
  </figcaption>
</figure>

<figure>
  <img
    src="{% link /assets/boxplot.webp %}"
    alt="Boxplot of running 2 versions of gix-blame on a set of files" />
  <figcaption>Boxplot of running 2 versions of
    <code class="language-plaintext">gix-blame</code> on a set of files
  </figcaption>
</figure>

## Details for individual benchmark runs

The commands have been shortened. The commit hash is short for a version of
`gitoxide` compiled from that commit. `e63d487fb` is the commit containing the
optimization, `29040a827` is its parent. All runs were regular `gix blame …`
runs.

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `29040a827 CHANGELOG.md` | 137.5 ± 2.7 | 133.4 | 143.8 | 1.00 |
| `e63d487fb CHANGELOG.md` | 137.8 ± 2.9 | 133.4 | 143.8 | 1.00 ± 0.03 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `29040a827 STABILITY.md` | 45.8 ± 2.0 | 42.6 | 51.1 | 1.01 ± 0.06 |
| `e63d487fb STABILITY.md` | 45.5 ± 1.6 | 42.0 | 48.7 | 1.00 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `29040a827 README.md` | 101.0 ± 2.6 | 95.8 | 107.2 | 1.00 ± 0.04 |
| `e63d487fb README.md` | 100.8 ± 2.8 | 95.7 | 106.2 | 1.00 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `29040a827 Cargo.toml` | 87.3 ± 2.3 | 82.6 | 91.5 | 1.00 |
| `e63d487fb Cargo.toml` | 88.1 ± 2.3 | 83.4 | 93.1 | 1.01 ± 0.04 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `29040a827 gix-blame/src/file/function.rs` | 33.2 ± 1.5 | 30.8 | 38.0 | 1.30 ± 0.09 |
| `e63d487fb gix-blame/src/file/function.rs` | 25.5 ± 1.3 | 23.2 | 28.3 | 1.00 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `29040a827 gix-path/src/env/mod.rs` | 37.2 ± 1.7 | 34.0 | 41.9 | 1.27 ± 0.08 |
| `e63d487fb gix-path/src/env/mod.rs` | 29.4 ± 1.3 | 27.1 | 32.7 | 1.00 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `29040a827 gix-index/tests/index/file/write.rs` | 55.2 ± 2.3 | 51.1 | 59.4 | 1.29 ± 0.09 |
| `e63d487fb gix-index/tests/index/file/write.rs` | 42.7 ± 2.3 | 38.7 | 54.3 | 1.00 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `29040a827 gix-object/src/lib.rs` | 76.8 ± 2.3 | 72.0 | 81.6 | 1.07 ± 0.05 |
| `e63d487fb gix-object/src/lib.rs` | 71.7 ± 2.8 | 65.3 | 77.8 | 1.00 |

| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `29040a827 gix-odb/src/store_impls/loose/write.rs` | 79.3 ± 2.7 | 74.5 | 84.8 | 1.14 ± 0.06 |
| `e63d487fb gix-odb/src/store_impls/loose/write.rs` | 69.6 ± 2.7 | 64.6 | 75.0 | 1.00 |
