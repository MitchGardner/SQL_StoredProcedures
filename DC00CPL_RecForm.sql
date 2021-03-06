USE [DC00CPL]
GO
/****** Object:  StoredProcedure [dbo].[rpt_RecForm]    Script Date: 3/22/2022 12:52:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mitch Gardner
-- Create date: 20200519
-- Description:	Fills in SKU details for Inbound Receiving form
-- =============================================
ALTER PROCEDURE [dbo].[rpt_RecForm] @PONbr char(17)

AS

-- if in interfaceshipmentconfirmationDetail (for EDI and ASN orders) then ASN table else PODetail (manual orders)

declare @SKU char(15)

create table #tmp (SKU char(15), SkuQty int, SKU_Weight decimal(18,4) null, Lot char(15), Allergens char(100))

if exists (select 1 from CDICPL.DBO.InterfaceShipmentConfirmationHeader where orderid = @PONbr)
begin
	insert into #tmp
	select d.SKU,
	Sum(d.UnitsShipped),
	sum(0), -- weight is not needed for Client
	d.LotID,
	null
	from CDICPL.DBO.InterfaceShipmentConfirmationHeader h
	inner join CDICPL.DBO.InterfaceShipmentConfirmationDetail d on d.ExternalUID = h.ExternalUID
	left outer join SKU_Allergens sa on sa.SKU = d.SKU
	where OrderID = @PONbr
	group by 
	d.sku,
	d.LotID
	--select * from #tmp
	--drop table #tmp
End
Else
begin
	insert into #tmp
	select pod.SKU,
	case when Received_Qty = 0 then Ordered_Qty
	else Received_Qty end,
	null,
	'', -- Lot not needed for these clients
	null
	from DC01CPL..PO_Line pod
	left outer join SKU_Allergens sa on sa.SKU = pod.SKU
	where PO_Nbr = @PONbr
end

select rtrim(Sku), -- 0
sum(SkuQty), -- 1
sum(SKU_Weight), -- 2
rtrim(Allergens), --3
rtrim(Lot)  -- 4
from #tmp
group by sku, Lot, Allergens

Drop table #tmp

-- select * from dc01cpl..vendor_part where sku = '67683402'
-- select * from podetail where ponbr = '578121         '
-- select * from poheader where ponbr = '578137'
-- exec rpt_recform '580486'
-- select * from sku_allergens
-- select * from cdicpl..interfaceshipmentconfirmationheader where
-- select * from CDICPL.DBO.InterfaceShipmentConfirmationHeader where orderid = '580486'

-- select * from CDICPL.DBO.InterfaceShipmentConfirmationDetail where externaluid = '22.0081882072'

-- select d.sku, d.unitsshipped, d.lotid from cdicpl..interfaceshipmentconfirmationHeader h left outer join cdicpl..InterfaceShipmentConfirmationDetail d on d.ExternalUID = h.ExternalUID where OrderID = '580486'
