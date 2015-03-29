note
	description: "The class abstracts everything relating to an orders including, making orders, cancelling orders and invoicing them. This class uses the ID class to generate valid IDs for it. The order class also returns string representations of all orders, items, and the sequence in which they were ordered"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ORDER

create
	make

feature{MODEL}
	make
		do
			create id_gen.make
			create orders.make_empty
		end

feature{NONE}
	id_gen: ID  --ID generator
	last_added: INTEGER
	orders: ARRAY[ TUPLE[ one:STRING; two:ARRAY[TUPLE[ id: STRING; qu: INTEGER ]] ]  ] --stores an array of orders along with its status

feature{ MODEL}

	add( a_order: ARRAY[ TUPLE[ pid:STRING; no:INTEGER ] ] )
		--adds a_order to the list of orders, and puts it as pending
		require
			non_empty: a_order.count > 0
		local
			int: INTEGER
		do
			int := id_gen.generate_id
			orders.force ( [ "pending", a_order ], int )
			last_added := int
		end

	cancel( id: INTEGER ): ARRAY[ TUPLE[ STRING, INTEGER ] ]
		--returns the cancelled order and makes the id available
		do
			Result := orders[id].two
			orders[id].one := ""
			id_gen.clear_id (id)
		end

	invoice( id: INTEGER )
		--switches order from pending to invoiced
		require
			valid_id: is_id_valid( id)
		do
			orders[id].one := "invoiced"
		ensure
			orders[id].one.is_equal ("invoiced")
		end

	is_invoiced( id: INTEGER ): BOOLEAN
		--checks if an order is already invoiced
		require
			valid_id: is_id_valid( id)
		do
			Result := orders[id].one.is_equal ("invoiced")
		end

	is_id_valid(id: INTEGER): BOOLEAN
		--determines if the id is valid i.e whether it exists or not
		require
			positive_id: id > 0
		do
			Result := id_gen.valid_id (id)
		end

	available_ids: BOOLEAN
		--Returns true for when there are available ids and false otherwise
		do
			Result := id_gen.available_ids
		end

	out_cart: STRING
		--Returns a string representation of all items ordered in each order
		local
			int: INTEGER
			int2: INTEGER
			seq: ARRAYED_LIST[INTEGER]
		do
			seq := id_gen.get_sequence
			int := 1
			create Result.make_empty

			from
				int := 1
			until
				int > seq.count
			loop												--Outer loop, loops through all the orders
				if not orders[seq[int] ].one.is_empty then
					Result := Result + seq[int].out + ": "
					from
						int2 := 1
					until
						int2 > orders[seq[int]].two.count
					loop										--Inner loop, loops through all the items in each order

						if int2 /= 1 then
							Result := Result + ","
						end

						Result := Result + orders[seq[int]].two[int2].id + "->" + orders[seq[int]].two[int2].qu.out
						int2 := int2 + 1
					end
				end
				Result := Result  + "%N               "
				int := int + 1;
			end

			Result.adjust
		end

	out_id: STRING
		--Returns a string representation of the id of the last accessed order
		do
			Result := last_added.out
		end

	out_orders: STRING
		--Returns a string representation of the order ids in the sequence they were generated
		local
			int: INTEGER
			seq: ARRAYED_LIST[INTEGER]
		do
			seq := id_gen.get_sequence
			int := 1
			Result := ""

			from
				int := 1
			until
				int > seq.count
			loop
				if not orders[seq[int]].one.is_empty then
					Result := Result + "," + seq[int].out
				end
				int := int + 1;
			end

			if not Result.is_empty then
				Result.remove (1)
			end
		end

	out_order_state: STRING
		--returns a string of all the current orders and status
		local
			int: INTEGER
			seq: ARRAYED_LIST[INTEGER]
		do
			seq := id_gen.get_sequence
			int := 1
			create Result.make_empty

			from
				int := 1
			until
				int > seq.count
			loop
				if not orders[seq[int]].one.is_empty then
					Result := Result + "," + seq[int].out + "->" + orders[seq[int]].one
				end
				int := int + 1;
			end

			if not Result.is_empty then
				Result.remove (1)
			end
		end

end
