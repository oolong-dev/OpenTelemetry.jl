export is_push_exporter,
    is_pull_exporter

is_push_exporter(::ConsoleExporter) = true
is_pull_exporter(::ConsoleExporter) = false

is_push_exporter(::InMemoryExporter) = true
is_pull_exporter(::InMemoryExporter) = false