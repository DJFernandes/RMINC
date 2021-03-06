% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/minc_interface.R
\name{runRMINCTestbed}
\alias{runRMINCTestbed}
\title{Run Testbed}
\usage{
runRMINCTestbed(
  ...,
  dataPath = getOption("RMINC_DATA_DIR", tempdir()),
  method = "libcurl",
  verboseTest = FALSE
)
}
\arguments{
\item{...}{additional parameter for \link[testthat]{test_dir}}

\item{dataPath}{The directory to download and unpack the test data 
(unpacks in dataPath/rminctestdata). Default can be set with the option RMINC_DATA_DIR which
can in turn be set with the environment variable RMINC_DATA_DIR. If unset a temporary directory
is created.}

\item{method}{Argument to pass to \link{download.file} typical options are \code{libcurl}}

\item{verboseTest}{Whether or not to verbosely print test output, default is
to print simplified results}
}
\value{
invisibly return the test results
}
\description{
Run the test bed to ensure all RMINC functions
work on your system
}
