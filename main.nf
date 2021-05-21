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

    memory '2 GB'

    input:
    tuple val(sample), path(sam)

    output:
    tuple val(sample), path("*.bam"), emit: bam

    script:
    """
    env
    # whoami ## Fails with unknown <id>
    mkdir .spark-local
    TMP=`realpath .spark-local`

    export SPARK_LOCAL_IP=127.0.0.1
    export SPARK_PUBLIC_DNS=127.0.0.1
    adam-submit \\
        --master local[${task.cpus}] \\
        --driver-memory ${task.memory.toGiga()}g \\
        --conf spark.local.dir=\$TMP \\
        --conf spark.jars.ivy=\$TMP/.ivy2 \\
        -- \\
        transformAlignments -single ${sam} ${sample}.bam
    """
}
