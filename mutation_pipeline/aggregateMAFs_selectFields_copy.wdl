task aggregateMAFs_selectFields {


    Array[File] inMafFNs
    String outputFN_prfx
    String SelectFields

    Int memory
    Int disk_space
    Int num_preempt


    command {
        git clone https://github.com/broadinstitute/ccle_processing.git

        Rscript ccle_processing/mutation_pipeline/aggregate_selectedFields_MAF.R "${outputFN_prfx}.mergedMAF.txt" ${write_lines(inMafFNs)} ${SelectFields}
    }

    output {
        File mergedMAFfn="${outputFN_prfx}.mergedMAF.txt"
    }

    runtime {
        docker: "us-docker.pkg.dev/depmap-omics/public/ccle-rnaseq:latest"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        preemptible: "${num_preempt}"
    }

    meta {
        author: "Mahmoud Ghandi"
    }
}


workflow aggregateMAFs_selectFields_workflow {
    call aggregateMAFs_selectFields
}
