---
name: conventions
description: R coding conventions covering safe coding practices, style, and naming rules. Use whenever the user wants to write, edit or check any R code, R script file or R code inside another document. It should be also invoked if user wants to only format an R script or code.
compatibility: R (>= 4.1)
---
# Long rules

Read these rules only if you need them.

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

- Do not read the target R file(s) before formatting.
- Do not read the target R file(s) after formatting, unless the user explicitly asks for a summary of the changes.

## Formatting

- All formatting rules should be defined in `.air.toml` (or `air.toml`) at the project root.
- Whenever you write or change any R code, format the files through the script call below.
- Never call `air` directly.

```bash
# Invoke the script from the project root directory.
bash <skill_directory>/scripts/air-format.sh <file_1.R> <file_2.R>
```