#! /usr/bin/env nextflow

// Enable DSL2 syntax for Nextflow
nextflow.enable.dsl = 2

workflow {

    main:
        PRINT_ENV().view()

        data = Channel.fromPath("test/**.sam").map { path -> tuple(path.baseName, path) }
        ADAM_TRANSFORMALIGNMENTS(data)
        ADAM_TRANSFORMALIGNMENTS.out.bam.view()
}

process PRINT_ENV {

    output:
    stdout()

    script:
    """
    env
    echo "-u \$(id -u):\$(id -g)"
    """

}

process ADAM_TRANSFORMALIGNMENTS {

    input:
    tuple val(sample), path(sam)

    output:
    tuple val(sample), path("*.bam"), emit: bam

    script:
    """
    adam-submit transformAlignments -single ${sam} ${sample}.bam
    """
}
