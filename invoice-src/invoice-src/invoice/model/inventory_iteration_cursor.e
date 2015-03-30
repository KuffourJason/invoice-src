note
	description: "Summary description for {MY_BAG_ITERATION_CURSOR}." -- #####INVENTORY_ITERATION_CURSOR  
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MY_BAG_ITERATION_CURSOR[G -> {HASHABLE, COMPARABLE} ]  -- #####INVENTORY_ITERATION_CURSOR  
inherit
	ITERATION_CURSOR[G]

create
	make

feature
	make( in: like container )
		do
			container := in
			container.start
		end

feature{NONE}
	container: HASH_TABLE[INTEGER, G]
	index: INTEGER

feature
	item: G
		do
			Result := container.key_for_iteration
		end

	forth
		do
			container.forth
		end

	after: BOOLEAN
		do
			Result :=  container.after
		end
end
