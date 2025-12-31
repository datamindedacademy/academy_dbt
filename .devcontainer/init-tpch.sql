
-- ======================
-- Create Schema
-- ======================
CREATE SCHEMA IF NOT EXISTS tpch;

-- ======================
-- Drop Tables if They Exist (in correct dependency order)
-- ======================
DROP TABLE IF EXISTS tpch.lineitem   CASCADE;
DROP TABLE IF EXISTS tpch.orders     CASCADE;
DROP TABLE IF EXISTS tpch.customer   CASCADE;
DROP TABLE IF EXISTS tpch.partsupp   CASCADE;
DROP TABLE IF EXISTS tpch.supplier   CASCADE;
DROP TABLE IF EXISTS tpch.part       CASCADE;
DROP TABLE IF EXISTS tpch.nation     CASCADE;
DROP TABLE IF EXISTS tpch.region     CASCADE;

-- ======================
-- Create Tables
-- ======================
CREATE TABLE tpch.region (
    r_regionkey  INTEGER NOT NULL,
    r_name       CHAR(25) NOT NULL,
    r_comment    VARCHAR(152)
);

CREATE TABLE tpch.nation (
    n_nationkey  INTEGER NOT NULL,
    n_name       CHAR(25) NOT NULL,
    n_regionkey  INTEGER NOT NULL,
    n_comment    VARCHAR(152)
);

CREATE TABLE tpch.part (
    p_partkey     INTEGER NOT NULL,
    p_name        VARCHAR(55) NOT NULL,
    p_mfgr        CHAR(25) NOT NULL,
    p_brand       CHAR(10) NOT NULL,
    p_type        VARCHAR(25) NOT NULL,
    p_size        INTEGER NOT NULL,
    p_container   CHAR(10) NOT NULL,
    p_retailprice DECIMAL(15,2) NOT NULL,
    p_comment     VARCHAR(23) NOT NULL
);

CREATE TABLE tpch.supplier (
    s_suppkey   INTEGER NOT NULL,
    s_name      CHAR(25) NOT NULL,
    s_address   VARCHAR(40) NOT NULL,
    s_nationkey INTEGER NOT NULL,
    s_phone     CHAR(15) NOT NULL,
    s_acctbal   DECIMAL(15,2) NOT NULL,
    s_comment   VARCHAR(101) NOT NULL
);

CREATE TABLE tpch.partsupp (
    ps_partkey    INTEGER NOT NULL,
    ps_suppkey    INTEGER NOT NULL,
    ps_availqty   INTEGER NOT NULL,
    ps_supplycost DECIMAL(15,2) NOT NULL,
    ps_comment    VARCHAR(199) NOT NULL
);

CREATE TABLE tpch.customer (
    c_custkey    INTEGER NOT NULL,
    c_name       VARCHAR(25) NOT NULL,
    c_address    VARCHAR(40) NOT NULL,
    c_nationkey  INTEGER NOT NULL,
    c_phone      CHAR(15) NOT NULL,
    c_acctbal    DECIMAL(15,2) NOT NULL,
    c_mktsegment CHAR(10) NOT NULL,
    c_comment    VARCHAR(117) NOT NULL
);

CREATE TABLE tpch.orders (
    o_orderkey      INTEGER NOT NULL,
    o_custkey       INTEGER NOT NULL,
    o_orderstatus   CHAR(1) NOT NULL,
    o_totalprice    DECIMAL(15,2) NOT NULL,
    o_orderdate     DATE NOT NULL,
    o_orderpriority CHAR(15) NOT NULL,
    o_clerk         CHAR(15) NOT NULL,
    o_shippriority  INTEGER NOT NULL,
    o_comment       VARCHAR(79) NOT NULL
);

CREATE TABLE tpch.lineitem (
    l_orderkey      INTEGER NOT NULL,
    l_partkey       INTEGER NOT NULL,
    l_suppkey       INTEGER NOT NULL,
    l_linenumber    INTEGER NOT NULL,
    l_quantity      DECIMAL(15,2) NOT NULL,
    l_extendedprice DECIMAL(15,2) NOT NULL,
    l_discount      DECIMAL(15,2) NOT NULL,
    l_tax           DECIMAL(15,2) NOT NULL,
    l_returnflag    CHAR(1) NOT NULL,
    l_linestatus    CHAR(1) NOT NULL,
    l_shipdate      DATE NOT NULL,
    l_commitdate    DATE NOT NULL,
    l_receiptdate   DATE NOT NULL,
    l_shipinstruct  CHAR(25) NOT NULL,
    l_shipmode      CHAR(10) NOT NULL,
    l_comment       VARCHAR(44) NOT NULL
);

-- ======================
-- Load Data
-- ======================
\COPY tpch.region   FROM '/tpch-data/region.tbl'   DELIMITER '|' CSV;
\COPY tpch.nation   FROM '/tpch-data/nation.tbl'   DELIMITER '|' CSV;
\COPY tpch.part     FROM '/tpch-data/part.tbl'     DELIMITER '|' CSV;
\COPY tpch.supplier FROM '/tpch-data/supplier.tbl' DELIMITER '|' CSV;
\COPY tpch.partsupp FROM '/tpch-data/partsupp.tbl' DELIMITER '|' CSV;
\COPY tpch.customer FROM '/tpch-data/customer.tbl' DELIMITER '|' CSV;
\COPY tpch.orders   FROM '/tpch-data/orders.tbl'   DELIMITER '|' CSV;
\COPY tpch.lineitem FROM '/tpch-data/lineitem.tbl' DELIMITER '|' CSV;

-- ======================
-- Indexes
-- ======================

-- Primary-key-like indexes
CREATE UNIQUE INDEX IF NOT EXISTS pk_region   ON tpch.region(r_regionkey);
CREATE UNIQUE INDEX IF NOT EXISTS pk_nation   ON tpch.nation(n_nationkey);
CREATE UNIQUE INDEX IF NOT EXISTS pk_part     ON tpch.part(p_partkey);
CREATE UNIQUE INDEX IF NOT EXISTS pk_supplier ON tpch.supplier(s_suppkey);
CREATE UNIQUE INDEX IF NOT EXISTS pk_customer ON tpch.customer(c_custkey);
CREATE UNIQUE INDEX IF NOT EXISTS pk_orders   ON tpch.orders(o_orderkey);
CREATE UNIQUE INDEX IF NOT EXISTS pk_lineitem ON tpch.lineitem(l_orderkey, l_linenumber);

-- Foreign-key support indexes (for joins)
CREATE INDEX IF NOT EXISTS idx_nation_region     ON tpch.nation(n_regionkey);
CREATE INDEX IF NOT EXISTS idx_supplier_nation   ON tpch.supplier(s_nationkey);
CREATE INDEX IF NOT EXISTS idx_customer_nation   ON tpch.customer(c_nationkey);
CREATE INDEX IF NOT EXISTS idx_orders_customer   ON tpch.orders(o_custkey);
CREATE INDEX IF NOT EXISTS idx_partsupp_part     ON tpch.partsupp(ps_partkey);
CREATE INDEX IF NOT EXISTS idx_partsupp_supplier ON tpch.partsupp(ps_suppkey);
CREATE INDEX IF NOT EXISTS idx_lineitem_order    ON tpch.lineitem(l_orderkey);
CREATE INDEX IF NOT EXISTS idx_lineitem_part     ON tpch.lineitem(l_partkey);
CREATE INDEX IF NOT EXISTS idx_lineitem_supplier ON tpch.lineitem(l_suppkey);

-- Common filter indexes for TPC-H queries
CREATE INDEX IF NOT EXISTS idx_orders_orderdate   ON tpch.orders(o_orderdate);
CREATE INDEX IF NOT EXISTS idx_lineitem_shipdate  ON tpch.lineitem(l_shipdate);
CREATE INDEX IF NOT EXISTS idx_lineitem_receiptdate ON tpch.lineitem(l_receiptdate);
CREATE INDEX IF NOT EXISTS idx_customer_mktsegment ON tpch.customer(c_mktsegment);
