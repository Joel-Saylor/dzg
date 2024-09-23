module Validator
using XLSX

function validate(filename::AbstractString)
    max_columns = Int64(0)
    first_row = []
    XLSX.openxlsx(filename, enable_cache=false) do f
        sheet = f[1]

        first_row = sheet[1, :]
        all(x -> isa(x, String), first_row) || throw(error("All columns must be strings in the first row."))

        max_columns = size(sheet[:])[2]
        expected_num_of_columns = length(sheet[1, :])

        first_row[1] == "SINK ID" || throw(error("A1 has to be SINK ID, not $(first_row[1])"))
        first_row[2] == "GRAIN ID" || throw(error("B1 has to be GRAIN ID, not $(first_row[2])"))

        for (row_index, row) in enumerate(XLSX.eachrow(sheet))
            if row_index != 1
                length(row.rowcells) == expected_num_of_columns || throw(error("Row size must be same as first row. Row: $row_index has size $(length(row.rowcells))"))
                for column in 1:max_columns
                    if ismissing(row[column])
                        throw(error("Missing value in row $row_index, column $column"))
                    end
                    if column > 2
                        if !isa(row[column], Number)
                            throw(error("Value in row $row_index, column $column is not a number"))
                        end
                    else
                        if !isa(row[column], String)
                            throw(error("Value in row $row_index, column $column is not a string"))
                        end
                    end
                end
            end
        end
    end
end

end
