% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/convert_CellPhoneDB_output.R
\name{convert_CellPhoneDB_output}
\alias{convert_CellPhoneDB_output}
\title{Converts CellPhoneDB output matrix into an array of weighted adjacency matrices}
\usage{
convert_CellPhoneDB_output(CellPhoneDB_output, complex_input, gene_input)
}
\arguments{
\item{CellPhoneDB_output}{Character string: significant_means.txt file in the output of CellPhoneDB.}

\item{complex_input}{Character string: complex_input.csv file. Download from CellPhoneDB.}

\item{gene_input}{Character string: gene_input.csv file. Download from CellPhoneDB.}
}
\value{
A list of:

\itemize{
  \item{weight_array}{

  Numeric array (3D): array of weighted adjacency matrices with dimensions [number of nodes, number of nodes, number of ligand-receptor pairs].
  \itemize{
    \item First dimension: sending nodes (note: this dimension has all possible nodes, even if some of them are silent for a particular ligand-receptor pair).
    \item Second dimension: receiving nodes (note: this dimension has all possible nodes, even if some of them are silent for a particular ligand-receptor pair).
    \item Third dimension: ligand-receptor pairs.
  }
  Note that the function filters out empty weight arrays and the corresponding ligand-receptor pairs.

  Note that the weight_array should contain dimnames: dimnames = list(nodes, nodes, ligand-receptor pairs).
}
  \item{ligand_receptor_pair_df}{

  Character string data frame: data frame with columns "pair", "ligand", "ligand_complex_composition", "receptor", "receptor_complex_composition".
  \itemize{
    \item "pair" contains values in a form "ligand:receptor", i.e. ligand being at the first place, receptor being at the second place, e.g. "TNFSF13:TNFRSF17".
    \item "ligand" contains ligand names, e.g. "TNFSF13".
    \item "ligand" contains ligand names, e.g. "TNFSF13".
    \item "ligand_complex_composition" if ligand is a complex (e.g. "aXb2_complex"), contains genes in the ligand complex separated with a comma, e.g. "ITGAX,ITGB2", else contains empty string "".
    \item "receptor" contains receptor names, e.g. "TNFRSF17".
    \item "receptor_complex_composition" if receptor is a complex (e.g. "NKG2D_II_receptor"), contains genes in the receptor complex separated with a comma, e.g. "KLRK1,HCST", else contains empty string "".

  }
  }
  \item{nodes}{

  Character string vector: a vector with all cell types in the data.
  }
}
}
\description{
Converts CellPhoneDB output matrix (significant_means.txt) into an array of weighted adjacency matrices.

The CellPhoneDB weight matrix (significant_means.txt) contains ligand-receptor pairs in the rows and all pairs of cell types in the columns.
COMUNET transforms it into a stack of weight matrices (i.e. weight array), one weight matrix per ligand-receptor pair.
If CellPhoneDB output contains \eqn{m} non-empty ligand-receptor pairs, then the number of matrices in the stack will be equal to \eqn{m}.
Each such weight matrix has all cell types in the rows and all cell types in the columns.
By this, if there are \eqn{n} cell types in the data, each weight matrix is an \eqn{n} x \eqn{n} matrix.

The rows of each matrix represent sending cell types, i.e. cell types that express a ligand of a ligand-receptor pair,
or just partner A of an undirected interacting pair (e.g. pair of adhesion molecules).
The columns of each matrix represent receiving cell types, i.e. cell types that express a receptor of a ligand-receptor pair,
or partner B of an undirected interacting pair (e.g. pair of adhesion molecules).
The NA values of the CellPhoneDB output are substituted with 0.

Please note that for simplicity, we address all interacting partners (including non-directional partners such as adhesion molecules) as "ligand-receptor pairs".
}
\examples{
# load CellPhoneDB output for embryo data
data("embryo_CellPhoneDB_output")

# load complex_input table
data("complex_input")

# load gene_input table
data("gene_input")

# transform CellPhoneDB output
embryo_interactions <- convert_CellPhoneDB_output(CellPhoneDB_output = embryo_CellPhoneDB_output, complex_input = complex_input, gene_input = gene_input)

# print(str(embryo_interactions))

}
\references{
CellPhoneDB:

\href{https://www.nature.com/articles/s41596-020-0292-x?proof=trueMay}{Efremova et al., \emph{Nature Protocols} 2019}

\href{http://dx.doi.org/10.1038/s41586-018-0698-6}{Vento-Tormo et al., \emph{Nature} 2018}
}
\author{
Maria Solovey \email{maria.solovey@helmholtz-muenchen.de}
}
