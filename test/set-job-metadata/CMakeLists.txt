# Simulation instances
list(APPEND simu_instances "${SGPLATFORM_small}?${BATWLOAD_compute1}")
list(APPEND simu_instances "${SGPLATFORM_small}?${BATWLOAD_delay1}")
list(APPEND simu_instances "${SGPLATFORM_small}?${BATWLOAD_delays}")
list(APPEND simu_instances "${SGPLATFORM_small}?${BATWLOAD_mixed}")

# Algorithms+dynamic submit mode
list(APPEND algos "${BSALGO_filler}!nodynsubmit!false")
list(APPEND algos "${BSALGO_submitter}!dynsubmit!true")

# Set job metadata?
list(APPEND metadatamodes "set!true")
list(APPEND metadatamodes "do-not-set!false")

foreach(mdm IN LISTS metadatamodes)
    # Parsing metadata mode
    string(REPLACE "!" ";" list_mdm ${mdm})
    list(GET list_mdm 0 mdm_name)
    list(GET list_mdm 1 mdm_value)

    foreach(simu_instance IN LISTS simu_instances)
        # Parsing simulation instance.
        string(REPLACE "?" ";" list_si ${simu_instance})
        list(GET list_si 0 platform)
        list(GET list_si 1 workload)

        string(REPLACE "!" ";" list_platform ${platform})
        list(GET list_platform 0 platform_name)
        list(GET list_platform 1 platform_filename)

        string(REPLACE "!" ";" list_workload ${workload})
        list(GET list_workload 0 workload_name)
        list(GET list_workload 1 workload_filename)

        foreach(algo IN LISTS algos)
            # Parsing algorithm+dynamic submit mode
            string(REPLACE "!" ";" list_algo ${algo})
            list(GET list_algo 0 algo_name)
            list(GET list_algo 1 algo_realname)
            list(GET list_algo 2 dynsubmitmode_name)
            list(GET list_algo 3 dynsubmitmode_value)

            # Some variables
            set(thistest_NAME "${mdm_name}-job-metadata-${workload_name}-${platform_name}-${algo_name}-${dynsubmitmode_name}")
            set(thistest_OUTPUT_DIR "${test_output_dir}/${thistest_NAME}")
            set(thistest_BATSIM_CONFIG_FILE "${thistest_OUTPUT_DIR}/batconf.json")
            set(thistest_SCHED_INPUT_FILE "${thistest_OUTPUT_DIR}/sched_input.json")

            set(thistest_OTH_BATSIM_ARGS "")
            if (${dynsubmitmode_value} MATCHES "true")
                set(thistest_OTH_BATSIM_ARGS "--enable-dynamic-jobs")
            endif()

            # Generate scheduler input
            file(MAKE_DIRECTORY ${thistest_OUTPUT_DIR})
            file(WRITE ${thistest_SCHED_INPUT_FILE}
"{\n\
    \"set_job_metadata\": ${mdm_value}\n\
}"
            )

            add_test_robintest_batsched(NAME ${thistest_NAME}
                PLATFORM ${platform_filename}
                WORKLOAD ${workload_filename}
                ALGORITHM ${algo_realname}
                OTH_BATSIM_ARGS "${thistest_OTH_BATSIM_ARGS}"
                OTH_BATSCHED_ARGS "--variant_options_filepath=${thistest_SCHED_INPUT_FILE}"
                ROBINTEST_EXPECTATION "--expect-ctx-clean --expect-robin-success --expect-sched-success --expect-batsim-success"
                CHECK_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/check_metadata_presence.py"
            )
        endforeach()
    endforeach()
endforeach()
