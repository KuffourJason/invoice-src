note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class CANCEL_ORDER
inherit
	CANCEL_ORDER_INTERFACE
	redefine cancel_order end
create
	make
feature -- command
	cancel_order(order_id: INTEGER)
		local
			m: ERROR_MESSAGES
    	do
			create m.make_ok

			if not model.positive_value (order_id)  then		-- checks if the order_id exists
				create m.make_invalid_id
				model.set_message (m)

			elseif not model.valid_order_id (order_id) then		-- checks if the order_id exists
				create m.make_invalid_id
				model.set_message (m) 

			else
				model.set_message (m)
				model.cancel_order_update (order_id)
			end

			container.on_change.notify ([Current])
    	end

end