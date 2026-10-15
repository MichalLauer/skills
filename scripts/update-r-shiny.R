plugin_dir <- file.path("plugins", "r-shiny")
overwrite <- TRUE

skills <- list(
  list(repo = "rstudio/shiny", path = "inst/skills/shiny-for-r"),
  list(repo = "posit-dev/skills", path = "r-lib/r-package-development"),
  list(repo = "posit-dev/skills", path = "shiny/shiny-bslib"),
  list(repo = "posit-dev/skills", path = "shiny/shiny-bslib-theming"),
  list(repo = "posit-dev/skills", path = "brand-yml")
)

options(timeout = max(300, getOption("timeout")))

zip_cache <- new.env()

get_repo_zip <- function(repo) {
  if (!is.null(zip_cache[[repo]])) {
    return(zip_cache[[repo]])
  }
  url <- sprintf("https://codeload.github.com/%s/zip/refs/heads/main", repo)
  dest <- tempfile(fileext = ".zip")
  message("Downloading ", repo, " ...")
  utils::download.file(url, dest, mode = "wb", quiet = TRUE)
  zip_cache[[repo]] <- dest
  dest
}

install_skill <- function(repo, path) {
  name <- basename(path)
  dest <- file.path(plugin_dir, name)

  if (dir.exists(dest) && !overwrite) {
    message("  - skipped ", name, " (already exists)")
    return(invisible(TRUE))
  }

  zipfile <- get_repo_zip(repo)
  entries <- utils::unzip(zipfile, list = TRUE)$Name
  top <- unique(sub("/.*$", "", entries))[1]
  prefix <- paste0(top, "/", path, "/")

  files <- entries[startsWith(entries, prefix) & !endsWith(entries, "/")]
  if (!(paste0(prefix, "SKILL.md") %in% files)) {
    stop(
      "No SKILL.md found at '",
      path,
      "' in ",
      repo,
      " - the repo layout may have changed."
    )
  }

  tmp <- tempfile("skill_")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  utils::unzip(zipfile, files = files, exdir = tmp)

  if (dir.exists(dest)) {
    unlink(dest, recursive = TRUE)
  }
  dir.create(dest, recursive = TRUE)
  src <- file.path(tmp, top, path)
  ok <- file.copy(
    list.files(src, full.names = TRUE, all.files = TRUE, no.. = TRUE),
    dest,
    recursive = TRUE
  )
  if (!all(ok)) {
    stop("Failed to copy some files for ", name)
  }

  message("  + ", name, " (", length(files), " files) <- ", repo, "/", path)
  invisible(TRUE)
}

dir.create(plugin_dir, recursive = TRUE, showWarnings = FALSE)

message("Installing ", length(skills), " skill(s) into ", plugin_dir, "/")

failed <- character()
for (s in skills) {
  tryCatch(
    install_skill(s$repo, s$path),
    error = function(e) {
      message("  ! FAILED ", basename(s$path), ": ", conditionMessage(e))
      failed <<- c(failed, basename(s$path))
    }
  )
}

message("\nInstalled skills:")
for (d in sort(vapply(skills, function(s) basename(s$path), character(1)))) {
  has <- file.exists(file.path(plugin_dir, d, "SKILL.md"))
  message("  ", if (has) "[ok] " else "[!!] ", d)
}

if (length(failed)) {
  stop("Some skills failed: ", paste(failed, collapse = ", "), call. = FALSE)
}
