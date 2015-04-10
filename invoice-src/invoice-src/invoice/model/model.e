note
	description: "Summary description for {MODEL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MODEL

inherit
	ANY
	redefine out end

create {MODEL_ACCESS}
	make

feature {NONE}
	make
		do
			create inventory.make_empty
			create ordering.make
			create products.make
			products.compare_objects
			create message.make_from_string ("ok")
		end

feature {NONE}
	inventory: INVENTORY[STRING]			 --holds the inventory
	ordering: ORDER
	products: SORTED_TWO_WAY_LIST[ STRING ]  --holds the registered product types
	message: STRING							 --holds the string representation of the system

feature -- model operations

	add_type_update( product_id: STRING )
		--adds product type to the inventory with zero items
		require
			non_empty_string: not product_id.is_empty
			does_not_exist: not does_exist(product_id)
		do
			products.extend (product_id)
		ensure
			exist: does_exist(product_id)
		end


	add_product_update(a_product: STRING; quantity: INTEGER)
		--adds a given quantity of a product to the inventory
		require
			exists: does_exist( a_product )
			positive_value: positive_value( quantity )
		do
			inventory.extend (a_product, quantity )
		ensure
			product_inventory_updated: inventory.has (a_product) and inventory[a_product] >= quantity
		end

	add_order_update (a_order: ARRAY[ TUPLE[ pid:STRING; no:INTEGER ] ] )
		--adds an order to ordering and removes the items ordered from the inventory
		require
			no_more_ids: available_ids
			non_empty_cart: a_order.count > 0
			valid_order: is_not_duplicate_products (a_order)
		local
			remove: INVENTORY[STRING]
		do
			remove := a_order						--order into a sub-inventory
			ordering.add (sort_order(remove) )		--sorts the items in the order and adds it
			inventory.remove_all (remove)			--removes the order from the inventory
		end

	invoice_update(order_id: INTEGER)
		--changes an order from pending to invoiced
		require
			valid_id: valid_order_id( order_id )
			not_invoiced_already: not is_invoiced (order_id)
		do
			ordering.invoice (order_id )
		ensure
			invoiced: ordering.is_invoiced (order_id)
		end

	cancel_order_update(order_id: INTEGER)
		--Cancels an order. Adds the items back to the inventory and makes id available
		require
			valid_id: valid_order_id( order_id )
		local
			return: INVENTORY[STRING]
		do
			return := ordering.cancel (order_id)
			inventory.add_all (return)
		ensure
			id_becomes_available: not ordering.is_id_valid (order_id)
		end

	nothing_update
		do
		end


feature -- queries
	out : STRING
		--Returns a string representation of the current state of orders and inventory
		local
			report, id, product, stock, order, cart, order_state: STRING
		do
			report  	:= "  report:      "	   + message				  + "%N"
			id 			:= "  id:          "	   + ordering.out_id          + "%N"
  			product 	:= "  products:    "       + out_product              + "%N"
			stock   	:= "  stock:       "       + out_stock                + "%N"
			order   	:= "  orders:      "       + ordering.out_orders      + "%N"
			cart    	:= "  carts:       "       + ordering.out_cart        + "%N"
			order_state := "  order_state: "       + ordering.out_order_state

			Result := report + id + product + stock + order + cart + order_state
		end

feature --helper functions for preconditions

	does_exist( product_string: STRING ): BOOLEAN
		--checks if the product type was registered already
		require
			non_empty_string: not product_string.is_empty
		do
			Result := products.has (product_string)
		end

	positive_value( quan: INTEGER ): BOOLEAN
		--determines if the given value is positive
		do
			Result := quan > 0
		end

	valid_products( a_order: ARRAY[TUPLE[pid: STRING; no: INTEGER]] ): BOOLEAN
		--checks if each product exists in the inventory
		require
			cart_not_empty: a_order.count > 0
		local
			i: INTEGER
		do
			from
				i := 1
				Result := true
			until
				i > a_order.count or  not Result
			loop
				Result := does_exist( a_order[i].pid )
				i := i + 1
			end
		end

	valid_quantities( a_order: ARRAY[TUPLE[pid: STRING; no: INTEGER]] ): BOOLEAN
		--checks if each product exists in the inventory
		require
			cart_not_empty: a_order.count > 0
		local
			i: INTEGER
		do
			from
				i := 1
				Result := true
			until
				i > a_order.count or  not Result
			loop
				Result := positive_value( a_order[i].no )
				i := i + 1
			end
		end

	available_ids: BOOLEAN
		do
			Result := ordering.available_ids
		end

	is_not_duplicate_products( a_order: ARRAY[TUPLE[pid: STRING; no: INTEGER]] ): BOOLEAN
		--checks for duplicate orders by first putting the order into a bag and the
		--looping through it and asserting that the quantities inside the bag are equal
		--to the each item in the order. If there were duplicates then an item quantity
		--would be greater
		require
			cart_not_empty: a_order.count > 0
		local
			i: INTEGER
			che: INVENTORY[ STRING ]
		do
			che := a_order

			from
				i := 1
				Result := true
			until
				i > a_order.count or not Result
			loop
				Result := a_order[i].no = che[ a_order[i].pid ]
				i := i + 1
			end
		end

	enough_in_stock( a_order: ARRAY[TUPLE[pid: STRING; no: INTEGER]] ): BOOLEAN
		--checks if there is enough quantities in stock
		require
			cart_not_empty: a_order.count > 0
		local
			i: INTEGER
		do
			from
				i := 1
				Result := true
			until
				i > a_order.count or  not Result
			loop
				Result := inventory[a_order[i].pid] >= a_order[i].no
				i := i + 1
			end
		end

	valid_order_id( id: INTEGER ): BOOLEAN
		--Checks if this id is being used
		do
			Result :=  ordering.is_id_valid (id)
		end

	is_invoiced( id: INTEGER ): BOOLEAN
		--Checks if an order with id has been invoiced
		require
			valid_order_id( id )
		do
			Result := ordering.is_invoiced (id)
		end

	set_message( m: ERROR_MESSAGES)
		--Sets the report message
		do
			message := m.out
		end

feature{NONE} --helper functions for string output
	out_product: STRING
		--Returns a string representation of all the product types
		do
			Result := ""

			from
				products.start
			until
				products.after
			loop
				Result := Result + "," + products.item
				products.forth
			end

			if not Result.is_empty then
				Result.remove (1)
			end
		end

	out_stock: STRING
		--returns a string representation all the items in the inventory
		local
			int: INTEGER
			dom: ARRAY[STRING]
		do
			dom := inventory.domain
			Result := ""

			from
				int := 1
			until
				int > dom.count
			loop
				Result := Result + "," + dom[int].out + "->" + inventory[dom[int]].out
				int := int + 1
			end

			if not Result.is_empty then
				Result.remove (1)
			end
		end

	sort_order( in: INVENTORY[STRING] ):ARRAY[TUPLE[STRING,INTEGER]]
		--Return an array of sorted items. This is used to sort an order
		local
			sor: ARRAY[STRING]
			int: INTEGER
			sorted_order: ARRAY[ TUPLE[STRING, INTEGER ] ]
		do
			sor := in.domain
			create sorted_order.make_empty

			from
				int := 1
			until
				int > sor.count
			loop
				sorted_order.force ([sor[int] ,in.occurrences (sor[int]) ], int )
				int := int + 1
			end

			Result := sorted_order
		end

end

