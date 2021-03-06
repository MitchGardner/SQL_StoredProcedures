USE [DC00CPL]
GO
/****** Object:  StoredProcedure [dbo].[Copy_Sku]    Script Date: 3/22/2022 12:31:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		mgardner
-- Create date: 01312020
-- Description:	Copy existing sku to create a new sku for same client different plant
-- =============================================
ALTER PROCEDURE [dbo].[Copy_Sku] @ExistingSKU char(15), @NewSKU char(15)

AS

declare @DT datetime
set @DT = getdate()

if exists(select 1 from DC01CPL.dbo.SKU_Master where SKU = @ExistingSKU)
insert into DC01CPL..sku_master
select @NewSKU, Class, Env_Code, Storage_Velocity_Code, CC_Velocity_Code, Description1, Description2, Unit_Desc, Bulk_Desc, Bulk_Qty, Bulk_Pick_Flag, Bulk_Loc_Type, Unit_Loc_Type,
Length, Width, Height, Cube, Weight, Serial_Track, Lot_Track, Exp_Date_Track, Mfg_Date_Track, High_Qty, Tie_Qty, Preemptive_Putaway_Flag, Shippable_Unit, cost, @NewSKU,
New_SKU, Age_Control, Rule_ID, Preferred_Zone, PickGen_Rule, getdate(), Update_User_ID, Update_PID, Unit_Pick_Flag, Lot_Override_Allowed 
from DC01CPL..sku_master
where SKU = @ExistingSKU

if exists(select 1 from DC01CPL.dbo.SKU_Master where sku = @ExistingSKU)
insert into DC01CPL..SKUInfo
select @DT, UpdateUserID, UpdatePID, @NewSKU, ProductType, FamilyID, GroupID, CategoryID, GroupingsID, ListPrice, DiscountPercent, RetailPrice, CostFactor, CostLast, CostLIFO,
CostRepl, CostLocal, CostVar, CostVarAdj, CostAvg, Status, SKUSize, SKUColor, SKUStyle, BeginDate, EndDate, Department, GLAcct, Taxable, MSDS, NMFCode, PalletHigh, BandingMult, SKUImage,
user1, user2, user3, user4, user5, @DT, DestroyDate, ReviewDate, QuantityMin, QuantityMax, Increment, StdDesc, SingleSKUFlag, ElectronicItemFlag, ElectronicItem, Thumbnail, 
ProductRecall, SuppressPrint, KitExplosionType, LengthTrack, WidthTrack, HeightTrack, WeightTrack, Attribute1Track, Attribute2Track, AltPickGenRule, DateTemplate, InvoiceTypeID, 
BoxFactor, MUType, MUGroup, NetWeight, CatchWeight, TareWeight, WeightTolerance, MinimumWeightTolerance, AllowOrderByWeight, Taxable2, ExpirationWindow, ExpWindowSet, TransportDays, 
TransDaysSet
from DC01CPL..SKUInfo
where SKU = @ExistingSKU

if exists(select 1 from DC01CPL.dbo.SKUUom where sku = @ExistingSKU)
insert into DC01CPL.dbo.skuuom
select @NewSKU, '01', UoM, UomDesc, Factor, UomType, @DT, UpdateUser, UpdatePID, LocType, Picking, Receiving, Shippable, Height, Width, Length, Weight
from DC01CPL.dbo.SKUUom
where sku = @ExistingSKU
