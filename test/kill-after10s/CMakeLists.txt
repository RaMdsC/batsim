# Simulation instances
list(APPEND simu_instances "${SGPLATFORM_small}?${BATWLOAD_compute1}")
list(APPEND simu_instances "${SGPLATFORM_small}?${BATWLOAD_delay1}")
list(APPEND simu_instances "${SGPLATFORM_small}?${BATWLOAD_delays}")
list(APPEND simu_instances "${SGPLATFORM_small}?${BATWLOAD_mixed}")
list(APPEND simu_instances "${SGPLATFORM_cluster512}?${BATWLOAD_long}")

# Whether redis should be enabled
# Syntax: "name!redis_mode"
list(APPEND redis_modes "redis!true")
list(APPEND redis_modes "noredis!false")

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

    # Setting algorithm
    set(algo_name "killer")
    set(algo_realname "killer")

    foreach(redis_mode IN LISTS redis_modes)
        # Parsing redis_mode
        string(REPLACE "!" ";" list_redis_mode ${redis_mode})
        list(GET list_redis_mode 0 redis_mode_name)
        list(GET list_redis_mode 1 redis_mode_value)

        # Some variables
        set(thistest_NAME "kill-after10s-${workload_name}-${platform_name}-${redis_mode_name}")

        set(thistest_OUTPUT_DIR "${test_output_dir}/${thistest_NAME}")
        set(thistest_BATSIM_CONFIG_FILE "${thistest_OUTPUT_DIR}/batconf.json")

        file(MAKE_DIRECTORY ${thistest_OUTPUT_DIR})

        set(thistest_OTH_BATSIM_ARGS "--forward-profiles-on-submission")
        if (${redis_mode_value} MATCHES "true")
            set(thistest_OTH_BATSIM_ARGS "${thistest_OTH_BATSIM_ARGS} --enable-redis --redis-prefix '${thistest_NAME}'")
        endif()

        # Create the test
        add_test_robintest_batsched(NAME ${thistest_NAME}
            PLATFORM ${platform_filename}
            WORKLOAD ${workload_filename}
            ALGORITHM ${algo_realname}
            OTH_BATSIM_ARGS "${thistest_OTH_BATSIM_ARGS}"
            OTH_BATSCHED_ARGS ""
            ROBINTEST_EXPECTATION "--expect-ctx-clean --expect-robin-success --expect-sched-success --expect-batsim-success"
            CHECK_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/check_jobs_duration_before_10s.py"
        )
    endforeach()
endforeach()
