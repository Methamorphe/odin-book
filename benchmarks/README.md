# Odin Book Benchmarks

These benchmarks accompany the performance, memory, and data-oriented design chapters. They are intentionally small, dependency-free, and reproducible.

## Run

Use an optimized build:

```bash
odin run benchmarks -o:speed
```

For more stable results:

1. close unrelated heavy applications;
2. keep the machine on AC power;
3. disable energy-saving modes;
4. run the suite several times;
5. compare medians rather than a single run;
6. record CPU, operating system, Odin version, and compiler flags.

The CI only performs `odin check benchmarks`. It does not compare timings because shared runners are noisy and unsuitable for performance regression thresholds.

## Included experiments

### AoS versus SoA

Updates the position of many particles. The AoS pass touches complete records; the SoA pass walks only the arrays required by the transformation.

Related chapters: 25, 28, 29.

### Contiguous versus strided traversal

Sums the same buffer using sequential access and a cache-unfriendly strided order.

Related chapters: 21, 25, 29.

### Direct indices versus generational handles

Compares raw indexed reads with validated handle lookups. The benchmark makes the cost of safety visible without implying that unsafe access is interchangeable with stable identity.

Related chapters: 30, 31, 45.

### Reused scratch storage versus repeated allocation

Compares repeatedly clearing and reusing a temporary buffer with allocating a new buffer for each round.

Related chapters: 14, 15, 16, 32.

## Interpreting results

A benchmark answers a narrow question for one workload and one machine. It does not prove that one representation is universally better. Change the item count, accessed fields, stride, working-set size, and mutation pattern before drawing architectural conclusions.

Keep the printed checksum. It ensures that every workload contributes observable output and helps detect accidental changes to the work being measured.
