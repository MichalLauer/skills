---
name: conventions
description: R coding conventions covering safe coding practices, style, and naming rules. Use whenever the user wants to write, edit or check any R code, R script file or R code inside another document.
compatibility: R (>= 4.1)
---
# Long rules

Read these rules only if you need them. Never read them passively or without a purpose.

- [functions.md](references/functions.md)

# Code standards

## Naming conventions

- Always write short, descriptive names for variables and functions.
- Use only English, and use snake_case.

```r
# Do
df <- read.csv(...)
model <- lm(...)
# Don't
x <- read.csv(...)
# Exceptions
## Loop variables
for (i in 1:5) {
  # ...
}
## Simulation variables
n <- 100
b <- 5
```

## Code comments

- Write clean, short, and simple code.
- Add comments only where domain knowledge is needed.

```r
# Do
# Because the raw data is broken, we need to identify correct countries and states
df$world <- grepl(df$country, df$state)
# Don't
# Mean of age
mean(df$age)
```

## Safety

- Either load the library at the top of the script/document.
- If there is a possibility of loading the same functions from different packages, use `pkg::fun()`.
- Never use `attach()`. It silently masks variables and makes code impossible to reason about.
- Avoid `<<-` and `assign()` to modify variables outside a function's scope.
- Use `vapply()` instead of `sapply()` when the output type matters.
- Set a seed (`set.seed()`) before any code that relies on randomness, so results are reproducible.
- Never call `setwd()` inside a script or function. Use relative paths instead.


## Piping, chaining

- Use the base pipe `|>` rather than the `{dplyr}`/`{magrittr}` pipe `%>%`.

```r
# Do
df |>
  pull(col1) |>
  mean()
# Don't
df %>%
  pull(col1) %>%
  mean()
```

# Code formatting

## Rules

- All formatting rules should be defined in `.air.toml` at the project root.
- If the project has no `.air.toml`, ask the user whether they want to use the default config:
  - If no: share a link to [the official configuration guide](https://posit-dev.github.io/air/configuration.html) so they can write their own.
  - If yes: copy [assets/.air.toml](assets/.air.toml) into the project root using bash.

## CLI formatting

- Whenever you change any R code, use the `air` CLI tool to format it.

```bash
# Single file
air format <file_1.R>
# Multiple files
air format <file_1.R> <file_2.R>
```

## Edge case: Air is not available

- Whenever the tool is not available, tell the user.
- Suggest that they install it using one of the following:
  - [posit-dev/air](https://github.com/posit-dev/air)
  - `uv tool install air-formatter`
- Never run those commands yourself.