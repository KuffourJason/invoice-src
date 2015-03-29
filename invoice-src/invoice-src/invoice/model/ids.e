note
	description: "Summary description for {IDS}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	IDS

create
	make

feature{ORDER}

	make
		do
			create ids.make (0)
			next_available := 1
			create available.make (0)
			create sequence.make(0)
		end

feature{NONE}
	ids: ARRAYED_LIST[INTEGER]
	next_available: INTEGER
	available: ARRAYED_QUEUE[INTEGER]
	sequence: ARRAYED_LIST[ INTEGER]

feature{ORDER}

	generate_id: INTEGER
	--returns the next available id
		local
			old_av: INTEGER
		do
			Result := next_available

			old_av := ids.index_of (0, 1)


			if available.count = 0 then
				ids.force (next_available)
				sequence.force (next_available)
				next_available := next_available + 1
			else
				Result := available.item
				available.remove
				ids.at (Result) := Result
				sequence.force (Result)
			end

		end

	clear_id( id:INTEGER )
	--makes the input number an available id
		require
			id > 0
		do
			available.force (id)
			ids.at (id) := 0
			sequence.prune(id)
		end

	valid_id( id: INTEGER): BOOLEAN
	--checks if the id exists. if it does not, it returns false
		do
			Result := ids.has (id)
		end

	get_sequence: ARRAYED_LIST[INTEGER]
		do
			Result := sequence
		end

	available_ids: BOOLEAN
	--checks if there are any available ids
		do
			Result := ids.count < 10000
		end
end
