module DBAbstracts

export Insert, set!, sql, stmt

struct Insert
  table::String
  columns::Vector{String}
  binds::Dict{Symbol, Int}
  values::Vector{Any}

  function Insert(table::String, columns::Vector{String})
    binds = Dict{Symbol, Any}()
    for c in 1:length(columns)
        binds[Symbol(columns[c])] = c
    end
    values = Vector(length(columns))
    foreach(i->values[i] = "", 1:length(columns))
    new(table, columns, binds, values)
  end
end

set!(i::Insert, s::Symbol, v::Any) = i.values[i.binds[s]] = v
set!(i::Insert, vs::Vector) = foreach(n->i.values[n] = vs[n], 1:length(i.values))

fmt(t::String) = "'" * replace(t, "'", "''") * "'"
fmt(n::Number) = "$n"
fmt(i::Irrational) = "$(i+0)"
fmt(d::Date) = "'" * Dates.format(d, "mm/dd/yyyy") * "'"
fmt(d::DateTime) = "'" * Dates.format(d, "mm/dd/yyyy HH:MM") * "'"
fmt(v::Any) = "'$v'"

function sql(io, i)
  print(io, "INSERT INTO ", i.table, " (", i.columns[1])
  foreach(c->print(io, ",", i.columns[c]), 2:length(i.columns))
  print(io, ") VALUES(", fmt(i.values[1]))
  foreach(c->print(io, ",", fmt(i.values[c])), 2:length(i.values))
  println(io, ");")
end

function stmt(io, i)
    print(io, "INSERT INTO ", i.table, " (", i.columns[1])
    foreach(c->print(io, ",", i.columns[c]), 2:length(i.columns))
    print(io, ") VALUES(?")
    foreach(c->print(io, ",?"), 2:length(i.values))
    println(io, ");")
end
##############################
end


#i = DBTools.Insert("PAB", ["Line", "StartT", "EndT", "Reason", "StopMins", "Part", "Target", "Operator", "Actual", "Comment"])
#println(i)
#DBTools.set!(i, :Reason, "laser issues")

#DBTools.sql(STDERR, i)
