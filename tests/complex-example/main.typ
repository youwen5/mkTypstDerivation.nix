#import "@youwen/zen:0.5.0": *
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1"

#show: codly-init.with()

#show: zen.with(
  title: "Lab 1 Writeup",
  author: "Youwen Wu",
  subtitle: "CS24, Spring 2025",
  outline-separate-page: false,
)

#outline()

#codly(languages: codly-languages)

#show link: underline

= Prelude

Code available on
#link("https://github.com/youwen5/cs24/tree/main/labs/lab01/code")[GitHub]. A
reproducible build environment is included, if you have
#link("https://nixos.org/")[Nix] with flakes installed, you can run
```sh
nix build github:youwen5/cs24#labs.lab01.code
result/bin/3sum_analysis
```

Additionally, in the same Git tree, you will find the source code of this document alongside the plotting code (written using CeTZ). You may reproducibly compile this document as well using Nix.
```sh
nix build github:youwen5/cs24#labs.lab01.writeup
# pdf available at result/main.pdf
```

= Runtime analysis

== Empirical

An empirical analysis was performed using various sample sizes, up to $n =
  3200$, as $n = 8000$ had a runtime that was too long. We perform 3 runs and
store the runtimes in a `map` of `vector<double>` keyed by the sample size.
Then we take their average and plot it, as in @raw-plot.

#[
  // Load the data from a CSV file.
  #let data = csv("data.csv", row-type: dictionary)

  // Cast data types
  #let widths = data.map(x => int(x.samples))
  #let heights = data.map(x => float(x.ms))

  #numbered-figure(caption: "Raw plot")[
    // Create coordinates
    #let coords = widths.zip(heights)

    #cetz.canvas({
      import cetz.draw: *
      import cetz-plot: *

      plot.plot(
        legend: "inner-north-west",
        x-label: [Sample size, $n$],
        y-label: [Runtime, $T(n)$ (ms, average of 3)],
        size: (12, 8),
        {
          plot.add(
            coords,
            mark: "o",
            line: "spline",
            label: "Actual",
          )
          plot.add(
            domain: (0, 3250),
            label: "Derived power-law",
            t => (calc.pow(2, -19.4) * calc.pow(t, 3.018)),
          )
        },
      )
    })
  ]<raw-plot>

  #numbered-figure(caption: "log-log plot")[
    #let widths-log = widths.map(x => calc.log(x, base: 2))
    #let heights-log = heights.map(x => calc.log(x, base: 2))
    #let coords = widths-log.zip(heights-log)
    #cetz.canvas({
      import cetz.draw: *
      import cetz-plot: *

      plot.plot(
        legend: "inner-north-west",
        x-label: [$log_2(n)$],
        y-label: [$log_2(T(n))$ (ms, average of 3)],
        x-min: calc.min(..widths-log) - 0.5,
        y-min: 0,
        size: (12, 8),
        y-ticks: heights-log,
        x-ticks: widths-log,
        x-tick-step: none,
        y-tick-step: none,
        {
          plot.add(
            coords,
            mark: "o",
            line: "linear",
            label: "Actual",
          )
          plot.add(
            domain: (6.64, calc.max(..widths-log)),
            label: "Derived power-law",
            t => (3.018 * t - 19.4),
          )
        },
      )
    })
  ]
]

== Derivation of power-law form

Using the endpoints of the linearized log-log plot, we obtain a slope
$
  m = (0.63 - 15.72) / (6.64 - 11.64) = 3.018
$
and $y$-intercept $b = -19.4$. Then
$
  log_2 (T(n)) &= 3.018 dot log_2 (n) -19.4 \
  T(n) &= 2^(-19.4) dot n^3.018
$

== Analysis

We have three nested loops, (and one more that seems to have negligible $O(1)$
runtime) so we expect our time complexity to be $O(N^3)$, which is exactly what
our empirical analysis shows.

The $log$-$log$ plot is linear while the raw plot is cubic. In the $log$-$log$
plot, we can easily extract a linear equation that can be converted to the
cubic power-law form, which matches up with our real world data nicely.

Overall we observed that the big-$O$ analysis is extremely accurate to the real
world results. Our empirical analysis showed that the runtime scaled almost
exactly according to $n^3$ scaled by a constant factor.

= Optimized solution

== Graphs and plots

I coded a more optimal solution with $O(N^2)$ runtime (although the raw runtime was still not very fast, only in the $5^"th"$ percentile). It was accepted on Leetcode and did not run into an out-of-time error.

In the graphs, we can see that the derived formula holds up for $n <= 3200$ but diverges quickly as the sample size increases. This is likely due to some operations that are $O(1)$ for small $n$ becoming $O(n)$ for very large $n$.

#[
  // Load the data from a CSV file.
  #let data = csv("optimized_data.csv", row-type: dictionary)

  // Cast data types
  #let widths = data.map(x => int(x.samples))
  #let heights = data.map(x => float(x.ms))

  #numbered-figure(caption: "Raw plot")[
    // Create coordinates
    #let coords = widths.zip(heights)

    #cetz.canvas({
      import cetz.draw: *
      import cetz-plot: *

      plot.plot(
        legend: "inner-north-west",
        x-label: [Sample size, $n$],
        y-label: [Runtime, $T(n)$ (ms, average of 3)],
        size: (12, 8),
        {
          plot.add(
            coords,
            mark: "o",
            line: "spline",
            label: "Actual",
          )
          plot.add(
            domain: (0, 8000),
            label: "Derived power-law",
            t => (calc.pow(2, -13.08) * calc.pow(t, 1.972)),
          )
        },
      )
    })
  ]<raw-plot-optimized>

  #numbered-figure(caption: "log-log plot")[
    #let widths-log = widths.map(x => calc.log(x, base: 2))
    #let heights-log = heights.map(x => calc.log(x, base: 2))
    #let coords = widths-log.zip(heights-log)
    #cetz.canvas({
      import cetz.draw: *
      import cetz-plot: *

      plot.plot(
        legend: "inner-north-west",
        x-label: [$log_2(n)$],
        y-label: [$log_2(T(n))$ (ms, average of 3)],
        x-min: calc.min(..widths-log) - 0.5,
        y-min: 0,
        size: (12, 8),
        y-ticks: heights-log,
        x-ticks: widths-log,
        x-tick-step: none,
        y-tick-step: none,
        {
          plot.add(
            coords,
            mark: "o",
            line: "linear",
            label: "Actual",
          )
          plot.add(
            domain: (6.64, calc.max(..widths-log)),
            label: "Derived power-law",
            t => (1.972 * t - 13.08),
          )
        },
      )
    })
  ]
]

== Power-law derivation

Using the endpoints of the linearized log-log plot, we obtain a slope
$
  m = (0.01 - 9.87) / (6.64 - 11.64) = 1.972
$
and $y$-intercept $b = -13.08$. Then
$
  log_2 (T(n)) &= 1.972 dot log_2 (n) -13.08 \
  T(n) &= 2^(-13.08) dot n^1.972
$

== Comparison

#[
  // Load the data from a CSV file.
  #let data = csv("optimized_data.csv", row-type: dictionary)
  // Load the data from a CSV file.
  #let unoptimized-data = csv("data.csv", row-type: dictionary)

  // Cast data types
  #let widths = data.map(x => int(x.samples))
  #let heights = data.map(x => float(x.ms))

  // Cast data types
  #let unoptimized-widths = unoptimized-data.map(x => int(x.samples))
  #let unoptimized-heights = unoptimized-data.map(x => float(x.ms))

  #numbered-figure(caption: "Raw plot")[
    // Create coordinates
    #let coords = widths.zip(heights)
    #let unoptimized-coords = unoptimized-widths.zip(unoptimized-heights)

    #cetz.canvas({
      import cetz.draw: *
      import cetz-plot: *

      plot.plot(
        legend: "inner-north-west",
        x-label: [Sample size, $n$],
        y-label: [Runtime, $T(n)$ (ms, average of 3)],
        size: (12, 8),
        {
          plot.add(
            coords,
            mark: "o",
            line: "spline",
            label: "Optimized",
          )
          plot.add(
            unoptimized-coords,
            mark: "o",
            line: "spline",
            label: "Brute force",
          )
        },
      )
    })
  ]<raw-plot-optimized>

  #numbered-figure(caption: "log-log plot")[
    #let widths-log = widths.map(x => calc.log(x, base: 2))
    #let heights-log = heights.map(x => calc.log(x, base: 2))
    #let coords = widths-log.zip(heights-log)
    #let widths-log = unoptimized-widths.map(x => calc.log(x, base: 2))
    #let heights-log = unoptimized-heights.map(x => calc.log(x, base: 2))
    #let unoptimized-coords = widths-log.zip(heights-log)
    #cetz.canvas({
      import cetz.draw: *
      import cetz-plot: *

      plot.plot(
        legend: "inner-north-west",
        x-label: [$log_2(n)$],
        y-label: [$log_2(T(n))$ (ms, average of 3)],
        x-min: calc.min(..widths-log) - 0.5,
        y-min: 0,
        size: (12, 8),
        y-ticks: heights-log,
        x-ticks: widths-log,
        x-tick-step: none,
        y-tick-step: none,
        {
          plot.add(
            coords,
            mark: "o",
            line: "linear",
            label: "Optimized",
          )
          plot.add(
            unoptimized-coords,
            mark: "o",
            line: "spline",
            label: "Brute force",
          )
        },
      )
    })
  ]
]

= Code

== Solution

Below is the brute-force solution using 3 nested for loops.

#figure(caption: "naive solution")[
  #codly(
    highlights: (
      (line: 11, start: 0, end: none, label: <loop-1>, tag: [Loop 1]),
      (line: 12, start: 0, end: none, label: <loop-2>, tag: [Loop 2]),
      (line: 13, start: 0, end: none, label: <loop-3>, tag: [Loop 3]),
    ),
    reference-by: "item",
  )
  ```cpp
  bool vectorContains(vector<vector<int>> &vec, vector<int> &test) {
    for (unsigned i = 0; i < vec.size(); i++) {
      if (vec[i] == test)
        return true; }
    return false;
  }

  vector<vector<int>> threeSum(vector<int> &nums) {
    sort(nums.begin(), nums.end());
    vector<vector<int>> result;
    for (unsigned i = 0; i < nums.size(); i++) {
      for (unsigned j = i + 1; j < nums.size(); j++) {
        for (unsigned k = j + 1; k < nums.size(); k++) {
          if (nums[i] + nums[j] + nums[k] == 0) {
            vector<int> newVec;
            newVec.push_back(nums[i]);
            newVec.push_back(nums[j]);
            newVec.push_back(nums[k]);
            if (!vectorContains(result, newVec)) {
              result.push_back(newVec);
            }
          }
        }
      }
    }
    return result;
  }
  ```
]<solution>

As expected, the time complexity of the three loops, @loop-1, @loop-2, and @loop-3 is $O(N^3)$, since they
each loop $n$ times for an input of length $n$ in the worst case. There is an
additional nested for loop in the `vectorContains` function, however it seems
contribute a mostly negligible amount to runtime.

== Data collection

For data collection, we ran the code on various sample sizes up to $n=3200$,
generated using a uniform distribution generated by a seeded Mersenne Twister.
Increasing sample size further would lead to excessive runtimes. We ran the
code 3 times and took the average of the runtimes to minimize the impact of
transient performance fluctuations on the host machine.

The final data was written to a CSV. The plotting was done natively in
#link("https://typst.app/")[Typst], using #link("https://typst.app/universe/package/cetz/")[CeTZ] and
#link("https://typst.app/universe/package/cetz-plot/")[CeTZ-plot].

== Timing code

#codly()
```cpp
mt19937 gen(12345);
unsigned samplePoints[] = {100, 200, 400, 800, 1600, 3200};
vector<int> *nums;
vector<vector<int>> *result;
uniform_int_distribution<> distrib(-100000, 100000);
unsigned runs = 3;

map<unsigned, vector<double>> times;

cout << "doing 3 runs..." << endl;

int temp1;
int temp2;

for (unsigned i = 0; i < runs; i++) {
  for (auto ct : samplePoints) {
    nums = new vector<int>;
    result = new vector<vector<int>>;
    for (unsigned j = 0; j < ct - 3; j++) {
      nums->push_back(distrib(gen));
    }

    // ensure at least one triplet is valid
    temp1 = distrib(gen);
    temp2 = distrib(gen);
    nums.push_back(temp1);
    nums.push_back(temp2);
    nums.push_back(-(temp1 + temp2));

    auto start = chrono::high_resolution_clock::now();
    result = new vector<vector<int>>(threeSum(*nums));
    auto end = chrono::high_resolution_clock::now();
    double time_ms =
        chrono::duration_cast<chrono::microseconds>(end - start).count() /
        1000.0;

    cout << "testing n=" << ct << " samples" << endl;
    cout << "time taken: " << time_ms << endl;

    times.emplace(ct, 0);
    times.at(ct).push_back(time_ms);

    delete nums;
    delete result;
  }
}
```

== Optimized solution

#codly()
```cpp
// assume vectors are same length
bool vectorsAreEqual(const vector<int> &vec1, const vector<int> &vec2) {
  for (unsigned i = 0; i < vec1.size(); i++) {
    if (vec1.at(i) != vec2.at(i)) {
      return false;
    }
  }
  return true;
}
vector<vector<int>> threeSumOptimized(vector<int> &nums) {
  vector<vector<int>> result;
  unordered_set<int> set;
  sort(nums.begin(), nums.end());
  if (nums.at(nums.size() - 1) < 0 || nums.at(0) > 0) {
    return result;
  }
  int ptr1;
  int ptr2;

  int sum;

  for (ptr1 = 0; ptr1 < nums.size(); ptr1++) {
    for (ptr2 = ptr1 + 1; ptr2 < nums.size(); ptr2++) {
      if (set.contains(nums.at(ptr2))) {
        vector<int> elem;
        elem.push_back(nums.at(ptr1));
        elem.push_back(nums.at(ptr2));
        elem.push_back(-(nums.at(ptr1) + nums.at(ptr2)));
        result.push_back(elem);
      }
      sum = nums.at(ptr1) + nums.at(ptr2);
      set.insert(-sum);
    }
    set.clear();
    while (ptr1 + 1 < nums.size() && nums.at(ptr1) == nums.at(ptr1 + 1)) {
      ptr1++;
    }
  }
  ptr1 = 0;
  ptr2 = 0;
  while (ptr1 < result.size()) {
    while (ptr2 + 1 < result.size() &&
           vectorsAreEqual(result.at(ptr2 + 1), result.at(ptr2))) {
      result.erase(result.begin() + ptr2 + 1);
    }
    ptr1++;
    ptr2 = ptr1;
  }
  return result;
}
```

== Data logging code

#codly()
```cpp
fstream csv;

if (argc > 1) {
  cout << "going to write file " << argv[1] << endl;
  csv.open(argv[1]);
  if (!csv.is_open()) {
    cout << "error: could not open file" << endl;
    return 1;
  }
  csv << "samples,ms" << endl;
  for (auto xs : times) {
    csv << xs.first << "," << average(xs.second) << endl;
  }

  csv.close();

  cout << "wrote output to " << argv[1] << endl;
}
```

= Acknowledgements

== Gen AI

No Generative AI was used in writing this report or generating code.

== Open source licenses

This document was produced using the typesetting system
#link("https://typst.app")[Typst]. Plotting code was derived from examples in
the Typst package
#link("https://github.com/cetz-package/cetz-plot")[CeTZ-plot], licensed under
the #smallcaps[gnu lgpl]-3.0.
