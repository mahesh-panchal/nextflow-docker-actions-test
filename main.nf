#! /usr/bin/env nextflow

// Enable DSL2 syntax for Nextflow
nextflow.enable.dsl = 2

workflow {

    main:
        PRINT_ENV()
}

process PRINT_ENV {

    output:
    stdout()

    script:
    """
    env
    """

}
