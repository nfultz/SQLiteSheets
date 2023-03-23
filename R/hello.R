setClass("SQLiteSheetsDriver", contains = "SQLiteDriver")

setClass("SQLiteSheetsConnection", contains = "SQLiteConnection")


SQLiteSheets <- function() {
  new("SQLiteSheetsDriver")
}

setMethod("dbConnect", "SQLiteSheetsDriver", function(drv, ...) {
  # ...
  con <- callNextMethod()

  file <- system.file("libs", "libxlite.so", package = 'SQLiteSheets') |>   enc2utf8() # path to so

  entry_point <- "sqlite3_xlite_init"

  .Call("_RSQLite_extension_load", con@ptr, file, entry_point, PACKAGE = "RSQLite")

  as(con, "SQLiteSheetsConnection")
})


setMethod("dbConnect", "SQLiteSheetsConnection", function(drv, ...) {
  if (drv@dbname %in% c("", ":memory:", "file::memory:")) {
    stop("Can't clone a temporary database", call. = FALSE)
  }

  dbConnect(SQLiteSheetsDriver(), drv@dbname,
            vfs = drv@vfs, flags = drv@flags,
            loadable.extensions = drv@loadable.extensions
  )

})
