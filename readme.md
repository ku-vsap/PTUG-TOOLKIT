
## Custom Tracker Evaluation Setting
Put the tracking prediction in ./trcking_results. It should look like:
   ```
   ${TOOLKIT_ROOT}
    -- Tracking_results
        -- ATOM
            |-- single_1.txt
            |-- single_2.txt
            |-- single_3.txt
            ...
        -- DiMP
            |-- single_1.txt
            |-- single_2.txt
            |-- single_3.txt
            ...
   ```

put the tracker name in  ./utils/cofig_tracker.m like:
 ```
    trackers = {
        struct('name', 'ATOM',      'publish', 'NA') ...
        struct('name', 'DiMP',      'publish', 'NA')
        }
   ```

## Custom TestSet Setting
put the evaluate sequences in sequence_evaluation_config like:
    ```
    ${TOOLKIT_ROOT}
    --  sequence_evaluation_config
        -- all_set.txt
            |-- multi_1
            |-- single_1
            |-- multi_2
            ...
        -- single_set.txt
            |-- single_1
            |-- single_2
            |-- single_3
            ...
    ```
Then involve the testset in ./utils/config_sequences.m like:
    ```
    switch type
        case 'single'
            dataset_name = 'single_set.txt';
        case 'multi'
            dataset_name = 'multi_set.txt';
        case 'all'
            dataset_name = 'all_set.txt';
        otherwise
            error('Error in evaluation dataset type! Either ''single_set'' or "multi_set" or ''all-set''.')
    end
    ```
Finally, in run_tracker_performance_evaluation.m line 25, change the "evaluation_dataset_type" = 'single' or 'all' or 'multi'.

## Start the Evaluation

execute the run_tracker_performance_evaluation.m file in Matlab


## Acknowledgments
* Thanks for the great [LaSOT](https://github.com/HengLan/LaSOT_Evaluation_Toolkit) Library, which helps us to quickly implement the dataset evaluation.

