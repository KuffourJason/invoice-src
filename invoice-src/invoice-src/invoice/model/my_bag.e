note
	description: "Summary description for {MY_BAG}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MY_BAG[G -> {HASHABLE, COMPARABLE}]
inherit
	ADT_BAG[G]

create
	make_empty,
	make_from_tupled_array

convert
	make_from_tupled_array ({attached ARRAY [attached TUPLE [x: G; y: INTEGER]]} )

feature

	make_empty
		do
			create bag.make (0)
		end

	make_from_tupled_array (a_array: ARRAY [TUPLE [x: G; y: INTEGER]])
		local
			item: INTEGER
		do
			create bag.make (0)

			from
				item := 1
			until
				item > a_array.count
			loop
				if bag.has (a_array[item].x) then
					Current.extend (a_array[item].x, a_array[item].y)
				else
					bag.force (a_array[item].y, a_array[item].x)
				end
				item := item + 1
			end
		end

feature{NONE}
	bag: HASH_TABLE[INTEGER, G]

feature --commands

	add_all (other: like Current)
		local
			int: INTEGER
			loc: ARRAY[G]
		do
			loc := other.domain
			from
				int := 1
			until
				int > loc.count
			loop
				Current.extend (loc[int], other.occurrences (loc[int]))
				int := int + 1
			end
		end

	extend (a_key: G; a_quantity: INTEGER_32)
		do
			if bag.has (a_key) then
				bag.at (a_key) := bag.at (a_key) + a_quantity
			else
				bag.force (a_quantity, a_key)
			end
		end

	remove (a_key: G; a_quantity: INTEGER_32)
		do
			if bag.has (a_key) then
				bag.at (a_key) := bag.at (a_key) - a_quantity

				if bag.at (a_key) <= 0 then
					bag.remove (a_key)
				end
			end
		end

	remove_all (other: like Current)
		local
			int: INTEGER
			loc: ARRAY[G]
		do
			loc := other.domain
			from
				int := 1
			until
				int > loc.count
			loop
				Current.remove (loc[int], other.occurrences (loc[int]))
				int := int + 1
			end
		end

feature --queries

	bag_equal alias "|=|" (other:like Current): BOOLEAN
		local
			index: INTEGER
		do
			Result := Current.domain.count = other.domain.count

			from
				index := 1
			until
				index > domain.count or not Result
			loop
				Result := domain[index] ~ other.domain[index]
				index := index + 1
			end

		end

	count: INTEGER_32
		do
			Result := bag.count
		end

	domain: ARRAY[G]
		do
			Result := sort( bag.current_keys )
			Result.compare_objects
		end

	is_nonnegative (a_array: ARRAY [TUPLE [x: G; y: INTEGER]]): BOOLEAN
		local
			int: INTEGER
		do
			Result := true
			from
				int := 1
			until
				int > a_array.count or not Result
			loop
				if a_array[int].y < 0 then
					Result := false
				end
				int := int + 1
			end
		end

	is_subset_of alias "|<:" (other:like Current): BOOLEAN
		local
			int: INTEGER
		do
			if Current.count > other.count then
				Result := false
			else
				from
					int := 1
					Result := true
				until
					int > current.count
				loop
					if other.occurrences (Current.domain[int] ) > 0 then
						Result := Result and true
					else
						Result := false
					end
					int := int + 1
				end
			end
		end

	new_cursor: MY_BAG_ITERATION_CURSOR [G] -- (from ITERABLE)
		do
			create Result.make(bag)
		end

	occurrences alias "[]" (key: G): INTEGER
		do
			Result := 0
			if bag.has (key) then
				Result := bag.at (key)
			end
		end

feature {NONE} --helpers
	sort( in:ARRAY[G] ): ARRAY[G]
		local
			index1: INTEGER
			index2: INTEGER
			sorted: ARRAY[G]
			done: ARRAY[INTEGER]
			store: INTEGER
			curr: G
		do
			create sorted.make_empty
			create done.make_empty

			from
				index1 := 1
			until
				index1 > in.count
			loop
				curr := in[1]
				store := 1

				from
					index2 := 1
				until
					index2 > in.count
				loop
					if in[index2] < curr and not done.has (index2) or (done.has (store)  and in[index2] > curr)  then
						curr := in[index2]
						store := index2
					end
					if index2 = in.count and not done.has (store) then
						done.force (store, index1)
					end

					index2 := index2 + 1
				end

				sorted.force (curr, index1)
				index1 := index1 + 1
			end
			Result := sorted
		end

end
