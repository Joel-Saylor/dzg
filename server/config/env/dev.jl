using Genie, Logging

Genie.Configuration.config!(
  server_port=8000,
  server_host="127.0.0.1",
  log_level=Logging.Info,
  log_to_file=false,
  server_handle_static_files=true,
  path_build="build",
  format_julia_builds=true,
  format_html_output=true,
  watch=true,
  run_as_server=true,
)

Genie.config.cors_headers["Access-Control-Allow-Origin"] = "http://localhost:5173"
Genie.config.cors_headers["Access-Control-Allow-Headers"] = "Content-Type"
Genie.config.cors_headers["Access-Control-Allow-Methods"] = "GET,POST,PUT,DELETE,OPTIONS"
Genie.config.cors_allowed_origins = ["*"]

ENV["JULIA_REVISE"] = "auto"
