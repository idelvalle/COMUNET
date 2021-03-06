#' @rdname plot_cluster_UMAP
#' @export
#'
#' @title
#' Plots UMAP of interacting partners
#'
#' @description
#' Plots UMAP of interacting partners colored and shaped by cluster.
#'
#' Please note that for simplicity, we address all interacting partners (including non-directional partners such as adhesion molecules) as "ligand-receptor pairs".
#'
#' @author
#' Maria Solovey \email{maria.solovey@helmholtz-muenchen.de}
#'
#' @param       ligand_receptor_pair_df Character string data frame: data frame with columns:
#'
#'  \itemize{
#'  \item "pair" contains values in a form "ligand:receptor", i.e. ligand being at the first place, receptor being at the second place, e.g. "TNFSF13:TNFRSF17".
#'  \item "ligand" contains ligand names, e.g. "TNFSF13".
#'  \item "ligand_complex_composition" if ligand is a complex (e.g. "aXb2_complex"),
#'  contains genes in the ligand complex separated with a comma, e.g. "ITGAX,ITGB2", else contains empty string "".
#'  \item "receptor" contains receptor names, e.g. "TNFRSF17".
#'  \item "receptor_complex_composition" if receptor is a complex (e.g. "NKG2D_II_receptor"),
#'  contains genes in the receptor complex separated with a comma, e.g. "KLRK1,HCST", else contains empty string "".
#'  }
#'
#' @param       dissim_matrix Numeric matrix: pairwise dissimilarity matrix.
#'
#' Note that row names and column names should contain ligand-receptor pairs.
#'
#' @param       lrp_clusters Numeric vector: cluster assignment for each ligand-receptor pair.
#'
#' Note that the the vector should be named and ordered in the same way as the row names and column names of the dissim_matrix.
#'
#' @param       seed Random seed for UMAP. Default value: 100.
#'
#' @param       cluster_colors Character string vector: vector with colours for each cluster. Default value: "".
#'
#' @param       unclustered_LRP_color Character string: colour for ligand-receptor pairs that remained unclustered (cluster assignment 0). Default value: "black".
#'
#' @param       cluster_shape Numeric vector: vector with shapes for each cluster. Default value: "".
#'
#' @param       point_size Numeric: size of points. Default value: 2.
#'
#' @param       title Character string: title of the UMAP plot. Argument of the \code{\link[ggtitle:ggplot2]{ggtitle}} function. Default value: "umap of ligand-receptor pairs".
#'
#' @param       legend_position Character string: argument of the \code{\link[theme:ggplot2]{theme}} function. Default value: "bottom" guide_legend.
#'
#' @param       legend_direction Character string: argument of the \code{\link[guide_legend:ggplot2]{guide_legend}} function. Default value: "horizontal".
#'
#' @param       legend_title_position Character string: argument of the \code{\link[guide_legend:ggplot2]{guide_legend}} function. Default value: "top".
#'
#' @param       legend_label_position Character string: argument of the \code{\link[guide_legend:ggplot2]{guide_legend}} function. Default value: "bottom".
#'
#' @param       legend_byrow logical: Argument of the \code{\link[guide_legend:ggplot2]{guide_legend}} function. Default value: TRUE.
#'
#' @return      UMAP of ligand-receptor pairs coloured and shaped by cluster.
#'
#' @examples
#' # load lrp_clusters
#' data("embryo_lrp_clusters")
#'
#' # load embryo_interactions
#' data("embryo_interactions")
#'
#' # plot heatmap
#' plot_cluster_UMAP(ligand_receptor_pair_df = embryo_interactions$ligand_receptor_pair_df, dissim_matrix = embryo_lrp_clusters$dissim_matrix, lrp_clusters = embryo_lrp_clusters$clusters)
#'
plot_cluster_UMAP <- function(ligand_receptor_pair_df
                              ,dissim_matrix
                              ,lrp_clusters
                              ,seed = 100
                              ,cluster_colors = ""
                              ,unclustered_LRP_color = "black"
                              ,cluster_shape = ""
                              ,point_size = 2
                              ,title = "umap of ligand-receptor pairs"
                              ,legend_position="bottom"
                              ,legend_direction = "horizontal"
                              ,legend_title_position = "top"
                              ,legend_label_position= "bottom"
                              ,legend_byrow=TRUE
){

        # set seed
        set.seed(seed)

        # define n_neighbors parameter
        n_neighbors <- umap::umap.defaults$n_neighbors
        if(n_neighbors >= nrow(ligand_receptor_pair_df)) n_neighbors <- round(nrow(ligand_receptor_pair_df) /2)

        # check wether there are enough ligand-receptor pairs to plot a UMAP
        if(n_neighbors > 1){
                custom.settings <-  umap.defaults
                custom.settings$input <- "dist"
                custom.settings$n_neighbors <- n_neighbors

                # calculate the UMAP
                my.umap <- umap::umap(dissim_matrix
                                      ,config = custom.settings)

                # make data frame for UMAP plotting
                dfForUmap <- data.frame(x=my.umap$layout[,1]
                                        ,y=my.umap$layout[,2]
                                        ,cluster=lrp_clusters
                )

                # factorize clusters
                dfForUmap$cluster <- as.factor(dfForUmap$cluster)

                # assign colours to clusters
                if(cluster_colors == "") cluster_colors <- structure(rainbow(length(levels(as.factor(lrp_clusters)))))
                names(cluster_colors) <- levels(as.factor(lrp_clusters))

                # if there are unclustered ligand-receptor pairs, colour them with a defined colour
                if(as.factor(0) %in% names(cluster_colors)) cluster_colors[names(cluster_colors) == as.factor(0)] <- unclustered_LRP_color

                # define cluster shape
                if(cluster_shape == "") cluster_shape <- as.integer(names(cluster_colors)) %% 5 +21
                names(cluster_shape) <- names(cluster_colors)

                # plot UMAP
                umap.clusters <- ggplot2::ggplot(dfForUmap
                                                 ,aes(x=x
                                                      ,y=y
                                                      ,color=cluster
                                                      ,shape = cluster
                                                 )
                ) +
                        geom_point(size=point_size) +
                        scale_color_manual(name = "Cluster"
                                           ,labels = c("unclustered"
                                                       ,1:max(lrp_clusters))
                                           ,values = cluster_colors) +
                        scale_shape_manual(name = "Cluster"
                                           ,labels = c("unclustered"
                                                       ,1:max(lrp_clusters))
                                           ,values = cluster_shape) +
                        ylab("umap2") +
                        xlab("umap1") +
                        ggtitle(title) +
                        theme(legend.position=legend_position) +
                        guides(fill=guide_legend(nrow=2
                                                 ,direction = legend_direction
                                                 ,title.position = legend_title_position
                                                 ,label.position= legend_label_position
                                                 ,byrow=legend_byrow
                        )
                        )
                print(umap.clusters)
        } else print("WARNING: too few ligand-receptor pairs. UMAP can not be plotted.")
}
