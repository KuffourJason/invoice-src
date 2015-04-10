note
	description: "This class handles generating the all error messages related to the system"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ERROR_MESSAGES

inherit
	ANY
		redefine out end

create
	make_ok,
	make_empty_string,
	make_product_exists,
	make_positive_quantity,
	make_not_exists,
	make_ids_done,
	make_empty_cart,
	make_invalid_products,
	make_duplicates,
	make_not_enough,
	make_invalid_id,
	make_invoiced_already

feature {NONE} -- Initialization

	make_ok
		do
			err_code := err_ok
		end
	make_empty_string
		do
			err_code := err_empty_string
		end
	make_product_exists
		do
			err_code := err_product_exists
		end
	make_positive_quantity
		do
			err_code := err_positive_quantity
		end
	make_not_exists
		do
			err_code := err_not_exists
		end
	make_ids_done
		do
			err_code := err_ids_don
		end
	make_empty_cart
		do
			err_code := err_empty_cart
		end
	make_invalid_products
		do
			err_code := err_invalid_products
		end
	make_duplicates
		do
			err_code := err_duplicates
		end
	make_not_enough
		do
			err_code := err_not_enough
		end

	make_invalid_id
		do
			err_code := err_invalid_id
		end

	make_invoiced_already
		do
			err_code := err_invoiced
		end

feature -- Output

	out: STRING
			-- string representation of current status message
		do
			Result := err_message [err_code]
		end

feature {NONE} -- Implementation

	err_code: INTEGER

	err_message: ARRAY[STRING]
		once
			create Result.make_filled ("", 1, 12)
			Result.put ("ok",1)
			Result.put ("product type must be non-empty string",2)
			Result.put ("product type already in database",3)
			Result.put ("quantity added must be positive", 4)
			Result.put ("product not in database", 5)
			Result.put ("no more order ids left", 6)
			Result.put ("cart must be non-empty", 7)
			Result.put ("some products in order not valid", 8)
			Result.put ("duplicate products in order array", 9)
			Result.put ("not enough in stock", 10)
			Result.put ("order id is not valid", 11)
			Result.put ("order already invoiced", 12)
		end

	err_ok: INTEGER = 1
	err_empty_string : INTEGER = 2
	err_product_exists: INTEGER = 3
	err_positive_quantity: INTEGER = 4
	err_not_exists: INTEGER = 5
	err_ids_don: INTEGER = 6
	err_empty_cart: INTEGER = 7
	err_invalid_products: INTEGER = 8
	err_duplicates: INTEGER = 9
	err_not_enough: INTEGER = 10
	err_invalid_id: INTEGER = 11
	err_invoiced: INTEGER = 12

end