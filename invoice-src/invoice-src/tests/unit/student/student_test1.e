note
	description: "Summary description for {STUDENT_TEST1}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	STUDENT_TEST1
inherit
	ES_TEST

create
	make

feature {NONE} -- Initialization

	make
			-- Initialization for `Current'.
		do
			add_boolean_case (agent t_add_type)
			add_boolean_case (agent t_add_product)
			add_boolean_case (agent t_add_order)
			add_boolean_case (agent t_invoice)
			add_boolean_case (agent t_cancel)

			add_violation_case_with_tag ("non_empty_string", agent t_type_empty)
			add_violation_case_with_tag ("exists", agent t_non_existing_product)
			add_violation_case_with_tag ("valid_order", agent t_duplicates_in_order)
			add_violation_case_with_tag ("valid_id", agent t_invoiced_already)
			add_violation_case_with_tag ("valid_id", agent t_nothing_to_cancel)
		end


feature

	t_add_type: BOOLEAN
		local
			m: MODEL_ACCESS
		do
			comment("t_add_type: tests whether the add type functionality works and successfully adds the type %N")

			m.m.add_type_update ("xylophone")
			m.m.add_type_update ("walrus")
			m.m.add_type_update ("snake")
			m.m.add_type_update ("frog")
			m.m.add_type_update ("aardvark")
			m.m.add_type_update ("dogs")

			Result := m.m.does_exist ("xylophone") and
					  m.m.does_exist ("walrus") and
					  m.m.does_exist ("snake") and
					  m.m.does_exist ("frog") and
					  m.m.does_exist ("aardvark") and
					  m.m.does_exist ("dogs")

			check Result end

			sub_comment( m.m.out )
		end


	t_type_empty
		local
			m: MODEL_ACCESS
		do
			comment("t_type_empty: adding an empty string as the product type")
			m.m.add_type_update ("")
			sub_comment(m.m.out)
		end


	t_add_product: BOOLEAN
		local
			m: MODEL_ACCESS
			chec: ARRAY[ TUPLE[STRING, INTEGER] ]
		do
			comment("t_add_product: tests whether the add product functionality works and successfully updates product quantity by testing if an order with the exact quantities are present in inventory %N")

			m.m.add_product_update ("snake", 23)
			m.m.add_product_update ("dogs", 437)
			m.m.add_product_update ("frog", 2343)
			m.m.add_product_update ("walrus", 5)
			m.m.add_product_update ("xylophone", 9876)
			m.m.add_product_update ("aardvark", 78)

			chec := << ["snake", 23], ["walrus", 5], ["frog", 2343], ["dogs", 437], ["xylophone", 9876], ["aardvark", 78]>>

			Result := m.m.enough_in_stock (chec)

			Check Result end

			sub_comment(m.m.out)
		end

	t_non_existing_product
		local
			m: MODEL_ACCESS
		do
			comment("t_non_existing_product: Adding a product to a non-existing type")
			m.m.add_product_update ("balloon", 78)
			sub_comment(m.m.out)
		end


	t_add_order: BOOLEAN
		local
			m: MODEL_ACCESS
			chec: ARRAY[ TUPLE[STRING, INTEGER] ]
		do
			comment("t_add_order: tests whether the add order functionality works by adding an order that completely empties the inventory and checking if there is enough quantity in stock to order the same quantities again %N")

			chec := << ["snake", 23], ["walrus", 5], ["frog", 2343], ["dogs", 437], ["xylophone", 9876], ["aardvark", 78]>>
			m.m.add_order_update (chec)

			Result := not m.m.enough_in_stock (chec)
			check Result end

			sub_comment(m.m.out)
		end

	t_duplicates_in_order
		local
			m: MODEL_ACCESS
			chec: ARRAY[ TUPLE[STRING, INTEGER] ]
		do
			comment("t_duplicates_in_order: Adding an order with duplicates in it")
			chec := << ["snake", 23], ["walrus", 5], ["frog", 2343], ["frog", 437], ["xylophone", 9876], ["aardvark", 78]>>
			m.m.add_order_update (chec)
		end

	t_invoice: BOOLEAN
		local
			m: MODEL_ACCESS
		do
			comment("t_invoice: tests whether the invoice functionality works by invoicing order 1 and asserting that it has been invoiced %N")

			Result := m.m.is_invoiced (1)   --Order 1 is not invoiced
			check not Result end

			m.m.invoice_update (1)
			--m.m.invoice_update (0)

			Result := m.m.is_invoiced (1)
			check Result end

			sub_comment(m.m.out)
		end

	t_invoiced_already
		local
			m: MODEL_ACCESS
		do
			comment("t_invoiced_already: Invoicing an already invoiced order")
			m.m.invoice_update (1)
			sub_comment(m.m.out)

		end


	t_cancel: BOOLEAN
		local
			m: MODEL_ACCESS
			chec: ARRAY[ TUPLE[STRING, INTEGER] ]
		do
			comment("t_cancel: tests whether the cancel order functionality works by cancelling an order and checking if the quantities were returned to stock %N")

			chec := << ["snake", 23], ["walrus", 5], ["frog", 2343], ["dogs", 437], ["xylophone", 9876], ["aardvark", 78]>>

			Result := not m.m.enough_in_stock (chec) and m.m.is_invoiced (1) --Assert that there is nothing in stock
			check Result end

			m.m.cancel_order_update (1)
			Result := m.m.enough_in_stock (chec)
			check Result end

			sub_comment( m.m.out )
		end


	t_nothing_to_cancel
		local
			m: MODEL_ACCESS
		do
			comment("t_nothing_to_cancel: Cancelling a non-existant order")
			m.m.cancel_order_update (4)
			sub_comment(m.m.out)
		end

end
