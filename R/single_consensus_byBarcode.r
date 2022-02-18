#' Compute SINGLE consensus
#'
#' Main function to compute consensus after correcting reads by a SINGLE model.
#'
#' @param barcodes_file File containing the names of the reads and the barcode associated (or any grouping tag).
#' @param refseq_fasta Fasta file containing reference sequence
#' @param single_corrected_seqs Files containing the sequences corrected by SINGLE, i.e. saved by single_evaluate
#' @param column_id,column_barcode Numeric. Columns where the sequences id and the barcode (or grouping tag) are, in the barcodes_file
#' @param header,dec,sep  Arguments for read.table(barcodes_file)
#' @param verbose Logical.
#' @return DNAStringSet with consensus sequences
#' @import dplyr
#' @importFrom rlang .data
#' @importFrom utils read.table
#' @importFrom Biostrings DNAStringSet
#' @export single_consensus_byBarcode
#' @examples
#' pos_start=1
#' pos_end = 100
#' barcodes_file = system.file("extdata", "BC_TABLE.txt", package = "single")
#' refseq_file = system.file("extdata", "ref_seq.fasta", package = "single")
#' reads_single = system.file("extdata", "single_reads_ex_corrected.txt", package = "single")
#' single_consensus_byBarcode(barcodes_file,refseq_file,reads_single,
#'                           verbose = FALSE)
single_consensus_byBarcode <- function(barcodes_file,refseq_fasta,
                                single_corrected_seqs,
                                column_id=NULL,column_barcode=NULL,
                                header=TRUE, dec=".",sep=" ", verbose=TRUE){
    bc_table <- utils::read.table(barcodes_file,header=header, dec=dec,sep=sep)
    if( (is.null(column_barcode) & !is.null(column_id))){
        stop('single_consensus_byBarcode: you need to specify column_barcode')
    }
    if( (!is.null(column_barcode) & is.null(column_id))){
        stop('single_consensus_byBarcode: you need to specify column_id')
    }
    if(!is.null(column_barcode) | !is.null(column_id)){
        bc_table <- bc_table[,c(column_id,column_barcode)]
    }
    colnames(bc_table) <- c("SeqID","BCsequence")

    ref_seq <- load_ref_seq(refseq_fasta)
    reads_corrected <- lapply(single_corrected_seqs,read.table, header=TRUE)
    reads_corrected <- do.call(rbind,reads_corrected)
    reads_corrected <- dplyr::left_join(reads_corrected,
                                        bc_table %>%
                                            select(.data$SeqID,.data$BCsequence),
                                        by="SeqID") %>%
                        dplyr::filter(!is.na(.data$BCsequence))
    reads_corrected$p_right_priors_model[is.na(reads_corrected$p_right_priors_model)]<-1

    rm(bc_table)
    barcodes = unique(reads_corrected$BCsequence)

    #Compute consensus for each barcode using all sequences available and using the three available methods
    consensus_sequences <- DNAStringSet()
    if(verbose){ pb <- utils::txtProgressBar(0,length(barcodes),style=3) }
    for(bc in seq_along(barcodes)){
        data_bc <- reads_corrected %>%
            dplyr::filter(.data$BCsequence==barcodes[bc])
        data_bc <- data_bc[,c("nucleotide","p_right_priors_model","position")]
        consensus_sequences[[bc]] <- consensus_seq(df = data_bc, cutoff_prob = 0)
        if(verbose){utils::setTxtProgressBar(pb,bc)}
    }
    return(consensus_sequences)
}

