# Short, one-line, anonymous functions

- Use the anonymous function `\(x) fnc(x)`.
- Do not use `function(x) fnc(x)`.
- Do not use `~ fnc(.x)` from `{purrr}`.

```r
# Do
sapply(X = df, MARGIN = 2, FUN = \(x) mean(x))
# Don't
sapply(X = df, MARGIN = 2, FUN = function(x) mean(x))
sapply(X = df, MARGIN = 2, FUN = ~ mean(.x))
```

- When creating functions, always put parameters on separate lines.

```r
# Do
fun <- function(
  a,
  b = NULL
) {
  # ...
}
# Don't
fun <- function(a, b = NULL) # ...
fun <- function(a, b = NULL) {
  # ...
}
```

# Parameter validation

- Use `{rlang}` to validate arguments and produce clear, informative errors instead of relying on R's default type coercion or cryptic base-R error messages.
- Use `rlang::check_required()` to enforce that a required argument was supplied.
- Use `rlang::arg_match()` to validate that an argument is one of a fixed set of allowed values.
- Use `rlang::abort()` with a descriptive message for other type/shape checks (e.g. length, class, numeric range).

```r
# Do
summarize_col <- function(
  data,
  col,
  stat = c("mean", "median")
) {
  # Parameter validation
  rlang::check_required(data)
  if (!is.data.frame(data)) {
    rlang::abort("`data` must be a data.frame.")
  }
  rlang::check_required(col)
  if (!(col %in% colnames(df))) {
    rlang::abort("`col` must be a colum in `data`.")
  }
  stat <- rlang::arg_match(stat)

  # ...
}
# Don't
summarize_col <- function(
  data,
  col,
  stat = c("mean", "median")
) {
  # ...
}
```

# Documentation

- Document every exported function with roxygen2 comments (`#'`) directly above its definition.
- Always include `@param` for every parameter, `@return` describing the output.
- Never include an `@example` block.
- Add `@export` only for functions meant to be part of the package's public API.
- Keep the title (first line) to a single short sentence; put longer explanation in the description paragraph below it.

Template structure:

```r
#' <One short title>
#' 
#' <Longer function, possibly split into multiple paragraphs if needed>
#' 
#' @param p1 <short name> (<required: class>)
#'     <Longer decription of the parameter>
#' 
#' @param p2 <short name> (<optional: class [default: NULL]>)
#'     <Longer decription of the parameter>
#' 
#' @param p2 <short name> (<optional: class [default: 1]>)
#'     <Longer decription of the parameter>
#'     <Describe options and their impact.>
#' 
#' @return <What is being returned> [<class>].
#' 
#' @export
function_name <- function(
  p1,
  p2 = NULL,
  p3 = c(1, 2, 3)
) {
  # ...
}
```

Example:

```r
#' Compute variance
#' 
#' Compute variance from a given vector if numerical values.
#' 
#' @param x Input data (required: vector<int>)
#'     Vector of values from which should the variance be computed.
#' 
#' @param population Which version to compute (optional: logical [default: TRUE])
#'     Whether the population variance should be returned or not.
#'     
#'     Options:
#'       FALSE - Return the sample variance.
#'       TRUE - Return the population variance.
#' 
#' @param return_value What value should be returned? (optional: int<1, 2, 3> [default: 1]>)
#'     What number from the formula should be returned.
#' 
#'     Options:
#'       1 - Return the nominator.
#'       2 - Return the denominator.
#'       3 - Return the computed variance.
#' 
#' @return Compute value, depending on parameter return_value [numeric].
#' 
#' @export
variance <- function(
  x,
  population = FALSE,
  return_value = c(1, 2, 3)
) {
  # ...
}
```