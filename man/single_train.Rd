% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/single_train.r
\name{single_train}
\alias{single_train}
\title{Train SINGLE model}
\usage{
single_train(
  bamfile,
  output = "results",
  refseq_fasta,
  rates.matrix = NULL,
  mean.n.mutations = NULL,
  pos_start = NULL,
  pos_end = NULL,
  verbose = TRUE,
  save_partial = FALSE,
  save_final = FALSE
)
}
\arguments{
\item{bamfile}{File containing the counts per position returned by samtools mpileup}

\item{output}{String. Prefix for output files}

\item{refseq_fasta}{Fasta file containing reference sequence}

\item{rates.matrix}{Mutation rate matrix: 4x5 matrix, each row/col representing a nucleotide (col adds deletion), and the values is the mutational rate from row to col.}

\item{mean.n.mutations}{Mean number of mutations expected (one number).}

\item{pos_start}{Numeric. Position to start analyzing, counting starts from 1 and it refers to reference used for minimap2 alignment.}

\item{pos_end}{Numeric. Position to stop analyzing, counting starts from 1 and it refers to reference used for minimap2 alignment.}

\item{verbose}{Logical.}

\item{save_partial}{Logical. Should partial results be saved in files?}

\item{save_final}{Logical. Should final fits be saved in a file?}
}
\value{
Creates file output_prefix_single_results.txt with SINGLE training results.
}
\description{
Main function to train a SINGLE model in a set of reads of a reference / wild type sequence. To get the input data you will need to run before a minimap2 alignment and samtools counts.
}
\details{
Before running single_train_function you have to align your INPUT data to a REFERENCE using minimap2 and count the nucleotides per position using samtools using these lines:

\code{minimap2 -ax map-ont --sam-hit-only  REFERENCE.fasta INPUT.fastq >ALIGNMENT.sam}

\code{samtools view -S -b ALIGNMENT.sam > ALIGNMENT.bam}

\code{samtools sort ALIGNMENT.bam -o ALIGNMENT.sorted.bam }

\code{samtools mpileup -Q 0 ALIGNMENT.sorted.bam > COUNTS.txt}
}
\examples{
refseq_fasta<- system.file("extdata", "ref_seq.fasta", package = "single")
train_reads_example <- system.file("extdata", "train_seqs_500.sorted.bam",
                                   package = "single")
train <- single_train(bamfile=train_reads_example,
                   refseq_fasta=refseq_fasta,
                   rates.matrix=mutation_rate,mean.n.mutations=5.4,
                   pos_start=1,pos_end=10)
print(head(train))
}
