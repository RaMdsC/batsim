# Simulation instances
list(APPEND simu_instances "${SGPLATFORM_energy128}?${BATWLOAD_compute1}")
list(APPEND simu_instances "${SGPLATFORM_energy128}?${BATWLOAD_delay1}")
list(APPEND simu_instances "${SGPLATFORM_energy128}?${BATWLOAD_delays}")
list(APPEND simu_instances "${SGPLATFORM_energy128}?${BATWLOAD_mixed}")
list(APPEND simu_instances "${SGPLATFORM_energy128}?${BATWLOAD_delay_sequences}")
list(APPEND simu_instances "${SGPLATFORM_energy128}?${BATWLOAD_tuto1}")
list(APPEND simu_instances "${SGPLATFORM_energy128}?${BATWLOAD_long}")
list(APPEND simu_instances "${SGPLATFORM_energy128}?${BATWLOAD_verylong}")

# Algorithms
list(APPEND algos ${BSALGO_easy_fast})
list(APPEND algos ${BSALGO_fcfs})
list(APPEND algos ${BSALGO_sleeper})
list(APPEND algos ${BSALGO_energy_watcher})


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
        # Parsing algorithm.
        string(REPLACE "!" ";" list_algo ${algo})
        list(GET list_algo 0 algo_name)
        list(GET list_algo 1 algo_realname)

        # Some variables
        set(thistest_NAME "energy-${workload_name}-${platform_name}-${algo_name}")
        set(thistest_OUTPUT_DIR "${test_output_dir}/${thistest_NAME}")
        set(thistest_SCHED_INPUT_FILE "${thistest_OUTPUT_DIR}/sched_input.json")
        set(thistest_SCHED_TRACEFILE "${thistest_OUTPUT_DIR}/sched_trace.csv")

        # Generate batsched input file
        file(MAKE_DIRECTORY ${thistest_OUTPUT_DIR})
        file(WRITE ${thistest_SCHED_INPUT_FILE}
"{ \n\
\"output_dir\":\"${thistest_OUTPUT_DIR}\", \n\
\"trace_output_filename\":\"${thistest_SCHED_TRACEFILE}\", \n\
\n\
\"ensured_sleep_time_lower_bound\":0, \n\
\"ensured_sleep_time_upper_bound\":0, \n\
\n\
\"power_sleep\":9.75, \n\
\"power_idle\":95, \n\
\"energy_switch_on\":19030, \n\
\"power_compute\":190.738, \n\
\"energy_switch_off\":620, \n\
\"time_switch_off\":6.1, \n\
\"pstate_sleep\":13, \n\
\"pstate_compute\":0, \n\
\"time_switch_on\":152 \n\
}"
        )

        # Create the test
        add_test_robintest_batsched(NAME ${thistest_NAME}
            PLATFORM ${platform_filename}
            WORKLOAD ${workload_filename}
            ALGORITHM ${algo_realname}
            OTH_BATSIM_ARGS "--energy"
            OTH_BATSCHED_ARGS "--variant_options_filepath=${thistest_SCHED_INPUT_FILE}"
            ROBINTEST_EXPECTATION "--expect-ctx-clean --expect-robin-success --expect-sched-success --expect-batsim-success"
        )
    endforeach()
endforeach()
