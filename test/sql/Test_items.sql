CREATE TABLE Test_items (
  Topic           varchar(128),
  ItemId	  smallint unsigned,
  EFDB_Name	  varchar(128),
  IDL_Type        varchar(128),
  Count           smallint unsigned,
  Units           varchar(128),
  Frequency       float,
  Constraints     varchar(128),
  Description     varchar(128),
  PRIMARY KEY (ItemId)
);
