window.BENCHMARK_DATA = {
  "lastUpdate": 1644717916851,
  "repoUrl": "https://github.com/oolong-dev/OpenTelemetry.jl",
  "entries": {
    "Benchmark Result with Julia v1.7": [
      {
        "commit": {
          "author": {
            "email": "tianjun.cpp@gmail.com",
            "name": "Jun Tian",
            "username": "findmyway"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "392c9dab3da5442c5bbc69578b516272a307e4e4",
          "message": "Delete TagBot.yml",
          "timestamp": "2021-12-08T10:55:24+08:00",
          "tree_id": "84666c4d724834f3bcc894906642e718519f5b87",
          "url": "https://github.com/oolong-dev/OpenTelemetry.jl/commit/392c9dab3da5442c5bbc69578b516272a307e4e4"
        },
        "date": 1638932197437,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 2120.1,
            "unit": "ns",
            "extra": "gctime=0\nmemory=576\nallocs=11\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 3377.8888888888887,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1328\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 8440.2,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5184\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":5,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tanmaykm@gmail.com",
            "name": "Tanmay Mohapatra",
            "username": "tanmaykm"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "8d32cee2550c137310d5b10298abbac6e3c81cfa",
          "message": "fix undefined field access in prometheus exporter (#31)\n\nFixes a few undefined field errors while using `OpenTelemetryExporterPrometheus` with `HistogramAgg`.",
          "timestamp": "2022-01-27T17:12:58+08:00",
          "tree_id": "4e22f9754ec3bf62a80d46fc41851155f91ba295",
          "url": "https://github.com/oolong-dev/OpenTelemetry.jl/commit/8d32cee2550c137310d5b10298abbac6e3c81cfa"
        },
        "date": 1643274848871,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 2140,
            "unit": "ns",
            "extra": "gctime=0\nmemory=576\nallocs=11\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 3422.222222222222,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1328\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 7600,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5184\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":5,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tianjun.cpp@gmail.com",
            "name": "Jun Tian",
            "username": "findmyway"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "8a4bfe6bde1494eab100ed0f19809f702a1bdc2b",
          "message": "bump version",
          "timestamp": "2022-01-27T17:15:46+08:00",
          "tree_id": "6ee2b69956594981af023f1769c5e139052d78ec",
          "url": "https://github.com/oolong-dev/OpenTelemetry.jl/commit/8a4bfe6bde1494eab100ed0f19809f702a1bdc2b"
        },
        "date": 1643275031095,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 2330,
            "unit": "ns",
            "extra": "gctime=0\nmemory=576\nallocs=11\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 3600,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1328\nallocs=28\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 7720,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5184\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":5,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tianjun.cpp@gmail.com",
            "name": "Jun Tian",
            "username": "findmyway"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "921a52a6f440c249523880bbec0782b9ad1d718a",
          "message": "Update benchmark.yml",
          "timestamp": "2022-02-11T23:45:31+08:00",
          "tree_id": "ffd2cca4e0b6b224078d88100cf0a4d96226b553",
          "url": "https://github.com/oolong-dev/OpenTelemetry.jl/commit/921a52a6f440c249523880bbec0782b9ad1d718a"
        },
        "date": 1644594465251,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 2377.8888888888887,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 3625.25,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":8,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 5043.285714285715,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1710.1,
            "unit": "ns",
            "extra": "gctime=0\nmemory=960\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "41898282+github-actions[bot]@users.noreply.github.com",
            "name": "github-actions[bot]",
            "username": "github-actions[bot]"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "d9ba78587ccd628de15961fd8b18437a6c703195",
          "message": "Format .jl files (#38)\n\nCo-authored-by: findmyway <findmyway@users.noreply.github.com>",
          "timestamp": "2022-02-12T12:03:54+08:00",
          "tree_id": "05db350b65942248fdf0cf560285029258b247be",
          "url": "https://github.com/oolong-dev/OpenTelemetry.jl/commit/d9ba78587ccd628de15961fd8b18437a6c703195"
        },
        "date": 1644638747828,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 1890,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 2833.4444444444443,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 4100,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1420,
            "unit": "ns",
            "extra": "gctime=0\nmemory=960\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "41898282+github-actions[bot]@users.noreply.github.com",
            "name": "github-actions[bot]",
            "username": "github-actions[bot]"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "4b6431a4575eb310407981e21dd51bff45e608ad",
          "message": "CompatHelper: add new compat entry for OpenTelemetrySDK at version 0.2 for package grpc, (keep existing compat) (#40)\n\nCo-authored-by: CompatHelper Julia <compathelper_noreply@julialang.org>",
          "timestamp": "2022-02-12T12:04:08+08:00",
          "tree_id": "2f59e53c4ad6695d17e8d8779b02a51c272a2316",
          "url": "https://github.com/oolong-dev/OpenTelemetry.jl/commit/4b6431a4575eb310407981e21dd51bff45e608ad"
        },
        "date": 1644638763844,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 1900,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 2866.6666666666665,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 4128.714285714285,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1440,
            "unit": "ns",
            "extra": "gctime=0\nmemory=960\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tianjun.cpp@gmail.com",
            "name": "Jun Tian",
            "username": "findmyway"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "b72e48d22e75d6f905dfd192bb40b18f04136d2c",
          "message": "Add instrumentation for `Base` (#41)\n\n* sync\r\n\r\n* add docs\r\n\r\n* fix doc pipeline\r\n\r\n* fix doc pipeline\r\n\r\n* bump version",
          "timestamp": "2022-02-13T00:40:15+08:00",
          "tree_id": "1a8e484bb169230d7586ea80f5ed4b4e5a94c9b8",
          "url": "https://github.com/oolong-dev/OpenTelemetry.jl/commit/b72e48d22e75d6f905dfd192bb40b18f04136d2c"
        },
        "date": 1644684121715,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 1600.1,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 2577.8888888888887,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 4057.285714285714,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1440,
            "unit": "ns",
            "extra": "gctime=0\nmemory=960\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tianjun.cpp@gmail.com",
            "name": "Jun Tian",
            "username": "findmyway"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "0441f55fa60c5e60216bd62b93a3cbb76e6aade0",
          "message": "Update README.md",
          "timestamp": "2022-02-13T00:42:39+08:00",
          "tree_id": "c6ff032355d08a63e34bed427d91dc3963fd4948",
          "url": "https://github.com/oolong-dev/OpenTelemetry.jl/commit/0441f55fa60c5e60216bd62b93a3cbb76e6aade0"
        },
        "date": 1644684287935,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 1940.2,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 3111.3333333333335,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 4886.142857142857,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1680.2,
            "unit": "ns",
            "extra": "gctime=0\nmemory=960\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "tianjun.cpp@gmail.com",
            "name": "Jun Tian",
            "username": "findmyway"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "7fa28a2d97d37a4fb9473c9d8c32203e641d5a5a",
          "message": "Update OpenTelemetryUber.jl",
          "timestamp": "2022-02-13T00:56:30+08:00",
          "tree_id": "3f7d090d5ee5a2980b19dce58a6bb54eabea6c54",
          "url": "https://github.com/oolong-dev/OpenTelemetry.jl/commit/7fa28a2d97d37a4fb9473c9d8c32203e641d5a5a"
        },
        "date": 1644685094891,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 1530.2,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 2377.8888888888887,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 3712.75,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":8,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1330.1,
            "unit": "ns",
            "extra": "gctime=0\nmemory=960\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "41898282+github-actions[bot]@users.noreply.github.com",
            "name": "github-actions[bot]",
            "username": "github-actions[bot]"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "609749a6d4a4ca4924bbe1bb856ddb66d08f23cb",
          "message": "Format .jl files (#42)",
          "timestamp": "2022-02-13T10:03:24+08:00",
          "tree_id": "37e12803839bbab689cff2f07b90597fbf3bcd79",
          "url": "https://github.com/oolong-dev/OpenTelemetry.jl/commit/609749a6d4a4ca4924bbe1bb856ddb66d08f23cb"
        },
        "date": 1644717915654,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 1390,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 2311.222222222222,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1360\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 3687.625,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4672\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":8,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1320,
            "unit": "ns",
            "extra": "gctime=0\nmemory=960\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      }
    ]
  }
}