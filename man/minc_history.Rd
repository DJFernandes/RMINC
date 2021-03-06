% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/minc_interface.R
\name{minc_history}
\alias{minc_history}
\alias{minc.get.history}
\alias{minc.append.history}
\title{Minc History}
\usage{
minc.get.history(filename)

minc.append.history(filename, new_history = NULL)
}
\arguments{
\item{filename}{A path to a minc volume}

\item{new_history}{A new line to be added to the history
defaults to "[timestamp]>>> Written out by RMINC"}
}
\value{
a character vector with one element per line of history
}
\description{
Retrieve or edit the history of a MINC Volume
}
\section{Functions}{
\itemize{
\item \code{minc.get.history}: retrieve

\item \code{minc.append.history}: append
}}

