CREATE OR REPLACE PACKAGE BODY customer_manager AS

    FUNCTION choose_gift_package(p_total NUMBER)
        RETURN NUMBER
    IS
        v_best_min  NUMBER;
        v_gift_id   gift_catalog.gift_id%TYPE;
    BEGIN
        SELECT MAX(min_purchase)
        INTO v_best_min
        FROM gift_catalog
        WHERE min_purchase <= p_total;

        CASE
            WHEN v_best_min IS NULL THEN
                RETURN NULL;
            ELSE
                SELECT gift_id
                INTO v_gift_id
                FROM gift_catalog
                WHERE min_purchase = v_best_min;
                RETURN v_gift_id;
        END CASE;
    END choose_gift_package;


    FUNCTION get_total_purchase(p_customer_id NUMBER)
        RETURN NUMBER
    IS
        v_total NUMBER := 0;
    BEGIN
        SELECT SUM(oi.unit_price * oi.quantity)
        INTO v_total
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.customer_id = p_customer_id
          AND o.order_status = 'COMPLETE';

        RETURN NVL(v_total, 0);
    END get_total_purchase;


    PROCEDURE assign_gifts_to_all
    IS
        v_total NUMBER;
        v_gift  NUMBER;
    BEGIN
        FOR c IN (SELECT customer_id, email_address FROM customers) LOOP
            v_total := get_total_purchase(c.customer_id);
            v_gift := choose_gift_package(v_total);

            IF v_gift IS NOT NULL THEN
                INSERT INTO customer_rewards (customer_email, gift_id)
                VALUES (c.email_address, v_gift);
            END IF;
        END LOOP;

        COMMIT;
    END assign_gifts_to_all;


    PROCEDURE display_results
    IS
    BEGIN
        DBMS_OUTPUT.put_line('REWARD_ID | CUSTOMER_EMAIL          | GIFT_ID | REWARD_DATE');
        DBMS_OUTPUT.put_line('------------------------------------------------------------');

        FOR r IN (
            SELECT reward_id,
                   customer_email,
                   gift_id,
                   reward_date
            FROM customer_rewards
            WHERE ROWNUM <= 5
            ORDER BY reward_id
        ) LOOP
            DBMS_OUTPUT.put_line(
                  LPAD(r.reward_id, 8) || ' | '
                || RPAD(r.customer_email, 24) || ' | '
                || LPAD(r.gift_id, 7) || ' | '
                || TO_CHAR(r.reward_date, 'YYYY-MM-DD')
            );
        END LOOP;
    END display_results;

END customer_manager;
/
