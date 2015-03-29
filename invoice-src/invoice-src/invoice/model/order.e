note
	description: "Summary description for {ORDER}."
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
	id_gen: IDS
	last_added: INTEGER
	orders: ARRAY[ TUPLE[ one:STRING; two:ARRAY[TUPLE[ id: STRING; qu: INTEGER ]] ]  ] --stores an array of orders along with its status

feature{ MODEL}

	add( a_order: ARRAY[ TUPLE[ pid:STRING; no:INTEGER ] ] )
		--adds a_order to the list of orders, and puts it as pending
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
		do
			orders[id].one := "invoiced"
		end

	is_invoiced( id: INTEGER ): BOOLEAN
		--checks if an order is already invoiced
		do
			Result := orders[id].one.is_equal ("invoiced")
		end

	is_id_valid(id: INTEGER): BOOLEAN
		--determines if the id is valid i.e whether it exists or not
		do
			Result := id_gen.valid_id (id)
		end

	available_ids: BOOLEAN
		do
			Result := id_gen.available_ids
		end

	out_cart: STRING
		local
			int: INTEGER
			int2: INTEGER
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
				if not orders[seq[int] ].one.is_empty then
					Result := Result + seq[int].out + ": "
					from
						int2 := 1
					until
						int2 > orders[seq[int]].two.count
					loop

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
		do
			Result := last_added.out
		end

	out_orders: STRING
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
