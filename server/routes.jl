include("validate.jl")

using .Validator
using Genie, Genie.Router, Genie.Requests, UUIDs, Genie.Renderer.Json
using Random
using JSON
using Redis

rconn = RedisConnection()

INITIALIZED = "0"
QUEUED = "1"
EXECUTING = "2"
COMPLETE = "3"
FAILED = "4"
TASKQUEUE = "taskqueue"
TYPE_INPUTVIZ = "InputViz"
TYPE_SOURCEANALYSIS = "SourceAnalysis"
KEYS_EXPIRE_IN = 604800

route("/api/hello", method=GET) do
    return "DZG backend is running!"
end

route("/api/upload", method=POST) do
    if !infilespayload(:inputfile)
        return Genie.Renderer.Json.json(
            Dict("message" => "No File Uploaded.", "details" => nothing),
            status=400
        )
    end

    file = filespayload(:inputfile)

    if !endswith(file.name, ".xlsx")
        return Genie.Renderer.Json.json(
            Dict("message" => "File uploaded is not of type xlsx.", "details" => nothing),
            status=400
        )
    end

    if length(file.data) == 0
        return Genie.Renderer.Json.json(
            Dict("message" => "File size is 0.", "details" => nothing),
            status=400
        )
    end

    if length(file.data) > 26000000
        return Genie.Renderer.Json.json(
            Dict("message" => "File is too large. Max size is 25 MB.", "details" => nothing),
            status=400
        )
    end

    id = string(UUIDs.uuid4())
    project_name = postpayload(:name)
    email = postpayload(:email)

    target_dir = "../data/$id"
    mkdir(target_dir)
    input_file = "$target_dir/input.xlsx"
    file.name = input_file
    write(file)

    try
        Validator.validate(input_file)
    catch e
        rm(target_dir, recursive=true)
        return Genie.Renderer.Json.json(
            Dict(
                "message" => hasproperty(e, :msg) ? "Invalid File Formatting: $(e.msg)" : "Unexpected Error",
                "details" => "$e"
            ),
            status=400
        )
    end
    open("$target_dir/metadata.json", "w") do f
        JSON.print(f,
            Dict(
                "id" => id,
                "project_name" => project_name,
                "email" => email,
            )
        )
    end
    # default task is input viz
    open("$target_dir/task-metadata.json", "w") do f
        JSON.print(f,
            Dict(
                "id" => id,
                "type" => TYPE_INPUTVIZ,
                "override_rank" => false,
                "custom_rank" => 0
            )
        )
    end
    set(rconn, "$id:$TYPE_INPUTVIZ", INITIALIZED)
    expire(rconn, "$id:$TYPE_INPUTVIZ", KEYS_EXPIRE_IN)
    return Genie.Renderer.Json.json(
        Dict(
            "message" => "Success",
            "data" => id,
        ),
        status=200
    )
end

route("/api/report/input-viz/:id", method=GET) do
    id = payload(:id)
    status = get(rconn, "$id:$TYPE_INPUTVIZ")
    if status == nothing
        return Genie.Renderer.Json.json(
            Dict("message" => "No file with that job ID was uploaded.", "details" => nothing),
            status=404
        )
    end

    target_dir = "../data/$id"
    if status == INITIALIZED
        lpush(rconn, TASKQUEUE, "$id:$TYPE_INPUTVIZ")
        set(rconn, "$id:$TYPE_INPUTVIZ", QUEUED)
        return Genie.Renderer.Json.json(
            Dict("message" => "Report has been queued. Waiting for execution.", "details" => nothing)
        )
    elseif status == QUEUED
        return Genie.Renderer.Json.json(
            Dict("message" => "Report has been queued. Waiting for execution.", "details" => nothing)
        )
    elseif status == EXECUTING
        return Genie.Renderer.Json.json(
            Dict("message" => "Report is executing. Wait for completion.", "details" => nothing)
        )
    elseif status == COMPLETE
        response_data = Dict()
        open("$target_dir/input-viz-response.json", "r") do f
            response_data = JSON.parse(f)
        end
        return Genie.Renderer.Json.json(Dict(
            "message" => "Success",
            "data" => response_data
        ))
    elseif status == FAILED
        response_data = Dict()
        open("$target_dir/error-response.json", "r") do f
            response_data = JSON.parse(f)
        end
        return Genie.Renderer.Json.json(response_data)
    end
end

route("/api/report/source-analysis/:id", method=POST) do
    id = payload(:id)
    override_rank = jsonpayload()["override_rank"]
    custom_rank = jsonpayload()["custom_rank"]

    open("../data/$id/task-metadata.json", "w") do f
        JSON.print(f,
            Dict(
                "id" => id,
                "type" => TYPE_SOURCEANALYSIS,
                "override_rank" => override_rank,
                "custom_rank" => custom_rank
            )
        )
    end
    set(rconn, "$id:$TYPE_SOURCEANALYSIS", INITIALIZED)
    expire(rconn, "$id:$TYPE_SOURCEANALYSIS", KEYS_EXPIRE_IN)
    return Genie.Renderer.Json.json(Dict(
        "message" => "Success",
        "details" => nothing
    ))
end

route("/api/report/source-analysis/:id", method=GET) do
    id = payload(:id)
    status = get(rconn, "$id:$TYPE_SOURCEANALYSIS")
    if status == nothing
        return Genie.Renderer.Json.json(
            Dict("message" => "No source analysis job was initialized for that id. Redirect to input viz", "details" => nothing),
            status=307
        )
    end

    target_dir = "../data/$id"
    if status == INITIALIZED
        lpush(rconn, TASKQUEUE, "$id:$TYPE_SOURCEANALYSIS")
        set(rconn, "$id:$TYPE_SOURCEANALYSIS", QUEUED)
        return Genie.Renderer.Json.json(
            Dict("message" => "Report has been queued. Waiting for execution.", "details" => nothing)
        )
    elseif status == QUEUED
        return Genie.Renderer.Json.json(
            Dict("message" => "Report has been queued. Waiting for execution.", "details" => nothing)
        )
    elseif status == EXECUTING
        return Genie.Renderer.Json.json(
            Dict("message" => "Report is executing. Wait for completion.", "details" => nothing)
        )
    elseif status == COMPLETE
        response_data = Dict()
        open("$target_dir/source-analysis-response.json", "r") do f
            response_data = JSON.parse(f)
        end
        return Genie.Renderer.Json.json(Dict(
            "message" => "Success",
            "data" => response_data
        ))
    elseif status == FAILED
        response_data = Dict()
        open("$target_dir/error-response.json", "r") do f
            response_data = JSON.parse(f)
        end
        return Genie.Renderer.Json.json(response_data)
    end
end