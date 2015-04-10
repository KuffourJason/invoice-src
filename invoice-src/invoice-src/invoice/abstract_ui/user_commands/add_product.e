note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class ADD_PRODUCT
inherit
	ADD_PRODUCT_INTERFACE
	redefine add_product end
create
	make
feature -- command
	add_product(a_product: STRING ; quantity: INTEGER)
		local
			m: ERROR_MESSAGES
    	do

    		create m.make_ok

    		if not model.positive_value (quantity) then  --Checks for positve quantity
				create m.make_positive_quantity
				model.set_message (m)

			elseif a_product.is_empty then				--Checks for empty string
				create m.make_not_exists
				model.set_message (m)

			elseif not model.does_exist (a_product) then  --Checks if the product was registered first
				create m.make_not_exists
				model.set_message (m)

			else
				model.set_message (m)
				model.add_product_update (a_product, quantity)
    		end

			container.on_change.notify ([Current])
    	end

end