include("helpers.jl")
include("emailer.jl")

using .SourceAnalysisHelpers
using .Emailer
using Redis
using JSON

rconn = RedisConnection()

INITIALIZED = "0"
QUEUED = "1"
EXECUTING = "2"
COMPLETE = "3"
FAILED = "4"
TASKQUEUE = "taskqueue"
TYPE_INPUTVIZ = "InputViz"
TYPE_SOURCEANALYSIS = "SourceAnalysis"

function main()
    # wait for task from redis queue
    id_type = brpop(rconn, TASKQUEUE, 0)[2]
    id, type = split(id_type, ":")
    set(rconn, id_type, EXECUTING)
    target_dir = "../data/$id"
    try
        metadata = Dict()
        open("$target_dir/metadata.json", "r") do f
            metadata = JSON.parse(f)
        end

        task_metadata = Dict()
        open("$target_dir/task-metadata.json", "r") do f
            task_metadata = JSON.parse(f)
        end

        if !isfile("$target_dir/transformed.xlsx")
            SourceAnalysisHelpers.transform("$target_dir/input.xlsx", "$target_dir/transformed.xlsx")
        end
        if type == TYPE_INPUTVIZ
            output_data = SourceAnalysisHelpers.create_input_viz_data("$target_dir/transformed.xlsx")
            output_file = "$target_dir/input-viz-response.json"
        elseif type == TYPE_SOURCEANALYSIS
            if task_metadata["override_rank"]
                output_data = SourceAnalysisHelpers.rank_sources_custom_rank(
                    "$target_dir/transformed.xlsx",
                    task_metadata["custom_rank"]
                )
            else
                output_data = SourceAnalysisHelpers.rank_sources("$target_dir/transformed.xlsx")
            end
            output_file = "$target_dir/source-analysis-response.json"
        end

        open(output_file, "w") do f
            JSON.print(f, output_data)
        end
        set(rconn, id_type, COMPLETE)
        if metadata["email"] != ""
            project_name = metadata["project_name"]
            message = ""
            if task_metadata["type"] == TYPE_SOURCEANALYSIS
                message = "Your Source Analysis Report for $project_name is ready.\nClick here to view: https://dzgrainalyzer.eoas.ubc.ca/report/source-analysis/$id"
            else
                message = "Your Input Viz Report for $project_name is ready.\nClick here to view: https://dzgrainalyzer.eoas.ubc.ca/report/input-viz/$id"
            end
            Emailer.send_email(metadata["email"], "DZG Report Ready for $project_name", message)
        end
    catch e
        set(rconn, id_type, FAILED)
        open("$target_dir/error-response.json", "w") do f
            JSON.print(f, Dict(
                "message" => hasproperty(e, :msg) ? "Invalid File Formatting: $(e.msg)" : "Unexpected Error. Start New.",
                "details" => "$e"
            ))
        end
    end
end


while true
    main()
end