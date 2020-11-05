test_that("length of ACT polling places is correct", {
  expect_equal(nrow(act_polling_places_2020), 82)
})

test_that("all valid geometries", {
  expect_equal(sum(sf::st_is_valid(act_polling_places_2020)), 82)
})
