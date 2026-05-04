test_that("get_transcripts_raw returns a named list by default", {
  skip_if_not(
    dir.exists(file.path("data-raw", "transcripts")) ||
      nzchar(system.file("data-raw", "transcripts", package = "BribeR")),
    message = "data-raw/transcripts not available"
  )
  result <- get_transcripts_raw()
  expect_type(result, "list")
  expect_gt(length(result), 0)
  expect_true(all(nzchar(names(result))))
})

test_that("get_transcripts_raw filters by n", {
  skip_if_not(
    dir.exists(file.path("data-raw", "transcripts")) ||
      nzchar(system.file("data-raw", "transcripts", package = "BribeR")),
    message = "data-raw/transcripts not available"
  )
  result <- get_transcripts_raw(n = 6)
  expect_type(result, "list")
  expect_equal(length(result), 1)
  expect_equal(names(result), "6")
})

test_that("get_transcripts_raw combine = TRUE returns a tibble with n column", {
  skip_if_not(
    dir.exists(file.path("data-raw", "transcripts")) ||
      nzchar(system.file("data-raw", "transcripts", package = "BribeR")),
    message = "data-raw/transcripts not available"
  )
  result <- get_transcripts_raw(n = 6, combine = TRUE)
  expect_s3_class(result, "data.frame")
  expect_true("n" %in% names(result))
  expect_true(all(result$n == 6))
})

test_that("get_transcripts_raw errors on non-existent ID", {
  skip_if_not(
    dir.exists(file.path("data-raw", "transcripts")) ||
      nzchar(system.file("data-raw", "transcripts", package = "BribeR")),
    message = "data-raw/transcripts not available"
  )
  expect_error(
    get_transcripts_raw(n = 99999),
    "No matching transcripts"
  )
})



