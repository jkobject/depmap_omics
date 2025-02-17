# public_19Q3

## Dataset contents

This DepMap release contains data from CRISPR knockout screens from project Achilles, as well as genomic characterization data from the CCLE project.

### Achilles data

This Achilles dataset contains the results of genome-scale CRISPR knockout screens for 18,333 genes in 666 cell lines. It was processed using the following steps:

- Sum raw readcounts by replicate and guide
- Remove the list of guides with suspected off-target activity
- Remove guides with pDNA counts less than one millionth of the pDNA pool
- Remove replicates that fail fingerprinting match to parent or derivative lines
- Remove replicates with total reads less than 15 million
- Calculate log2-fold-change from pDNA counts for each replicate
- Calculate the NNMD for each replicate using genes targeting the Hart reference non-essentials and the intersection of the Hart and Blomen essentials, and remove those with values more positive than -1.0. See Hart et al., Mol. Syst. Biol, 2014 and Blomen et al., Science, 2015
- Remove replicates that do not have a Pearson coefficient > .61 with at least one other replicate for the line when looking at genes with the highest variance (top 3%) in gene effect across cell lines
- Calculate the NNMD for each cell line after averaging remaining replicates, and remove those more positive than -1.0
- Run CERES to generate gene-level scores
- Scale so the median of common essentials in each cell lines is -1
- Remove the mean and variance of each gene across datasets, so each gene has mean 0 and variance 1
- Remove the first five principle components of the resulting matrix and restore the prior means of genes
- Scale again so the median of common essentials in each cell lines is -1
- Identify pan-dependent genes as those for whom 90% of cell lines rank the gene above a given dependency cutoff. The cutoff is determined from the central minimum in a histogram of gene ranks in their 90th percentile least dependent line
- For each CERES gene score, infer the probability that the score represents a true dependency or not. This is done using an EM step until convergence independently in each cell line. The dependent distribution is given by the list of essential genes. The null distribution is determined from unexpressed gene scores in those cell lines that have expression data available, and from the Hart non-essential gene list in the remainder
- Replace all genes on X chromosome for cell lines that only have Broad SNP copy number data with NA in gene_effect.csv, gene_effect_unscaled.csv, and gene_dependency.csv

The source for copy number data varies by cell line. Copy number data  indicated as "Sanger WES" are based on the Sanger Institute whole exome sequencing data (COSMIC: http://cancer.sanger.ac.uk/cell_lines, EGA accession number: EGAD00001001039) reprocessed using CCLE pipelines. Copy number source was chosen according to the following logic:
- Broad WES for lines where available
- Broad SNP when Broad WES is not available and Sanger WES not available, or Sanger WES copy number has less correlation with logfold change than Broad SNP
- Sanger WES in all other cases


More details about data processing will be published on bioRxiv in summer 19Q3.


### CCLE data

#### Expression

CCLE expression data is quantified from RNAseq files using the GTEx pipelines. A detailed description of the pipelines and tool versions can be found here: https://github.com/broadinstitute/gtex-pipeline/blob/v9/TOPMed_RNAseq_pipeline.md. We provide a subset of the data files outputted from this pipeline available on FireCloud. These are aligned to hg38.

#### Copy number

The CN is called using Broad WES as top priority. If Broad WES is not yet available for a line, then Sanger WES data is used as long as the Sanger WES CN data correlates well with the Achilles log-fold change data. If the correlation is too low and the Sanger WES CN profile differs from the Broad Affy CN, then we used Broad Affy CN. If no WES data is available for a cell line, Broad Affy data is used. We plan to complete WES for all lines that do not have WES soon so we will phase out using Affy CN data. For the WES data, CN is called using a panel of normals that is female only. Therefore X CN is relative to 2 copies of X for WES data. We do not use the X chromosome CN data for cell lines where CN was derived from Affy arrays.


CCLE WES copy number data is generated by running the GATK copy number pipeline aligned to hg38. Tutorials and descriptions of this method can be found here https://software.broadinstitute.org/gatk/documentation/article?id=11682, https://software.broadinstitute.org/gatk/documentation/article?id=11683. WES samples have been realigned to hg38 and run through this pipeline.


Post processing of the segmented level data addressed gaps and the ends of the called chromosomal regions.

#### Mutations

CCLE mutation calls are aggregated from several different sources and sequencing technologies. 

Currently, WES-based calls are generated on a quarterly basis using a cell line implementation of the CGA WES Characterization Pipeline (more info here: https://docs.google.com/document/d/1VO2kX_fgfUd0x3mBS9NjLUWGZu794WbTepBel3cBg08/edit). The cell line implementation of this pipeline has one key difference: because CCLE lines do not have a matched control sample, we use the same normal sample as a matched normal input for all samples using the same baits (Agilent vs. ICE). In addition, mutation calls still use hg19 alignment.

Quarterly WES-based mutation calls are added to the existing mutation calls from previous releases. WGS, Sanger WES, RNAseq, HC, and RD based calls from the 2nd phase of the CCLE project are also included. More details on how these mutations were called and filtered can be found in the manuscript “Next generation characterization of the Cancer Cell Line Encyclopedia” in Nature.

#### Fusions

CCLE generates RNAseq based fusion calls using the STAR-Fusion pipeline. A comprehensive overview of how the STAR-Fusion pipeline works can be found here: https://github.com/STAR-Fusion/STAR-Fusion/wiki. We run STAR-Fusion version 1.6.0 using the plug-n-play resources available in the STAR-Fusion docs for gencode v29. We run the fusion calling with default parameters except we add the --no_annotation_filter and --min_FFPM 0 arguments to prevent filtering.

# Files

## File: sample_info

Cell line information definitions    

- DepMap_ID:  Static primary key assigned by DepMap
- stripped_cell_line_name:  Cell line name with alphanumeric characters only
- CCLE_name:  Stripped cell line name followed by underscore and tissue assignment
- alias:  Additional cell line identifiers (not a comprehensive list)
- COSMIC_ID:  Cell line ID used in Cosmic cancer database
- lineage, lineage_subtype, lineage_sub_subtype:  Cancer type classifications
- sex:  Sex of tissue donor if known
- source:  Source of cell line vial used by DepMap
- Achilles_n_replicates:  Number of replicates used in Achilles CRISPR screen passing QC
- cell_line_NNMD:  Difference in the means of positive and negative controls normalized by the standard deviation of the negative control distribution
- culture_type:  Growth pattern of cell line (Adherent, Suspension, Mixed adherent and suspension, 3D, or Adherent (requires laminin coating))
- culture_medium:  Medium used to grow cell line
- cas9_activity:  Percentage of cells remaining GFP positive on days 12-14 of cas9 activity assay as measured by FACs
- RRID:  Cellosaurus research resource identifier
- sample_collection_site:  Tissue collection site
- primary_or_metastasis:  Indicates whether tissue sample is from primary or metastatic site
- disease:  General cancer lineage category
- disease_subtype:  Subtype of disease; specific disease name
- age:  If known, age of tissue donor at time of sample collection
- Sanger_model_ID:  Sanger Institute Cell Model Passport ID
- additional_info:  Further information about cell line modifications and drug resistance

## File: Achilles_gene_effect_unscaled

*Post-CERES*

CERES inferred effects of knocking out genes, without additional scaling. More negative effects produce more negative logfold changes.

- Columns: genes in the format  “HUGO (Entrez)”
- Rows: cell lines (Broad IDs)


## File: Achilles_gene_effect

*Post-CERES*

CERES data with principle components strongly related to known batch effects removed, then shifted and scaled per cell line so the median nonessential KO effect is 0 and the median essential KO effect is -1.

- Columns: genes in the format  “HUGO (Entrez)”
- Rows: cell lines (Broad IDs)

## File: Achilles_gene_dependency

*Post-CERES*

Probability that knocking out the gene has a real depletion effect using gene_effect.

- Columns: genes in the format  “HUGO (Entrez)”
- Rows: cell lines (Broad IDs)

## File: Achilles_guide_efficacy

*Post-CERES*

Columns:

- sgrna (nucleotides)
- efficacy - CERES inferred efficacy for the guide

## File: Achilles_common_essentials

*Post-CERES*

List of genes identified as dependencies in all lines, one per line. 

## File: common_essentials

*Pre-CERES file*

List of genes used as positive controls, intersection of Biomen (2014) and Hart (2015) essentials in the format “HUGO (Entrez)”. Each entry is separated by a newline.
The scores of these genes are used as the dependent distribution for inferring dependency probability.

## File: nonessentials

*Pre-CERES file*

List of genes used as negative controls (Hart (2014) nonessentials) in the format “HUGO (Entrez)”. Each entry is separated by a newline.

## File: Achilles_raw_readcounts

*Pre-CERES file*

Summed counts for each replicate/PDNA

- Columns: replicate/pDNA IDs 
- Rows: Guides (nucleotides)

## File: Achilles_logfold_change

*Pre-CERES file*

Post-QC log2-fold change (not ZMADed)

- Columns: replicate IDs
- Rows: Guides (nucleotides)

## File: Achilles_guide_map

*Pre-CERES file*

Columns:

- sgrna (nucleotides) - appears more than once
- genome_alignment
- gene (“HUGO (Entrez)”)
- n_alignments (integer number of perfect matches for that guide)

## File: Achilles_replicate_map

*Pre-CERES file*

Columns:

- replicate_ID (str)
- Broad_ID
- pDNA_batch (int): indicates which processing batch the replicate belongs to and therefore which pDNA reference it should be compared with.

## File: Achilles_dropped_guides

*Pre-CERES file*

Columns:

- sgrna (nucleotides) - appears more than once
- genome_alignment
- gene (“HUGO (Entrez)”)
- n_alignments (integer number of perfect matches for that guide)
- fail_reason (why this guide is not used for gene effect/dependency calculation) Note: in_dropped_guides = guide dropped for suspected off-target activity

## File: CCLE_RNAseq_reads

RNAseq read count data from RSEM

- Rows: cell lines (Broad IDs)
- Columns: genes (HGNC symbol and Ensembl ID)


## File: CCLE_expression_full

RNAseq TPM gene expression data for all genes using RSEM. Log2 transformed, using a pseudo-count of 1.

- Rows: cell lines (Broad IDs)
- Columns: genes (HGNC symbol and Ensembl ID)

## File: CCLE_expression

RNAseq TPM gene expression data for just protein coding genes using RSEM. Log2 transformed, using a pseudo-count of 1.

- Rows: cell lines (Broad IDs)
- Columns: genes (HGNC symbol and Entrez ID)

## File: CCLE_RNAseq_transcripts

RNAseq transcript count data using RSEM.

- Rows: cell lines (Broad IDs)
- Columns: transcripts

## File: CCLE_segmented_cn

Segment level copy number data

- DepMap_ID
- Chromosome
- Start (bp start of the segment)
- End (bp end of the segment)
- Num_Probes (the number of targeting probes that make up this segment)
- Segment_Mean (relative copy ratio for that segment)

## File: CCLE_gene_cn

Gene level copy number data, log2 transformed with a pseudo count of 1. This is generated by mapping genes onto the segment level calls.

- Rows: cell lines (Broad IDs)
- Columns: genes (HGNC symbol and Entrez ID)

## File: CCLE_fusions

Gene fusion data derived from RNAseq data. Data is filtered using by performing the following:

- Removing fusion involving mitochondrial chromosomes or HLA genes
- Removed common false positive fusions (red herring annotations as described in the STAR-Fusion docs)
- Recurrent fusions observed in CCLE across cell lines (in 25 or more samples)
- Removed fusions where SpliceType='INCL_NON_REF_SPLICE' and LargeAnchorSupport='NO_LDAS' and FFPM < 0.1
- FFPM < 0.05

Column descriptions can be found in the STAR-Fusion wiki, except for CCLE_count, which indicates the number of CCLE samples that have this fusion.

## File: CCLE_fusions_unfiltered

Gene fusion data derived from RNAseq data. Data is unfiltered. Column descriptions can be found in the STAR-Fusion wiki

## File: CCLE_mutations 

MAF of gene mutations. 

For all columns with AC, the allelic ratio is presented as [ALTERNATE:REFERENCE].

- CGA_WES_AC: the allelic ratio for this variant in Broad WES using a cell line adapted version of the CGA pipeline (https://docs.google.com/document/d/1VO2kX_fgfUd0x3mBS9NjLUWGZu794WbTepBel3cBg08/edit) that includes germline filtering.
- SangerWES_AC: in Sanger WES
- SangerRecalibWES_AC: in Sanger WES after realignment at Broad
- RNAseq_AC: in Broad RNAseq data from the CCLE2 project
- HC_AC: in Broad Hybrid capture data from the CCLE2 project
- RD_AC: in Broad Raindance data from the CCLE2 project
- WGS_AC: in Broad WGS data from the CCLE2 project

Additional columns:

- isTCGAhotspot: is this mutation commonly found in TCGA
- TCGAhsCnt: number of times this mutation is observed in TCGA
- isCOSMIChotspot: is this mutation commonly found in COSMIC
- COSMIChsCnt: number of samples in COSMIC with this mutation
- ExAC_AF: the allelic frequency in the Exome Aggregation Consortium (ExAC)

Descriptions of the remaining columns in the MAF can be found here: https://docs.gdc.cancer.gov/Data/File_Formats/MAF_Format/