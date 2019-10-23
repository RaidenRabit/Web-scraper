use master
go
DROP DATABASE IF EXISTS Deliveries
go
CREATE DATABASE Deliveries
go
use Deliveries
go

create table ZipCodes(
	ZipCode int Primary key,
	City varchar(max),
	SupportedByCoop bit DEFAULT 0
);

create table DeliveryDays(
  deliveryId int Primary key identity,
  mobileText varchar(max),
  date DateTime,
  text varchar(max),
  active bit,
  inMonth bit,
  cheapestAmount int
);

create table Slots(
	slotId int Primary key identity,
	fromHour int,
	dlvModeId varchar(max),
	isFlexDelivery bit,
	text varchar(max),
	isMealKitEligible bit,
	amountMinor int,
	amount int,
	amountText varchar(max),
	mobileAmountText varchar(max),
	soldOut bit,
	isDiscounted bit,
	isDeliverable bit,
	isAlternativeDeadline bit
);

create table ZipCodesToDeliveries(
	ZipCode int foreign key references ZipCodes(ZipCode),
	DeliveryId int foreign key references DeliveryDays(deliveryId),
	Primary key (ZipCode, DeliveryId)
);

create table DeliveriesToSlots(
	deliveryId int Foreign key references DeliveryDays(deliveryId),
	slotId int FOREIGN KEY REFERENCES Slots(slotId)
);
go

-- stored procedures

DROP PROCEDURE IF EXISTS AddDelivery
GO
CREATE PROCEDURE AddDelivery   @zipCode int, @mobileText varchar(max), @date DateTime, @text varchar(max), 
								@active bit, @inMonth bit, @cheapestAmount int
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	BEGIN TRANSACTION
	DECLARE @asdf INT;
	IF EXISTS(SELECT deliveryId FROM DeliveryDays WHERE mobileText = @mobileText AND date = @date AND text = @text AND active = @active
	AND inMonth = @inMonth AND cheapestAmount = @cheapestAmount)
		BEGIN
			SET @asdf = (SELECT deliveryId FROM DeliveryDays WHERE mobileText = @mobileText AND date = @date AND text = @text AND active = @active
	AND inMonth = @inMonth AND cheapestAmount = @cheapestAmount)
	IF EXISTS(SELECT * FROM ZipCodesToDeliveries WHERE DeliveryId = @asdf AND ZipCode = @zipCode)
			BEGIN
			ROLLBACK
			SELECT 0 as deliveryId
			END
		ELSE
			BEGIN
			INSERT INTO ZipCodesToDeliveries (DeliveryId, ZipCode) VALUES (@asdf, @zipCode);
			COMMIT
			SELECT @asdf as deliveryId
			END
		END
	ELSE
		BEGIN
		DECLARE @newId int;
		INSERT INTO DeliveryDays(active, cheapestAmount, date, inMonth, mobileText, text)
		VALUES (@active, @cheapestAmount, @date, @inMonth, @mobileText, @text);
		SET @newId = SCOPE_IDENTITY()
		IF EXISTS(SELECT * FROM ZipCodesToDeliveries WHERE DeliveryId = @newId AND ZipCode = @zipCode)
			BEGIN
			ROLLBACK
			SELECT 0 as deliveryId
			END
		ELSE
			BEGIN
			INSERT INTO ZipCodesToDeliveries (DeliveryId, ZipCode) VALUES (@newId, @zipCode);
			COMMIT
			SELECT @newId as deliveryId
			END
		END
END
GO

DROP PROCEDURE IF EXISTS AddSlots
GO
CREATE PROCEDURE AddSlots   @deliveryId int, @fromHour int, @dlvModeId varchar(max), @isFlexDelivery bit, @text varchar(max), @isMealKitEligible bit,
							@amountMinor int, @amount int, @amountText varchar(max), @mobileAmountText varchar(max), @soldOut bit,
							@isDiscounted bit, @isDeliverable bit, @isAlternativeDeadline bit
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
	BEGIN TRANSACTION
	DECLARE @asdf INT;

	IF EXISTS(SELECT slotId FROM Slots WHERE fromHour = @fromHour AND dlvModeId = @dlvModeId AND isFlexDelivery = @isFlexDelivery AND
											text = @text AND isMealKitEligible = @isMealKitEligible AND amountMinor = @amountMinor AND
											amount = @amount AND amountText = @amountText AND mobileAmountText = @mobileAmountText AND
											soldOut = @soldOut AND isDiscounted = @isDiscounted AND isAlternativeDeadline = @isAlternativeDeadline)
		BEGIN
		SET @asdf = (SELECT slotId FROM Slots WHERE fromHour = @fromHour AND dlvModeId = @dlvModeId AND isFlexDelivery = @isFlexDelivery AND
											text = @text AND isMealKitEligible = @isMealKitEligible AND amountMinor = @amountMinor AND
											amount = @amount AND amountText = @amountText AND mobileAmountText = @mobileAmountText AND
											soldOut = @soldOut AND isDiscounted = @isDiscounted AND isAlternativeDeadline = @isAlternativeDeadline);
		IF EXISTS(SELECT * FROM DeliveriesToSlots WHERE deliveryId = @deliveryId AND slotId = @asdf)
			BEGIN
			ROLLBACK
			SELECT 0 as slotId
			END
		ELSE
			BEGIN
			INSERT INTO DeliveriesToSlots(deliveryId, slotId) VALUES (@deliveryId, @asdf);
			COMMIT
			SELECT @asdf as slotId
			END
		END
	ELSE
		BEGIN
		DECLARE @newId INT;
		INSERT INTO Slots(text, soldOut, mobileAmountText, isMealKitEligible, isFlexDelivery, isDiscounted, isDeliverable, isAlternativeDeadline,
		fromHour, dlvModeId, amountText, amountMinor, amount)
		VALUES (@text, @soldOut, @mobileAmountText, @isMealKitEligible, @isFlexDelivery, @isDiscounted, @isDeliverable, @isAlternativeDeadline,
		@fromHour, @dlvModeId, @amountText, @amountMinor, @amount);
		SET @newId = SCOPE_IDENTITY()
		IF EXISTS(SELECT * FROM DeliveriesToSlots WHERE deliveryId = @deliveryId AND slotId = @newId)
			BEGIN
			ROLLBACK
			SELECT 0 as slotId
			END
		ELSE
			BEGIN
			INSERT INTO DeliveriesToSlots(deliveryId, slotId) VALUES (@deliveryId, @newId);
			COMMIT
			SELECT @newId as slotId
			END
		END
END
GO

-- trigger

CREATE OR ALTER TRIGGER SupportedByCoop
ON ZipCodesToDeliveries
FOR INSERT
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	BEGIN TRANSACTION
	DECLARE @ZipCode INT;
	SELECT @ZipCode = ZipCode FROM INSERTED
	UPDATE ZipCodes SET SupportedByCoop = 1 WHERE ZipCode = @ZipCode
	COMMIT
End
GO

-- seed data for zipcodes

INSERT INTO ZipCodes (ZipCode,City) VALUES ('1050','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1051','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1052','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1053','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1054','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1055','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1056','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1057','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1058','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1059','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1060','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1061','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1062','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1063','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1064','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1065','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1066','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1067','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1068','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1069','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1070','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1071','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1072','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1073','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1074','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1092','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1093','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1095','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1098','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1100','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1101','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1102','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1103','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1104','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1105','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1106','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1107','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1110','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1111','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1112','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1113','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1114','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1115','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1116','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1117','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1118','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1119','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1120','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1121','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1122','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1123','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1124','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1125','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1126','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1127','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1128','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1129','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1130','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1131','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1140','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1147','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1148','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1150','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1151','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1152','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1153','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1154','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1155','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1156','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1157','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1158','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1159','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1160','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1161','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1162','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1163','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1164','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1165','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1166','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1167','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1168','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1169','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1170','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1171','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1172','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1173','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1174','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1175','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1200','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1201','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1202','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1203','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1204','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1205','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1206','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1207','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1208','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1209','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1210','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1211','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1212','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1213','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1214','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1215','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1216','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1217','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1218','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1219','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1220','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1221','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1240','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1250','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1251','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1253','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1254','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1255','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1256','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1257','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1259','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1260','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1261','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1263','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1264','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1265','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1266','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1267','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1268','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1270','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1271','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1300','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1301','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1302','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1303','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1304','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1306','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1307','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1308','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1309','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1310','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1311','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1312','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1313','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1314','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1315','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1316','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1317','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1318','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1319','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1320','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1321','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1322','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1323','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1324','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1325','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1326','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1327','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1328','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1329','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1350','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1352','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1353','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1354','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1355','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1356','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1357','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1358','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1359','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1360','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1361','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1362','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1363','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1364','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1365','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1366','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1367','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1368','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1369','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1370','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1371','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1400','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1401','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1402','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1403','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1404','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1406','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1407','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1408','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1409','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1410','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1411','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1412','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1413','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1414','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1415','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1416','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1417','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1418','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1419','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1420','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1421','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1422','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1423','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1424','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1425','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1426','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1427','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1428','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1429','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1430','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1431','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1432','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1433','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1434','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1435','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1436','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1437','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1438','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1439','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1440','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1441','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1448','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1450','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1451','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1452','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1453','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1454','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1455','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1456','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1457','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1458','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1459','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1460','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1461','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1462','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1463','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1464','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1465','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1466','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1467','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1468','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1470','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1471','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1472','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1473','København K');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1500','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1501','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1502','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1503','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1504','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1505','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1506','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1507','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1508','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1509','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1510','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1532','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1533','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1550','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1551','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1552','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1553','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1554','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1555','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1556','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1557','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1558','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1559','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1560','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1561','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1562','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1563','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1564','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1567','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1568','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1569','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1570','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1571','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1572','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1573','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1574','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1575','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1576','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1577','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1592','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1599','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1600','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1601','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1602','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1603','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1604','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1605','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1606','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1607','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1608','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1609','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1610','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1611','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1612','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1613','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1614','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1615','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1616','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1617','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1618','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1619','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1620','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1621','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1622','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1623','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1624','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1630','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1631','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1632','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1633','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1634','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1635','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1650','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1651','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1652','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1653','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1654','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1655','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1656','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1657','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1658','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1659','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1660','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1661','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1662','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1663','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1664','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1665','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1666','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1667','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1668','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1669','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1670','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1671','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1672','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1673','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1674','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1675','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1676','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1677','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1699','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1700','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1701','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1702','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1703','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1704','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1705','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1706','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1707','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1708','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1709','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1710','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1711','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1712','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1713','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1714','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1715','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1716','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1717','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1718','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1719','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1720','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1721','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1722','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1723','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1724','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1725','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1726','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1727','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1728','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1729','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1730','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1731','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1732','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1733','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1734','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1735','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1736','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1737','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1738','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1739','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1749','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1750','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1751','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1752','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1753','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1754','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1755','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1756','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1757','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1758','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1759','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1760','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1761','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1762','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1763','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1764','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1765','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1766','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1770','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1771','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1772','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1773','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1774','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1775','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1777','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1780','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1782','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1785','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1786','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1787','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1790','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1799','København V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1800','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1801','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1802','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1803','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1804','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1805','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1806','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1807','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1808','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1809','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1810','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1811','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1812','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1813','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1814','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1815','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1816','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1817','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1818','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1819','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1820','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1822','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1823','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1824','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1825','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1826','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1827','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1828','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1829','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1835','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1850','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1851','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1852','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1853','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1854','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1855','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1856','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1857','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1860','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1861','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1862','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1863','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1864','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1865','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1866','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1867','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1868','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1870','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1871','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1872','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1873','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1874','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1875','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1876','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1877','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1878','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1879','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1900','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1901','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1902','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1903','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1904','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1905','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1906','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1908','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1909','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1910','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1911','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1912','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1913','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1914','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1915','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1916','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1917','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1920','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1921','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1922','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1923','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1924','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1925','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1926','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1927','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1928','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1931','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1950','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1951','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1952','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1953','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1954','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1955','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1956','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1957','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1958','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1959','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1960','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1961','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1962','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1963','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1964','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1965','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1966','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1967','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1970','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1971','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1972','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1973','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('1974','Frederiksberg C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2000','Frederiksberg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2100','København Ø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2150','Nordhavn');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2200','København N');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2300','København S');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2400','København NV');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2450','København SV');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2500','Valby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2600','Glostrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2605','Brøndby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2610','Rødovre');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2620','Albertslund');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2625','Vallensbæk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2630','Taastrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2635','Ishøj');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2640','Hedehusene');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2650','Hvidovre');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2660','Brøndby Strand');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2665','Vallensbæk Strand');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2670','Greve');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2680','Solrød Strand');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2690','Karlslunde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2700','Brønshøj');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2720','Vanløse');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2730','Herlev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2740','Skovlunde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2750','Ballerup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2760','Måløv');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2765','Smørum');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2770','Kastrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2791','Dragør');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2800','Kongens Lyngby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2820','Gentofte');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2830','Virum');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2840','Holte');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2850','Nærum');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2860','Søborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2870','Dyssegård');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2880','Bagsværd');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2900','Hellerup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2920','Charlottenlund');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2930','Klampenborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2942','Skodsborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2950','Vedbæk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2960','Rungsted Kyst');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2970','Hørsholm');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2980','Kokkedal');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('2990','Nivå');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3000','Helsingør');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3050','Humlebæk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3060','Espergærde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3070','Snekkersten');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3080','Tikøb');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3100','Hornbæk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3120','Dronningmølle');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3140','Ålsgårde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3150','Hellebæk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3200','Helsinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3210','Vejby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3220','Tisvildeleje');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3230','Græsted');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3250','Gilleleje');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3300','Frederiksværk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3310','Ølsted');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3320','Skævinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3330','Gørløse');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3360','Liseleje');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3370','Melby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3390','Hundested');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3400','Hillerød');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3450','Allerød');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3460','Birkerød');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3480','Fredensborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3490','Kvistgård');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3500','Værløse');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3520','Farum');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3540','Lynge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3550','Slangerup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3600','Frederikssund');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3630','Jægerspris');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3650','Ølstykke');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3660','Stenløse');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3670','Veksø Sjælland');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3700','Rønne');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3720','Aakirkeby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3730','Nexø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3740','Svaneke');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3751','Østermarie');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3760','Gudhjem');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3770','Allinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3782','Klemensker');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('3790','Hasle');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4000','Roskilde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4030','Tune');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4040','Jyllinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4050','Skibby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4060','Kirke Såby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4070','Kirke Hyllinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4100','Ringsted');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4130','Viby Sjælland');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4140','Borup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4160','Herlufmagle');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4171','Glumsø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4173','Fjenneslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4174','Jystrup Midtsj');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4180','Sorø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4190','Munke Bjergby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4200','Slagelse');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4220','Korsør');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4230','Skælskør');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4241','Vemmelev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4242','Boeslunde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4243','Rude');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4244','Agersø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4245','Omø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4250','Fuglebjerg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4261','Dalmose');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4262','Sandved');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4270','Høng');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4281','Gørlev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4291','Ruds Vedby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4293','Dianalund');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4295','Stenlille');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4296','Nyrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4300','Holbæk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4305','Orø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4320','Lejre');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4330','Hvalsø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4340','Tølløse');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4350','Ugerløse');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4360','Kirke Eskilstrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4370','Store Merløse');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4390','Vipperød');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4400','Kalundborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4420','Regstrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4440','Mørkøv');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4450','Jyderup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4460','Snertinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4470','Svebølle');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4480','Store Fuglede');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4490','Jerslev Sjælland');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4500','Nykøbing Sj');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4520','Svinninge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4532','Gislinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4534','Hørve');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4540','Fårevejle');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4550','Asnæs');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4560','Vig');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4571','Grevinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4572','Nørre Asmindrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4573','Højby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4581','Rørvig');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4583','Sjællands Odde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4591','Føllenslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4592','Sejerø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4593','Eskebjerg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4600','Køge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4621','Gadstrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4622','Havdrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4623','Lille Skensved');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4632','Bjæverskov');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4640','Faxe');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4652','Hårlev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4653','Karise');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4654','Faxe Ladeplads');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4660','Store Heddinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4671','Strøby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4672','Klippinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4673','Rødvig Stevns');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4681','Herfølge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4682','Tureby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4683','Rønnede');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4684','Holmegaard');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4690','Haslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4700','Næstved');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4720','Præstø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4733','Tappernøje');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4735','Mern');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4736','Karrebæksminde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4750','Lundby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4760','Vordingborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4771','Kalvehave');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4772','Langebæk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4773','Stensved');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4780','Stege');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4791','Borre');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4792','Askeby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4793','Bogø By');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4800','Nykøbing F');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4840','Nørre Alslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4850','Stubbekøbing');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4862','Guldborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4863','Eskilstrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4871','Horbelev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4872','Idestrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4873','Væggerløse');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4874','Gedser');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4880','Nysted');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4891','Toreby L');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4892','Kettinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4894','Øster Ulslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4895','Errindlev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4900','Nakskov');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4912','Harpelunde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4913','Horslunde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4920','Søllested');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4930','Maribo');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4941','Bandholm');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4942','Askø og Lilleø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4943','Torrig L');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4944','Fejø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4945','Femø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4951','Nørreballe');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4952','Stokkemarke');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4953','Vesterborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4960','Holeby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4970','Rødby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4983','Dannemare');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('4990','Sakskøbing');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5000','Odense C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5200','Odense V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5210','Odense NV');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5220','Odense SØ');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5230','Odense M');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5240','Odense NØ');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5250','Odense SV');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5260','Odense S');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5270','Odense N');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5290','Marslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5300','Kerteminde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5320','Agedrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5330','Munkebo');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5350','Rynkeby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5370','Mesinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5380','Dalby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5390','Martofte');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5400','Bogense');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5450','Otterup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5462','Morud');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5463','Harndrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5464','Brenderup Fyn');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5466','Asperup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5471','Søndersø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5474','Veflinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5485','Skamby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5491','Blommenslyst');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5492','Vissenbjerg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5500','Middelfart');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5540','Ullerslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5550','Langeskov');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5560','Aarup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5580','Nørre Aaby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5591','Gelsted');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5592','Ejby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5600','Faaborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5601','Lyø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5602','Avernakø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5603','Bjørnø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5610','Assens');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5620','Glamsbjerg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5631','Ebberup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5642','Millinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5672','Broby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5683','Haarby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5690','Tommerup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5700','Svendborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5750','Ringe');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5762','Vester Skerninge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5771','Stenstrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5772','Kværndrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5792','Årslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5800','Nyborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5853','Ørbæk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5854','Gislev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5856','Ryslinge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5863','Ferritslev Fyn');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5871','Frørup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5874','Hesselager');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5881','Skårup Fyn');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5882','Vejstrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5883','Oure');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5884','Gudme');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5892','Gudbjerg Sydfyn');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5900','Rudkøbing');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5932','Humble');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5935','Bagenkop');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5943','Strynø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5953','Tranekær');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5960','Marstal');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5965','Birkholm');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5970','Ærøskøbing');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('5985','Søby Ærø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6000','Kolding');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6040','Egtved');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6051','Almind');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6052','Viuf');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6064','Jordrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6070','Christiansfeld');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6091','Bjert');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6092','Sønder Stenderup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6093','Sjølund');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6094','Hejls');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6100','Haderslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6200','Aabenraa');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6210','Barsø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6230','Rødekro');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6240','Løgumkloster');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6261','Bredebro');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6270','Tønder');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6280','Højer');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6300','Gråsten');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6310','Broager');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6320','Egernsund');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6330','Padborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6340','Kruså');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6360','Tinglev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6372','Bylderup-Bov');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6392','Bolderslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6400','Sønderborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6430','Nordborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6440','Augustenborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6470','Sydals');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6500','Vojens');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6510','Gram');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6520','Toftlund');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6534','Agerskov');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6535','Branderup J');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6541','Bevtoft');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6560','Sommersted');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6580','Vamdrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6600','Vejen');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6621','Gesten');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6622','Bække');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6623','Vorbasse');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6630','Rødding');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6640','Lunderskov');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6650','Brørup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6660','Lintrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6670','Holsted');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6682','Hovborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6683','Føvling');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6690','Gørding');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6700','Esbjerg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6705','Esbjerg Ø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6710','Esbjerg V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6715','Esbjerg N');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6720','Fanø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6731','Tjæreborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6740','Bramming');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6752','Glejbjerg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6753','Agerbæk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6760','Ribe');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6771','Gredstedbro');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6780','Skærbæk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6792','Rømø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6800','Varde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6818','Årre');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6823','Ansager');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6830','Nørre Nebel');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6840','Oksbøl');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6851','Janderup Vestj');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6852','Billum');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6853','Vejers Strand');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6854','Henne');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6855','Outrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6857','Blåvand');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6862','Tistrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6870','Ølgod');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6880','Tarm');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6893','Hemmet');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6900','Skjern');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6920','Videbæk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6933','Kibæk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6940','Lem St');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6950','Ringkøbing');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6960','Hvide Sande');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6971','Spjald');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6973','Ørnhøj');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6980','Tim');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('6990','Ulfborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7000','Fredericia');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7080','Børkop');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7100','Vejle');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7120','Vejle Øst');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7130','Juelsminde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7140','Stouby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7150','Barrit');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7160','Tørring');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7171','Uldum');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7173','Vonge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7182','Bredsten');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7183','Randbøl');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7184','Vandel');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7190','Billund');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7200','Grindsted');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7250','Hejnsvig');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7260','Sønder Omme');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7270','Stakroge');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7280','Sønder Felding');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7300','Jelling');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7321','Gadbjerg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7323','Give');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7330','Brande');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7361','Ejstrupholm');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7362','Hampen');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7400','Herning');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7430','Ikast');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7441','Bording');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7442','Engesvang');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7451','Sunds');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7470','Karup J');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7480','Vildbjerg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7490','Aulum');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7500','Holstebro');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7540','Haderup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7550','Sørvad');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7560','Hjerm');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7570','Vemb');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7600','Struer');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7620','Lemvig');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7650','Bøvlingbjerg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7660','Bækmarksbro');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7673','Harboøre');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7680','Thyborøn');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7700','Thisted');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7730','Hanstholm');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7741','Frøstrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7742','Vesløs');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7752','Snedsted');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7755','Bedsted Thy');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7760','Hurup Thy');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7770','Vestervig');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7790','Thyholm');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7800','Skive');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7830','Vinderup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7840','Højslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7850','Stoholm Jyll');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7860','Spøttrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7870','Roslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7884','Fur');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7900','Nykøbing M');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7950','Erslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7960','Karby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7970','Redsted M');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7980','Vils');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('7990','Øster Assels');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8000','Aarhus C');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8200','Aarhus N');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8210','Aarhus V');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8220','Brabrand');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8230','Åbyhøj');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8240','Risskov');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8250','Egå');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8260','Viby J');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8270','Højbjerg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8300','Odder');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8305','Samsø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8310','Tranbjerg J');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8320','Mårslet');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8330','Beder');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8340','Malling');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8350','Hundslund');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8355','Solbjerg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8361','Hasselager');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8362','Hørning');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8370','Hadsten');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8380','Trige');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8381','Tilst');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8382','Hinnerup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8400','Ebeltoft');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8410','Rønde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8420','Knebel');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8444','Balle');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8450','Hammel');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8462','Harlev J');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8464','Galten');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8471','Sabro');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8472','Sporup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8500','Grenaa');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8520','Lystrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8530','Hjortshøj');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8541','Skødstrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8543','Hornslet');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8544','Mørke');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8550','Ryomgård');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8560','Kolind');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8570','Trustrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8581','Nimtofte');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8585','Glesborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8586','Ørum Djurs');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8592','Anholt');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8600','Silkeborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8620','Kjellerup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8632','Lemming');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8641','Sorring');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8643','Ans By');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8653','Them');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8654','Bryrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8660','Skanderborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8670','Låsby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8680','Ry');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8700','Horsens');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8721','Daugård');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8722','Hedensted');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8723','Løsning');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8732','Hovedgård');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8740','Brædstrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8751','Gedved');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8752','Østbirk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8762','Flemming');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8763','Rask Mølle');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8765','Klovborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8766','Nørre Snede');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8781','Stenderup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8783','Hornsyld');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8800','Viborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8830','Tjele');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8831','Løgstrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8832','Skals');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8840','Rødkærsbro');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8850','Bjerringbro');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8860','Ulstrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8870','Langå');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8881','Thorsø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8882','Fårvang');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8883','Gjern');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8900','Randers');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8920','Randers NV');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8930','Randers NØ');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8940','Randers SV');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8950','Ørsted');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8960','Randers SØ');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8961','Allingåbro');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8963','Auning');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8970','Havndal');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8981','Spentrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8983','Gjerlev J');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('8990','Fårup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9000','Aalborg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9200','Aalborg SV');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9210','Aalborg SØ');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9220','Aalborg Øst');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9230','Svenstrup J');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9240','Nibe');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9260','Gistrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9270','Klarup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9280','Storvorde');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9293','Kongerslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9300','Sæby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9310','Vodskov');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9320','Hjallerup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9330','Dronninglund');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9340','Asaa');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9352','Dybvad');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9362','Gandrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9370','Hals');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9380','Vestbjerg');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9381','Sulsted');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9382','Tylstrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9400','Nørresundby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9430','Vadum');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9440','Aabybro');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9460','Brovst');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9480','Løkken');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9490','Pandrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9492','Blokhus');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9493','Saltum');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9500','Hobro');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9510','Arden');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9520','Skørping');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9530','Støvring');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9541','Suldrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9550','Mariager');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9560','Hadsund');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9574','Bælum');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9575','Terndrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9600','Aars');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9610','Nørager');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9620','Aalestrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9631','Gedsted');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9632','Møldrup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9640','Farsø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9670','Løgstør');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9681','Ranum');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9690','Fjerritslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9700','Brønderslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9740','Jerslev J');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9750','Østervrå');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9760','Vrå');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9800','Hjørring');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9830','Tårs');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9850','Hirtshals');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9870','Sindal');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9881','Bindslev');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9900','Frederikshavn');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9940','Læsø');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9970','Strandby');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9981','Jerup');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9982','Ålbæk');
INSERT INTO ZipCodes (ZipCode,City) VALUES ('9990','Skagen');
