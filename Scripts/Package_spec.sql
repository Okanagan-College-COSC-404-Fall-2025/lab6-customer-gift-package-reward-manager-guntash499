CREATE OR REPLACE PACKAGE customer_manager AS
    FUNCTION get_total_purchase(p_customer_id NUMBER)
        RETURN NUMBER;

    PROCEDURE assign_gifts_to_all;

    PROCEDURE display_results;  
END customer_manager;
/
