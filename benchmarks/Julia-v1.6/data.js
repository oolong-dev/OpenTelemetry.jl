window.BENCHMARK_DATA = {
  "lastUpdate": 1643274843758,
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
      }
    ]
  }
}