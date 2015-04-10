note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class ADD_ORDER
inherit
	ADD_ORDER_INTERFACE
	redefine add_order end
create
	make
feature -- command
	add_order(a_order: ARRAY[TUPLE[pid: STRING; no: INTEGER]])
		local
			m : ERROR_MESSAGES
    	do

			create m.make_ok

			if not model.available_ids then		--Checks if there are any available ids
				create m.make_ids_done
				model.set_message (m)

			elseif a_order.count = 0 then		--Checks if cart is not empty
				create m.make_empty_cart
				model.set_message (m)

			elseif not model.valid_quantities( a_order) then	--checks if quantities are positive
				create m.make_positive_quantity
				model.set_message (m)

			elseif not model.valid_products (a_order) then		--checks if products are registered
				create m.make_invalid_products
				model.set_message (m)

			elseif not model.is_not_duplicate_products (a_order) then		--checks if there are any duplicate orders
				create m.make_duplicates
				model.set_message (m)

			elseif not model.enough_in_stock (a_order) then		--checks if there is enough in stock
				create m.make_not_enough
				model.set_message (m)

			else
				model.set_message (m)
				model.add_order_update (a_order)
			end

			container.on_change.notify ([Current])
    	end

end