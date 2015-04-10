note
	description: "[ This class handles and abstracts all aspects of the order ID implementation, This includes generating an available ID for each order, storing the sequence in which these IDs were generated and reusing and deleting old generated IDs	."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ID

create
	make

feature{ORDER}

	make
		do
			create ids.make (0)
			next_available := 1
			create available.make (0)
			create sequence.make(0)
			sequence.compare_objects
			available.compare_objects
		end

feature{NONE}
	ids: ARRAYED_LIST[INTEGER]			--Stores a list of used ids
	next_available: INTEGER				--Points to the next available id if previous ids are unavailable
	available: ARRAYED_QUEUE[INTEGER]	--Stores the list of recently made available ids
	sequence: ARRAYED_LIST[ INTEGER]	--Stores the sequence of ids in the order they were assigned

feature{ORDER}

	generate_id: INTEGER
		--returns the next available id number
		do
			Result := next_available

			if available.count = 0 then						--if there are no available old ids, then it is assigned the next available id
				ids.force (next_available)
				sequence.force (next_available)
				next_available := next_available + 1
			else											--If an old id is available then it is assigned
				Result := available.item
				available.remove
				ids.at (Result) := Result
				sequence.force (Result)
			end
		end

	clear_id( id:INTEGER )
		--makes the used id number available for usage
		require
			id_exists: id > 0 and valid_id( id )
		do
			available.force (id)
			ids.at (id) := 0
			sequence.prune_all (id)
		ensure
			ids.at (id) = 0 and not sequence.has (id) and available.has (id)
		end

	valid_id( id: INTEGER): BOOLEAN
		--checks if the id exists ( is being used). if it does not, it returns false
		require
			positive_id: id > 0
		do
			Result := ids.has (id)
		end

	get_sequence: ARRAYED_LIST[INTEGER]
		--returns the order in which the ids were assigned
		do
			Result := sequence
		end

	available_ids: BOOLEAN
		--checks if there are any available ids
		do
			Result := ids.count < 10000
		end
end
