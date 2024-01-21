SELECT datas.id,texts.name,datas.ot,datas.alias,datas.setcode,datas.type,datas.atk,datas.def,datas.level,datas.race,datas.attribute,datas.category FROM datas
INNER JOIN texts
	ON datas.id==texts.id
WHERE type&2147483648>0;

UPDATE datas
SET type=type|33554432
WHERE type&2147483648>0;

SELECT datas.id,texts.name,datas.ot,datas.alias,datas.setcode,datas.type,datas.atk,datas.def,datas.level,datas.race,datas.attribute,datas.category FROM datas
INNER JOIN texts
	ON datas.id==texts.id
WHERE type&2147483648>0;