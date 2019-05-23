module SQLiteTools

using SQLite
using DataArrays

inserts = Dict()
updates = Dict()

export bind!, exebind!, truncate!, table_by, select_all, insert!, missInt, int2date, int2time, key_val, last_insert

missInt(v) = typeof(v) == Missings.Missing ? 0 : convert(Int, v)
int2date(dv) = Date(Dates.UTD(missInt(dv)))
int2time(dv) = DateTime(Dates.UTM(missInt(dv)))
insert!(db, name, sql) = inserts[name] = SQLite.Stmt(db, sql)

bind!(st::SQLite.Stmt, vals::Vector, cols::Vector) = foreach((n)->SQLite.bind!(st, cols[n], vals[n]), 1:length(cols))

bind!(st::SQLite.Stmt, vals::Vector) = foreach((n)->SQLite.bind!(st, n, vals[n]), 1:length(vals))

function exebind!(st::SQLite.Stmt, vals::Vector, cols::Vector)
	bind!(st, vals, cols)
	execute_st(st, vals)
end

function exebind!(st::SQLite.Stmt, vals::Vector)
	bind!(st, vals)
	execute_st(st, vals)
end

function execute_st(st, vals)
	try
		SQLite.execute!(st)
		return true
	catch s
		println(STDERR, "ERR: ", s)
		println(STDERR, "ST: ", vals)
	end
	return false
end

truncate!(db, table::String) = SQLite.query(db, "DELETE FROM $table")

table_by(db, table::String, orderby::String) = SQLite.query(db, "select * from $table Order By $orderby")

bind!(ins::String, coln::Int, val) = SQLite.bind!(inserts[ins], coln, val)

bind!(ins::String, vals::Vector, cols::Vector) = bind!(inserts[ins], vals, cols)

exebind!(ins::String, vals::Vector, cols::Vector) = exebind!(inserts[ins], vals, cols)

exebind!(ins::String, vals::Vector) = exebind!(inserts[ins], vals)

last_insert(db) = SQLite.query(db, "SELECT last_insert_rowid()")[1][1]

function key_val(frame, k, v)
	# assumes the keys are unique - or at least that later rows overwriting earlier ones is what is required
	kv = Dict{typeof(frame[1,k]), typeof(frame[1,v])}()
	foreach(r->kv[frame[r,k]]=frame[r,v], 1:size(frame,1))
	kv
end

function index_by_k(frame, k)
	index = Dict()
	for r in 1:size(frame)
		index[frame[r, k]] = r
	end
	index
end


##########################
end
