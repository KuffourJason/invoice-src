note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class ADD_TYPE
inherit
	ADD_TYPE_INTERFACE
	redefine add_type end
create
	make
feature -- command
	add_type(product_id: STRING)
		local
			m : ERROR_MESSAGES
    	do
			if product_id.is_empty then --checks for empty string
				create m.make_empty_string
				model.set_message (m)

			elseif model.does_exist (product_id) then --checks if the product has been registered already
				create m.make_product_exists
				model.set_message (m)

			else					--Everything is good
				create m.make_ok
				model.set_message (m)
				model.add_type_update (product_id)
			end

			container.on_change.notify ([Current])
    	end

end