test_that("length of ACT polling places is correct", {
  expect_equal(nrow(act_polling_places_2020), 82)
})

test_that("can retrieve correct CRS id", {
  crs <- sf::st_crs(act_polling_places_2020)$input
  expect_equal(crs, "EPSG:3857")
})
