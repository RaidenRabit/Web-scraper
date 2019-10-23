DROP DATABASE IF EXISTS Deliveries;
CREATE DATABASE Deliveries
create table DeliveryDays(
  deliveryId int Primary key identity,
  zipCode int,
  index int,
  mobileText varchar(max),
  date DateTime,
  text varchar(max),
  active bit,
  inMonth bit,
  cheapestAmount int
);
go
create table Slots(
slotId int Primary key identity,
zipCode int FOREIGN KEY REFERENCES DeliveryDays(zipCode),
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
)
