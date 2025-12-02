CREATE TABLE gift_catalog (
    gift_id       NUMBER PRIMARY KEY,
    min_purchase  NUMBER NOT NULL,
    gifts         gift_list_t
)
NESTED TABLE gifts STORE AS gift_items_nt;
