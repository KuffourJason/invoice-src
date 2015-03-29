note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class INVOICE
inherit
	INVOICE_INTERFACE
	redefine invoice end
create
	make
feature -- command
	invoice(order_id: INTEGER)
		local
			m : ERROR_MESSAGES
    	do
    		create m.make_ok

			if model.positive_value (order_id) and not model.valid_order_id (order_id) then		-- checks if the order_id exists
				create m.make_invalid_id
				model.set_message (m)

			elseif model.is_invoiced(order_id) then		--checks if the order has been invoiced already
				create m.make_invoiced_already
				model.set_message (m)

			else
				model.set_message (m)
				model.invoice_update (order_id)
			end

			container.on_change.notify ([Current])
    	end

end
