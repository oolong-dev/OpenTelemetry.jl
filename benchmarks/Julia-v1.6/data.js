window.BENCHMARK_DATA = {
  "lastUpdate": 1644734235950,
  "repoUrl": "https://github.com/oolong-dev/OpenTelemetry.jl",
  "entries": {
    "Benchmark Result with Julia v1.6": [
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
        "date": 1638932203190,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 2377.777777777778,
            "unit": "ns",
            "extra": "gctime=0\nmemory=576\nallocs=11\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 4762.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1536\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":8,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 7440.2,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5424\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":5,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
        "date": 1643274841947,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 2400,
            "unit": "ns",
            "extra": "gctime=0\nmemory=576\nallocs=11\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 4450.125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1536\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":8,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 5783.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5424\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
        "date": 1643275011295,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 1980,
            "unit": "ns",
            "extra": "gctime=0\nmemory=576\nallocs=11\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 3687.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1536\nallocs=29\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":8,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 5042.714285714285,
            "unit": "ns",
            "extra": "gctime=0\nmemory=5424\nallocs=56\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
        "date": 1644594468963,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 2370.3,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 4155.888888888889,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1568\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 4600.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4912\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":8,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1710.2,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
        "date": 1644638756321,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 2350.1,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 4200.25,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1568\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":8,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 4800.25,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4912\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":8,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1690.1,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
        "date": 1644638763077,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 2010,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 3787.375,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1568\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":8,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 4314.142857142857,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4912\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1579.9,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
        "date": 1644684125379,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 1760,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 3455.5555555555557,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1568\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 4285.714285714285,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4912\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1590,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
        "date": 1644684285058,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 1840,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 4011.1111111111113,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1568\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 5571.571428571428,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4912\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1760,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
        "date": 1644685115257,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 2133.3333333333335,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 4325.125,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1568\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":8,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 5183.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4912\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":6,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1790.1,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
        "date": 1644717908281,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 1729.9,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 3433.222222222222,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1568\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 4285.714285714285,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4912\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1540,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
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
          "id": "c0f59eba2ec8aa2cdb6605edb8566d2145417a01",
          "message": "Add instrumentation for Downloads (#43)\n\n* sync\r\n\r\n* add docs\r\n\r\n* fix doc pipeline\r\n\r\n* fix doc pipeline\r\n\r\n* bump version\r\n\r\n* add downloads\r\n\r\n* fix ci\r\n\r\n* fix manifest.toml in docs\r\n\r\n* use @test_throws to catch error\r\n\r\n* add Test to dependency\r\n\r\n* add Test to dependency",
          "timestamp": "2022-02-13T14:35:22+08:00",
          "tree_id": "03a50a9a79123744e8a0a34d47ca5034245dc0c0",
          "url": "https://github.com/oolong-dev/OpenTelemetry.jl/commit/c0f59eba2ec8aa2cdb6605edb8566d2145417a01"
        },
        "date": 1644734234764,
        "tool": "julia",
        "benches": [
          {
            "name": "Meter/Update Counter",
            "value": 1760,
            "unit": "ns",
            "extra": "gctime=0\nmemory=608\nallocs=12\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Meter/Update Histogram",
            "value": 3455.5555555555557,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1568\nallocs=30\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":9,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Span",
            "value": 4342.857142857143,
            "unit": "ns",
            "extra": "gctime=0\nmemory=4912\nallocs=49\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":7,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Trace/Create Dummy Span",
            "value": 1590,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1056\nallocs=17\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"samples\":10000,\"evals\":10,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      }
    ]
  }
}