USE [SymphonyInfiniti]
GO
/****** Object:  View [dbo].[MasterSkus]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MasterSkus]
AS
SELECT  
 [MSKU].[skuID]
,[skuName]
,[skuDescription]
,[status]
,[hasImage] = CAST(ISNULL(SKU.[imageID],0)/ISNULL(SKU.[imageID],1) AS bit)
,[MSKU].[familyID]
,[familyMemberID]
,[FAG].[assortmentGroupID]
,[AGDG].[displayGroupID]
,FSR.[salesEstimation],[FSR].[decile]
,[npiQuantity]
,[uomID]
,[throughput]
,[tvc]
,[unitPrice]
,[safetyStock]
,[bufferManagementPolicyID]
,[skuPropertyID1]
,[skuPropertyID2]
,[skuPropertyID3]
,[skuPropertyID4]
,[skuPropertyID5]
,[skuPropertyID6]
,[skuPropertyID7]
,[custom_num1]
,[custom_num2]
,[custom_num3]
,[custom_num4]
,[custom_num5]
,[custom_num6]
,[custom_num7]
,[custom_num8]
,[custom_num9]
,[custom_num10]
,[custom_txt1]
,[custom_txt2]
,[custom_txt3]
,[custom_txt4]
,[custom_txt5]
,[custom_txt6]
,[custom_txt7]
,[custom_txt8]
,[custom_txt9]
,[custom_txt10]
,[groupID]
,[isPreferred]
,[minimumReplenishment]
,[replenishmentMultiplication]
,[lastBatchReplenishment]
FROM [dbo].[Symphony_MasterSkus] MSKU
INNER JOIN [dbo].[Symphony_SKUs] SKU ON SKU.[skuID] = MSKU.[skuID] 
LEFT JOIN [dbo].[Symphony_SkuFamilies] F ON F.[id] = MSKU.[familyID] 
LEFT JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG ON FAG.familyID = MSKU.familyID
LEFT JOIN [dbo].[Symphony_RetailAgDgConnection] AGDG ON AGDG.[assortmentGroupID] = FAG.[assortmentGroupID]
LEFT JOIN [dbo].[Symphony_RetailFamilySalesRanking] FSR ON FSR.[familyID] = MSKU.familyID AND FSR.[assortmentGroupID] = FAG.[assortmentGroupID] AND [propertyItemID] IS NULL


GO
/****** Object:  View [dbo].[MasterSkusView]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MasterSkusView]
AS
SELECT
	MSKU.skuName, 
	MSKU.skuid as skuID,
	skuDescription, 
	MSKU.[status],--CASE WHEN MSKU.[status] = 0 THEN 'Active'   ELSE 'Inactive'  END AS [status],
	SF.id as familyID,
	SF.name as familyName,
	SF.familyDescription,
	ASG.id as assortmentGroupID,
	ASG.name as assortmentGroupName,
	ASG.[description] as assortmentGroupDescription,
	SFM.id as familyMemberID,
	salesEstimation, 
	decile as salesDecileRanking, 
	npiQuantity, 
	uomID,
	tvc, 
	throughput, 
	unitPrice, 
	safetyStock, 
	bufferManagementPolicyID,
	MSKU.skuPropertyID1,
	MSKU.skuPropertyID2,
	MSKU.skuPropertyID3,
	MSKU.skuPropertyID4,
	MSKU.skuPropertyID5,
	MSKU.skuPropertyID6,
	MSKU.skuPropertyID7,
	custom_num1, 
	custom_num2, 
	custom_num3, 
	custom_num4, 
	custom_num5, 
	custom_num6, 
	custom_num7, 
	custom_num8, 
	custom_num9, 
	custom_num10, 
	custom_txt1, 
	custom_txt2, 
	custom_txt3, 
	custom_txt4, 
	custom_txt5, 
	custom_txt6, 
	custom_txt7, 
	custom_txt8, 
	custom_txt9, 
	custom_txt10, 
	MSKU.groupID, --GRP.skuGroupName as groupID_display,
	isPreferred,
	hasImage, --= CAST(ISNULL(I.[id],0)/ISNULL(I.[id],1) AS bit),
	ISNULL(DGs.name,NULL) as displayGroupName,
	DGs.id as displayGroupID,
	ISNULL(DGs.[description],NULL) as dgDesc
	,HBT.HBTSegmentID_AG [hbtAG]
    ,HBT.HBTSegmentID_DG [hbtDG]
    ,HBTSegmentID_Universe [hbtAll]
	,MSKU.minimumReplenishment
	,MSKU.replenishmentMultiplication
	,MSKU.lastBatchReplenishment / 100 as [lastBatchReplenishment]
	
FROM dbo.MasterSkus MSKU 
	LEFT JOIN [dbo].[Symphony_RetailAgDgConnection] AGDG ON AGDG.[assortmentGroupID] = MSKU.[assortmentGroupID] 
	LEFT JOIN Symphony_AssortmentGroups ASG on MSKU.assortmentGroupID = ASG.id
	LEFT JOIN Symphony_DisplayGroups DGs on MSKU.displayGroupID = DGs.id
	LEFT JOIN Symphony_SkuFamilies SF ON MSKU.familyID = SF.id
	LEFT JOIN Symphony_SkuFamilyMembers SFM ON MSKU.familyMemberID = SFM.id
	LEFT JOIN Symphony_HBTGradation HBT ON HBT.familyID = MSKU.familyID AND HBT.assortmentGroupID = ASG.id


GO
/****** Object:  View [dbo].[FamilySalesRankingByProperty]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FamilySalesRankingByProperty] AS(
-- This view is expected to be called with where stockLocationID = @stockLocationID AND assortmentGroupID = @assortmentGroupID
		SELECT 
			 FSR.[familyID]
			,TMP.[stockLocationID]
			,FSR.[assortmentGroupID]
			,FSR.[propertyItemID]
			,FSR.[salesEstimation]
			,FSR.[decile]
		FROM [dbo].[Symphony_RetailFamilySalesRanking] FSR
		INNER JOIN(
			SELECT stockLocationID, [propertyItemID] FROM (
				SELECT stockLocationID, slPropertyID1 [propertyItemID], 'slPropertyID1' [slPropertyID] FROM Symphony_StockLocations 
				UNION ALL SELECT stockLocationID, slPropertyID2 [propertyItemID], 'slPropertyID2' [slPropertyID] FROM Symphony_StockLocations 
				UNION ALL SELECT stockLocationID, slPropertyID3 [propertyItemID], 'slPropertyID3' [slPropertyID] FROM Symphony_StockLocations 
				UNION ALL SELECT stockLocationID, slPropertyID4 [propertyItemID], 'slPropertyID4' [slPropertyID] FROM Symphony_StockLocations 
				UNION ALL SELECT stockLocationID, slPropertyID5 [propertyItemID], 'slPropertyID5' [slPropertyID] FROM Symphony_StockLocations 
				UNION ALL SELECT stockLocationID, slPropertyID6 [propertyItemID], 'slPropertyID6' [slPropertyID] FROM Symphony_StockLocations 
				UNION ALL SELECT stockLocationID, slPropertyID7 [propertyItemID], 'slPropertyID7' [slPropertyID] FROM Symphony_StockLocations 
			)SLP 
			INNER JOIN (
				SELECT  flag_value [slPropertyID] FROM Symphony_Globals WHERE flag_name = 'Retail.SalesEstimationSLPropertyForDeviation' 
				) GP
			ON GP.[slPropertyID] = SLP.[slPropertyID]
		)TMP
		ON TMP.propertyItemID = FSR.propertyItemID
)

GO
/****** Object:  View [dbo].[FamiliesMembers_StockLocationsView]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FamiliesMembers_StockLocationsView]
AS
SELECT 
                     SF.name as familyName
					,SF.ID as familyID
					,SF.familyDescription
					,SL.stockLocationID
                    ,SL.stockLocationName 
                    ,SKUs.skuName
					,SKUs.skuID
                    ,MS.familyMemberID
                    ,LAG.assortmentGroupID
					,AGs.name as assortmentGroupName 
					,ISNULL(AGs.[description],N'') as assortmentGroupDescription 
                    ,AGDG.displayGroupID
					,ISNULL(DGs.name,NULL) as displayGroupName
					,DGs.[description] as displayGroupDescription
					,SL.slPropertyID1
                    ,SL.slPropertyID2
                    ,SL.slPropertyID3
                    ,SL.slPropertyID4
                    ,SL.slPropertyID5
                    ,SL.slPropertyID6
                    ,SL.slPropertyID7
                    ,LAG.varietyTarget as AGTarget
					,LAG.spaceTarget as AGSpace
                    ,CASE LAG.gapMode WHEN 0 THEN NULL ELSE LAG.spaceTarget END AGSpaceTarget
                    ,CASE 
	                    WHEN LFA.npiSetID IS NULL THEN MS.npiQuantity 
	                    ELSE ISNULL(NPI.npiQuantity, 0)
	                    END [npiQuantity]
					,FSR.salesEstimation AS salesEstimation
					,FSR.decile  AS [salesDecileRanking]
                    ,OriginSL.stockLocationName as originStockLocation 
                    ,SLS.inventoryAtSite
                    ,(SLS.inventoryAtSite + SLS.inventoryAtTransit + SLS.inventoryAtProduction) AS inventoryAtPipe
                    ,SLS.bufferSize
                    ,SLS.skuPropertyID1
                    ,SLS.skuPropertyID2
                    ,SLS.skuPropertyID3
                    ,SLS.skuPropertyID4
                    ,SLS.skuPropertyID5
                    ,SLS.skuPropertyID6
                    ,SLS.skuPropertyID7
                    ,SLS.custom_num1
                    ,SLS.custom_num2
                    ,SLS.custom_num3
                    ,SLS.custom_num4
                    ,SLS.custom_num5
                    ,SLS.custom_num6
                    ,SLS.custom_num7
                    ,SLS.custom_num8
                    ,SLS.custom_num9
                    ,SLS.custom_num10
                    ,SLS.custom_txt1
                    ,SLS.custom_txt2
                    ,SLS.custom_txt3
                    ,SLS.custom_txt4
                    ,SLS.custom_txt5
                    ,SLS.custom_txt6
                    ,SLS.custom_txt7
                    ,SLS.custom_txt8
                    ,SLS.custom_txt9
                    ,SLS.custom_txt10
                    ,SEBP.salesEstimation AS SalesEstimationBy
                    ,SEBP.decile AS SalesDecileBy
                    ,MS.groupID
					,ISNULL(SKUs.[imageID],-1) as SKUimage
					,HBT.HBTSegmentID_AG [hbtAG]
					,HBT.HBTSegmentID_DG [hbtDG]
					,HBTSegmentID_Universe [hbtAll]
					FROM [dbo].[Symphony_MasterSkus] MS
		            INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG  
                        ON FAG.[familyID] = MS.[familyID]
		            INNER JOIN [dbo].[Symphony_LocationAssortmentGroups] LAG
                        ON LAG.[assortmentGroupID] = FAG.[assortmentGroupID]	
                    INNER JOIN [dbo].[Symphony_StockLocationSkus] SLS 
	                    ON MS.skuID = sls.skuID 
	                    AND LAG.stockLocationID = SLS.stockLocationID
		            INNER JOIN [dbo].[Symphony_SKUs] SKUs
                        ON SKUs.skuID = MS.[skuID]
                    INNER JOIN [dbo].[Symphony_StockLocations] SL 
	                    ON SLS.stockLocationID = SL.stockLocationID AND SL.isDeleted=0
					LEFT JOIN [dbo].[Symphony_StockLocations] OriginSL 
	                    ON SLS.originStockLocation = OriginSL.stockLocationID AND OriginSL.isDeleted=0
                    LEFT JOIN [dbo].[Symphony_RetailAgDgConnection] AGDG 
	                    ON LAG.assortmentGroupID = AGDG.assortmentGroupID
				    LEFT JOIN [dbo].[Symphony_AssortmentGroups] AGs 
	                    ON AGs.id = LAG.assortmentGroupID
					LEFT JOIN [dbo].[Symphony_DisplayGroups] DGs
	                    ON DGs.id = AGDG.displayGroupID
                    LEFT JOIN [dbo].[Symphony_LocationFamilyAttributes] LFA 
	                    ON LFA.familyID = MS.familyID 
	                    AND LFA.stockLocationID = SLS.stockLocationID
                    LEFT JOIN [dbo].[Symphony_NPISetMembers] NPI 
	                    ON LFA.npiSetID = NPI.npiSetID 
	                    AND MS.familyMemberID = NPI.familyMemberID 
                    LEFT JOIN [dbo].[Symphony_RetailFamilySalesRanking] FSR 
	                    ON  FSR.[familyID] = FAG.[familyID]
	                    AND FSR.[assortmentGroupID] = LAG.[assortmentGroupID]
	                    AND FSR.[propertyItemID] IS  NULL
					LEFT JOIN FamilySalesRankingByProperty SEBP
					ON SEBP.stockLocationID = LAG.stockLocationID
						AND SEBP.assortmentGroupID = LAG.assortmentGroupID
						AND SEBP.familyID = FAG.[familyID]                  
                    LEFT JOIN [dbo].[Symphony_SkuFamilies] SF 
                        ON SF.id = MS.familyID
					LEFT JOIN Symphony_HBTGradation HBT 
						 ON HBT.familyID = MS.familyID AND HBT.assortmentGroupID = LAG.assortmentGroupID

                    WHERE SLS.[isDeleted] = 0

GO
/****** Object:  View [dbo].[RootStockLocationSku]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[RootStockLocationSku]
AS
SELECT [skuID] [rootSkuID]
	,[stockLocationName] [rootStockLocationName]
FROM [dbo].[Symphony_StockLocationSkus] SLS
INNER JOIN [dbo].[Symphony_StockLocations] SL
	ON SL.[stockLocationID] = SLS.[stockLocationID]

GO
/****** Object:  View [dbo].[DownstreamSupplyChain]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DownstreamSupplyChain]
AS
SELECT RSKU.[rootSkuID]
	,RSKU.[rootStockLocationName]
	,SC.*
FROM [RootStockLocationSku] RSKU
CROSS APPLY [dbo].[GetDownstreamSupplyChain](RSKU.[rootSkuID], [RSKU].[rootStockLocationName]) SC

GO
/****** Object:  View [dbo].[LAGFamilyRecommendations]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[LAGFamilyRecommendations] AS(
-- This view is expected to be called with where stockLocationID = @stockLocationID AND assortmentGroupID = @assortmentGroupID
SELECT AR.familyID
	,LAG.stockLocationID
	,LAG.assortmentGroupID
	,F.NAME [familyName]
	,F.familyDescription [familyDescription]
	,AR.originID
	,OSL.[stockLocationName] [originStockLocationName]
	,OSL.[allowOverAllocation]
	,AR.requestStatus
	,AR.sentToReplenishment
	,CONVERT(bit, AR.userSelection) [selected]
	,ISNULL(AR.bySystem, 0) AS recommended
	,FLD.NumFamiliesInPipeBUL AS familiesOriginPipe
	,FLD.NumFamiliesAtSiteBUL AS familiesOriginSite
	,AR.groupID
	,AR.totalNPI AS totalNpiQuantity
	,AR.allocationRecommendationType
	,CASE 
		WHEN (FLD.NumAllocatedRequests - FLD.NumFamiliesAtSiteBUL) <= 0 	THEN NULL
		ELSE (FLD.NumAllocatedRequests - FLD.NumFamiliesAtSiteBUL)	END AS overAllocatedAtSite
	,CASE 
		WHEN (FLD.NumAllocatedRequests - FLD.NumFamiliesInPipeBUL) <= 0 	THEN NULL
		ELSE (FLD.NumAllocatedRequests - FLD.NumFamiliesInPipeBUL)	END AS overAllocatedInPipe
	,SE.salesEstimation
	,SE.decile
	,SEBP.salesEstimation [salesEstimationByProperty]
	,SEBP.decile [decileByProperty]
	,MSD.skuPropertyID1
	,MSD.skuPropertyID2
	,MSD.skuPropertyID3
	,MSD.skuPropertyID4
	,MSD.skuPropertyID5
	,MSD.skuPropertyID6
	,MSD.skuPropertyID7
	,MSD.custom_num1
	,MSD.custom_num2
	,MSD.custom_num3
	,MSD.custom_num4
	,MSD.custom_num5
	,MSD.custom_num6
	,MSD.custom_num7
	,MSD.custom_num8
	,MSD.custom_num9
	,MSD.custom_num10
	,MSD.custom_txt1
	,MSD.custom_txt2
	,MSD.custom_txt3
	,MSD.custom_txt4
	,MSD.custom_txt5
	,MSD.custom_txt6
	,MSD.custom_txt7
	,MSD.custom_txt8
	,MSD.custom_txt9
	,MSD.custom_txt10
	,CASE 
		WHEN GR.groupID IS NOT NULL
			THEN 1
		ELSE 0
		END AS groupExists
	,NULL groupForDisplay
	,ISNULL(F.imageID,-1) [imageID]
	,LFA.npiSetID
	,RAD.originQuantity
FROM [dbo].[Symphony_LocationAssortmentGroups] LAG
INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG
	ON FAG.assortmentGroupID = LAG.assortmentGroupID
INNER JOIN [dbo].[Symphony_SkuFamilies] F
	ON F.id = FAG.familyID
INNER JOIN [dbo].[Symphony_RetailAllocationRequest] AR
	ON AR.destinationID = LAG.stockLocationID
		AND AR.familyID = FAG.familyID
INNER JOIN [dbo].[Symphony_RetailFamilyMasterData] MSD
	ON MSD.familyID = FAG.familyID
LEFT JOIN [dbo].[Symphony_StockLocations] OSL
	ON OSL.[stockLocationID] = AR.[originID]
LEFT JOIN [dbo].[Symphony_RetailFamiliesLocationData] FLD
	ON FLD.familyID = FAG.familyID
		AND FLD.stockLocationID = AR.originID
LEFT JOIN dbo.Symphony_RetailFamilySalesRanking SE
	ON SE.familyID = FAG.familyID
		AND SE.propertyItemID IS NULL
		AND SE.assortmentGroupID = LAG.assortmentGroupID
LEFT JOIN FamilySalesRankingByProperty SEBP
	ON SEBP.stockLocationID = LAG.stockLocationID
		AND SEBP.assortmentGroupID = LAG.assortmentGroupID
		AND SEBP.familyID = F.id
LEFT JOIN [dbo].[Symphony_RetailLocationGroupsData] GR
	ON AR.destinationID = GR.stockLocationId
		AND AR.groupID = GR.groupID
LEFT JOIN [dbo].[Symphony_LocationFamilyAttributes] LFA
	ON LFA.[stockLocationID] = LAG.[stockLocationID]
	AND LFA.[familyID] = FAG.[familyID]
LEFT JOIN [dbo].[Symphony_RetailAllocationData] RAD
	ON RAD.originID = AR.originID
	AND RAD.familyID = FAG.[familyID]
)

GO
/****** Object:  View [dbo].[LAGExistingFamiliesData]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[LAGExistingFamiliesData] AS(
-- This view is expected to be called with where stockLocationID = @stockLocationID AND assortmentGroupID = @assortmentGroupID
    SELECT  
		 SLS.stockLocationID
		,LAG.assortmentGroupID
		,MAS.familyID, 
        MIN(SLS.originStockLocation) as originID, 
	    SUM(SLS.bufferSize) AS totalBuffers,
	    SUM(SLS.inventoryAtSite) AS totalInvAtSite,
        SUM(SLS.inventoryAtSite + SLS.inventoryAtTransit + SLS.inventoryAtProduction) As totalInvInPipe,
        CASE WHEN MAX(SLS.skuPropertyID1) <> MIN(SLS.skuPropertyID1) THEN NULL ELSE MIN(SLS.skuPropertyID1) END AS skuPropertyID1,
        CASE WHEN MAX(SLS.skuPropertyID2) <> MIN(SLS.skuPropertyID2) THEN NULL ELSE MIN(SLS.skuPropertyID2) END AS skuPropertyID2,
        CASE WHEN MAX(SLS.skuPropertyID3) <> MIN(SLS.skuPropertyID3) THEN NULL ELSE MIN(SLS.skuPropertyID3) END AS skuPropertyID3,
        CASE WHEN MAX(SLS.skuPropertyID4) <> MIN(SLS.skuPropertyID4) THEN NULL ELSE MIN(SLS.skuPropertyID4) END AS skuPropertyID4,
        CASE WHEN MAX(SLS.skuPropertyID5) <> MIN(SLS.skuPropertyID5) THEN NULL ELSE MIN(SLS.skuPropertyID5) END AS skuPropertyID5,
        CASE WHEN MAX(SLS.skuPropertyID6) <> MIN(SLS.skuPropertyID6) THEN NULL ELSE MIN(SLS.skuPropertyID6) END AS skuPropertyID6,
        CASE WHEN MAX(SLS.skuPropertyID7) <> MIN(SLS.skuPropertyID7) THEN NULL ELSE MIN(SLS.skuPropertyID7) END AS skuPropertyID7,
        CASE WHEN MAX(SLS.custom_num1) <> MIN(SLS.custom_num1) THEN NULL ELSE MIN(SLS.custom_num1) END AS custom_num1,
        CASE WHEN MAX(SLS.custom_num2) <> MIN(SLS.custom_num2) THEN NULL ELSE MIN(SLS.custom_num2) END AS custom_num2,
        CASE WHEN MAX(SLS.custom_num3) <> MIN(SLS.custom_num3) THEN NULL ELSE MIN(SLS.custom_num3) END AS custom_num3,
        CASE WHEN MAX(SLS.custom_num4) <> MIN(SLS.custom_num4) THEN NULL ELSE MIN(SLS.custom_num4) END AS custom_num4,
        CASE WHEN MAX(SLS.custom_num5) <> MIN(SLS.custom_num5) THEN NULL ELSE MIN(SLS.custom_num5) END AS custom_num5,
        CASE WHEN MAX(SLS.custom_num6) <> MIN(SLS.custom_num6) THEN NULL ELSE MIN(SLS.custom_num6) END AS custom_num6,
        CASE WHEN MAX(SLS.custom_num7) <> MIN(SLS.custom_num7) THEN NULL ELSE MIN(SLS.custom_num7) END AS custom_num7,
        CASE WHEN MAX(SLS.custom_num8) <> MIN(SLS.custom_num8) THEN NULL ELSE MIN(SLS.custom_num8) END AS custom_num8,
        CASE WHEN MAX(SLS.custom_num9) <> MIN(SLS.custom_num9) THEN NULL ELSE MIN(SLS.custom_num9) END AS custom_num9,
        CASE WHEN MAX(SLS.custom_num10) <> MIN(SLS.custom_num10) THEN NULL ELSE MIN(SLS.custom_num10) END AS custom_num10,
        CASE WHEN MAX(SLS.custom_txt1) <> MIN(SLS.custom_txt1) THEN NULL ELSE MIN(SLS.custom_txt1) END AS custom_txt1,
        CASE WHEN MAX(SLS.custom_txt2) <> MIN(SLS.custom_txt2) THEN NULL ELSE MIN(SLS.custom_txt2) END AS custom_txt2,
        CASE WHEN MAX(SLS.custom_txt3) <> MIN(SLS.custom_txt3) THEN NULL ELSE MIN(SLS.custom_txt3) END AS custom_txt3,
        CASE WHEN MAX(SLS.custom_txt4) <> MIN(SLS.custom_txt4) THEN NULL ELSE MIN(SLS.custom_txt4) END AS custom_txt4,
        CASE WHEN MAX(SLS.custom_txt5) <> MIN(SLS.custom_txt5) THEN NULL ELSE MIN(SLS.custom_txt5) END AS custom_txt5,
        CASE WHEN MAX(SLS.custom_txt6) <> MIN(SLS.custom_txt6) THEN NULL ELSE MIN(SLS.custom_txt6) END AS custom_txt6,
        CASE WHEN MAX(SLS.custom_txt7) <> MIN(SLS.custom_txt7) THEN NULL ELSE MIN(SLS.custom_txt7) END AS custom_txt7,
        CASE WHEN MAX(SLS.custom_txt8) <> MIN(SLS.custom_txt8) THEN NULL ELSE MIN(SLS.custom_txt8) END AS custom_txt8,
        CASE WHEN MAX(SLS.custom_txt9) <> MIN(SLS.custom_txt9) THEN NULL ELSE MIN(SLS.custom_txt9) END AS custom_txt9,
        CASE WHEN MAX(SLS.custom_txt10) <> MIN(SLS.custom_txt10) THEN NULL ELSE MIN(SLS.custom_txt10) END AS custom_txt10,
        MIN(MAS.groupID) [groupID]
FROM Symphony_StockLocationSkus SLS       
INNER JOIN  Symphony_MasterSkus MAS      on MAS.skuID = SLS.skuID  
INNER JOIN Symphony_RetailFamilyAgConnection FAG ON FAG.familyID = MAS.familyID
INNER JOIN Symphony_LocationAssortmentGroups LAG
    ON LAG.assortmentGroupID = FAG.assortmentGroupID
    AND LAG.stockLocationID = SLS.stockLocationID
WHERE  SLS.[isDeleted] = 0 
GROUP BY SLS.stockLocationID, LAG.assortmentGroupID, MAS.familyID
)


GO
/****** Object:  View [dbo].[LAGExistingFamilies]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[LAGExistingFamilies] AS (
-- This view is expected to be called with where stockLocationID = @stockLocationID AND assortmentGroupID = @assortmentGroupID
	SELECT EF.familyID
		,F.name as familyName
		,F.familyDescription
		,LAG.stockLocationID
		,LAG.assortmentGroupID
		,EF.originID
		,OSL.[stockLocationName] [originStockLocationName]
		,VR.lastInvalidationDate AS invalidationDate
		-- 1= Valid, 2 = NewlyInvallid, 3=ExpiredInvalid
		,CASE 
			WHEN (VR.isValid = 1) THEN 1
			WHEN (VR.isInvalidOverThreshold = 0) THEN 2
			WHEN (VR.isInvalidOverThreshold = 1) THEN 3
			ELSE NULL
		 END AS validityState
		,CASE CIP.considerInventoryInPipe
			WHEN 1
				THEN CASE 
						WHEN EF.totalBuffers > EF.totalInvInPipe
							THEN EF.totalBuffers
						ELSE EF.totalInvInPipe
						END
			ELSE EF.totalBuffers
		END totalSpace
		,EF.totalBuffers
		,EF.totalInvAtSite
		,EF.totalInvInPipe
		,EF.skuPropertyID1
		,EF.skuPropertyID2
		,EF.skuPropertyID3
		,EF.skuPropertyID4
		,EF.skuPropertyID5
		,EF.skuPropertyID6
		,EF.skuPropertyID7
		,EF.custom_num1
		,EF.custom_num2
		,EF.custom_num3
		,EF.custom_num4
		,EF.custom_num5
		,EF.custom_num6
		,EF.custom_num7
		,EF.custom_num8
		,EF.custom_num9
		,EF.custom_num10
		,EF.custom_txt1
		,EF.custom_txt2
		,EF.custom_txt3
		,EF.custom_txt4
		,EF.custom_txt5
		,EF.custom_txt6
		,EF.custom_txt7
		,EF.custom_txt8
		,EF.custom_txt9
		,EF.custom_txt10
		,FLD.NumFamiliesAtSite AS familiesOriginSite
		,FLD.NumFamiliesAtPipe AS familiesOriginPipe
		,SE.salesEstimation
		,SE.decile
		,SEBP.salesEstimation [salesEstimationByProperty]
		,SEBP.decile [decileByProperty]
		,EF.groupID
		,ISNULL(F.imageID,-1) [imageID]
	FROM [dbo].[Symphony_LocationAssortmentGroups] LAG
	CROSS JOIN (
		SELECT CONVERT(BIT, [flag_value]) allocateZeroInventory
		FROM [dbo].[Symphony_Globals]
		WHERE flag_name = 'RetailAllocateExistingFamilyWithZeroBufferInventory'
		) AZI
	CROSS JOIN (
		SELECT CONVERT(BIT, [flag_value]) considerInventoryInPipe
		FROM [dbo].[Symphony_Globals]
		WHERE flag_name = 'retail.ConsiderInventoryGC'
		) CIP
	INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG
		ON FAG.assortmentGroupID = LAG.assortmentGroupID
	INNER JOIN [dbo].[Symphony_SkuFamilies] F
		ON F.id = FAG.familyID
	INNER JOIN LAGExistingFamiliesData EF
		ON EF.stockLocationID = LAG.stockLocationID
			AND EF.assortmentGroupID = LAG.assortmentGroupID
			AND EF.familyID = F.id
	LEFT JOIN [dbo].[Symphony_StockLocations] OSL
		ON OSL.[stockLocationID] = EF.[originID]
	LEFT JOIN Symphony_FamilyValidationResults VR
		ON EF.familyID = VR.familyID
			AND VR.stockLocationID = EF.stockLocationID
			AND VR.assortmentGroupID = FAG.assortmentGroupID
	LEFT JOIN dbo.Symphony_RetailFamiliesLocationData FLD
		ON FLD.familyID = EF.familyID
			AND FLD.stockLocationID = EF.originID
	LEFT JOIN dbo.Symphony_RetailFamilySalesRanking SE
		ON EF.familyID = SE.familyID
			AND SE.propertyItemID IS NULL
			AND SE.assortmentGroupID = LAG.assortmentGroupID
	LEFT JOIN FamilySalesRankingByProperty SEBP
		ON SEBP.stockLocationID = LAG.stockLocationID
			AND SEBP.assortmentGroupID = LAG.assortmentGroupID
			AND SEBP.familyID = F.id
	WHERE 
			AZI.allocateZeroInventory = 0
			OR (
				AZI.allocateZeroInventory = 1
				AND (
					totalInvInPipe > 0
					OR totalBuffers > 0
					)
				)
) 


GO
/****** Object:  View [dbo].[DistributionReplenishment]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DROP VIEW [DistributionReplenishment]

CREATE VIEW [dbo].[DistributionReplenishment]
AS
SELECT 
	 1 [rowType]
	,t0.id
	,t0.stockLocationID
	,t1.stockLocationName
	,t1.stockLocationDescription
	,t2.stockLocationName as originStockLocationName 
	,t1.slPropertyID1
	,t1.slPropertyID2
	,t1.slPropertyID3
	,t1.slPropertyID4
	,t1.slPropertyID5
	,t1.slPropertyID6
	,t1.slPropertyID7
	,skuName
	,t0.skuID
	,t0.skuDescription
	,t0.locationSkuName
	,t0.bufferSize
	,inventoryNeeded
	,t0.bpProduction
	,t0.productionColor
	,t0.toReplenish
	,t0.sentToReplenishment
	,t0.skuPropertyID1
	,t0.skuPropertyID2
	,t0.skuPropertyID3
	,t0.skuPropertyID4
	,t0.skuPropertyID5
	,t0.skuPropertyID6
	,t0.skuPropertyID7
	,t0.originStockLocation
	,t0.originSKU
	,t0.suggestedReplenishmentAmount
	,t0.replenishmentQuantity
	,t0.minimumRequiredBP / 100 AS minimumRequiredBP
	,t0.minimumReplenishment
	,t0.multiplications
	,t0.autoReplenishment
	,ISNULL(t0.uomID,NULL) [uomID]
	,'' [clientOrderID]
	,0 AS replenishType -- 'Stock'
	,NULL AS productuionDueDate
	,t0.notes
	,t0.custom_num1
	,t0.custom_num2
	,t0.custom_num3
	,t0.custom_num4
	,t0.custom_num5
	,t0.custom_num6
	,t0.custom_num7
	,t0.custom_num8
	,t0.custom_num9
	,t0.custom_num10
	,t0.custom_txt1
	,t0.custom_txt2
	,t0.custom_txt3
	,t0.custom_txt4
	,t0.custom_txt5
	,t0.custom_txt6
	,t0.custom_txt7
	,t0.custom_txt8
	,t0.custom_txt9
	,t0.custom_txt10
	,NULL AS projectID
	,NULL AS taskOrder
	,CASE WHEN shipmentMeasure IS NULL THEN NULL ELSE shipmentMeasure * replenishmentQuantity END shipmentMeasure
	,-1 [istrID]
	,t0.TVC
	,t0.shipmentMeasure as shipmentMeasureOriginal
	,ISNULL(t0.replenishmentQuantity,0) * ISNULL(t0.TVC,0) as [orderValue]
	,t4.reasonID
FROM Symphony_StockLocationSkus t0
INNER JOIN Symphony_StockLocations t1
	ON t0.stockLocationID = t1.stockLocationID
LEFT JOIN Symphony_StockLocations t2
	ON t2.stockLocationID = t0.originStockLocation
INNER JOIN Symphony_SKUs t3
	ON t0.skuID = t3.skuID
INNER JOIN Symphony_Aux_SLSkusToReplenishment t4
	ON t0.stockLocationID = t4.stockLocationID
		AND t0.skuID = t4.skuID
WHERE t0.inventoryNeeded > 0
	AND t0.sentToReplenishment = 0
	AND t0.avoidReplenishment = 0
	AND t0.toReplenish <= 2
	AND t0.isDeleted = 0
	AND (t2.stockLocationType IS NULL OR t2.stockLocationType NOT IN (1, 2))

UNION ALL
SELECT
	2 [rowType]
	,CONVERT(bigint, ROW_NUMBER() OVER (ORDER BY [clientOrderID])) [id]
	,*
FROM (
	SELECT 
		 replinshmentDestination AS stockLocationID
		,t1.stockLocationName
		,t1.stockLocationDescription
    	,t2.stockLocationName as originStockLocationName
		,t1.slPropertyID1
		,t1.slPropertyID2
		,t1.slPropertyID3
		,t1.slPropertyID4
		,t1.slPropertyID5
		,t1.slPropertyID6
		,t1.slPropertyID7
		,skuName
		,t4.skuID
		,t0.skuDescription
		,t3.skuName AS locationSkuName
		,NULL AS bufferSize
		,quantityToReplenish AS inventoryNeeded
		,bufferPenetration AS bpProduction
		,bpColor AS productionColor
		,t4.toReplenish
		,t4.sentToReplenishment
		,t0.skuPropertyID1
		,t0.skuPropertyID2
		,t0.skuPropertyID3
		,t0.skuPropertyID4
		,t0.skuPropertyID5
		,t0.skuPropertyID6
		,t0.skuPropertyID7
		,replinshmentSource AS originStockLocation
		,NULL AS originSKU
		,quantityToReplenish AS suggestedReplenishmentAmount
		,quantityToReplenish AS replenishmentQuantity
		,t0.minimumRequiredBP / 100 AS minimumRequiredBP
		,t0.minimumReplenishment
		,t0.multiplications
		,1 AS autoReplenishment
		,ISNULL(t0.uomID,NULL) [uomID]
		,ISNULL(clientOrderID, '') [clientOrderID]
		,1 AS replenishType --'Order'
		,productuionDueDate
		,t4.notesReplenishment
		,t0.custom_num1
		,t0.custom_num2
		,t0.custom_num3
		,t0.custom_num4
		,t0.custom_num5
		,t0.custom_num6
		,t0.custom_num7
		,t0.custom_num8
		,t0.custom_num9
		,t0.custom_num10
		,t0.custom_txt1
		,t0.custom_txt2
		,t0.custom_txt3
		,t0.custom_txt4
		,t0.custom_txt5
		,t0.custom_txt6
		,t0.custom_txt7
		,t0.custom_txt8
		,t0.custom_txt9
		,t0.custom_txt10
		,NULL AS projectID
		,NULL AS taskOrder
		,CASE WHEN t0.shipmentMeasure IS NULL THEN NULL ELSE t0.shipmentMeasure * quantityToReplenish END shipmentMeasure
		,-1 [istrID]
		,t0.TVC
		,t0.shipmentMeasure as shipmentMeasureOriginal
		,ISNULL(quantityToReplenish,0) * ISNULL(t0.TVC,0) as [orderValue]
		,t4.reasonID
	FROM Symphony_ClientOrder t4
		,Symphony_StockLocationSkus t0
		,Symphony_StockLocations t1
		,Symphony_SKUs t3
		,Symphony_StockLocations t2
	WHERE quantityToReplenish > 0
		AND t4.sentToReplenishment = 0
		AND needToProduceRepOrder = 0
		AND t4.replinshmentDestination = t1.stockLocationID
		AND t4.skuID = t3.skuID
		AND t4.replinshmentDestination = t0.stockLocationID
		AND t4.skuID = t0.skuID
		AND t0.isDeleted = 0
		AND t2.stockLocationID = replinshmentSource
	UNION ALL
	SELECT 
		 replinshmentDestination AS stockLocationID
		 ,t1.stockLocationName
		 ,t1.stockLocationDescription
         ,t2.stockLocationName as originStockLocationName
		,t1.slPropertyID1
		,t1.slPropertyID2
		,t1.slPropertyID3
		,t1.slPropertyID4
		,t1.slPropertyID5
		,t1.slPropertyID6
		,t1.slPropertyID7
		,skuName
		,t4.skuID
		,t0.skuDescription
		,t3.skuName AS locationSkuName
		,NULL AS bufferSize
		,quantityToReplenish AS inventoryNeeded
		,bufferPenetration AS bpProduction
		,bpColor AS productionColor
		,t4.toReplenish
		,t4.sentToReplenishment
		,t0.skuPropertyID1
		,t0.skuPropertyID2
		,t0.skuPropertyID3
		,t0.skuPropertyID4
		,t0.skuPropertyID5
		,t0.skuPropertyID6
		,t0.skuPropertyID7
		,replinshmentSource AS originStockLocation
		,NULL AS originSKU
		,quantityToReplenish AS suggestedReplenishmentAmount
		,quantityToReplenish AS replenishmentQuantity
		,NULL AS minimumRequiredBP
		,NULL AS minimumReplenishment
		,NULL AS multiplications
		,1 AS autoReplenishment
		,ISNULL(t0.uomID,NULL) [uomID]
		,ISNULL(clientOrderID, '') [clientOrderID]
		,1 AS replenishType --'Order'
		,productuionDueDate
		,t4.notesReplenishment
		,NULL AS custom_num1
		,NULL AS custom_num2
		,NULL AS custom_num3
		,NULL AS custom_num4
		,NULL AS custom_num5
		,NULL AS custom_num6
		,NULL AS custom_num7
		,NULL AS custom_num8
		,NULL AS custom_num9
		,NULL AS custom_num10
		,NULL AS custom_txt1
		,NULL AS custom_txt2
		,NULL AS custom_txt3
		,NULL AS custom_txt4
		,NULL AS custom_txt5
		,NULL AS custom_txt6
		,NULL AS custom_txt7
		,NULL AS custom_txt8
		,NULL AS custom_txt9
		,NULL AS custom_txt10
		,NULL AS projectID
		,NULL AS taskOrder
		,NULL AS shipmentMeasure
		,-1 [istrID]
		,t0.TVC
		,null as shipmentMeasureOriginal
		,ISNULL(quantityToReplenish,0) * ISNULL(t0.TVC,0) as [orderValue]
		,t4.reasonID
FROM Symphony_ClientOrder t4
		,Symphony_MTOSkus t0
		,Symphony_StockLocations t1
		,Symphony_SKUs t3
		,Symphony_StockLocations t2
	WHERE quantityToReplenish > 0
		AND t4.sentToReplenishment = 0
		AND needToProduceRepOrder = 0
		AND t4.replinshmentDestination = t1.stockLocationID
		AND t4.skuID = t3.skuID
		AND t4.replinshmentDestination = t0.stockLocationID
		AND t4.skuID = t0.skuID
		AND t0.isDeleted = 0
	    AND t2.stockLocationID = replinshmentSource
) CO

UNION ALL --IST Recommendation

SELECT 3 [rowType]
	,CONVERT(bigint,t5.id) id
	,t5.stockLocationID
	,t1.stockLocationName
	,t1.stockLocationDescription
	,t6.stockLocationName as originStockLocationName
	,t1.slPropertyID1
	,t1.slPropertyID2
	,t1.slPropertyID3
	,t1.slPropertyID4
	,t1.slPropertyID5
	,t1.slPropertyID6
	,t1.slPropertyID7
	,skuName
	,t5.skuID
	,t0.skuDescription
	,t0.locationSkuName
	,t0.bufferSize
	,inventoryNeeded
	,t0.bpProduction
	,t0.productionColor
	,t5.toReplenish
	,t5.sentToReplenishment
	,t0.skuPropertyID1
	,t0.skuPropertyID2
	,t0.skuPropertyID3
	,t0.skuPropertyID4
	,t0.skuPropertyID5
	,t0.skuPropertyID6
	,t0.skuPropertyID7
	,t5.originStockLocationID AS originStockLocation
	,t0.originSKU
	,t5.suggestedReplenishmentQuantity AS suggestedReplenishmentAmount
	,t5.replenishmentQuantity
	,t0.minimumRequiredBP / 100 AS minimumRequiredBP
	,t0.minimumReplenishment
	,t0.multiplications
	,t0.autoReplenishment
	,ISNULL(t0.uomID,NULL) [uomID]
	,'' [clientOrderID]
	,2 AS replenishType --'IST'
	,NULL AS productuionDueDate
	,t0.notes
	,t0.custom_num1
	,t0.custom_num2
	,t0.custom_num3
	,t0.custom_num4
	,t0.custom_num5
	,t0.custom_num6
	,t0.custom_num7
	,t0.custom_num8
	,t0.custom_num9
	,t0.custom_num10
	,t0.custom_txt1
	,t0.custom_txt2
	,t0.custom_txt3
	,t0.custom_txt4
	,t0.custom_txt5
	,t0.custom_txt6
	,t0.custom_txt7
	,t0.custom_txt8
	,t0.custom_txt9
	,t0.custom_txt10
	,NULL AS projectID
	,NULL AS taskOrder
    ,CASE WHEN shipmentMeasure IS NULL THEN NULL ELSE shipmentMeasure * t5.replenishmentQuantity END shipmentMeasure
	,t5.id [istrID]
	,t0.TVC
	,t0.shipmentMeasure as shipmentMeasureOriginal
	,ISNULL(t5.replenishmentQuantity,0) * ISNULL(t0.TVC,0) as [orderValue]
	,t5.reasonID
FROM [dbo].[Symphony_ISTRecommendations] AS t5
LEFT JOIN Symphony_StockLocationSkus t0
	ON t5.stockLocationID = t0.stockLocationID
		AND t5.skuid = t0.skuid
INNER JOIN Symphony_StockLocations t1
	ON t0.stockLocationID = t1.stockLocationID
LEFT JOIN Symphony_StockLocations t6
	ON t5.originStockLocationID = t6.stockLocationID
INNER JOIN Symphony_SKUs t3
	ON t0.skuID = t3.skuID
WHERE t5.ToReplenish <= 2
	AND t5.sentToReplenishment = 0


GO
/****** Object:  View [dbo].[SkusReplenishmentLogView]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SkusReplenishmentLogView] 
AS
SELECT 
RD.ID, 
RD.stockLocationID, 
SL.stockLocationName,
SL.stockLocationDescription,
RD.skuID, 
SS.skuName,
SLS.skuDescription as skuDescription,
SLS.locationSkuName, 
RD.originStockLocation, 
SL1.stockLocationName as originStockLocationName,
RD.bufferSize, 
RD.inventoryNeeded, 
RD.bpProduction, 
case when MTOS.skuid is not null then UOM_MTO.uomID else UOM_MTS.uomID  end as uomID, 
RD.replenishmentQuantity, 
RD.originSKU, 
RD.productionColor, 
RD.userName, 
RD.updateDate, 
RD.clientOrderID,
DR.projectID,
SL.[slPropertyID1],
SL.[slPropertyID2],
SL.[slPropertyID3],
SL.[slPropertyID4],
SL.[slPropertyID5],
SL.[slPropertyID6],
SL.[slPropertyID7],
SLS.skuPropertyID1,
SLS.skuPropertyID2,
SLS.skuPropertyID3,
SLS.skuPropertyID4,
SLS.skuPropertyID5,
SLS.skuPropertyID6,
SLS.skuPropertyID7,
SLS.custom_txt1,
SLS.custom_txt2,
SLS.custom_txt3,
SLS.custom_txt4,
SLS.custom_txt5,
SLS.custom_txt6,
SLS.custom_txt7,
SLS.custom_txt8,
SLS.custom_txt9,
SLS.custom_txt10,
SLS.custom_num1,
SLS.custom_num2,
SLS.custom_num3,
SLS.custom_num4,
SLS.custom_num5,
SLS.custom_num6,
SLS.custom_num7,
SLS.custom_num8,
SLS.custom_num9,
SLS.custom_num10,
RD.reasonID, 
RD.toReplenish
FROM         dbo.Symphony_ReplenishmentDistributionLog AS RD 
				LEFT JOIN dbo.Symphony_StockLocations AS SL ON RD.stockLocationID = SL.stockLocationID 
                LEFT JOIN dbo.Symphony_StockLocations AS SL1 ON RD.originStockLocation = SL1.stockLocationID 
                LEFT JOIN [dbo].Symphony_StockLocationSkus AS SLS ON SLS.[skuID] = RD.[skuID] AND RD.stockLocationID=SLS.stockLocationID
				LEFT JOIN [dbo].Symphony_MTOSkus AS MTOS ON MTOS.[skuID] = RD.[skuID] AND RD.stockLocationID=MTOS.stockLocationID
                LEFT JOIN [dbo].Symphony_UOM AS UOM_MTS ON SLS.uomID = UOM_MTS.uomID
				LEFT JOIN [dbo].Symphony_UOM AS UOM_MTO ON MTOS.uomID = UOM_MTO.uomID
                LEFT JOIN [dbo].[Symphony_SKUs] AS SS ON SS.[skuID] = RD.[skuID]
                LEFT JOIN [dbo].[Symphony_BPColors] AS SC ON RD.productionColor = SC.colorID    
				LEFT JOIN [dbo].[DistributionReplenishment] DR
				ON DR.stockLocationID = RD.stockLocationID and DR.skuID = RD.skuID and DR.ID = RD.id

GO
/****** Object:  View [dbo].[Families_StockLocations_Base]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Families_StockLocations_Base] 

AS

SELECT 
 MS.familyID
,SF.name as familyName 
,SF.familyDescription
,SL.stockLocationName
,LAG.stockLocationID
,LAG.assortmentGroupID
,AGDG.displayGroupID
,MAX(SLS.originStockLocation) As originID
,SL.slPropertyID1
,SL.slPropertyID2
,SL.slPropertyID3
,SL.slPropertyID4
,SL.slPropertyID5
,SL.slPropertyID6
,SL.slPropertyID7
,LAG.varietyTarget as AGTarget
,CASE LAG.gapMode WHEN 0 THEN NULL ELSE LAG.spaceTarget END AGSpaceTarget
,SUM(SLS.inventoryAtSite + SLS.inventoryAtTransit + SLS.inventoryAtProduction) as SumInventoryAtPipe
,SUM(SLS.bufferSize) AS SumBufferSize
,SUM(SLS.inventoryAtSite) AS SumInventoryAtSite
,SUM(case WHEN SLS.inventoryAtProduction + SLS.inventoryAtTransit + SLS.inventoryAtSite < SLS.bufferSize THEN SLS.bufferSize ELSE SLS.inventoryAtProduction + SLS.inventoryAtTransit + SLS.inventoryAtSite END) AS TotalSpace
,MAX(MS.groupID) AS groupID
,CASE WHEN SUM(bufferSize) > 0 OR SUM(inventoryAtSite) > 0 THEN 1 ELSE 0 END AS DisplaySkus
,CASE WHEN MIN(SLS.inventoryAtSite) = 0 THEN NULL ELSE MIN(SLS.noConsumptionDays) END AS ShelfAge
FROM   [dbo].[Symphony_MasterSkus] MS 
INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG  
ON FAG.[familyID] = MS.[familyID]
INNER JOIN [dbo].[Symphony_LocationAssortmentGroups] LAG  
ON LAG.[assortmentGroupID] = FAG.[assortmentGroupID]	
INNER JOIN [dbo].[Symphony_StockLocationSkus] SLS 
ON MS.skuID = sls.skuID AND LAG.stockLocationID = SLS.stockLocationID 
INNER JOIN [dbo].[Symphony_StockLocations] SL 
ON SLS.stockLocationID = SL.stockLocationID
LEFT JOIN [dbo].[Symphony_SkuFamilies] SF 
ON SF.id = MS.familyID 
LEFT JOIN [dbo].[Symphony_RetailAgDgConnection] AGDG 
ON LAG.assortmentGroupID = AGDG.assortmentGroupID  
WHERE SLS.[isDeleted] = 0
GROUP BY
 MS.familyID
,SF.name
,SF.familyDescription
,SL.stockLocationName
,LAG.stockLocationID
,LAG.assortmentGroupID
,AGDG.displayGroupID
,SLS.originStockLocation
,slPropertyID1
,slPropertyID2
,slPropertyID3
,slPropertyID4
,slPropertyID5
,slPropertyID6
,slPropertyID7
,LAG.varietyTarget
,LAG.gapMode
,LAG.spaceTarget


GO
/****** Object:  View [dbo].[Families_StockLocations_View]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Families_StockLocations_View] 

AS

SELECT FAMILIES.[familyid], 
         FAMILIES.[familyname], 
         FAMILIES.[familydescription], 
         FAMILIES.[stocklocationid], 
         FAMILIES.[stocklocationname], 
         FAMILIES.[assortmentgroupid], 
         FAMILIES.[displaygroupid], 
         DGs.NAME                       AS displayGroupName, 
         AGs.NAME                       AS assortmentGroupName, 
         Isnull(DGs.[description], N'') AS displayGroupDescription, 
         Isnull(AGs.[description], N'') AS assortmentGroupDescription 
         --,FAMILIES.[originID] as originStockLocation 
         , 
         originSL.stocklocationname     AS originStockLocation, 
         FAMILIES.[slpropertyid1], 
         FAMILIES.[slpropertyid2], 
         FAMILIES.[slpropertyid3], 
         FAMILIES.[slpropertyid4], 
         FAMILIES.[slpropertyid5], 
         FAMILIES.[slpropertyid6], 
         FAMILIES.[slpropertyid7], 
         FAMILIES.[agtarget], 
         FAMILIES.[agspacetarget], 
         FAMILIES.[suminventoryatpipe], 
         FAMILIES.[sumbuffersize], 
         FAMILIES.[suminventoryatsite], 
         FAMILIES.[totalspace], 
         FAMILIES.[groupid], 
         FAMILIES.[displayskus], 
         FAMILIES.[shelfage], 
         FSR.decile                     AS salesDecileRanking, 
         FSR.salesestimation, 
         CASE VALID.isvalid 
           WHEN 1 THEN 1 
           ELSE 
             CASE VALID.isinvalidoverthreshold 
               WHEN 0 THEN 2 
               WHEN 1 THEN 3 
             END 
         END                            [validity], 
         FSRBP.salesestimation          AS SalesEstimationBy, 
         FSRBP.decile                   AS SalesDecileBy, 
         CASE 
           WHEN VALID.isvalid = 1 THEN NULL 
           ELSE VALID.lastinvalidationdate 
         END                            [lastInvalidationDate] 
         --,LFA.npiSetID 
         , 
         NPIS.NAME                      AS npiSetName, 
         LFA.replenishmenttime, 
         LFA.originstocklocationid, 
         LFA.invalidfamilythreshold, 
         LFA.avoidrefreshment, 
         FMC.monthlyconsumption, 
         CONS.averageconsumptionag      AS localAGCons, 
         CONS.averageconsumptiondg      AS localDGCons, 
         FSL.numfamiliesatsite          AS inventoryOriginSite, 
         FSL.numfamiliesatpipe          AS inventoryOriginPipe, 
         SLFP.currentstateid            [dplmStatusID], 
         SR.salerate, 
         SR.coverage, 
         HBT.hbtsegmentid_ag            [hbtAG], 
         HBT.hbtsegmentid_dg            [hbtDG], 
         hbtsegmentid_universe          [hbtAll],
		 SRFLR.[ranking]
  FROM   [dbo].[families_stocklocations_base] AS FAMILIES 
         LEFT JOIN [dbo].[symphony_familyvalidationresults] VALID 
                ON FAMILIES.stocklocationid = VALID.stocklocationid 
                   AND FAMILIES.familyid = VALID.familyid 
         LEFT JOIN [dbo].[symphony_retailfamilysalesranking] FSR 
                ON FSR.[familyid] = FAMILIES.[familyid] 
                   AND FSR.[assortmentgroupid] = FAMILIES.[assortmentgroupid] 
                   AND FSR.[propertyitemid] IS NULL 
         LEFT JOIN familysalesrankingbyproperty FSRBP 
                ON FSRBP.stocklocationid = FAMILIES.stocklocationid 
                   AND FSRBP.assortmentgroupid = FAMILIES.assortmentgroupid 
                   AND FSRBP.familyid = FAMILIES.[familyid] 
         LEFT JOIN [dbo].[symphony_skufamiliesmonthlyconsumption] FMC 
                ON FMC.[familyid] = FAMILIES.[familyid] 
                   AND FMC.[stocklocationid] = FAMILIES.[stocklocationid] 
         LEFT JOIN [dbo].[symphony_locationfamilyattributes] LFA 
                ON LFA.familyid = FAMILIES.familyid 
                   AND LFA.stocklocationid = FAMILIES.stocklocationid 
         LEFT JOIN [dbo].symphony_assortmentgroupconsumptionsummarydata CONS 
                ON CONS.stocklocationid = FAMILIES.stocklocationid 
                   AND CONS.[assortmentgroupid] = FAMILIES.[assortmentgroupid] 
         LEFT JOIN [dbo].[symphony_retailfamilieslocationdata] FSL 
                ON FSL.familyid = FAMILIES.familyid 
                   AND FSL.stocklocationid = FAMILIES.originid 
         LEFT JOIN [dbo].[symphony_dplm_stocklocationfamilypolicy] SLFP 
                ON SLFP.[familyid] = FAMILIES.[familyid] 
                   AND SLFP.[stocklocationid] = FAMILIES.[stocklocationid] 
         LEFT JOIN [dbo].[symphony_assortmentgroups] AGs 
                ON AGs.id = FAMILIES.assortmentgroupid 
         LEFT JOIN [dbo].[symphony_displaygroups] DGs 
                ON DGs.id = FAMILIES.displaygroupid 
         LEFT JOIN [dbo].[symphony_stocklocations] originSL 
                ON FAMILIES.[originid] = originSL.stocklocationid 
         LEFT JOIN [symphony_npisets] NPIS 
                ON NPIS.id = LFA.npisetid 
         LEFT JOIN [dbo].[symphony_salesratefamily] SR 
                ON SR.familyid = FAMILIES.familyid 
                   AND SR.stocklocationid = FAMILIES.stocklocationid 
         LEFT JOIN [dbo].[symphony_hbtgradation] HBT 
                ON HBT.familyid = FAMILIES.familyid 
                   AND HBT.assortmentgroupid = FAMILIES.assortmentgroupid 
		LEFT JOIN [dbo].[Symphony_RetailFamilyLocationsLiquidationRanking] SRFLR
				ON SRFLR.[stockLocationID] = FAMILIES.[stocklocationid] AND SRFLR.[familyID] = FAMILIES.[familyID]


GO
/****** Object:  View [dbo].[DPLMActions]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DPLMActions]
AS
SELECT *
FROM (
	SELECT DA.[ID] AS uniqueId
		,1 [rowType]
		,DA.[calculationDate]
		,DA.[stockLocationID]
		,SL.[stockLocationName] 
		,Rad.[displayGroupID] 
		,SDG.[name] as DGName
		,Rfa.[assortmentGroupID]
		,SAG.[name] as AGName
		,DA.[familyID]
		,FAM.[name] AS [itemName]
		,FAM.[familyDescription] AS itemDescription
		,ISNULL(Dps.[policyID], DAD.[policyID]) AS policyID
		,Dsp.[currentStateID]
		,DpsC.[stateName] AS currentStateName
		,Dsp.[previousStateID]
		,Dps.[stateName] AS previousStateName
		,AL.[actionText] AS actionText
		,DA.[automatic]
		,DA.[actionStatus]
		,DA.[ruleType]
		,DA.[ruleId]
		,DA.[userID]
		,DA.[actionsDate]
		,SL.slPropertyID1
		,SL.slPropertyID2
		,SL.slPropertyID3
		,SL.slPropertyID4
		,SL.slPropertyID5
		,SL.slPropertyID6
		,SL.slPropertyID7
	FROM [dbo].[Symphony_DPLM_Actions] DA
	INNER JOIN [dbo].[Symphony_StockLocations] SL
		ON DA.stockLocationID = SL.stockLocationID
			AND SL.isdeleted = 0
	INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] Rfa
		ON DA.familyID = Rfa.familyID
	INNER JOIN [dbo].[Symphony_LocationAssortmentGroups] LAG
		ON LAG.stockLocationID = DA.stockLocationID
			AND LAG.assortmentGroupID = RFA.assortmentGroupID
	INNER JOIN [dbo].[Symphony_SkuFamilies] FAM
		ON FAM.id = DA.familyID
	LEFT JOIN [dbo].[Symphony_RetailAgDgConnection] Rad
		ON Rfa.assortmentGroupID = Rad.assortmentGroupID
	INNER JOIN [dbo].[Symphony_DisplayGroups] SDG
		ON SDG.id = Rad.displayGroupID
	INNER JOIN [dbo].[Symphony_AssortmentGroups] SAG
		ON SAG.id = Rad.assortmentGroupID
	LEFT JOIN [dbo].[Symphony_DPLM_PoliciesRules] Dpr
		ON DA.ruleId = Dpr.ID
	LEFT JOIN [dbo].[Symphony_DPLM_PoliciesStates] Dps
		ON Dpr.policyStateID = Dps.ID
	LEFT JOIN [dbo].[Symphony_DPLM_StockLocationFamilyPolicy] Dsp
		ON Dsp.stockLocationID = DA.stockLocationID
			AND Dsp.familyID = da.familyID
	LEFT JOIN [dbo].[Symphony_DPLM_PoliciesStates] DpsC
		ON Dsp.currentStateID = DpsC.ID
	LEFT JOIN [dbo].[Symphony_DPLM_ActionsDeleted] DAD
		ON DA.ruleId = DAD.ruleID
	LEFT JOIN [dbo].[Symphony_DPLM_Policies] DP
		ON Dps.policyID = DP.ID
	LEFT JOIN [dbo].[Symphony_DPLM_ActionLookup] AL
		ON AL.ID = DA.actionTextID
	
	UNION ALL
	
	SELECT DA.[ID] AS uniqueId
		,2 [rowType]
		,DA.[calculationDate]
		,DA.[stockLocationID]
		,SL.[stockLocationName]
		,Rad.[displayGroupID]
		,SDG.[name] as DGName
		,Rfa.[assortmentGroupID]
		,SAG.[name] as AGName
		,DA.[familyID]
		,FAM.[name] AS [itemName]
		,FAM.[familyDescription] [itemDescription]
		,ISNULL(Dps.policyID, DAD.policyID) [policyID]
		,DA.[currentStateID]
		,Dps.[stateName] AS currentStateName
		,DA.[previousStateID]
		,DpsP.[stateName] AS previousStateName
		,AL.[actionText] AS actionText
		,DA.[automatic]
		,DA.[actionStatus]
		,DA.[ruleType]
		,DA.[ruleId]
		,DA.[userID]
		,DA.[actionsDate]
		,SL.slPropertyID1
		,SL.slPropertyID2
		,SL.slPropertyID3
		,SL.slPropertyID4
		,SL.slPropertyID5
		,SL.slPropertyID6
		,SL.slPropertyID7
	FROM dbo.[Symphony_DPLM_ActionsHistory] AS DA
	INNER JOIN dbo.[Symphony_StockLocations] AS SL
		ON DA.stockLocationID = SL.stockLocationID
			AND SL.isdeleted = 0
	INNER JOIN [dbo].[Symphony_LocationAssortmentGroups] LAG
		ON LAG.stockLocationID = DA.stockLocationID
	INNER JOIN dbo.[Symphony_RetailFamilyAgConnection] AS Rfa
		ON DA.familyID = Rfa.familyID
			AND LAG.assortmentGroupID = RFA.assortmentGroupID
	LEFT JOIN dbo.[Symphony_RetailAgDgConnection] AS Rad
		ON Rfa.assortmentGroupID = Rad.assortmentGroupID
	INNER JOIN [dbo].[Symphony_DisplayGroups] SDG
		ON SDG.id = Rad.displayGroupID
	INNER JOIN [dbo].[Symphony_AssortmentGroups] SAG
		ON SAG.id = Rad.assortmentGroupID
	LEFT JOIN dbo.[Symphony_DPLM_PoliciesRules] AS Dpr
		ON DA.ruleId = Dpr.ID
	LEFT JOIN dbo.[Symphony_DPLM_PoliciesStates] AS Dps
		ON DA.currentStateID = Dps.ID	
	LEFT JOIN dbo.[Symphony_DPLM_PoliciesStates] AS DpsP
		ON DA.previousStateID = DpsP.ID
	LEFT JOIN dbo.[Symphony_DPLM_ActionsDeleted] AS DAD
		ON DA.ruleId = DAD.ruleId
	LEFT JOIN [dbo].Symphony_DPLM_Policies DP
		ON Dps.policyID = DP.ID
	LEFT JOIN [dbo].[Symphony_SkuFamilies] FAM
		ON FAM.id = DA.familyID
	LEFT JOIN [dbo].[Symphony_DPLM_ActionLookup] AL
		ON AL.ID = DA.actionTextID
	) TMP
WHERE (
		currentStateID <> previousStateID
		OR (previousStateID IS NULL)
		)
	OR ruleType <> 2


GO
/****** Object:  View [dbo].[DPLMFamilyCalculatedItemInfo]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DPLMFamilyCalculatedItemInfo]
AS
SELECT DA.uniqueId
	,DA.[rowType]
	,DA.[calculationDate]
	,DA.[familyID]
	,DA.[itemName] [familyName]
	,DA.itemDescription [familyDescription]
	,DA.stockLocationID
	,SL.stockLocationName
	,SL.stockLocationDescription
FROM DPLMActions DA
INNER JOIN Symphony_StockLocations SL
	ON SL.stockLocationID = da.stockLocationID


GO
/****** Object:  View [dbo].[DPLMSkuCalculatedItemInfo]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DPLMSkuCalculatedItemInfo]
AS
SELECT DA.uniqueId
	,DA.[rowType]
	,DA.[calculationDate]
	,DA.[familyID]
	,SKU.[skuName]
	,SLS.[skuDescription]
	,DA.stockLocationID
	,SL.stockLocationName
	,SL.stockLocationDescription
FROM DPLMActions DA
INNER JOIN [dbo].[Symphony_StockLocations] SL
	ON SL.stockLocationID = da.stockLocationID
INNER JOIN [dbo].[Symphony_SKUs] SKU
	ON SKU.[skuName] = DA.[itemName]
LEFT JOIN [dbo].[Symphony_StockLocationSkus] SLS
ON SLS.[stockLocationID] = SL.[stockLocationID]
AND SLS.[skuID] = SKU.[skuID]


GO
/****** Object:  View [dbo].[DPLMCalculatedParameters]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DPLMCalculatedParameters]
AS
SELECT CP.id
	,CP.[stockLocationID]
	,SL.[stockLocationName]
	,CP.[familyID]
	,SF.name [itemName]
	,CP.[policyID]
	,DP.policyName
	,CP.[stateID]
	,PS.[stateName]
	,DPLP.[functionConditions]
	,CP.[calculationDate]
	,CASE 
		WHEN paramValInt16 IS NOT NULL THEN CAST(paramValInt16 AS NVARCHAR)
		WHEN paramValInt32 IS NOT NULL THEN CAST(paramValInt32 AS NVARCHAR)
		WHEN paramValInt64 IS NOT NULL THEN CAST(paramValInt64 AS NVARCHAR)
		WHEN paramValDecimal IS NOT NULL THEN CAST(CAST(paramValDecimal AS DECIMAL(18, 3)) AS NVARCHAR)
		WHEN paramValDateTime IS NOT NULL THEN CAST(CAST(paramValDateTime AS DATETIME) AS NVARCHAR)
		WHEN paramValBit IS NOT NULL AND paramValBit > 0	THEN 'True'
		WHEN paramValBit IS NOT NULL AND paramValBit = 0 THEN 'False'
		WHEN paramValString IS NOT NULL	THEN CAST(paramValString AS NVARCHAR)	ELSE NULL
	END AS [paramValue]
FROM Symphony_DPLM_WorkingCalculatedParameters CP
LEFT JOIN dbo.Symphony_SkuFamilies AS SF
	ON CP.familyID = SF.id
LEFT JOIN dbo.Symphony_DPLM_Policies AS DP
	ON CP.policyID = DP.ID
LEFT JOIN dbo.Symphony_StockLocations AS SL
	ON CP.stockLocationID = SL.stockLocationID
LEFT JOIN dbo.Symphony_DPLM_PoliciesStates AS PS
	ON CP.stateID = PS.ID
INNER JOIN 	Symphony_DPLM_ParametersLookUp DPLP
	ON DPLP.id = CP.functionConditionsID


GO
/****** Object:  View [dbo].[DPLMCalculatedParametersAux]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DPLMCalculatedParametersAux]
AS
SELECT DA.[uniqueId]
	,DA.[rowType]
	,DP.*
FROM DPLMActions DA
INNER JOIN DPLMCalculatedParameters DP
	ON DA.stockLocationID = DP.stockLocationID
		AND DA.familyID = DP.familyID
		AND DA.policyID = DP.policyID
		AND DA.previousStateID = DP.stateID
		AND DA.calculationDate = DP.calculationDate


GO
/****** Object:  View [dbo].[DPLMHistory]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DPLMHistory]
AS
WITH ActionsHistory
AS (
	SELECT 'A' + cast(DA.ID AS VARCHAR) AS uniqueId
		,stockLocationId
		,familyID
		,DA.[calculationDate]
		,CASE 
			WHEN DA.ruleType = 2
				THEN DA.[currentStateID]
			ELSE DA.[previousStateID]
			END AS currentStateID
		,DA.[previousStateID]
		,Dps.policyID AS Policy
		,DA.[ruleId]
		,CL.[conditionText] AS DecidingCondition
		,AL.[actionText] AS actionText
		,ISNULL(DA.[automatic], 1) AS actionStatus
		,DA.[ruleType]
	FROM Symphony_DPLM_Actions DA
	LEFT JOIN [dbo].[Symphony_DPLM_PoliciesStates] Dps
		ON Dps.ID = DA.currentStateID
	LEFT JOIN [dbo].[Symphony_DPLM_ActionLookup] AL
		ON AL.ID = DA.actionTextID
	LEFT JOIN [dbo].[Symphony_DPLM_ConditionLookup] CL
		ON CL.ID = DA.conditionTextID
	
	UNION
	
	SELECT 'H' + cast(DA.ID AS VARCHAR) AS uniqueId
		,stockLocationID
		,familyID
		,DA.[calculationDate]
		,CASE 
			WHEN DA.ruleType = 2
				THEN DA.[currentStateID]
			ELSE DA.[previousStateID]
			END AS currentStateID
		,DA.[previousStateID]
		,Dps.policyID AS Policy
		,DA.[ruleId]
		,CL.[conditionText] AS DecidingCondition
		,AL.[actionText]
		,ISNULL(DA.[automatic], 1) AS actionStatus
		,DA.[ruleType]
	FROM Symphony_DPLM_ActionsHistory DA
	LEFT JOIN [dbo].[Symphony_DPLM_PoliciesStates] Dps
		ON Dps.ID = DA.currentStateID
	LEFT JOIN [dbo].[Symphony_DPLM_ActionLookup] AL
		ON AL.ID = DA.actionTextID
	LEFT JOIN [dbo].[Symphony_DPLM_ConditionLookup] CL
		ON CL.ID = DA.conditionTextID
	)
SELECT *
FROM ActionsHistory AAS
WHERE (
		AAS.currentStateID <> AAS.previousStateID
		OR (AAS.previousStateID IS NULL)
		)
	OR AAS.ruleType <> 2


GO
/****** Object:  View [dbo].[DPLMHistoryView]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE
 VIEW [dbo].[DPLMHistoryView]
AS
SELECT     H.uniqueId, 
	H.stockLocationId as stockLocationID, 
	H.familyID,
	H.calculationDate, 
	H.currentStateID, 
	PS1.stateName as currentStateName,
	H.previousStateID, 
	PS2.stateName as previousStateName,	 
	H.Policy, 
	DP.policyName as policyName,
	H.ruleId, 
	H.DecidingCondition, 
	H.actionText, 
	H.actionStatus, 
	S.Name as actionStatusName,
	H.ruleType, 
	RT.Name as  ruleTypeName
FROM dbo.DPLMHistory H
LEFT JOIN dbo.Symphony_DPLM_Policies AS DP ON H.Policy = DP.ID 
LEFT JOIN dbo.Symphony_DPLM_PoliciesStates AS PS1 ON H.currentStateID = PS1.ID 
LEFT JOIN dbo.Symphony_DPLM_PoliciesStates AS PS2 ON H.previousStateID = PS2.ID
LEFT JOIN dbo.Symphony_DPLM_RuleTypes AS RT ON H.ruleType = RT.Id 
LEFT JOIN dbo.Symphony_DPLM_ActionStatuses AS S ON H.actionStatus = S.Id 



GO
/****** Object:  View [dbo].[Symphony_AssortmentGroup]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Symphony_AssortmentGroup]
AS
SELECT 
id as assortmentGroupID,
name as assortmentGroupName,
[description]
FROM [dbo].[Symphony_AssortmentGroups]


GO
/****** Object:  View [dbo].[DPLMUpdateStates]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DPLMUpdateStates]
AS
SELECT 
			SL.stockLocationID ,
			SL.stockLocationName , 
			Rad.displayGroupID ,
			DG.name AS DGName,
			LAG.assortmentGroupID AS assortmentGroupID,
			AG.assortmentGroupName AS AGName,
			DP.familyID ,
			SF.[name] AS [itemName],
			ISNULL(SF.familyDescription, '') AS [itemDescription],
			DP.policyID ,
			DP.currentStateID ,
			DP.[stateStartDate] AS lastUpdated,
			DPS.stateName,
			SL.slPropertyID1,
			SL.slPropertyID2,
			SL.slPropertyID3,
			SL.slPropertyID4,
			SL.slPropertyID5,
			SL.slPropertyID6,
			SL.slPropertyID7

	FROM  [dbo].[Symphony_DPLM_StockLocationFamilyPolicy] DP 
	LEFT JOIN [dbo].[Symphony_RetailFamilyAgConnection] Rfa ON DP.familyID = Rfa.familyID 
	INNER JOIN [dbo].[Symphony_LocationAssortmentGroups] LAG  ON LAG.assortmentGroupID = Rfa.assortmentGroupID AND LAG.stockLocationID = DP.stockLocationID 
	LEFT JOIN [dbo].[Symphony_RetailAgDgConnection] Rad ON Rfa.assortmentGroupID = Rad.assortmentGroupID
	LEFT JOIN [dbo].[Symphony_SkuFamilies] SF ON SF.id = DP.familyID
	INNER JOIN [dbo].Symphony_StockLocations SL ON DP.stockLocationID = SL.stockLocationID AND SL.isdeleted = 0
	LEFT JOIN [dbo].[Symphony_DPLM_StockLocationFamilyPolicy] DA  ON DP.familyID = DA.familyID and DA.stockLocationID = DP.stockLocationID 
	LEFT JOIN [dbo].[Symphony_DisplayGroups] DG ON DG.id = Rad.displayGroupID
	LEFT JOIN [dbo].Symphony_AssortmentGroup AG ON AG.assortmentGroupID = LAG.assortmentGroupID
	LEFT JOIN [dbo].[Symphony_DPLM_PoliciesStates] DPS ON DPS.ID = DP.currentStateID 

GO
/****** Object:  View [dbo].[FSLVSFilter]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FSLVSFilter] 
AS 
SELECT 
LAG.stockLocationID, 
SL.stockLocationName,
LAG.assortmentGroupID,
AG.assortmentGroupName, 
ADC.displayGroupID,
DG.name as displayGroupName,
SL.slPropertyID1,
SL.slPropertyID2,
SL.slPropertyID3,
SL.slPropertyID4,
SL.slPropertyID5,
SL.slPropertyID6,
SL.slPropertyID7
FROM Symphony_LocationAssortmentGroups AS LAG
JOIN Symphony_RetailAgDgConnection AS ADC
ON LAG.assortmentGroupID = ADC.assortmentGroupID 
LEFT JOIN Symphony_StockLocations AS SL
ON SL.stockLocationID = LAG.stockLocationID
LEFT JOIN Symphony_DisplayGroups AS DG
ON DG.id = ADC.displayGroupID
LEFT JOIN Symphony_AssortmentGroup AS AG
ON AG.assortmentGroupID = LAG.assortmentGroupID
WHERE SL.stockLocationType = 3 AND SL.isDeleted = 0

GO
/****** Object:  View [dbo].[AGOBreakdownByFamiliesView]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AGOBreakdownByFamiliesView] 
AS
SELECT
FVR.familyID, 
SF.name AS familyName, 
FVR.isValid, 
--AGDG.displayGroupID,
DG.name AS displayGroupName, 
SFV.name AS validityState, 
FVR.lastInvalidationDate,
FVR.assortmentGroupID,
FVR.stockLocationID
						
FROM 
	(SELECT id, familyID, isValid, 
		CASE WHEN (isValid = 1) THEN 1 ELSE CASE WHEN (isInvalidOverThreshold = 0) THEN 2 ELSE 3 END END AS validityState,
		lastInvalidationDate, assortmentGroupID, stockLocationID 
		FROM dbo.Symphony_FamilyValidationResults) AS FVR
	
	LEFT OUTER JOIN
                      dbo.Symphony_LocationAssortmentGroups AS LAG ON LAG.assortmentGroupID = FVR.assortmentGroupID AND 
                      LAG.stockLocationID = FVR.stockLocationID LEFT OUTER JOIN
                      dbo.Symphony_RetailAgDgConnection AS AGDG ON LAG.assortmentGroupID = AGDG.assortmentGroupID LEFT OUTER JOIN
                      dbo.Symphony_DisplayGroups AS DG ON AGDG.displayGroupID = DG.id LEFT OUTER JOIN
                      dbo.Symphony_SkuFamilies AS SF ON FVR.familyID = SF.id

				LEFT OUTER JOIN
                      dbo.Symphony_FamilyValidity AS SFV ON FVR.validityState = SFV.id

GO
/****** Object:  View [dbo].[AGOBreakdownByTotalInventory]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AGOBreakdownByTotalInventory] 
AS
SELECT 			FVR.stockLocationID, 
				FVR.assortmentGroupID, 
				AG.[name] as assortmentGroupName,
				AG.[description] as assortmentGroupDescription,
				DG.id as displayGroupID,
				DG.name as displayGroupName,
				SKU.skuID, 
				SKU.skuName, 
				SLS.skuDescription, 
				FVR.familyID, 
				SF.name as familyName,
				MSKU.familyMemberID, 
                SLS.inventoryAtSite + SLS.inventoryAtTransit + SLS.inventoryAtProduction AS totalInventory, 
				(SLS.inventoryAtSite + SLS.inventoryAtTransit + SLS.inventoryAtProduction) * SLS.TVC AS totalCost, 
                SLS.bufferSize, 
				SLS.inventoryAtSite, 
				ISNULL(SKU.[imageID],-1) as SKUimage,
                SLS.skuPropertyID1,SLS.skuPropertyID2, SLS.skuPropertyID3, SLS.skuPropertyID4, SLS.skuPropertyID5, SLS.skuPropertyID6, SLS.skuPropertyID7, 
				SLS.custom_num1, SLS.custom_num2, SLS.custom_num3, SLS.custom_num4, SLS.custom_num5, SLS.custom_num6, SLS.custom_num7, SLS.custom_num8, SLS.custom_num9, SLS.custom_num10, 
				SLS.custom_txt1, SLS.custom_txt2, SLS.custom_txt3, SLS.custom_txt4, SLS.custom_txt5, SLS.custom_txt6, SLS.custom_txt7, SLS.custom_txt8, SLS.custom_txt9, SLS.custom_txt10
FROM         dbo.Symphony_FamilyValidationResults AS FVR 
		INNER JOIN [dbo].[Symphony_MasterSkus] MSKU
             ON MSKU.[familyID] = FVR.[familyID]
         INNER JOIN [dbo].[Symphony_StockLocationSkus] SLS
             ON SLS.[stockLocationID] = FVR.[stockLocationID]
             AND SLS.[skuID] = MSKU.[skuID]
         INNER JOIN [dbo].[Symphony_LocationAssortmentGroups] LAG
             ON LAG.[assortmentGroupID] = FVR.[assortmentGroupID]
             AND LAG.[stockLocationID] = FVR.[stockLocationID]
         LEFT JOIN [dbo].[Symphony_RetailAgDgConnection] AGDG
             ON LAG.[assortmentGroupID] = AGDG.[assortmentGroupID]
         INNER JOIN [dbo].[Symphony_SKUs] SKU
             ON SKU.[skuID] = MSKU.[skuID]
	     LEFT JOIN [dbo].[Symphony_DisplayGroups] DG
             ON DG.[id] = AGDG.[DisplayGroupID]
		 LEFT JOIN [dbo].[Symphony_AssortmentGroups] AG
             ON AG.[id] = AGDG.[assortmentGroupID]
		 LEFT JOIN [dbo].[Symphony_SkuFamilies] SF
             ON SF.id = MSKU.familyID

WHERE     (SLS.isDeleted = 0)

GO
/****** Object:  View [dbo].[AllMtsSkus]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[AllMtsSkus]  as
SELECT SLS.ID as uniqueId 
	,SL.[slPropertyID1]
	,SL.[slPropertyID2]
	,SL.[slPropertyID3]
	,SL.[slPropertyID4]
	,SL.[slPropertyID5]
	,SL.[slPropertyID6]
	,SL.[slPropertyID7]
	,SL.stockLocationName
	,SL.[stockLocationDescription]
	,SK.[skuName]
	,SLS.[stockLocationID]
	,SLS.[skuID]
	,SLS.[skuDescription]
	,SLS.[locationSkuName]
	,SLS.[bufferSize]
	,SLS.[inventoryAtSite]
	,SLS.[inventoryAtTransit]
	,SLS.[inventoryAtProduction]
	,SLS.[noConsumptionDays]
	,SLS.[inventoryNeeded]
	,SLS.[updateDate]  
	,CONVERT (int, SLS.[replenishmentTime]) [replenishmentTime]
	,SLS.[bpSite]
	,SLS.[bpTransit]
	,SLS.[bpProduction]
	,SLS.[siteColor]
	,SLS.[transitColor]
	,SLS.[productionColor]
	,SLS.[unitPrice]
	,SLS.[avoidReplenishment]
	,SLS.[blackReason]
	,SLS.[redReason]
	,SLS.[skuPropertyID1]
	,SLS.[skuPropertyID2]
	,SLS.[skuPropertyID3]
	,SLS.[skuPropertyID4]
	,SLS.[skuPropertyID5]
	,SLS.[skuPropertyID6]
	,SLS.[skuPropertyID7]
	,SLS.[minimumBufferSize]
	,SLS.originStockLocation
	,ISNULL(OSL.[stockLocationName], NULL) as [originStockLocationName]
	,ISNULL(OSL.[stockLocationDescription], NULL) as [originStockLocationDescription]
	,SLS.[originSKU]
	,SLS.[saftyStock]
	,SLS.[minimumRequiredBP] / 100 as [minimumRequiredBP]
	,SLS.[minimumReplenishment]
	,SLS.[multiplications]
	,SLS.[avoidSeasonality]
	,SLS.[autoReplenishment]
	,SLS.[uomID]
	,SLS.[Throughput]
	,SLS.[TVC]
	,SLS.[isDeleted] 
	,ISNULL(SLS.[notes],N'') [notes]
	,SLS.[bufferManagementPolicy]
	,SLS.[inSeasonality]
	,SLS.[irrInvAtSite]
	,SLS.[irrInvAtTransit]
	,SLS.[irrInvAtProduction]
	,SLS.[custom_num1]
	,SLS.[custom_num2]
	,SLS.[custom_num3]
	,SLS.[custom_num4]
	,SLS.[custom_num5]
	,SLS.[custom_num6]
	,SLS.[custom_num7]
	,SLS.[custom_num8]
	,SLS.[custom_num9]
	,SLS.[custom_num10]
	,SLS.[custom_txt1]
	,SLS.[custom_txt2]
	,SLS.[custom_txt3]
	,SLS.[custom_txt4]
	,SLS.[custom_txt5]
	,SLS.[custom_txt6]
	,SLS.[custom_txt7]
	,SLS.[custom_txt8]
	,SLS.[custom_txt9]
	,SLS.[custom_txt10]
	,SLS.[greenPipeDate]
	,SLS.[shipmentMeasure]
	,SLS.[endOfLifePolicy]
	,SLS.[endOfLifeStatus]
	,IST.inventoryAllotment 
	,IST.clusterID
	,IST.inventoryAllotment  AS ISTState
	,SR.coverage
	,SR.saleRate
        FROM [dbo].[Symphony_StockLocationSkus] AS SLS
        INNER JOIN [dbo].[Symphony_StockLocations] AS SL ON SLS.[stockLocationID] = SL.[stockLocationID]
        INNER JOIN [dbo].[Symphony_SKUs] AS SK ON SLS.[skuID] = SK.[skuID]
		LEFT JOIN [dbo].[Symphony_ISTPolicy] as IST ON IST.stockLocationID=SLS.stockLocationID AND IST.skuID=SLS.skuID
		LEFT JOIN [dbo].[Symphony_StockLocations] AS OSL ON SLS.[originStockLocation] =  OSL.[stockLocationID]
		LEFT JOIN [dbo].[Symphony_SalesRateSku] SR  ON SLS.stockLocationID = SR.stockLocationID AND SLS.skuID = SR.skuID 
 WHERE SL.isDeleted = 0 AND SLS.isDeleted = 0
		

GO
/****** Object:  View [dbo].[AssortmentGroupBPLevels]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[AssortmentGroupBPLevels] AS
WITH bpLevels as(
SELECT (
		SELECT CONVERT(DECIMAL, flag_value) / 100
		FROM Symphony_Globals
		WHERE flag_name = 'RetailSettings.VarietyPenetrationColorsBlack'
		) blackLevel
	,(
		SELECT CONVERT(DECIMAL, flag_value) / 100
		FROM Symphony_Globals
		WHERE flag_name = 'RetailSettings.VarietyPenetrationColorsRed'
		) redLevel
	,(
		SELECT CONVERT(DECIMAL, flag_value) / 100
		FROM Symphony_Globals
		WHERE flag_name = 'RetailSettings.VarietyPenetrationColorsYellow'
		) yellowLevel
	,(
		SELECT CONVERT(DECIMAL, flag_value) / 100
		FROM Symphony_Globals
		WHERE flag_name = 'RetailSettings.VarietyPenetrationColorsGreen'
		) greenLevel
)
SELECT id assortmentGroupID, bpLevels.* FROM Symphony_AssortmentGroups
CROSS JOIN bpLevels

GO
/****** Object:  View [dbo].[AssortmentGroups]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AssortmentGroups] 
AS 
	SELECT
             LAG.[stockLocationID]
			,SL.stockLocationName
			,SL.stockLocationDescription 
            ,LAG.[assortmentGroupID]
			,SAG.name as assortmentGroupName
			,SAG.[description] as assortmentGroupDescription
			,AGDG.displayGroupID
			,DG.name as displayGroupName
            ,LAG.[varietyTarget]
            ,LAG.[minTarget]
            ,LAG.[maxTarget]
            ,LAG.[notValidFamiliesOverThresholdNum] AS [expiredInvalidFamilyCount]
            ,LAG.[notValidFamiliesNum] - LAG.[notValidFamiliesOverThresholdNum] AS [newlyInvalidFamilies]
            ,LAG.[spaceTarget]
	        ,LAG.[gapMode]	        
	        ,LAG.[spaceType]
            ,LAG.[quantityPerFamily]
            ,LAG.[invalidThresholdFactor]
            ,LAG.[alignmentToInventory]
            ,LAG.[ignoreNrBuffers]
            ,DCP.name as defaultDbmPolicy
            ,LAG.[dominantSalesEstimation]
            ,LAG.[maximumFamiliesPerGroup]
            ,LAG.[attributesSetID]
            ,LAG.[allocationPriority]
            ,LAG.[eligibilityRule]
            ,LAG.[overrideAllocationMethod]
            ,LAG.[limitAllocationToGap]
            ,(CASE WHEN LAG.gapMode = 0 THEN NULL ELSE LAG.[totalSpace] END) AS totalSpace
            ,SumScope.sumInventoryAtSite
            --,SumScope.SumInventoryAtPipe
            --,SumScope.sumBufferSize
            ,CASE LAG.spaceTarget WHEN 0 THEN 0 ELSE (1 - (SumScope.sumBufferSize/LAG.spaceTarget)) END bufferSizePenetration
            ,CASE LAG.spaceTarget WHEN 0 THEN 0 ELSE (1 - (SumScope.sumInventoryAtSite/LAG.spaceTarget)) END inventoryAtSitePenetration
            ,CASE LAG.spaceTarget WHEN 0 THEN 0 ELSE (1 - (SumScope.SumInventoryAtPipe/LAG.spaceTarget)) END inventoryAtPipePenetration
			,CASE varietyTarget WHEN 0 THEN 0 ELSE 1 - ((CAST(SD.[validFamilyCount] as decimal)+ CAST((LAG.[notValidFamiliesNum] - LAG.[notValidFamiliesOverThresholdNum]) as decimal)) /CAST(varietyTarget as decimal)) END varietyPenetration
            ,SD.[familyCount]
            ,SD.[validFamilyCount]
            ,SD.[totalInventory]
            ,SL.slPropertyID1
            ,SL.slPropertyID2
            ,SL.slPropertyID3
            ,SL.slPropertyID4
            ,SL.slPropertyID5
            ,SL.slPropertyID6
            ,SL.slPropertyID7
			,LAG.agCustom_num1
			,LAG.agCustom_num2
			,LAG.agCustom_num3
			,LAG.agCustom_num4
			,LAG.agCustom_num5
			,LAG.agCustom_num6
			,LAG.agCustom_num7
			,LAG.agCustom_num8
			,LAG.agCustom_num9
			,LAG.agCustom_num10
			,LAG.newness
			,LAG.newnessThreshold
			,LAG.oddmentsRatio
			,LAG.enableDTM
            ,LAG.DTMBenchmark
            ,LAG.DTMIncreaseThreshold
            ,LAG.DTMDecreaseThreshold
            ,LAG.DTMDecileForIncrease
            ,LAG.DTMDecileForDecrease
			,LAG.DTMIncreaseFactor
            ,LAG.DTMDecreaseFactor
			,CL.clusterName
			,LAG.familyValidityMethod
			,SL.stockLocationType
			FROM [dbo].[Symphony_LocationAssortmentGroups] LAG
			INNER JOIN [dbo].[Symphony_StockLocations] SL
			ON SL.[stockLocationID] = LAG.[stockLocationID]
			LEFT OUTER JOIN dbo.Symphony_AssortmentGroups AS SAG 
			ON assortmentGroupID = SAG.id
			LEFT JOIN [dbo].[Symphony_AssortmentGroupSummaryData] SD
			ON SD.[assortmentGroupID] = LAG.[assortmentGroupID]
			AND SD.[stockLocationID] = LAG.[stockLocationID]
			LEFT JOIN [dbo].[Symphony_RetailAgDgConnection] AGDG
			ON AGDG.[assortmentGroupID] = LAG.[assortmentGroupID]
			LEFT JOIN dbo.Symphony_DisplayGroups AS DG 
			ON AGDG.displayGroupID = DG.id
			LEFT JOIN [dbo].[Symphony_DBMChangePolicies] DCP
			ON DCP.ID= LAG.[defaultDbmPolicy]
			LEFT JOIN (
			SELECT LAG.assortmentGroupID,
			SLS.stockLocationID,
			SUM(SLS.inventoryAtSite) AS sumInventoryAtSite,
			SUM(SLS.bufferSize) AS sumBufferSize,
			SUM(SLS.inventoryAtSite + SLS.inventoryAtTransit + SLS.inventoryAtProduction) as SumInventoryAtPipe
			FROM [dbo].[Symphony_StockLocationSkus] SLS
			INNER JOIN dbo.Symphony_MasterSkus MS
			ON MS.skuID = SLS.skuID
			INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG
			ON FAG.[familyID] = MS.[familyID]
			INNER JOIN [dbo].[Symphony_LocationAssortmentGroups] LAG
			ON LAG.[assortmentGroupID] = FAG.[assortmentGroupID]
			AND LAG.[stockLocationID] = SLS.[stockLocationID]
			GROUP BY LAG.assortmentGroupID, SLS.stockLocationID
        ) SumScope
         ON SumScope.assortmentGroupID = LAG.assortmentGroupID AND LAG.stockLocationID = SumScope.stockLocationID
		 LEFT JOIN Symphony_RetailClusters CL ON LAG.clusterID = CL.id
         WHERE SL.[isDeleted] = 0

GO
/****** Object:  View [dbo].[BI_Retail_AGs]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--**************************************
--**  Creating BI Views
--**************************************

CREATE VIEW [dbo].[BI_Retail_AGs] 
AS
select AG.name [AG Name],
AG.id [Assortment Group ID],
SL.stockLocationID [Stock Location ID],
SL.stocklocationname [Stock Location Name],
case when LAG.gapMode=0 then 'Variety'
		when LAG.gapMode=1 then 'Space Over Variety'
		when LAG.gapMode=2 then 'Variety Over Space'
End [Gap Mode],
LAG.maxTarget [AG Max Variety],
LAG.minTarget [AG Min Variety],
LAG.varietyTarget [AG Variety Target],
LAG.spaceTarget [AG Space Target],
LAG.validFamiliesNum [Valid Families],
LAG.notValidFamiliesNum [Invalid Familes],
LAG.notValidFamiliesOverThresholdNum [Expired Families],
(LAG.notValidFamiliesNum - LAG.notValidFamiliesOverThresholdNum) [Newly Invalid Families],
case when LAG.spaceManaged=0 then 'No'
		when LAG.spaceManaged=1 then 'Yes'
End [Space Managed],
AGS.familyCount [Total Families],
AGCS.averageConsumptionAG [AG Average Consumption],
CASE LAG.spaceTarget WHEN 0 THEN 0 ELSE convert(decimal(18,2),round((1 - (SumScope.sumBufferSize/LAG.spaceTarget))*100,1)) END [Buffer Size Penetration (Space)],
CASE LAG.spaceTarget WHEN 0 THEN 0 ELSE convert(decimal(18,2),round((1 - (SumScope.sumInventoryAtSite/LAG.spaceTarget))*100,1)) END [Inventory At Site Penetration (Space)],
CASE LAG.spaceTarget WHEN 0 THEN 0 ELSE convert(decimal(18,2),round((1 - (SumScope.SumInventoryAtPipe/LAG.spaceTarget))*100,1)) END [Inventory At Pipe Penetration (Space)],
convert(decimal(18,2),round(LAG.spaceBP*100,1)) [Space Buffer Penetration],
convert(decimal(18,2),round(LAG.agBP*100,1)) [AG Buffer Penetration],
convert(decimal(18,2),round(LAG.varietyBP*100,1)) [Variety Buffer Peneteration],
			totalSpace [Total Space]
					
from Symphony_LocationAssortmentGroups LAG
join Symphony_AssortmentGroups AG on AG.id=LAG.assortmentGroupID
join Symphony_StockLocations SL on SL.stockLocationID=LAG.stockLocationID
left join Symphony_AssortmentGroupSummaryData AGS on AGS.assortmentGroupID=LAG.assortmentGroupID and AGS.stockLocationID=LAG.stockLocationID
left join Symphony_AssortmentGroupConsumptionSummaryData AGCS on AGCS.assortmentGroupID=LAG.assortmentGroupID and AGCS.stockLocationID=LAG.stockLocationID
left join (
		SELECT	MS.assortmentGroupID,       
				SLS.stockLocationID,       
				SUM(SLS.inventoryAtSite) AS sumInventoryAtSite,      
				SUM(SLS.bufferSize) AS sumBufferSize,       
				SUM(SLS.inventoryAtSite + SLS.inventoryAtTransit + SLS.inventoryAtProduction) as SumInventoryAtPipe   
		FROM [dbo].[Symphony_StockLocationSkus] SLS   
		INNER JOIN dbo.Symphony_MasterSkus MS ON MS.skuID = SLS.skuID   GROUP BY MS.assortmentGroupID, SLS.stockLocationID
		) 
		SumScope ON SumScope.assortmentGroupID = LAG.assortmentGroupID AND LAG.stockLocationID = SumScope.stockLocationID 
	where sl.isDeleted=0


GO
/****** Object:  View [dbo].[BI_Retail_DG]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--**********************************


CREATE VIEW [dbo].[BI_Retail_DG] AS
select DG.id [Display Group ID],
DG.name [Display Group Name],
AG.id [Assortment Group ID]
			 
from Symphony_DisplayGroups DG
join Symphony_RetailAgDgConnection AGDG on AGDG.displayGroupID=DG.id
join Symphony_AssortmentGroups AG on AG.id=AGDG.assortmentGroupID


GO
/****** Object:  View [dbo].[BI_StockLocations]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--**********************************


CREATE VIEW [dbo].[BI_StockLocations] 
AS
select sl.stockLocationName [Stock Location Name],
sl.stockLocationID [Stock Location ID],
sl.stocklocationdescription [SL Description],	
SLitm1.slItemName [SL Property 1],
SLitm2.slItemName [SL Property 2],
SLitm3.slItemName [SL Property 3],
SLitm4.slItemName [SL Property 4],
SLitm5.slItemName [SL Property 5],
SLitm6.slItemName [SL Property 6],
SLitm7.slItemName [SL Property 7],
Case 
	when SL.stockLocationType=1 then 'Plant'
	when SL.stockLocationType=2 then 'Supplier'
	when SL.stockLocationType=3 then 'Point of Sale'
	when SL.stockLocationType=4 then 'Transparent'
	when SL.stockLocationType=5 then 'Warehouse'
End [Stock location Type],
--SL.storePriority [Store Priority],
SLorigin.stockLocationName [Default Origin]
				
from Symphony_StockLocations SL 
left join Symphony_StockLocationPropertyItems SLitm1 on sl.slPropertyID1=slitm1.slItemID
left join Symphony_StockLocationPropertyItems SLitm2 on sl.slPropertyID2=slitm2.slItemID
left join Symphony_StockLocationPropertyItems SLitm3 on sl.slPropertyID3=slitm3.slItemID	
left join Symphony_StockLocationPropertyItems SLitm4 on sl.slPropertyID4=slitm4.slItemID
left join Symphony_StockLocationPropertyItems SLitm5 on sl.slPropertyID5=slitm5.slItemID
left join Symphony_StockLocationPropertyItems SLitm6 on sl.slPropertyID6=slitm6.slItemID	
left join Symphony_StockLocationPropertyItems SLitm7 on sl.slPropertyID7=slitm7.slItemID
left join Symphony_StockLocations SLOrigin on SLOrigin.stockLocationID=SL.defaultOriginID
where SL.isDeleted=0
				

GO
/****** Object:  View [dbo].[BufferHistory]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BufferHistory]  
AS
SELECT 
  BST.[bufferSizeTraceabilityID]
  ,BST.[userName]
  ,ALG.[value] as [algReportName]
  ,BST.[stockLocationID]
  ,BST.[skuID]
  ,ISNULL(BST.[uomID],0) as uomID
  ,BST.[date]
  ,BST.[oldBufferSize]
  ,BST.[symphonySuggestedBufferSize]
  ,BST.[requestedNewBufferSize]
  ,BST.[newBufferSize]
  ,BST.[rejectionReason] as [rejectionReasonCode]
  ,BST.[eventName]
  --,REJ.[displayValue] as [rejectionReason]
  ,CASE WHEN W.ID = 0 THEN NULL ELSE W.ID end [tooMuchRedWarning]
  ,SL.stockLocationName, SKU.skuName,
  S.[originStockLocation],
  S.skuDescription, SL.slPropertyID1,SL.slPropertyID2,SL.slPropertyID3,SL.slPropertyID4,SL.slPropertyID5,SL.slPropertyID6,SL.slPropertyID7,  
  S.skuPropertyID1, S.skuPropertyID2, S.skuPropertyID3, S.skuPropertyID4, S.skuPropertyID5, S.skuPropertyID6, S.skuPropertyID7,  
  S.custom_txt1, S.custom_txt2, S.custom_txt3, S.custom_txt4, S.custom_txt5,  
  S.custom_txt6, S.custom_txt7, S.custom_txt8, S.custom_txt9, S.custom_txt10,  
  S.custom_num1, S.custom_num2, S.custom_num3, S.custom_num4, S.custom_num5,  
  S.custom_num6, S.custom_num7, S.custom_num8, S.custom_num9, S.custom_num10  
FROM  
  [dbo].Symphony_BufferSizeTraceability as BST 
  INNER JOIN [dbo].Symphony_StockLocations AS SL ON BST.stockLocationID = SL.stockLocationID  
  INNER JOIN [dbo].Symphony_StockLocationSkus AS S ON BST.skuID = S.skuID AND BST.stockLocationID = S.stockLocationID  
  INNER JOIN [dbo].Symphony_SKUs AS SKU ON BST.skuID = SKU.skuID
  LEFT JOIN [dbo].Symphony_BufferSizeAlgReportNames ALG ON BST.[algorithmReportName] = ALG.[value]
 -- LEFT JOIN [dbo].Symphony_BufferRejectionReasons REJ ON BST.rejectionReason = REJ.value
  LEFT JOIN [dbo].Symphony_TooMuchRedGreenWarning W ON W.ID = BST.tooMuchRedWarning
WHERE S.isDeleted = 0 AND SL.isDeleted = 0

GO
/****** Object:  View [dbo].[BufferSizeAlgorithmReportNames]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[BufferSizeAlgorithmReportNames]
AS
SELECT 
	 [value]
    ,[displayValue]
  FROM [dbo].[Symphony_BufferSizeAlgReportNames]


GO
/****** Object:  View [dbo].[BufferSizeRecommendationsAttention]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[BufferSizeRecommendationsAttention]
AS
SELECT     RDL.ID, 
0 AS recommendationStatus,
S.skuName AS skuName,
RDL.stockLocationID, 
SL.stockLocationName, 
RDL.skuID, 
RDL.recommendationType, 
RDL.oldBufferSize, 
RDL.bufferSizeAfterChange, 
RDL.tooMuchRedWarning, 
RDL.updateDate,
SL.stockLocationDescription, SLS.skuDescription, SLS.locationSkuName, SLS.uomID, SLS.bufferSize, SLS.minimumBufferSize, ISNULL(SLS.notes,N'') as notes, SLS.originStockLocation,  
SLS.skuPropertyID1, SLS.skuPropertyID2, SLS.skuPropertyID3, SLS.skuPropertyID4, SLS.skuPropertyID5, SLS.skuPropertyID6, SLS.skuPropertyID7, 
SLS.[custom_num1],SLS.[custom_num2],SLS.[custom_num3],SLS.[custom_num4],SLS.[custom_num5],SLS.[custom_num6],SLS.[custom_num7],SLS.[custom_num8],SLS.[custom_num9],SLS.[custom_num10]
,SLS.custom_txt1, SLS.custom_txt2,SLS.custom_txt3,SLS.custom_txt4,SLS.custom_txt5,SLS.custom_txt6,SLS.custom_txt7,SLS.custom_txt8,SLS.custom_txt9,SLS.custom_txt10
,SL.slPropertyID1,  SL.slPropertyID2, SL.slPropertyID3, SL.slPropertyID4, SL.slPropertyID5, SL.slPropertyID6, SL.slPropertyID7
FROM  dbo.Symphony_DBMAttentions AS RDL 
	INNER JOIN dbo.Symphony_StockLocationSkus AS SLS 
		ON RDL.stockLocationID = SLS.stockLocationID AND RDL.skuID = SLS.skuID 
	INNER JOIN dbo.Symphony_StockLocations AS SL 
		ON SLS.stockLocationID = SL.stockLocationID
    INNER JOIN dbo.Symphony_SKUs AS S
		ON SLS.skuID = S.skuID
WHERE     
	(SLS.isDeleted = 0) AND (SL.isDeleted = 0)

GO
/****** Object:  View [dbo].[BufferSizeRecommendationsGeneralView]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BufferSizeRecommendationsGeneralView] as
SELECT
	--id,
	id [uniqueId],
	0 AS recommendationStatus,
	SLS.stockLocationID,
	SL.stockLocationName,
	SL.stockLocationDescription,
	OSL.stockLocationName as originStockLocationName,
	SL.slPropertyID1,
	SL.slPropertyID2,
	SL.slPropertyID3,
	SL.slPropertyID4,
	SL.slPropertyID5,
	SL.slPropertyID6,
	SL.slPropertyID7,
	SL.slCustom_num1,
	SL.slCustom_num2,
	SL.slCustom_num3,
	SL.slCustom_num4,
	SL.slCustom_num5,
	SL.slCustom_num6,
	SL.slCustom_num7,
	SL.slCustom_num8,
	SL.slCustom_num9,
	SL.slCustom_num10,
	SLS.skuID,
	S.skuName,
	SLS.skuDescription,
	SLS.bufferSize,
	SLS.newBufferSize,
	SLS.skuPropertyID1,
	SLS.skuPropertyID2,
	SLS.skuPropertyID3,
	SLS.skuPropertyID4,
	SLS.skuPropertyID5,
	SLS.skuPropertyID6,
	SLS.skuPropertyID7,
	SLS.minimumBufferSize,
	SLS.originStockLocation,
	SLS.uomID,
	SLS.recommendationType,
	SLS.notes,
	SLS.bufferManagementPolicy,
	SLS.custom_num1,
	SLS.custom_num2,
	SLS.custom_num3,
	SLS.custom_num4,
	SLS.custom_num5,
	SLS.custom_num6,
	SLS.custom_num7,
	SLS.custom_num8,
	SLS.custom_num9,
	SLS.custom_num10,
	SLS.custom_txt1,
	SLS.custom_txt2,
	SLS.custom_txt3,
	SLS.custom_txt4,
	SLS.custom_txt5,
	SLS.custom_txt6,
	SLS.custom_txt7,
	SLS.custom_txt8,
	SLS.custom_txt9,
	SLS.custom_txt10,
	SLS.siteColor,
	SLS.productionColor,
	SLS.newBufferSize AS suggestedBufferSize,
	CASE WHEN SLS.tooMuchRedWarning = 0 THEN NULL ELSE SLS.tooMuchRedWarning end [tooMuchRedWarning],
	SE.name [eventName]
	
FROM dbo.Symphony_StockLocationSkus AS SLS
INNER JOIN dbo.Symphony_StockLocations AS SL
	ON SLS.stockLocationID = SL.stockLocationID
LEFT JOIN dbo.Symphony_StockLocations AS OSL
	ON SLS.originStockLocation = OSL.stockLocationID
INNER JOIN dbo.Symphony_SKUs AS S
	ON SLS.skuID = S.skuID
LEFT JOIN dbo.Symphony_SeasonalityInstances SE 
	ON SE.stockLocationID = SLS.[stockLocationID] AND SE.itemID = SLS.skuID AND 
	SE.name IS NOT NULL AND SE.eventState = 2 AND SLS.recommendationType in (3, 13)
WHERE SLS.isDeleted = 0
AND SLS.recommendationType > 0

GO
/****** Object:  View [dbo].[BufferSizeTraceability]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[BufferSizeTraceability] AS(
SELECT 
	   BST.[bufferSizeTraceabilityID][uniqueId]
	  ,BST.[bufferSizeTraceabilityID]
      ,BST.[userName]
      ,BST.[algorithmReportName]
      ,BST.[stockLocationID]
      ,BST.[skuID]
      ,BST.[uomID]
      ,BST.[date]
      ,BST.[oldBufferSize]
      ,BST.[symphonySuggestedBufferSize]
      ,BST.[requestedNewBufferSize]
      ,BST.[newBufferSize]
      ,BST.[rejectionReason]
      ,BST.[isAvoidedBufferChange]
	  ,BST.[eventName]
      ,CASE WHEN BST.[tooMuchRedWarning] = 0 THEN NULL ELSE BST.[tooMuchRedWarning] end [tooMuchRedWarning]
  FROM [dbo].[Symphony_BufferSizeTraceability] BST
  INNER JOIN [dbo].[Symphony_StockLocationSkus] SLS
  ON SLS.stockLocationID = BST.stockLocationID
  AND SLS.skuID = BST.skuID
  )

GO
/****** Object:  View [dbo].[CustomProperty_SL]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[CustomProperty_SL]
AS
WITH [propertyCounts] as
(
SELECT 
	 [propType]
	,MIN([ID]) [propertyCount]
FROM [dbo].[Symphony_StockLocationProperty]
GROUP BY [propType]
)
SELECT ISNULL( [ID] - PC.[propertyCount] + 1, -1) [Index]
	,ISNULL(CONVERT(tinyint, CASE P.[propType]
		WHEN 0 THEN 1
		WHEN 1 THEN 7
	 END), 0) [PropertyType]
	,[slPropertyID] [FieldName]
	,[slPropertyName] [Caption]
FROM [dbo].[Symphony_StockLocationProperty] P
INNER JOIN [propertyCounts] PC
ON PC.[propType] = P.[propType]

GO
/****** Object:  View [dbo].[CustomProperty_SLS]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[CustomProperty_SLS]
AS
WITH [propertyCounts] as
(
SELECT 
	 [propType]
	,MIN([ID]) [propertyCount]
FROM [dbo].[Symphony_SKUsProperty]
GROUP BY [propType]
)

SELECT ISNULL([ID] - PC.[propertyCount] + 1, -1) [Index]
	,ISNULL(CONVERT( tinyint, CASE P.[propType]
		WHEN 0 THEN 0
		WHEN 1 THEN 5
		WHEN 2 THEN 6
	 END), 0) [PropertyType]
	,[skuPropertyID] [FieldName]
	,[skuPropertyName] [Caption]
FROM [dbo].[Symphony_SKUsProperty] P
INNER JOIN [propertyCounts] PC
ON PC.[propType] = P.[propType]

GO
/****** Object:  View [dbo].[CustomPropertyItem_SL]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[CustomPropertyItem_SL]
AS
SELECT P.[id] [Index]
	,[slItemID] [Value]
	,I.[slPropertyID] [FieldName]
	,[slItemName] [DisplayValue]
--	,CONVERT(tinyint, 1) [PropertyType]
FROM [dbo].[Symphony_StockLocationPropertyItems] I
INNER JOIN [dbo].[Symphony_StockLocationProperty] P ON P.[slPropertyID] = I.[slPropertyID]

GO
/****** Object:  View [dbo].[CustomPropertyItem_SLS]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[CustomPropertyItem_SLS]
AS
SELECT P.[ID] [Index]
	,[skuItemID] [Value]
	,I.[skuPropertyID] [FieldName]
	,[skuItemName] [DisplayValue]
--	,CONVERT(tinyint, 0) [PropertyType]
FROM [dbo].[Symphony_SKUsPropertyItems] I
INNER JOIN [dbo].[Symphony_SKUsProperty] P 
ON P.[skuPropertyID] = I.[skuPropertyID]

GO
/****** Object:  View [dbo].[CustomReportsSharing]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CustomReportsSharing]
AS
	SELECT CR.ID as reportID, CR.name as reportName,CR.date as creationDate, 
	CR.userName as createdBy, CR.description as reportDescription, SHARED.userPasswordID,
	CASE WHEN ASSIGNED.ID IS NOT NULL THEN 0 ELSE 1 END AS assignedToMe
	FROM [Symphony_CustomReports] CR
	INNER JOIN  
    (SELECT DISTINCT reportID, ISNULL(G.userPasswordID, CRM.userPasswordID) as userPasswordID from 
    Symphony_CustomReportsSharingManagement CRM
    LEFT JOIN Symphony_UserReportGroups G ON CRM.reportGroupID = G.reportGroupID AND CRM.userPasswordID IS NULL) SHARED
	ON CR.ID = SHARED.reportID
	LEFT JOIN Symphony_CustomReportsUsers ASSIGNED ON CR.ID = ASSIGNED.reportID AND SHARED.userPasswordID = ASSIGNED.userID

GO
/****** Object:  View [dbo].[DashboardSharingView]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DashboardSharingView]
AS
	SELECT WD.id, WD.[name], WD.orderID, SHARED.userPasswordID
	FROM Symphony_WebDashboards WD
	JOIN
	(SELECT DISTINCT dashboardID, ISNULL(G.userPasswordID, DRM.userPasswordID) as userPasswordID from 
    Symphony_DashboardSharingManagement DRM
    LEFT JOIN Symphony_UserReportGroups G ON DRM.reportGroupID = G.reportGroupID AND DRM.userPasswordID IS NULL) SHARED
	ON WD.ID = SHARED.dashboardID

GO
/****** Object:  View [dbo].[DisplayGroups]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DisplayGroups]
AS
SELECT     
LDG.id AS uniqueId, 
LDG.stockLocationID, 
SL.stockLocationName, 
SL.stockLocationDescription, 
LDG.displayGroupID, 
DG.name as displayGroupName,
DG.[description] as displayGroupDescription,
LDG.minQuantity, 
LDG.maxQuantity, 
LDG.minCost, 
LDG.maxCost, 
SL.slPropertyID1, 
SL.slPropertyID2, 
SL.slPropertyID3, 
SL.slPropertyID4, 
SL.slPropertyID5, 
SL.slPropertyID6, 
SL.slPropertyID7,
SM.totalInventory, 
SM.totalCost, 
SM.existingAGs,
LDG.dgCustom_num1,
LDG.dgCustom_num2,
LDG.dgCustom_num3,
LDG.dgCustom_num4,
LDG.dgCustom_num5,
LDG.dgCustom_num6,
LDG.dgCustom_num7,
LDG.dgCustom_num8,
LDG.dgCustom_num9,
LDG.dgCustom_num10
FROM Symphony_LocationDisplayGroups AS LDG 
JOIN Symphony_DisplayGroups as DG
ON LDG.displayGroupID = DG.id
INNER JOIN Symphony_StockLocations AS SL ON SL.stockLocationID = LDG.stockLocationID
LEFT OUTER JOIN Symphony_DisplayGroupSummaryData AS SM 
ON LDG.displayGroupID = SM.displayGroupID AND LDG.stockLocationID = SM.stockLocationID 
WHERE     (SL.isDeleted = 0)

GO
/****** Object:  View [dbo].[Distribution_History]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--**********************************


CREATE VIEW [dbo].[Distribution_History] 
AS
SELECT 	sl.stockLocationName [Stock Location Name],
His.stockLocationID [Stock Location ID],
His.skuID [SKU ID],
sku.skuName [SKU Name], 
convert(datetime, convert(int, convert(float, His.updateDate))) [SKU's History Date],
Ag.name [AG Name],
DG.name [DG Name],
sls.skuDescription [SKU Description],
sls.Throughput,
convert(decimal(18,0),His.bufferSize) [Buffer Size],
convert(decimal(18,0),His.inventoryAtSite) [Inventory At Site],
convert(decimal(18,0),His.inventoryAtProduction) [Inventory At Production],
convert(decimal(18,0),His.inventoryAtTransit) [Inventory At Transit],
convert(decimal(18,0),His.consumption) [Consumption],
convert(decimal(18,0),His.totalIn) [Total In Qty],
convert(decimal(18,0),His.returned) [Total returned Qty],
convert(decimal(18,0),His.unitPrice) [Unit Price],
convert(decimal(18,2),round(His.bpSite*100,1)) [Buffer Penetration (Site)],
convert(decimal(18,2),round(His.bpTransit*100,1)) [Buffer Penetration (Transit)],
convert(decimal(18,2),round(His.bpProduction*100,1)) [Buffer Penetration (Production)],
originsl.stockLocationName [Origin Stock Location],			
Itm1.skuItemName [SKU Property 1],
Itm2.skuItemName [SKU Property 2],
Itm3.skuItemName [SKU Property 3],
Itm4.skuItemName [SKU Property 4],
Itm5.skuItemName [SKU Property 5],
Itm6.skuItemName [SKU Property 6],
Itm7.skuItemName [SKU Property 7],		
slitm1.slItemName [SL Property 1],
SLitm2.slItemName [SL Property 2],
SLitm3.slItemName [SL Property 3],
SLitm4.slItemName [SL Property 4],
SLitm5.slItemName [SL Property 5],
SLitm6.slItemName [SL Property 6],
SLitm7.slItemName [SL Property 7],
case 
	when SL.stockLocationType=1 then 'Plant'
	when SL.stockLocationType=2 then 'Supplier'
	when SL.stockLocationType=3 then 'Point of Sale'
	when SL.stockLocationType=4 then 'Transparent'
	when SL.stockLocationType=5 then 'Warehouse'
End [Stock location Type],
		
case 
	when His.originType=1 then 'Plant'
	when His.originType=2 then 'Supplier'
	when His.originType=3 then 'Point of Sale'
	when His.originType=4 then 'Transparent'
	when His.originType=5 then 'Warehouse'
End [Origin SL Type],
convert(decimal(18,0),His.safetyStock) [Safety Stock],
sls.custom_num1 [Custom Number 1],
sls.custom_num2 [Custom Number 2],
sls.custom_num3 [Custom Number 3],
sls.custom_num4 [Custom Number 4],
sls.custom_num5 [Custom Number 5],
sls.custom_num6 [Custom Number 6],
sls.custom_num7 [Custom Number 7],
sls.custom_num8 [Custom Number 8],
sls.custom_num9 [Custom Number 9],
sls.custom_num10 [Custom Number 10],
sls.custom_txt1 [Custom Text 1],
sls.custom_txt2 [Custom Text 2],
sls.custom_txt3 [Custom Text 3],
sls.custom_txt4 [Custom Text 4],
sls.custom_txt5 [Custom Text 5],
sls.custom_txt6 [Custom Text 6],
sls.custom_txt7 [Custom Text 7],
sls.custom_txt8 [Custom Text 8],
sls.custom_txt9 [Custom Text 9],
sls.custom_txt10 [Custom Text 10]
		
FROM Symphony_StockLocationSkuHistory His 
join Symphony_StockLocationSkus sls on His.skuID=sls.skuID and His.stockLocationID=sls.stockLocationID
join Symphony_SKUs SKU on SKU.skuID=sls.skuID
join Symphony_StockLocations SL on SL.stockLocationID=sls.stockLocationID
left join Symphony_SKUsPropertyItems Itm1 on sls.skuPropertyID1=Itm1.skuItemID
left join Symphony_SKUsPropertyItems Itm2 on sls.skuPropertyID2=Itm2.skuItemID
left join Symphony_SKUsPropertyItems Itm3 on sls.skuPropertyID3=Itm3.skuItemID
left join Symphony_SKUsPropertyItems Itm4 on sls.skuPropertyID4=Itm4.skuItemID
left join Symphony_SKUsPropertyItems Itm5 on sls.skuPropertyID5=Itm5.skuItemID
left join Symphony_SKUsPropertyItems Itm6 on sls.skuPropertyID6=Itm6.skuItemID
left join Symphony_SKUsPropertyItems Itm7 on sls.skuPropertyID7=Itm7.skuItemID
left join Symphony_StockLocationPropertyItems SLitm1 on sl.slPropertyID1=slitm1.slItemID
left join Symphony_StockLocationPropertyItems SLitm2 on sl.slPropertyID2=slitm2.slItemID
left join Symphony_StockLocationPropertyItems SLitm3 on sl.slPropertyID3=slitm3.slItemID	
left join Symphony_StockLocationPropertyItems SLitm4 on sl.slPropertyID4=slitm4.slItemID
left join Symphony_StockLocationPropertyItems SLitm5 on sl.slPropertyID5=slitm5.slItemID
left join Symphony_StockLocationPropertyItems SLitm6 on sl.slPropertyID6=slitm6.slItemID	
left join Symphony_StockLocationPropertyItems SLitm7 on sl.slPropertyID7=slitm7.slItemID	
left join Symphony_stocklocations Originsl on originsl.stockLocationID=His.originStockLocation
left join Symphony_UOM UOM on uom.uomID=sls.uomID 
left join Symphony_DBMChangePolicies dbm on dbm.ID=sls.bufferManagementPolicy 
left join Symphony_MasterSkus MAS on MAS.skuID=sku.skuID
left join Symphony_AssortmentGroups AG on MAS.assortmentGroupID=AG.id
left join Symphony_RetailAgDgConnection AGDG on AGDG.assortmentGroupID=MAS.assortmentGroupID
left join Symphony_DisplayGroups DG on DG.id=AGDG.displayGroupID
where sls.isDeleted=0 and sl.isDeleted=0

GO
/****** Object:  View [dbo].[DPLMFamilyItemInfo]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DPLMFamilyItemInfo]
AS
SELECT [stockLocationID]
	,[stockLocationName]
	,[stockLocationDescription]
	,[familyID]
	,[familyName]
	,[familyDescription]
	,[skuID]
	,[locationSkuName] 
	,[skuDescription]
FROM (
	SELECT SL.[stockLocationID]
		,SL.[stockLocationName]
		,SL.[stockLocationDescription]
		,F.[id] [familyID]
		,F.[name] [familyName]
		,F.[familyDescription]
		,MAS.[skuID]
		,MTS.[locationSkuName] 
		,MTS.[skuDescription]
	FROM [dbo].[Symphony_StockLocations] SL
	INNER JOIN [dbo].[Symphony_LocationAssortmentGroups] LAG
		ON LAG.[stockLocationID] = SL.[stockLocationID]
	INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG
		ON FAG.[assortmentGroupID] = LAG.[assortmentGroupID]
	INNER JOIN [dbo].[Symphony_SkuFamilies] F
		ON F.[id] = FAG.[familyID]
	INNER JOIN [dbo].[Symphony_MasterSkus] MAS
		ON MAS.familyID = F.[id] 
	INNER  JOIN [Symphony_StockLocationSkus] MTS
        ON MAS.skuID = MTS.skuID AND MTS.stockLocationID = SL.stockLocationID
	) TMP

GO
/****** Object:  View [dbo].[DPLMPendingActions]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DPLMPendingActions]
AS
SELECT
	MAX(DA.ID) AS [uniqueId]
   ,MAX(DA.[calculationDate]) AS [calculationDate]
   ,DA.[stockLocationID]
   ,MAX(SL.[stockLocationName]) AS [stockLocationName]
   ,MAX(Rad.[displayGroupID]) [displayGroupID]
   ,MAX(SDG.[name]) AS [DGName]
   ,MAX(Rfa.[assortmentGroupID]) AS [assortmentGroupID]
   ,MAX(SAG.[name]) AS [AGName]
   ,DA.[familyID]
   ,MAX(SF.[Name]) AS [itemName]
   ,MAX(SF.[familyDescription]) AS [itemDescription]
   ,MAX(Dsp.[policyID]) AS [policyID]
   ,MAX(Dsp.[previousStateID]) AS [previousStateID]
   ,MAX(DpsP.[stateName]) AS [previousState]
   ,MAX(Dsp.[currentStateID]) AS [currentStateID]
   ,MAX(DpsC.[stateName]) AS [currentState]
   ,MAX(AL.[actionText]) AS [actionText]
   ,MAX(DAP.[resultActionsPresenting]) AS [resultActionsPresenting]
   ,MAX(DAP.[resultActions]) AS [resultActionsExecute]
   ,MAX(DAP.[resultActionsBufferSize]) AS [resultActionsBufferSize]
   ,CONVERT(bit, MAX(CONVERT(int, DA.[isIndependent]))) AS [isIndependent]
   ,CONVERT(bit, MAX(CONVERT(int, DA.[automatic]))) AS [automatic]
   ,MAX(DA.[actionStatus]) AS [actionStatus]
   ,MAX(DA.[ruleType]) AS [ruleType]
   ,MAX(DA.[ruleId]) AS [ruleId]
   ,MAX(DA.[userID]) AS [userID]
   ,MAX(DA.[actionsDate]) AS [actionsDate]
   ,MAX(SL.[slPropertyID1]) AS [slPropertyID1]
   ,MAX(SL.[slPropertyID2]) AS [slPropertyID2]
   ,MAX(SL.[slPropertyID3]) AS [slPropertyID3]
   ,MAX(SL.[slPropertyID4]) AS [slPropertyID4]
   ,MAX(SL.[slPropertyID5]) AS [slPropertyID5]
   ,MAX(SL.[slPropertyID6]) AS [slPropertyID6]
   ,MAX(SL.[slPropertyID7]) AS [slPropertyID7]
   ,MAX(SLS.[bufferSize]) AS [bufferSize]
   ,MAX(SLS.[uomID]) AS [uomID]
   ,MAX(SLS.[inventoryAtSite]) AS [inventoryAtSite]
   ,MAX(SLS.[saftyStock]) AS [safetyStock]
   ,MAX(SLS.[tvc]) AS [tvc]
   ,MAX(SLS.TVC * DAP.resultActionsBufferSize) AS [newBufferSize]
   ,MAX(SLS.[skuPropertyID1]) AS [skuPropertyID1]
   ,MAX(SLS.[skuPropertyID2]) AS [skuPropertyID2]
   ,MAX(SLS.[skuPropertyID3]) AS [skuPropertyID3]
   ,MAX(SLS.[skuPropertyID4]) AS [skuPropertyID4]
   ,MAX(SLS.[skuPropertyID5]) AS [skuPropertyID5]
   ,MAX(SLS.[skuPropertyID6]) AS [skuPropertyID6]
   ,MAX(SLS.[skuPropertyID7]) AS [skuPropertyID7]
   ,MAX(SLS.[custom_num1]) AS [custom_num1]
   ,MAX(SLS.[custom_num2]) AS [custom_num2]
   ,MAX(SLS.[custom_num3]) AS [custom_num3]
   ,MAX(SLS.[custom_num4]) AS [custom_num4]
   ,MAX(SLS.[custom_num5]) AS [custom_num5]
   ,MAX(SLS.[custom_num6]) AS [custom_num6]
   ,MAX(SLS.[custom_num7]) AS [custom_num7]
   ,MAX(SLS.[custom_num8]) AS [custom_num8]
   ,MAX(SLS.[custom_num9]) AS [custom_num9]
   ,MAX(SLS.[custom_num10]) AS [custom_num10]
   ,MAX(SLS.[custom_txt1]) AS [custom_txt1]
   ,MAX(SLS.[custom_txt2]) AS [custom_txt2]
   ,MAX(SLS.[custom_txt3]) AS [custom_txt3]
   ,MAX(SLS.[custom_txt4]) AS [custom_txt4]
   ,MAX(SLS.[custom_txt5]) AS [custom_txt5]
   ,MAX(SLS.[custom_txt6]) AS [custom_txt6]
   ,MAX(SLS.[custom_txt7]) AS [custom_txt7]
   ,MAX(SLS.[custom_txt8]) AS [custom_txt8]
   ,MAX(SLS.[custom_txt9]) AS [custom_txt9]
   ,MAX(SLS.[custom_txt10]) AS [custom_txt10]
FROM [dbo].[Symphony_DPLM_Actions] DA
LEFT JOIN [dbo].[Symphony_RetailFamilyAgConnection] Rfa
	ON DA.familyID = Rfa.familyID
INNER JOIN [dbo].[Symphony_LocationAssortmentGroups] LAG
	ON LAG.assortmentGroupID = Rfa.assortmentGroupID
		AND LAG.stockLocationID = DA.stockLocationID
LEFT JOIN [dbo].[Symphony_RetailAgDgConnection] Rad
	ON Rfa.assortmentGroupID = Rad.assortmentGroupID
INNER JOIN [dbo].[Symphony_DisplayGroups] SDG
	ON SDG.id = Rad.displayGroupID
INNER JOIN [dbo].[Symphony_AssortmentGroups] SAG
	ON SAG.id = Rad.assortmentGroupID
INNER JOIN [dbo].[Symphony_DPLM_PoliciesRules] Dpr
	ON DA.ruleId = Dpr.ID
INNER JOIN [dbo].[Symphony_DPLM_StockLocationFamilyPolicy] Dsp
	ON Dsp.stockLocationID = DA.stockLocationID
		AND Dsp.familyID = DA.familyID
LEFT JOIN dbo.Symphony_DPLM_ActionsPresenting DAP
	ON DAP.familyID = DA.familyID
		AND DA.ruleId = DAP.ruleID
		AND DAP.stockLocationID = DA.stockLocationID
INNER JOIN [dbo].[Symphony_DPLM_PoliciesStates] DpsP
	ON Dsp.previousStateID = DpsP.ID
INNER JOIN [dbo].[Symphony_DPLM_PoliciesStates] DpsC
	ON Dsp.currentStateID = DpsC.ID
INNER JOIN [dbo].[Symphony_StockLocations] SL
	ON DA.stockLocationID = SL.stockLocationID
		AND SL.isdeleted = 0
LEFT JOIN [dbo].[Symphony_SkuFamilies] SF
	ON SF.id = DA.familyID
LEFT JOIN [dbo].[Symphony_DPLM_ActionLookup] AL
	ON AL.ID = DA.actionTextID
LEFT JOIN [dbo].[Symphony_MasterSkus] MAS
    ON MAS.familyID  = DA.familyID 
LEFT JOIN [dbo].[Symphony_StockLocationSkus] SLS
	ON SLS.stockLocationID = SL.stockLocationID
		AND SLS.skuID = MAS.skuID
LEFT JOIN [dbo].[Symphony_DBMChangePolicies] AS DCP
	ON DCP.ID = SLS.bufferManagementPolicy
WHERE DA.[actionStatus] = 0
GROUP BY DA.stockLocationID, DA.familyID 

GO
/****** Object:  View [dbo].[DPLMPendingActionsSkuAux]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DPLMPendingActionsSkuAux]
AS
SELECT  MTS.[stockLocationID],MAS.[familyID],SF.[name] as familyName ,MTS.[skuID],MTS.[locationSkuName]  
    FROM  [dbo].[Symphony_MasterSkus] MAS
    INNER  JOIN [Symphony_StockLocationSkus] MTS
        ON MAS.skuID = MTS.skuID
    INNER  JOIN [Symphony_SkuFamilies] SF	
        ON SF.id = MAS.familyID

GO
/****** Object:  View [dbo].[DPLMSkuItemInfo]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DPLMSkuItemInfo]
AS
SELECT [stockLocationID]
	,[stockLocationName]
	,[stockLocationDescription]
	,[familyID]
	,[skuName]
	,[skuDescription]
FROM (
	SELECT SL.[stockLocationID]
		,SL.[stockLocationName]
		,SL.[stockLocationDescription]
		,F.[id] [familyID]
		,SKU.[skuName]
		,SLS.[skuDescription]
	FROM [dbo].[Symphony_StockLocations] SL
	INNER JOIN [dbo].[Symphony_LocationAssortmentGroups] LAG
		ON LAG.[stockLocationID] = SL.[stockLocationID]
	INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG
		ON FAG.[assortmentGroupID] = LAG.[assortmentGroupID]
	INNER JOIN [dbo].[Symphony_SkuFamilies] F
		ON F.[id] = FAG.[familyID]
	INNER JOIN [dbo].[Symphony_SKUs] SKU
		ON SKU.[skuName] = F.[name]
	LEFT JOIN [dbo].[Symphony_StockLocationSkus] SLS
		ON SLS.[stockLocationID] = SL.[stockLocationID]
			AND SLS.[skuID] = SKU.[skuID]
	) TMP


GO
/****** Object:  View [dbo].[DTM]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[DTM]
AS
SELECT  VR.[id],
VR.[updateDate],
VR.[creationDate],
VR.[stockLocationID],
SL.[stockLocationName],
SL.[stockLocationDescription],
VR.[displayGroupID],
DG.[name] as [displayGroupName],
VR.[assortmentGroupID],
AG.[name] AS assortmentGroupName,
AG.[description] as assortmentGroupDescription,
VR.[recommendedVarietyTarget],
VR.[status],
SD.[familyCount],
SD.[validFamilyCount],
SD.[totalInventory],
LAG.[varietyTarget],
LAG.[maxTarget],
LAG.[minTarget],
SL.slPropertyID1,SL.slPropertyID2,SL.slPropertyID3,SL.slPropertyID4,SL.slPropertyID5,SL.slPropertyID6,SL.slPropertyID7,
LAG.[spaceTarget],
LAG.[totalSpace],
VR.[recommendedSpaceTarget],
VR.[salesPerformance],
LAG.[DTMBenchmark],
LAG.[oddmentsRatio],
LAG.[quantityPerFamily],
VR.[calculatedVarietyTarget],
VR.[suggestedVarietyTarget],
VR.[recommendationType],
VR.[increaseVariety]

FROM [dbo].[Symphony_AssortmentGroupVarietyRecommendations] VR 
INNER JOIN [dbo].[Symphony_LocationAssortmentGroups] LAG 
	ON LAG.[stockLocationID] = VR.[stockLocationID] AND LAG.[assortmentGroupID] = VR.[assortmentGroupID] 
INNER JOIN [dbo].[Symphony_AssortmentGroupSummaryData] SD 
	ON SD.[stockLocationID] = VR.[stockLocationID] AND SD.[assortmentGroupID] = VR.[assortmentGroupID] 
INNER JOIN [dbo].[Symphony_StockLocations] SL ON SL.[stockLocationID] = VR.[stockLocationID] 
LEFT JOIN Symphony_AssortmentGroups AG ON LAG.assortmentGroupID = AG.id
LEFT JOIN Symphony_DisplayGroups DG ON VR.displayGroupID = DG.id
WHERE SL.[isDeleted] = 0

GO
/****** Object:  View [dbo].[ExistingAGsBreakdown]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ExistingAGsBreakdown]
AS
SELECT
LAG.stockLocationID
,LAG.displayGroupID
,FVR.[familyID]
,families.name as familyName
,FVR.[isValid]
,LAG.[assortmentGroupID]
,AG.name as [assortmentGroupName]
FROM(
SELECT LAG.[stockLocationID]                                    
,LAG.[assortmentGroupID] 
,AGDG.[displayGroupid]
FROM [dbo].[Symphony_LocationAssortmentGroups] LAG
INNER JOIN [dbo].[Symphony_RetailAgDgConnection] AGDG
ON AGDG.[assortmentGroupID] = LAG.[assortmentGroupID]
) LAG
INNER JOIN [dbo].[Symphony_FamilyValidationResults] FVR
ON FVR.[assortmentGroupID] = LAG.[assortmentGroupID]
AND FVR.[stockLocationID] = LAG.[stockLocationID]
JOIN [dbo].[Symphony_AssortmentGroups] AG
ON AG.id = LAG.assortmentGroupID
JOIN [dbo].[Symphony_SkuFamilies] families
ON families.id = FVR.familyID


GO
/****** Object:  View [dbo].[Families_StockLocationsVisualScreen_View]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Families_StockLocationsVisualScreen_View] AS

SELECT LAG.*, IMG.[image] as images
FROM Symphony_Aux_LocationAssortment LAG
LEFT JOIN Symphony_SkuFamilies F
ON F.id = LAG.familyID
LEFT JOIN Symphony_Images IMG
ON IMG.id = F.imageID


GO
/****** Object:  View [dbo].[Families_StockLocationsVisualScreenChart_View]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Families_StockLocationsVisualScreenChart_View] AS 

SELECT stockLocationID,familyID,consumption,weeklyDateEnd
FROM [dbo].[Symphony_WeeklyLocationFamilyConsumption]


GO
/****** Object:  View [dbo].[Families_StockLocationsVisualScreenInventory_View]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Families_StockLocationsVisualScreenInventory_View] AS 
SELECT
	MTS.stocklocationID
   ,MAS.familyID
   ,MAS.familyMemberID
   ,MTS.inventoryAtSite
   ,SSM.Name
FROM  Symphony_MasterSkus MAS 
INNER JOIN 	Symphony_StockLocationSKUs MTS
 	ON MTS.skuID = MAS.skuID AND MTS.isDeleted = 0 
INNER JOIN Symphony_SkuFamilyMembers SSM
ON SSM.id = MAS.familyMemberID


GO
/****** Object:  View [dbo].[FamilyDiscounts]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE VIEW [dbo].[FamilyDiscounts]
AS
(
SELECT AUX.[familyID]
      ,[familyName]
	  ,[assortmentGroupID]
	  ,[displayGroupID]
      ,[assortmentGroupName]
      ,[displayGroupName]
	  ,[liquidationGroup]
      ,FD.[percentDiscount]
      ,CASE WHEN (FD.[percentDiscount] IS NULL OR FD.[percentDiscount] = 0) AND  FD.[newPercentDiscount] = 0 THEN NULL
	  ELSE FD.[newPercentDiscount]
	  END [newPercentDiscount]
      ,FD.[updateDate]
      ,[weeklyFamilySalesRate]
      ,[coverage]
      ,[assortmentGroupHBT]
      ,[totalInventory]
      ,[totalInventoryStores]
      ,[totalInventoryWarehouses]
		,[totalInventory] * [unitPrice] * (1 - (ISNULL(FD.percentDiscount/ 100, 0))) [totalValueDiscounted]
		,[weeklyFamilySalesRate] * ([throughput] - ([unitPrice] * ISNULL([percentDiscount] / 100, 0))) [salesRateThroughput]
		,[unitPrice] * (1 - ISNULL(FD.[percentDiscount] / 100, 0)) [discountUnitPrice]
      ,[storeCount]
      ,[unitPrice]
      ,[throughput]
      ,[totalConsumption]
      ,[percentValidity]
      ,[daysSinceIntroduction]
      ,[percentSalesRateChange] * 100 [percentSalesRateChange]
		,[totalConsumption] + [totalInventory] [totalBought]
		,CASE WHEN [totalConsumption] + [totalInventory] = 0 THEN NULL 
			WHEN [totalConsumption]  IS NULL OR [totalInventory] IS NULL THEN NULL
			ELSE [totalConsumption]/([totalConsumption] + [totalInventory]) * 100
			END [sellThrough]
      ,[custom_num1]
      ,[custom_num2]
      ,[custom_num3]
      ,[custom_num4]
      ,[custom_num5]
      ,[custom_num6]
      ,[custom_num7]
      ,[custom_num8]
      ,[custom_num9]
      ,[custom_num10]
      ,[custom_txt1]
      ,[custom_txt2]
      ,[custom_txt3]
      ,[custom_txt4]
      ,[custom_txt5]
      ,[custom_txt6]
      ,[custom_txt7]
      ,[custom_txt8]
      ,[custom_txt9]
      ,[custom_txt10]
      ,[skuPropertyID1]
      ,[skuPropertyID2]
      ,[skuPropertyID3]
      ,[skuPropertyID4]
      ,[skuPropertyID5]
      ,[skuPropertyID6]
      ,[skuPropertyID7]
  FROM [dbo].[Symphony_Aux_FamilyDiscounts] AUX
  LEFT JOIN [dbo].[Symphony_FamilyDiscounts] FD
  ON FD.familyID = AUX.familyID
)

GO
/****** Object:  View [dbo].[FamilyItemInfo]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FamilyItemInfo]
AS
(
		SELECT DISTINCT id [familyID]
			,NAME [familyName]
			,[familyDescription]
			,[imageID]
		FROM Symphony_SkuFamilies
)

GO
/****** Object:  View [dbo].[FamilySLItemInfo]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[FamilySLItemInfo] AS
(
SELECT DISTINCT FAG.familyID, LAG.stockLocationID, SL.stockLocationName, SL.stockLocationDescription, SF.name as familyName, SF.familyDescription, SF.imageID
FROM  Symphony_RetailFamilyAgConnection FAG  
INNER JOIN Symphony_LocationAssortmentGroups LAG  
ON LAG.[assortmentGroupID] = FAG.[assortmentGroupID]
INNER JOIN Symphony_SkuFamilies SF
ON SF.id = FAG.familyID  
INNER JOIN Symphony_StockLocations AS SL
ON SL.stockLocationID = LAG.stockLocationID
)

GO
/****** Object:  View [dbo].[FillParetoReasons]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[FillParetoReasons] AS 
SELECT woid
	,WO.skuID
	,SKUs.skuName
	,WO.stockLocationName
	,plantID
	,sl.stockLocationName as plantName
	,WO.stockLocationDesc
	,isToOrder
	,quantity
	,dueDate = CASE isToOrder
		WHEN 1
			THEN dueDate
		ELSE NULL
		END
	,materialReleaseScheduledDate
	,materialReleaseActualDate
	,bufferPenetration
	,bufferColor
	,WO.bufferSize
	,ropeViolation
	,workCenter
	,WO.description as woDescription
	,saleOrderID
	,woPropertyID1
	,woPropertyID2
	,woPropertyID3
	,woPropertyID4
	,woPropertyID5
	,woPropertyID6
	,woPropertyID7
	,woPropertyID8
	,woPropertyID9
	,woPropertyID10
	,woPropertyID11
	,woPropertyID12
	,woPropertyID13
	,woPropertyID14
	,woPropertyID15
	,woPropertyID16
	,woPropertyID17
	,woPropertyID18
	,woPropertyID19
	,woPropertyID20
	,woCustom_txt1
	,woCustom_txt2
	,woCustom_txt3
	,woCustom_txt4
	,woCustom_txt5
	,woCustom_txt6
	,woCustom_txt7
	,woCustom_txt8
	,woCustom_txt9
	,woCustom_txt10
	,woCustom_num1
	,woCustom_num2
	,woCustom_num3
	,woCustom_num4
	,woCustom_num5
	,woCustom_num6
	,woCustom_num7
	,woCustom_num8
	,woCustom_num9
	,woCustom_num10
	,ISNULL([SkuDesc], mtoSk.skuDescription) AS SkuDesc
	,orderType
	,componentID
	,WO.lastReason
	,WO.lastReasonDate
	,WO.notes
	,WO.newRedBlack
	,initialBPAtCurrentWC
	,WO.uomID
	,WO.clientOrderID
	,null as newReason
	,WO.stockLocationName as clientName 
	,CASE 
		WHEN LEN(ISNULL(WO.stockLocationDesc,N'')) > 0 THEN WO.stockLocationDesc 
	END AS clientDescription 
	,CASE 
		WHEN [initialBPAtCurrentWC] IS NULL
			THEN 0
		WHEN [bufferPenetration] <= [initialBPAtCurrentWC]
			THEN 0
		ELSE [bufferPenetration] - [initialBPAtCurrentWC]
		END AS [percentPLTAtWC]
	,slwo.slPropertyID1
	,slwo.slPropertyID2
	,slwo.slPropertyID3
	,slwo.slPropertyID4
	,slwo.slPropertyID5
	,slwo.slPropertyID6
	,slwo.slPropertyID7
	,Sk.skuPropertyID1
	,Sk.skuPropertyID2
	,Sk.skuPropertyID3
	,Sk.skuPropertyID4
	,Sk.skuPropertyID5
	,Sk.skuPropertyID6
	,Sk.skuPropertyID7
FROM Symphony_WorkOrders WO
LEFT JOIN Symphony_StockLocations sl 
ON sl.stockLocationID = WO.PlantID
LEFT JOIN Symphony_StockLocations slwo 
ON sl.stockLocationName= WO.stockLocationName
LEFT JOIN Symphony_MTOSkus mtoSk 
ON mtoSk.skuID = WO.skuID AND mtoSk.stockLocationID = WO.PlantID 
JOIN Symphony_SKUs as SKUs
ON SKUs.skuid = mtoSk.skuID
LEFT JOIN Symphony_StockLocationSkus Sk 
ON Sk.skuID = WO.skuID AND Sk.stockLocationID = WO.PlantID
LEFT JOIN [Symphony_ProductionFamilies] PF ON [WO].[productionFamily] = [PF].[ID]
WHERE WO.isFinished = 0 AND isPhantom = 0

GO
/****** Object:  View [dbo].[IstStock]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[IstStock]
AS

WITH totalRequests
AS (SELECT TOP 20000000
		P.skuID,
		P.stockLocationID,
		SUM(ISNULL(R.replenishmentQuantity, 0)) AS totalAllocatedQuantity,
		SUM(ISNULL(PO.quantity, 0)) AS totalOrderedQuantity
	FROM dbo.Symphony_ISTPolicy AS P
	LEFT OUTER JOIN dbo.Symphony_ISTRecommendations AS R
		ON R.originStockLocationID = P.stockLocationID
		AND R.skuID = P.skuID
	LEFT OUTER JOIN dbo.Symphony_PurchasingOrder AS PO
		ON PO.supplierID = P.stockLocationID
		AND PO.skuID = P.skuID
	WHERE (P.inventoryAllotment > 0)
	GROUP BY	P.skuID,
				P.stockLocationID)

SELECT
		P.clusterID,
		P.skuID,
		SK.skuName,
		SLS.locationSkuName AS locationSkuName,
		P.stockLocationID,
		SL.stockLocationName,
		OSL.StockLocationID AS originStockLocation,
		OSL.stockLocationName AS originStockLocationName,
		OSLS.inventoryAtSite AS originInventoryAtSite,
		SLSH.avgMonthlyConsumption,
		ISNULL(CASE
			WHEN P.inventoryAllotment = 1 THEN SLS.inventoryAtSite
			WHEN P.inventoryAllotment = 2 THEN SLS.inventoryAtSite - SLS.bufferSize
			ELSE 0
		END - TR.totalOrderedQuantity - TR.totalAllocatedQuantity, 0) * ISNULL(SLS.unitPrice, 0) AS StockValue,
		CASE
			WHEN P.inventoryAllotment = 1 THEN SLS.inventoryAtSite
			WHEN P.inventoryAllotment = 2 THEN SLS.inventoryAtSite - SLS.bufferSize
			ELSE 0
		END - TR.totalOrderedQuantity - TR.totalAllocatedQuantity
		AS OpenISTInventory,
		TR.totalAllocatedQuantity,
		TR.totalOrderedQuantity,
		CASE
			WHEN P.inventoryAllotment = 1 THEN SLS.inventoryAtSite
			WHEN P.inventoryAllotment = 2 THEN 
			CASE
				WHEN (SLS.inventoryAtSite - SLS.bufferSize - SLS.saftyStock) > 0 THEN SLS.inventoryAtSite - SLS.bufferSize - SLS.saftyStock
				ELSE 0 END
			ELSE 0
		END AS availableInventory,
		SLS.bufferSize,
		SLS.saftyStock,
		SLS.inventoryAtSite,
		SLS.inventoryAtSite + SLS.inventoryAtTransit + SLS.inventoryAtProduction AS inventoryAtPipe,
		--	CASE
		--	WHEN P.inventoryAllotment = 0 THEN 'No'
		--	WHEN P.inventoryAllotment = 1 THEN 'Inventory at Site'
		--	WHEN P.inventoryAllotment = 2 THEN 'Inventory at Site in Cyan'
		--END AS inventoryAllotment,
		inventoryAllotment,
		SL.slPropertyID1,
		SL.slPropertyID2,
		SL.slPropertyID3,
		SL.slPropertyID4,
		SL.slPropertyID5,
		SL.slPropertyID6,
		SL.slPropertyID7,
		SLS.skuPropertyID1,
		SLS.skuPropertyID2,
		SLS.skuPropertyID3,
		SLS.skuPropertyID4,
		SLS.skuPropertyID5,
		SLS.skuPropertyID6,
		SLS.skuPropertyID7,
		SLS.custom_num1,
		SLS.custom_num2,
		SLS.custom_num3,
		SLS.custom_num4,
		SLS.custom_num5,
		SLS.custom_num6,
		SLS.custom_num7,
		SLS.custom_num8,
		SLS.custom_num9,
		SLS.custom_num10,
		SLS.custom_txt1,
		SLS.custom_txt2,
		SLS.custom_txt3,
		SLS.custom_txt4,
		SLS.custom_txt5,
		SLS.custom_txt6,
		SLS.custom_txt7,
		SLS.custom_txt8,
		SLS.custom_txt9,
		SLS.custom_txt10,
		SLS.uomID
	FROM dbo.Symphony_ISTPolicy AS P
	INNER JOIN dbo.Symphony_StockLocationSkus AS SLS
		ON SLS.stockLocationID = P.stockLocationID
		AND SLS.skuID = P.skuID
	INNER JOIN dbo.Symphony_SKUs SK
	ON SK.skuID = SLS.skuID
	--LEFT JOIN Symphony_ISTRecommendations AS ISTR
	--	ON SLS.stockLocationID = ISTR.stockLocationID
	--	AND SLS.skuID = ISTR.skuID
	LEFT JOIN dbo.Symphony_StockLocations AS OSL
		ON OSL.stockLocationID = SLS.originStockLocation
		AND OSL.isDeleted = 0
	LEFT JOIN dbo.Symphony_StockLocationSkus AS OSLS
		ON OSLS.stockLocationID = SLS.originStockLocation
		AND OSLS.skuID = SLS.skuID
		AND OSLS.isdeleted = 0
	LEFT JOIN dbo.Symphony_StockLocationSkuHistory AS SLSH
		ON SLSH.stockLocationID = P.stockLocationID
		AND SLSH.skuID = P.skuID
		AND SLSH.updateDate = SLS.updateDate
	LEFT OUTER JOIN totalRequests AS TR
		ON TR.stockLocationID = P.stockLocationID
		AND TR.skuID = P.skuID
	INNER JOIN dbo.Symphony_StockLocations AS SL
		ON SL.stockLocationID = SLS.stockLocationID
	--LEFT JOIN dbo.Symphony_StockLocations AS OSL
	--	ON OSL.stockLocationID = SLS.originStockLocation
	--	AND OSL.isDeleted = 0
	WHERE (P.inventoryAllotment > 0)
	AND SLS.isdeleted = 0
	AND (CASE
		WHEN P.inventoryAllotment = 1 THEN SLS.inventoryAtSite
		WHEN P.inventoryAllotment = 2 THEN SLS.inventoryAtSite - SLS.bufferSize
		ELSE 0
	END - TR.totalOrderedQuantity) > 0


GO
/****** Object:  View [dbo].[LAGAllocationSummary]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[LAGAllocationSummary] as
SELECT 
	 AR.destinationID [stockLocationID]
	,SL.[stockLocationName]
	,SL.[stockLocationDescription]
	,AR.[originID]
	,OSL.[stockLocationName] [originStockLocationName]
	,AR.[familyID]
	,F.[name] [familyName]
	,F.[familyDescription]
	,AR.[requestStatus] AS [status]
	,AR.[bySystem] AS recommended
	,LAG.[assortmentGroupID]
	,AG.[name] [assortmentGroupName]
	,AG.[description] [assortmentGroupDescription]
	,AGDG.[displayGroupID]
	,DG.[name] [displayGroupName]
	,DG.[description] [displayGroupDescription]
	,FD.[NumFamiliesAtSiteBUL] AS [numFamiliesAtSite]
	,FD.[NumFamiliesInPipeBUL] AS [numFamiliesAtPipe]

	,CASE 
		WHEN (FD.[NumAllocatedRequests] - FD.[NumFamiliesAtSiteBUL]) <= 0 THEN NULL
		ELSE (FD.[NumAllocatedRequests] - FD.[NumFamiliesAtSiteBUL]) 
	 END [overAllocatedAtSite]
	,CASE 
		WHEN (FD.[NumAllocatedRequests] - FD.[NumFamiliesInPipeBUL]) <= 0 THEN NULL
		ELSE (FD.[NumAllocatedRequests] - FD.[NumFamiliesInPipeBUL])	
	 END [overAllocatedInPipe]
	,LAG.[varietyTarget]
	,CASE 
		WHEN LAG.[isGapCalculatedByVariety] = 1	THEN LAG.[varietyGap]
		ELSE LAG.[spaceGap]
		END agGap
	,LAG.[agBP] AS [agBufferPenetration]
	,LAG.[gapMode]
	,LAG.[validFamiliesNum]
	,LAG.[notValidFamiliesNum] - LAG.[notValidFamiliesOverThresholdNum] AS [newlyInvalidFamilies]
	,LAG.[notValidFamiliesOverThresholdNum] AS [expiredInvalidFamilyCount]
	,SL.[slPropertyID1]
	,SL.[slPropertyID2]
	,SL.[slPropertyID3]
	,SL.[slPropertyID4]
	,SL.[slPropertyID5]
	,SL.[slPropertyID6]
	,SL.[slPropertyID7]
	,AR.[totalNPI] [totalNpiQuantity]
	,AR.[groupID]
	,CASE 
		WHEN LAG.[isGapCalculatedByVariety] = 1	THEN NULL
		ELSE LAG.[spaceTarget]
	 END [spaceTarget]
	,MSD.[skuPropertyID1]
	,MSD.[skuPropertyID2]
	,MSD.[skuPropertyID3]
	,MSD.[skuPropertyID4]
	,MSD.[skuPropertyID5]
	,MSD.[skuPropertyID6]
	,MSD.[skuPropertyID7]
	,MSD.[custom_num1]
	,MSD.[custom_num2]
	,MSD.[custom_num3]
	,MSD.[custom_num4]
	,MSD.[custom_num5]
	,MSD.[custom_num6]
	,MSD.[custom_num7]
	,MSD.[custom_num8]
	,MSD.[custom_num9]
	,MSD.[custom_num10]
	,MSD.[custom_txt1]
	,MSD.[custom_txt2]
	,MSD.[custom_txt3]
	,MSD.[custom_txt4]
	,MSD.[custom_txt5]
	,MSD.[custom_txt6]
	,MSD.[custom_txt7]
	,MSD.[custom_txt8]
	,MSD.[custom_txt9]
	,MSD.[custom_txt10]
	,LAG.[limitAllocationToGap]
	,LAG.[maximumFamiliesPerGroup]
	,AR.[userSelection]
	,AR.[allocationRecommendationType]
	,LAG.[isGapCalculatedByVariety]
	,LAG.[overrideAllocationMethod]
	,LAG.[varietyGap]
	,LAG.[spaceGap]
	,ISNULL(LAG.[isAllocationCompleted],0) [isAllocationCompleted]
FROM [dbo].[Symphony_RetailAllocationRequest] AR
INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAM
	ON FAM.[familyID] = AR.[familyID]
INNER JOIN [dbo].[Symphony_RetailFamilyMasterData] MSD
	ON MSD.[familyID] = FAM.[familyID]
INNER JOIN [dbo].[Symphony_LocationAssortmentGroups] LAG
	ON LAG.[stockLocationID] = AR.[destinationID]
		AND LAG.[assortmentGroupID] = FAM.[assortmentGroupID]
INNER JOIN [dbo].[Symphony_StockLocations] SL
	ON SL.[stockLocationID] = AR.[destinationID]
INNER JOIN [dbo].[Symphony_SkuFamilies] F
	ON F.[id] = AR.[familyID]
INNER JOIN [dbo].[Symphony_AssortmentGroups] AG
	ON AG.[id] = LAG.[assortmentGroupID]
LEFT JOIN [dbo].[Symphony_StockLocations] OSL
	ON OSL.[stockLocationID] = AR.[originID]
LEFT JOIN [dbo].[Symphony_RetailAgDgConnection] AGDG
	ON FAM.[assortmentGroupID] = AGDG.[assortmentGroupID]
LEFT JOIN [dbo].[Symphony_DisplayGroups] DG
	ON DG.[id] = AGDG.[displayGroupID]
LEFT JOIN [dbo].[Symphony_RetailFamiliesLocationData] FD
	ON FD.[familyID] = AR.[familyID]
		AND FD.[stockLocationID] = AR.[originID]
WHERE AR.[sentToReplenishment] = 0
	AND SL.[isDeleted] = 0
	AND (
		(
			AR.[optionalRequest] = 0
			AND AR.[requestStatus] IN (0, 1)
			)
		OR (
			AR.[optionalRequest] = 1
			AND AR.[requestStatus] IN (2)
			)
		)


GO
/****** Object:  View [dbo].[LAGFamilyAllocations]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Get all of the families for a location assortment group.
--For this set of families get of the allocation recommendations.
--The columns stockLocationID and assortmentGroupID are intended
--to allow filtering of the data

-- We need to get all recommendation that their destination is SL
-- Plus all other recommendation from other stock locations, with user selection = 1
-- So we can calcualte over allocation if the user will try to select
-- new recommendation for current SL
CREATE VIEW [dbo].[LAGFamilyAllocations]
AS
WITH SRC
AS (
	SELECT LAG.[stockLocationID]
		,LAG.[assortmentGroupID]
		,FAG.[familyID]
		,AR.[originID]
		,AR.[userSelection]
		,AR.[encodedNpiQuantities]
	FROM [dbo].[Symphony_LocationAssortmentGroups] LAG
	INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG
		ON FAG.[assortmentGroupID] = LAG.[assortmentGroupID]
	INNER JOIN [dbo].[Symphony_RetailAllocationRequest] AR
		ON AR.[familyID] = FAG.[familyID]
			AND AR.[destinationID] = LAG.[stockLocationID]
	)
--This part take all the recommendation for the location (LAG) where AR.[destinationID] = LAG.[stockLocationID]
SELECT SRC.[originID]
	,SRC.[familyID]
	,SRC.[stockLocationID]
	,SRC.[assortmentGroupID]
	,SRC.[stockLocationID] [destinationStockLocationID]
	,SRC.[assortmentGroupID] [destinationAssortmentGroupID]
	,CONVERT(BIT, SRC.[userSelection]) [selected]
	,SRC.[encodedNpiQuantities]
FROM SRC

UNION ALL
--This part take  the recommendation for all other locations beside the selected location (LAG) but only those with userSelection = 1
SELECT AR.[originID]
	,AR.[familyID]
	,SRC.[stockLocationID]
	,SRC.[assortmentGroupID]
	,AR.[destinationID] [destinationStockLocationID]
	,DLAG.[assortmentGroupID] [destinationAssortmentGroupID]
	,CONVERT(BIT, AR.[userSelection]) [selected]
	,AR.[encodedNpiQuantities]
FROM SRC
INNER JOIN [dbo].[Symphony_RetailAllocationRequest] AR
	ON AR.[originID] = SRC.[originID]
		AND AR.[familyID] = SRC.[familyID]
INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG
	ON FAG.[familyID] = AR.[familyID]
INNER JOIN [dbo].[Symphony_LocationAssortmentGroups] DLAG
	ON DLAG.[assortmentGroupID] = FAG.[assortmentGroupID]
		AND DLAG.[stockLocationID] = AR.[destinationID]
WHERE AR.[userSelection] = 1
AND SRC.[stockLocationID] <> AR.[destinationID]


GO
/****** Object:  View [dbo].[LAGVarietyGap]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[LAGVarietyGap]
AS
WITH SKU_SUM
AS (
	SELECT SLS.stockLocationID
		,LAG.assortmentGroupID
		,SUM(SLS.bufferSize) AS totalBuffers
		,SUM(SLS.inventoryAtSite) AS totalInvAtSite
		,SUM(SLS.inventoryAtSite + SLS.inventoryAtTransit + SLS.inventoryAtProduction) AS totalInvInPipe
	FROM Symphony_StockLocationSkus SLS
	INNER JOIN Symphony_MasterSkus MS
		ON SLS.skuID = MS.skuID
	INNER JOIN Symphony_RetailFamilyAgConnection FAG
		ON FAG.familyID = MS.familyID
	INNER JOIN Symphony_LocationAssortmentGroups LAG
		ON LAG.assortmentGroupID = FAG.assortmentGroupID
			AND LAG.stockLocationID = SLS.stockLocationID
	WHERE SLS.isDeleted = 0
	GROUP BY SLS.stockLocationID
		,LAG.assortmentGroupID
	)
	,CHANGES_IN_ALLOCATIONS
AS (
	SELECT DISTINCT AR.destinationID AS stockLocationID
		,LAG.assortmentGroupID
		,1 AS recommendationsEdited
	FROM Symphony_RetailAllocationRequest AR
	INNER JOIN Symphony_RetailFamilyAgConnection FAG
		ON AR.familyID = FAG.familyID
	INNER JOIN Symphony_LocationAssortmentGroups LAG
		ON LAG.assortmentGroupID = FAG.assortmentGroupID
			AND LAG.stockLocationID = AR.destinationID
	WHERE AR.requestStatus = 2
		OR (
			bySystem = 0
			AND optionalRequest = 0
			)
	)
	,currentAllocations
AS (
	SELECT destinationID stockLocationID
		,FAM.assortmentGroupID
		,SUM(totalNPI) totalNpiQuantity
		,COUNT(1) familyCount
	FROM dbo.Symphony_RetailAllocationRequest AR
	INNER JOIN Symphony_RetailFamilyAgConnection FAM
		ON FAM.familyID = AR.familyID
	INNER JOIN Symphony_LocationAssortmentGroups LAG
		ON LAG.stockLocationId = AR.destinationID
			AND FAM.assortmentGroupID = LAG.assortmentGroupID
	WHERE requestStatus < 2
		AND optionalRequest = 0
		AND AR.originID IS NOT NULL
	GROUP BY destinationID
		,FAM.assortmentGroupID
	)
SELECT LAG.stockLocationID
	,SL.stockLocationName
	,SL.stockLocationDescription
	,CASE 
		WHEN LAG.isGapCalculatedByVariety = 1
			THEN LAG.varietyGap
		ELSE LAG.spaceGap
		END gap
	,LAG.assortmentGroupID
	,AG.[description] [assortmentGroupDescription]
	,AG.[name] [assortmentGroupName]
	,LAG.[varietyTarget]
	,AGDG.[displayGroupID]
	,DG.[description] [displayGroupDescription]
	,DG.[name] [displayGroupName]
	,SL.slPropertyID1
	,SL.slPropertyID2
	,SL.slPropertyID3
	,SL.slPropertyID4
	,SL.slPropertyID5
	,SL.slPropertyID6
	,SL.slPropertyID7
	,CONS.averageConsumptionAG AS agConsumption
	,CONS.averageConsumptionDG AS dgConsumption
	,LAG.agBP AS agBufferPenetration
	,LAG.gapMode
	,LAG.validFamiliesNum AS validFamilies
	,LAG.[notValidFamiliesNum] - LAG.[notValidFamiliesOverThresholdNum] AS newlyInvalid
	,LAG.notValidFamiliesOverThresholdNum AS expiredInvalid
	,CASE 
		WHEN LAG.gapMode = 0
			THEN NULL
		ELSE LAG.spaceTarget
		END AS spaceTarget
	,SUMDATA.totalBuffers
	,SUMDATA.totalInvAtSite
	,SUMDATA.totalInvInPipe
	,CASE 
		WHEN LAG.gapMode = 0
			THEN NULL
		ELSE LAG.totalSpace
		END AS totalSpace
	,ISNULL(AR.recommendationsEdited, 0) AS recommendationsEdited
	,SL.allocationPriority [storePriority]
	,LAG.allocateExistingGroups
	,ISNULL(LAG.maximumFamiliesPerGroup, 0) AS maxFamiliesSameGroup
	,LAG.limitAllocationToGap
	,LAG.allocationPriority
	,CASE 
		WHEN gapMode = 0
			THEN NULL
		ELSE ISNULL(LAG.spaceType, 2)
		END [spaceType]
	,SL.allowOverAllocation
	,ISNULL(LAG.isAllocationCompleted,0) [isAllocationCompleted]
	,LAG.isGapCalculatedByVariety
	,LAG.dominantSalesEstimation
	,LAG.overrideAllocationMethod
	,LAG.[varietyGap]
	,LAG.[spaceGap]
	,LAG.[maximumFamiliesPerGroup]
	,CASE 
		WHEN isGapCalculatedByVariety IS NULL
			THEN 0
		WHEN LAG.isGapCalculatedByVariety = 1
			THEN CASE WHEN LAG.[varietyGap] - ISNULL(CA.[familyCount], 0) > 0 THEN LAG.[varietyGap] - ISNULL(CA.[familyCount], 0) ELSE 0 END
		ELSE CASE WHEN LAG.[spaceGap] - ISNULL(CA.totalNPIQuantity, 0) > 0 THEN LAG.[spaceGap] - ISNULL(CA.totalNPIQuantity, 0) ELSE 0 END
	END [remainingGap]
FROM Symphony_LocationAssortmentGroups LAG
INNER JOIN Symphony_AssortmentGroups AG
	ON AG.id = LAG.assortmentGroupID
INNER JOIN Symphony_StockLocations SL
	ON LAG.stockLocationID = SL.stockLocationID
LEFT JOIN Symphony_RetailAgDgConnection AGDG
	ON AGDG.assortmentGroupID = LAG.assortmentGroupID
LEFT JOIN Symphony_DisplayGroups DG
	ON DG.id = AGDG.displayGroupID
LEFT JOIN Symphony_AssortmentGroupConsumptionSummaryData CONS
	ON LAG.stockLocationID = CONS.stockLocationID
		AND LAG.assortmentGroupID = CONS.assortmentGroupID
LEFT JOIN SKU_SUM SUMDATA
	ON SUMDATA.stockLocationID = LAG.stockLocationID
		AND SUMDATA.assortmentGroupID = LAG.assortmentGroupID
LEFT JOIN CHANGES_IN_ALLOCATIONS AR
	ON AR.stockLocationID = LAG.stockLocationID
		AND AR.assortmentGroupID = LAG.assortmentGroupID
LEFT JOIN currentAllocations CA
	ON CA.[stockLocationID] = LAG.[stockLocationID]
		AND CA.[assortmentGroupID] = LAG.[assortmentGroupID]
WHERE CASE 
		WHEN isGapCalculatedByVariety = 1
			THEN LAG.varietyGap
		ELSE LAG.spaceGap
		END > 0
	AND SL.[isDeleted] = 0
	AND (SL.[isClosed] IS NULL  OR SL.[isClosed] = 0)

GO
/****** Object:  View [dbo].[Lookup_bpColor]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Lookup_bpColor]
AS
SELECT        colorID AS bpColor, colorName
FROM            dbo.Symphony_BPColors
WHERE        (colorID < 5)


GO
/****** Object:  View [dbo].[Lookup_DPLM_PoliciesState]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Lookup_DPLM_PoliciesState]
AS
	 SELECT DISTINCT  [ID],[stateName] 
	 FROM [dbo].[Symphony_DPLM_PoliciesStates]
 UNION ALL
	 SELECT DISTINCT  [ID],[stateName] 
	 FROM [dbo].[Symphony_DPLM_ActionsDeleted]

GO
/****** Object:  View [dbo].[Lookup_DPLM_RuleTypes]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Lookup_DPLM_RuleTypes]
AS
SELECT *
FROM  dbo.Symphony_DPLM_RuleTypes


GO
/****** Object:  View [dbo].[Lookup_DplmPolicy]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Lookup_DplmPolicy]
AS
SELECT        ID, policyName
FROM            dbo.Symphony_DPLM_Policies


GO
/****** Object:  View [dbo].[Lookup_EndOfLifePolicy]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Lookup_EndOfLifePolicy]
AS
SELECT        id, name
FROM            dbo.Symphony_EndOfLifePolicies

GO
/****** Object:  View [dbo].[Lookup_OrderTypes]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Lookup_OrderTypes]
AS
SELECT [orderTypeID]
      ,[orderTypeName]
  FROM [dbo].[Symphony_OrderTypes]


GO
/****** Object:  View [dbo].[Lookup_OriginSL]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Lookup_OriginSL]
AS
SELECT DISTINCT   [originStockLocation] as [originStockLocationID],
				  SL.[stockLocationName] as [originStockLocationName]
FROM [dbo].[Symphony_StockLocationSkus] as SLS
JOIN [dbo].[Symphony_StockLocations] as SL
ON SLS.originStockLocation = SL.stockLocationID
WHERE SL.isDeleted = 0


GO
/****** Object:  View [dbo].[Lookup_SKUCustomNumber]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Lookup_SKUCustomNumber]
AS
SELECT 
       [custom_num1]
      ,[custom_num2]
      ,[custom_num3]
      ,[custom_num4]
      ,[custom_num5]
      ,[custom_num6]
      ,[custom_num7]
      ,[custom_num8]
      ,[custom_num9]
      ,[custom_num10]
  FROM [dbo].[Symphony_StockLocationSkus]

GO
/****** Object:  View [dbo].[Lookup_SKUCustomText]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Lookup_SKUCustomText]
AS
SELECT 
       [custom_txt1]
      ,[custom_txt2]
      ,[custom_txt3]
      ,[custom_txt4]
      ,[custom_txt5]
      ,[custom_txt6]
      ,[custom_txt7]
      ,[custom_txt8]
      ,[custom_txt9]
      ,[custom_txt10]
  FROM [dbo].[Symphony_StockLocationSkus]

GO
/****** Object:  View [dbo].[Lookup_SKUProperty]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Lookup_SKUProperty]
AS
SELECT [skuItemID]
      ,[skuItemName]
      ,[skuPropertyID]
  FROM [dbo].[Symphony_SKUsPropertyItems]


GO
/****** Object:  View [dbo].[Lookup_SLCustomNumber]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Lookup_SLCustomNumber]
AS
SELECT 
       [slCustom_num1]
      ,[slCustom_num2]
      ,[slCustom_num3]
      ,[slCustom_num4]
      ,[slCustom_num5]
      ,[slCustom_num6]
      ,[slCustom_num7]
      ,[slCustom_num8]
      ,[slCustom_num9]
      ,[slCustom_num10]
  FROM [dbo].[Symphony_StockLocations]

GO
/****** Object:  View [dbo].[Lookup_SLProperty]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Lookup_SLProperty]
AS
SELECT [slItemID]
      ,[slItemName]
      ,[slPropertyID]
  FROM [dbo].[Symphony_StockLocationPropertyItems]

GO
/****** Object:  View [dbo].[Lookup_StockLocationName]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Lookup_StockLocationName]
AS
	SELECT [stockLocationID],[stockLocationName]
	FROM Symphony_StockLocations
	WHERE isdeleted=0 AND stockLocationID>=0

GO
/****** Object:  View [dbo].[Lookup_StockLocationPlant]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Lookup_StockLocationPlant]
AS
	SELECT [stockLocationID],[stockLocationName]
	FROM Symphony_StockLocations
	WHERE isdeleted = 0 AND stockLocationID >= 0 AND stockLocationType = 1

GO
/****** Object:  View [dbo].[Lookup_Suppliers]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Lookup_Suppliers]
AS
SELECT DISTINCT   SL.[stockLocationID] as [stockLocationID],
				  SL.[stockLocationName] as [stockLocationName]
FROM [dbo].[Symphony_StockLocations] as SL
WHERE stockLocationType = 2 AND SL.isDeleted = 0

GO
/****** Object:  View [dbo].[Lookup_WOProperty]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Lookup_WOProperty]
AS
SELECT [woItemID]
      ,[woPropertyID]
      ,[woItemName]
  FROM [dbo].[Symphony_WorkOrdersPropertyItems]

GO
/****** Object:  View [dbo].[LookupRopeViolationReason]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[LookupRopeViolationReason]
AS
SELECT reason as value, reason as text FROM Symphony_ReasonsSBRope

GO
/****** Object:  View [dbo].[MaterialReleaseScheduled]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MaterialReleaseScheduled] AS
SELECT  
			sl.stockLocationName as plantName
			,sl.stockLocationDescription as plantDescription
            ,materialReleaseScheduledDate 
            ,woid 
			,saleOrderID
            ,S.skuName as skuName 
            ,WO.bufferColor 
            ,WO.bufferSlack 
            ,dueDate 
            ,WO.description 
            ,componentID 
            ,woPropertyID1 
            ,woPropertyID2 
            ,woPropertyID3 
            ,woPropertyID4 
            ,woPropertyID5 
            ,woPropertyID6 
            ,woPropertyID7 
            ,woPropertyID8 
            ,woPropertyID9 
            ,woPropertyID10 
            ,woPropertyID11 
            ,woPropertyID12 
            ,woPropertyID13 
            ,woPropertyID14 
            ,woPropertyID15 
            ,woPropertyID16 
            ,woPropertyID17 
            ,woPropertyID18 
            ,woPropertyID19 
            ,woPropertyID20 
            ,woCustom_txt1 
            ,woCustom_txt2 
            ,woCustom_txt3 
            ,woCustom_txt4 
            ,woCustom_txt5 
            ,woCustom_txt6 
            ,woCustom_txt7 
            ,woCustom_txt8 
            ,woCustom_txt9 
            ,woCustom_txt10 
            ,woCustom_num1 
            ,woCustom_num2 
            ,woCustom_num3 
            ,woCustom_num4 
            ,woCustom_num5 
            ,woCustom_num6 
            ,woCustom_num7 
            ,woCustom_num8 
            ,woCustom_num9 
            ,woCustom_num10 
            ,quantity 
            ,ISNULL(SkuDesc, mtoSk.skuDescription) as SkuDesc 
            ,WO.stockLocationName as clientName 
            ,CASE 
                    WHEN LEN(ISNULL(WO.stockLocationDesc,N'')) > 0 THEN WO.stockLocationDesc 
                    ELSE sl1.stockLocationDescription 
                END AS clientDescription 
            ,WO.uomID 
        FROM Symphony_WorkOrders WO  
            left join Symphony_StockLocations sl on (sl.stockLocationID = WO.PlantID)  
            left join Symphony_StockLocations sl1 on (sl1.stockLocationName = WO.stockLocationName)  
            left join Symphony_MTOSkus mtoSk on (mtoSk.skuID = WO.skuID AND mtoSk.stockLocationID = WO.PlantID)  
            left join Symphony_StockLocationSkus Sk on (Sk.skuID = WO.skuID AND Sk.stockLocationID = WO.PlantID)  
			left join Symphony_SKUs S on s.skuID = WO.skuID
        WHERE isToOrder=1 AND isPhantom = 0 AND materialReleaseActualDate Is Null 

GO
/****** Object:  View [dbo].[MTORopeViolation]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MTORopeViolation] AS
SELECT   
	W.ID
	,W.woid
	,W.componentID
	,S.skuName
	,saleOrderID
	,W.description as woidDescription
	,W.stockLocationName as client
	,W.materialReleaseScheduledDate
	,W.materialReleaseActualDate
	,sl.stockLocationName as plant
	, ISNULL(W.SkuDesc, mtoSk.skuDescription) as SkuDesc 
    , DATEDIFF(day, w.materialReleaseActualDate, W.materialReleaseScheduledDate) AS violationDays  
    ,RV.reason as reason  
	,W.woPropertyID1 
    ,W.woPropertyID2 
    ,W.woPropertyID3 
    ,W.woPropertyID4 
    ,W.woPropertyID5 
    ,W.woPropertyID6 
    ,W.woPropertyID7 
    ,W.woPropertyID8 
    ,W.woPropertyID9 
    ,W.woPropertyID10 
    ,W.woPropertyID11 
    ,W.woPropertyID12 
    ,W.woPropertyID13 
    ,W.woPropertyID14 
    ,W.woPropertyID15 
    ,W.woPropertyID16 
    ,W.woPropertyID17 
    ,W.woPropertyID18 
    ,W.woPropertyID19 
    ,W.woPropertyID20 
    ,W.woCustom_txt1 
    ,W.woCustom_txt2 
    ,W.woCustom_txt3 
    ,W.woCustom_txt4 
    ,W.woCustom_txt5 
    ,W.woCustom_txt6 
    ,W.woCustom_txt7 
    ,W.woCustom_txt8 
    ,W.woCustom_txt9 
    ,W.woCustom_txt10 
    ,W.woCustom_num1 
    ,W.woCustom_num2 
    ,W.woCustom_num3 
    ,W.woCustom_num4 
    ,W.woCustom_num5 
    ,W.woCustom_num6 
    ,W.woCustom_num7 
    ,W.woCustom_num8 
    ,W.woCustom_num9 
    ,W.woCustom_num10 
FROM Symphony_WorkOrders W  
        left join Symphony_SBRopeViolations RV on W.woid = RV.woid AND W.componentID = RV.componentID AND W.plantId = RV.plantID  
        left join Symphony_StockLocations sl on (sl.stockLocationID=W.PlantID)  
        left join Symphony_MTOSkus mtoSk on (mtoSk.skuID=W.skuID AND mtoSk.stockLocationID=W.PlantID)  
        left join Symphony_StockLocationSkus Sk on (Sk.skuID=W.skuID AND Sk.stockLocationID=W.PlantID)  
		left join Symphony_SKUs S on (S.skuID=W.skuID )  
WHERE W.isToOrder=1 AND W.ropeViolation=1 AND isPhantom = 0

GO
/****** Object:  View [dbo].[MTOSKUItemInfo]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  CREATE VIEW [dbo].[MTOSKUItemInfo] AS(
	SELECT 
		 SLS.skuID
		,SLS.stockLocationID
		,SLS.locationSkuName [skuName]
		,SLS.skuDescription
		,SL.stockLocationName
		,SL.stockLocationDescription
		,ISNULL(SKU.imageID, -1) [imageID]
	FROM [dbo].[Symphony_MTOSkus] SLS
	INNER JOIN [dbo].[Symphony_StockLocations] SL
		ON SL.[stockLocationID] = SLS.[stockLocationID]
	INNER JOIN Symphony_SKUs SKU ON SLS.skuID = SKU.skuID
)


GO
/****** Object:  View [dbo].[MTOSKUs]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[MTOSKUs] AS 		
	SELECT sl.stockLocationName
		,SL.stockLocationID
		,sl.stockLocationDescription
		,M.skuID
		,M.locationSkuName
		,skuName
		,M.uomID
		,M.skuDescription
		,M.originStockLocation
		,OSL.stockLocationName as originStockLocationName
		,M.inventoryAtSite
		,M.inventoryAtProduction
		,M.inventoryAtTransit
		,M.timeBuffer
		,M.unitPrice
		,M.skuPropertyID1
		,M.skuPropertyID2
		,M.skuPropertyID3
		,M.skuPropertyID4
		,M.skuPropertyID5
		,M.skuPropertyID6
		,M.skuPropertyID7
		,SL.slPropertyID1
		,SL.slPropertyID2
		,SL.slPropertyID3
		,SL.slPropertyID4
		,SL.slPropertyID5
		,SL.slPropertyID6
		,SL.slPropertyID7
	FROM Symphony_MTOSkus M
	JOIN Symphony_StockLocations SL
	ON M.stockLocationID = SL.stockLocationID
	LEFT JOIN Symphony_StockLocations OSL
	ON OSL.stockLocationID = M.originStockLocation
	JOIN Symphony_SKUs S
	ON M.skuID = S.skuID
	WHERE SL.isDeleted = 0 AND M.isDeleted = 0

GO
/****** Object:  View [dbo].[MTSSKU_Nidhi]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE View [dbo].[MTSSKU_Nidhi] as

SELECT  
		 sl.stockLocationName
		,sl.stockLocationDescription
		,[locationSkuName]
		,sk.[skuDescription]
		,[custom_txt4][WW Article Code]
		,case [siteColor]
			when 0 then 'Cyan'
			when 1 then 'Green'
			when 2 then 'Yellow'
			when 3 then 'Red'
			when 4 then 'Black'
		end as [BP Site color]
		,Case [transitColor]
			when 0 then 'Cyan'
			when 1 then 'Green'
			when 2 then 'Yellow'
			when 3 then 'Red'
			when 4 then 'Black'
		end as [BP Transit Color]
		,spi4.skuItemName [Status]		
		,spi6.skuItemName [Ranging] 
	--	,spi5.skuItemName [Sourcing Rule]
		,osl.stockLocationName [Origin SL Name]
		,[bufferSize]
		,[minimumBufferSize]
		,[saftyStock]
		,[bufferManagementPolicy]
		,[avoidReplenishment]
		,[autoReplenishment]
		,[replenishmentTime]
		,[inventoryAtSite]
		,[inventoryAtTransit]
		,[custom_txt5][Brand Description]
		,spi1.skuItemName [Class Description]
	    ,[custom_txt1][Class code]
		,spi2.[skuItemName] [Category Description]
		,[custom_txt2][Category Code]
		,spi3.[skuItemName] [Group Description]
		,[custom_txt3][Group Code]
		,[custom_txt10] [SLM Type]
		
 
FROM [Symphony_StockLocationSkus] sk
	join [Symphony_StockLocations] sl on sl.stockLocationID =sk.stockLocationID
	join [Symphony_StockLocations] osl on osl.stockLocationID =sk.originStockLocation
	join Symphony_SKUsPropertyItems SPI1 on sk.skuPropertyID1 = SPI1.skuItemID
	join Symphony_SKUsPropertyItems SPI2 on sk.skuPropertyID2 = SPI2.skuItemID
	join Symphony_SKUsPropertyItems SPI3 on sk.skuPropertyID3 = SPI3.skuItemID
	join Symphony_SKUsPropertyItems SPI4 on sk.skuPropertyID4 = SPI4.skuItemID
	join Symphony_SKUsPropertyItems SPI6 on sk.skuPropertyID6 = SPI6.skuItemID
where sk.isDeleted=0 and sk.inventoryAtSite>0 and sl.stockLocationType = 5



GO
/****** Object:  View [dbo].[MTSSKU_Report]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create View [dbo].[MTSSKU_Report] as

SELECT  
sl.stockLocationName
	,sl.stockLocationDescription
	 ,[locationSkuName]
	  ,sk.[skuDescription]
      ,[custom_txt4][WW Article Code]
      ,case [siteColor]
        when 0 then 'Cyan'
        when 1 then 'Green'
        when 2 then 'Yellow'
        when 3 then 'Red'
        when 4 then 'Black'
      end as [BP Site color]
      ,Case [transitColor]
      when 0 then 'Cyan'
      when 1 then 'Green'
      when 2 then 'Yellow'
      when 3 then 'Red'
      when 4 then 'Black'
      end as [BP Transit Color]
      ,case [skuPropertyID4]
			when 9 then 'ZA'
			else Null
			End As [Status]
      
      ,case [skuPropertyID6]
			when 423 then 'Y'
			else Null
			End As[Ranging]

      ,[skuPropertyID5][Sourcing Rule]
    --  ,[originStockLocation]
      ,osl.stockLocationName [Origin SL Name]
      ,[bufferSize]
      ,[minimumBufferSize]
      ,[saftyStock]
      ,[bufferManagementPolicy]
      ,[avoidReplenishment]
      ,[autoReplenishment]
      ,[replenishmentTime]
      ,[inventoryAtSite]
      ,[inventoryAtTransit]
      ,[custom_txt5][Brand Description]
    --  ,[skuPropertyID1][Class Description]
      ,spi1.skuItemName [Class Description]
      ,[custom_txt1][Class code]
    --  ,[skuPropertyID2][Category Description]
      ,spi2.[skuItemName] [Category Description]
      ,[custom_txt2][Category Code]
    --  ,[skuPropertyID3][Group Description]
      ,spi3.[skuItemName] [Group Description]
      ,[custom_txt3][Group Code]
 
FROM [Symphony_StockLocationSkus] sk
  join [Symphony_StockLocations] sl on sl.stockLocationID =sk.stockLocationID
  join [Symphony_StockLocations] osl on osl.stockLocationID =sk.originStockLocation
  join Symphony_SKUsPropertyItems SPI1 on sk.skuPropertyID1 = SPI1.skuItemID
  join Symphony_SKUsPropertyItems SPI2 on sk.skuPropertyID2 = SPI2.skuItemID
  join Symphony_SKUsPropertyItems SPI3 on sk.skuPropertyID3 = SPI3.skuItemID
  join Symphony_SKUsPropertyItems SPI5 on sk.skuPropertyID5 = SPI5.skuItemID
 where [skuPropertyID4]=9 and [skuPropertyID6]=423 and sk.isDeleted=0




GO
/****** Object:  View [dbo].[MTSSKUItemInfo]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


  CREATE VIEW [dbo].[MTSSKUItemInfo] AS(
	SELECT 
	     SLS.id [uniqueId]
		,SLS.skuID
		,SLS.stockLocationID
		,SLS.locationSkuName [skuName]
		,SLS.skuDescription
		,SL.stockLocationName
		,SL.stockLocationDescription
		,ISNULL(SKU.imageID, -1) [imageID]
	FROM [dbo].[Symphony_StockLocationSkus] SLS
	INNER JOIN [dbo].[Symphony_StockLocations] SL
		ON SL.[stockLocationID] = SLS.[stockLocationID]
	INNER JOIN Symphony_SKUs SKU ON SLS.skuID = SKU.skuID
)

GO
/****** Object:  View [dbo].[NonReleasedRM]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

    CREATE VIEW [dbo].[NonReleasedRM]
	AS
	SELECT      WO.ID
			,WO.woid
			,sl.stockLocationID
			,WO.stockLocationName [Client]
			,WO.stockLocationDesc [ClientDescription]
			,WO.skuID
			,SKU.skuName
            ,ISNULL([SkuDesc], mtoSk.skuDescription) as SkuDesc
			,WO.saleOrderID
			,WO.description
			,WO.orderType
			,WO.uomID
			,WO.quantity
			,WO.materialReleaseScheduledDate
			,WO.toReleaseMtaCapacity
			,WO.inputSuspicion
			,WO.woPropertyID1
			,WO.woPropertyID2
			,WO.woPropertyID3
			,WO.woPropertyID4
			,WO.woPropertyID5
			,WO.woPropertyID6
			,WO.woPropertyID7
			,WO.woPropertyID8
			,WO.woPropertyID9
			,WO.woPropertyID10
			,WO.woPropertyID11
			,WO.woPropertyID12
			,WO.woPropertyID13
			,WO.woPropertyID14
			,WO.woPropertyID15
			,WO.woPropertyID16
			,WO.woPropertyID17
			,WO.woPropertyID18
			,WO.woPropertyID19
			,WO.woPropertyID20
			,WO.bufferPenetration
			,WO.bufferColor
			,WO.clientOrderID
			,WO.isToOrder
			,WO.componentID
			,SL.stockLocationName [Plant]
FROM Symphony_WorkOrders WO 
LEFT join Symphony_StockLocations sl on (sl.stockLocationID=WO.PlantID)
LEFT join Symphony_MTOSkus mtoSk on (mtoSk.skuID=WO.skuID AND mtoSk.stockLocationID=WO.PlantID)
LEFT join Symphony_StockLocationSkus Sk on (Sk.skuID=WO.skuID AND Sk.stockLocationID=WO.PlantID) 
INNER JOIN Symphony_SKUs SKU ON WO.skuID = SKU.skuID
WHERE ISNULL(materialReleaseActualDate,0)=0 AND 
((isToOrder=0) Or materialReleaseScheduledDate<=CONVERT(DATETIME,CONVERT(VARCHAR,GETDATE(),112))) 
AND isPhantom = 0

GO
/****** Object:  View [dbo].[OpenStoresSkuHistory]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[OpenStoresSkuHistory]
AS(
	SELECT
	SLSH.*
	FROM [dbo].[Symphony_StockLocationSkuHistory] SLSH
	LEFT JOIN [dbo].[Symphony_StoreClosuresExpanded] SC
	ON SC.[stocklocationID] = SLSH.[stockLocationID]
	AND SC.[updateDate] = SLSH.[updateDate]
	WHERE ISNULL(SC.[isClosed], 0) = 0
)

GO
/****** Object:  View [dbo].[ProcurmentRecommendationsView]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[ProcurmentRecommendationsView]  as
SELECT 
PR.ID as uniqueId,
PR.[status] AS recommendationStatus,
--PD.ID as [procurementDataID],
PR.woid,
[submit] = CASE PR.isAwaitsConfirmation WHEN 0 THEN 0 ELSE NULL END
,[confirm] = 0
,PR.isAwaitsConfirmation
,PR.sentToReplenishment
,PR.submissionDate
,ISNULL(PR.showInReport, 0) AS [showInReport]
,PR.supplierID
--,PR.supplierID  AS [supplierName]-- 
,SSL1.stockLocationName AS [supplierName]
--,PR.supplierID  AS [supplierDescription] --
,SSL1.stockLocationDescription AS [supplierDescription]
,PR.skuID
,SKU.skuName
,SLSKU.skuDescription
,ISNULL(PD.supplierSkuName, SLSKU.locationSkuName) AS [supplierSkuName]
,PR.stockLocationID
,SL.stockLocationName
,SL.stockLocationDescription
,PR.inventoryNeeded
,ISNULL(PD.minimumOrderQuantity,SLSKU.minimumReplenishment) AS [minimumOrderQuantity]
,ISNULL(PD.orderMultiplications,SLSKU.multiplications) AS [orderMultiplications]
,ISNULL(PD.lastBatchReplenishment / 100,SLSKU.minimumRequiredBP / 100) AS [lastBatchReplenishment]
,PD.quantityProtection / 100 AS [quantityProtection]
,PR.suggestedQuantity AS [quantityCalculated]
,PR.quantity AS [quantityToPurchase]
,SLSKU.inventoryAtSite
,SLSKU.inventoryAtTransit
,SLSKU.bufferSize
,SLSKU.uomID
,CASE WHEN PR.bufferColor = 100 THEN NULL ELSE PR.bufferColor END [bufferColor]
,PR.virtualBufferPenetration
,CASE WHEN PR.clientOrderID IS NULL THEN PR.daysLate ELSE NULL END AS daysLate
,PR.orderType
,PR.earliestOrderDate
,PR.latestOrderDate
,PR.needDate AS [neededDate]
,PR.noteID
,PR.note as notes
,PR.orderID
,PR.clientOrderID
,PR.orderPrice
,[orderDate] = GETDATE()
,PR.promisedDueDate
,[needsMtoSku] = 0
,PR.prPropertyID1,PR.prPropertyID2,PR.prPropertyID3,PR.prPropertyID4,PR.prPropertyID5,PR.prPropertyID6,PR.prPropertyID7
,CASE WHEN SLSKU.shipmentMeasure IS NULL THEN NULL ELSE SLSKU.shipmentMeasure * PR.quantity END AS shipmentMeasure
,SLSKU.skuPropertyID1,SLSKU.skuPropertyID2,SLSKU.skuPropertyID3,SLSKU.skuPropertyID4,SLSKU.skuPropertyID5,SLSKU.skuPropertyID6,SLSKU.skuPropertyID7
,SLSKU.custom_txt1,SLSKU.custom_txt2,SLSKU.custom_txt3,SLSKU.custom_txt4,SLSKU.custom_txt5,SLSKU.custom_txt6,SLSKU.custom_txt7,SLSKU.custom_txt8,SLSKU.custom_txt9,SLSKU.custom_txt10
,SLSKU.custom_num1,SLSKU.custom_num2,SLSKU.custom_num3,SLSKU.custom_num4,SLSKU.custom_num5,SLSKU.custom_num6,SLSKU.custom_num7,SLSKU.custom_num8,SLSKU.custom_num9,SLSKU.custom_num10
,SL.slPropertyID1,SL.slPropertyID2,SL.slPropertyID3,SL.slPropertyID4,SL.slPropertyID5,SL.slPropertyID6,SL.slPropertyID7
,SLSKU.tvc 
,SLSKU.saftyStock as safetyStock 
,SLSKU.tvc * PR.quantity as orderValue
FROM [dbo].[Symphony_PurchasingRecommendation] PR 
INNER JOIN [dbo].[Symphony_StockLocationSkus] SLSKU  
ON  SLSKU.isDeleted = 0  AND PR.isConfirmed = 0  AND PR.isDeleted = 0  
AND DATEDIFF(DAY, GETDATE(),ISNULL( PR.earliestOrderDate, GETDATE())) <= (SELECT [flag_value]
  FROM [dbo].[Symphony_Globals]
  WHERE flag_name ='ProcurementOrdersTimeHorizon')  AND PR.skuID = SLSKU.skuID  
AND PR.stockLocationID = SLSKU.stockLocationID 
INNER JOIN [dbo].[Symphony_SKUs] SKU  
ON SKU.skuID = PR.skuID 
LEFT JOIN [dbo].[Symphony_SkuProcurementData] PD  
ON PR.supplierID = PD.supplierID  AND SKU.skuName = PD.skuName  AND PR.stockLocationID = PD.stockLocationID 
INNER JOIN [dbo].[Symphony_StockLocations] SL  
ON SL.isDeleted = 0  AND PR.stockLocationID = SL.stockLocationID 
INNER JOIN [dbo].[Symphony_StockLocations] SSL1  
ON SSL1.isDeleted = 0  AND PR.supplierID = SSL1.stockLocationID 
WHERE PR.sentToReplenishment = 0

UNION  
SELECT 
PR.ID
,PR.[status] AS recommendationStatus
--,PD.ID AS [procurementDataID]
,PR.woid,[submit] = CASE PR.isAwaitsConfirmation WHEN 0 THEN 0 ELSE NULL END
,[confirm] = 0
,PR.isAwaitsConfirmation
,PR.sentToReplenishment
,PR.submissionDate
,ISNULL(PR.showInReport, 0) AS [showInReport]
,PR.supplierID
--,PR.supplierID  AS [supplierName]-- 
,SSL1.stockLocationName AS [supplierName]
--,PR.supplierID  AS [supplierDescription] --
,SSL1.stockLocationDescription AS [supplierDescription]
,PR.skuID
,SKU.skuName,
SLSKU.skuDescription,
PD.supplierSkuName,
PR.stockLocationID,
SL.stockLocationName,
SL.stockLocationDescription,
PR.inventoryNeeded,
PD.minimumOrderQuantity,
PD.orderMultiplications,
PD.lastBatchReplenishment / 100 AS lastBatchReplenishment,
PD.quantityProtection /100 AS [quantityProtection],
PR.suggestedQuantity AS [quantityCalculated],
PR.quantity AS [quantityToPurchase],
SLSKU.inventoryAtSite,
SLSKU.inventoryAtTransit,
NULL AS bufferSize,
SLSKU.uomID,
CASE WHEN PR.bufferColor = 100 THEN NULL ELSE PR.bufferColor END [bufferColor],
PR.virtualBufferPenetration,PR.daysLate,PR.orderType,PR.earliestOrderDate,
PR.latestOrderDate,PR.needDate AS [neededDate],PR.noteID,PR.note,PR.orderID,PR.clientOrderID,PR.orderPrice,[orderDate] = GETDATE(),PR.promisedDueDate,[needsMtoSku] =  CASE WHEN SLSKU.skuID IS NULL THEN 1  ELSE 0 END              ,PR.prPropertyID1,PR.prPropertyID2,PR.prPropertyID3,PR.prPropertyID4,PR.prPropertyID5,PR.prPropertyID6,PR.prPropertyID7,NULL as shipmentMeasure,SLSKU.skuPropertyID1,SLSKU.skuPropertyID2,SLSKU.skuPropertyID3,SLSKU.skuPropertyID4,SLSKU.skuPropertyID5,SLSKU.skuPropertyID6,SLSKU.skuPropertyID7,NULL as custom_txt1,NULL as custom_txt2,NULL as custom_txt3,NULL as custom_txt4,NULL as custom_txt5,NULL as custom_txt6,NULL as custom_txt7,NULL as custom_txt8,NULL as custom_txt9,NULL as custom_txt10,NULL as custom_num1,NULL as custom_num2,NULL as custom_num3,NULL as custom_num4,NULL as custom_num5,NULL as custom_num6,NULL as custom_num7,NULL as custom_num8,NULL as 
custom_num9,NULL as custom_num10
,SL.slPropertyID1,SL.slPropertyID2,SL.slPropertyID3,SL.slPropertyID4,SL.slPropertyID5,SL.slPropertyID6,SL.slPropertyID7 
,SLSKU.tvc 
,null as safetyStock 
,SLSKU.tvc * PR.quantity as orderValue
FROM [dbo].[Symphony_PurchasingRecommendation] PR 
INNER JOIN [dbo].[Symphony_SKUs] SKU  
ON SKU.skuID = PR.skuID  AND PR.clientOrderID IS NULL AND PR.isConfirmed = 0 AND PR.isDeleted = 0  AND PR.earliestOrderDate IS NOT NULL AND DATEDIFF(DAY, GETDATE(),PR.earliestOrderDate) <= (SELECT [flag_value]
  FROM [dbo].[Symphony_Globals]
  WHERE flag_name ='ProcurementOrdersTimeHorizon')
INNER JOIN [dbo].[Symphony_SkuProcurementData] PD 
ON PR.supplierID = PD.supplierID AND SKU.skuName 
= PD.skuName AND PR.stockLocationID = PD.stockLocationID 
INNER JOIN [dbo].[Symphony_StockLocations] SL 
ON SL.isDeleted = 0 AND PR.stockLocationID = SL.stockLocationID 
INNER JOIN [dbo].[Symphony_StockLocations] SSL1 
ON SSL1.isDeleted = 0 AND PD.supplierID = SSL1.stockLocationID 
LEFT JOIN [dbo].[Symphony_MTOSkus] SLSKU 
ON SLSKU.isDeleted = 0 AND PR.skuID = SLSKU.skuID AND PR.stockLocationID = SLSKU.stockLocationID 
WHERE sentToReplenishment = 0

UNION  

SELECT 
PR.ID,
PR.[status] AS recommendationStatus,
--PD.ID AS [procurementDataID],
PR.woid,
[submit] = CASE PR.isAwaitsConfirmation WHEN 0 THEN 0 ELSE NULL END
,[confirm] = 0,
PR.isAwaitsConfirmation,
PR.sentToReplenishment,
PR.submissionDate,
ISNULL(PR.showInReport, 0) AS [showInReport],
PR.supplierID,
--PR.supplierID  AS [supplierName]--
SSL.stockLocationName AS [supplierName],
--,PR.supplierID  AS [supplierDescription] 
SSL.stockLocationDescription AS [supplierDescription]
,PR.skuID
,SKU.skuName,
SLSKU.skuDescription,
PD.supplierSkuName,
PR.stockLocationID,SL.stockLocationName,
SL.stockLocationDescription,PR.inventoryNeeded,PD.minimumOrderQuantity,
PD.orderMultiplications,
PD.lastBatchReplenishment / 100 AS lastBatchReplenishment,
PD.quantityProtection / 100 AS [quantityProtection],
PR.suggestedQuantity AS [quantityCalculated],
PR.quantity AS [quantityToPurchase],
SLSKU.inventoryAtSite,SLSKU.inventoryAtTransit,
NULL AS bufferSize,SLSKU.uomID,
CASE WHEN PR.bufferColor = 100 THEN NULL ELSE PR.bufferColor END [bufferColor],
PR.virtualBufferPenetration, NULL AS 
daysLate,PR.orderType,PR.earliestOrderDate,
PR.latestOrderDate,PR.needDate AS [neededDate],
PR.noteID,PR.note,PR.orderID,PR.clientOrderID,PR.orderPrice,
[orderDate] = GETDATE(),PR.promisedDueDate,
[needsMtoSku] =  CASE WHEN SLSKU.skuID IS NULL THEN 1  ELSE 0 END              
,PR.prPropertyID1,PR.prPropertyID2,PR.prPropertyID3,PR.prPropertyID4,PR.prPropertyID5,PR.prPropertyID6,PR.prPropertyID7,NULL 
as shipmentMeasure,SLSKU.skuPropertyID1,SLSKU.skuPropertyID2,SLSKU.skuPropertyID3,SLSKU.skuPropertyID4,SLSKU.skuPropertyID5,SLSKU.skuPropertyID6,SLSKU.skuPropertyID7
,NULL as custom_txt1,NULL as custom_txt2,NULL as custom_txt3,NULL as custom_txt4,NULL as custom_txt5,NULL as custom_txt6,NULL as custom_txt7
,NULL as custom_txt8,NULL as custom_txt9,NULL as custom_txt10
,NULL as custom_num1,NULL as custom_num2,NULL as custom_num3,NULL as custom_num4,NULL as custom_num5,NULL as custom_num6,NULL as custom_num7,NULL as custom_num8,NULL as custom_num9,NULL as custom_num10
,SL.slPropertyID1,SL.slPropertyID2,SL.slPropertyID3,SL.slPropertyID4,SL.slPropertyID5,SL.slPropertyID6,SL.slPropertyID7 
,SLSKU.tvc 
,null as safetyStock 
,SLSKU.tvc * PR.quantity as orderValue
FROM [dbo].[Symphony_PurchasingRecommendation] PR 
INNER JOIN [dbo].[Symphony_SKUs] SKU  
ON SKU.skuID = PR.skuID AND PR.isConfirmed = 0  AND PR.clientOrderID IS NOT NULL  AND PR.isDeleted = 0  
INNER JOIN [dbo].[Symphony_StockLocations] SL  
ON SL.isDeleted = 0  AND PR.stockLocationID = SL.stockLocationID 
INNER JOIN [dbo].[Symphony_StockLocations] SSL  
ON SSL.isDeleted = 0  AND PR.supplierID = SSL.stockLocationID 
INNER JOIN [dbo].[Symphony_MTOSkus] SLSKU 
ON SLSKU.isDeleted = 0 AND PR.skuID = SLSKU.skuID  AND PR.stockLocationID = SLSKU.stockLocationID 
LEFT JOIN [dbo].[Symphony_SkuProcurementData] PD  
ON PR.supplierID = PD.supplierID  AND SKU.skuName = PD.skuName  AND PR.stockLocationID = PD.stockLocationID
WHERE sentToReplenishment = 0


GO
/****** Object:  View [dbo].[ProductionQuotes]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ProductionQuotes] AS
SELECT PQ.[ID]
      ,[orderID]
      ,[plantID]
	  ,SL.stockLocationName AS plantName
      ,[quotedDueDate]
      ,[earliestDueDate]
      ,PQ.[skuID]
	  ,CASE WHEN PF.familyName is null then SKUs.skuName else null end as skuName
      ,PQ.[skuDescription]
      ,[marketFamily]
	  ,MF.familyName as marketFamilyName
      ,[productionFamily]
	  ,PF.familyName as productionFamilyName
      ,[quantity]
      ,PQ.[bufferSize]
      ,[leadTime]
      ,[issueDate]
      ,[expireDate]
      ,[status]
      ,[orderSize]
      ,M.[uomID]
  FROM Symphony_ProductionQuotes AS PQ
  LEFT JOIN Symphony_SKUs SKUs
  ON SKUs.skuID = PQ.skuID
  LEFT JOIN  Symphony_ProductionFamilies AS PF
  ON PF.ID = PQ.productionFamily
  LEFT JOIN Symphony_MarketFamilies AS MF
  ON MF.ID = PQ.marketFamily
  LEFT JOIN Symphony_StockLocations AS SL
  ON plantID = SL.stockLocationID
  INNER JOIN [Symphony_MTOSkus] M 
  ON PQ.skuID = M.skuID and PQ.plantID = M.stockLocationID

GO
/****** Object:  View [dbo].[ProductionReplenishment]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ProductionReplenishment] AS

SELECT SLS.stockLocationID
	,SL.stockLocationName
	,SL1.stockLocationName as originStockLocationName
	,SL.stockLocationDescription
	,SL.slPropertyID1
	,SL.slPropertyID2
	,SL.slPropertyID3
	,SL.slPropertyID4
	,SL.slPropertyID5
	,SL.slPropertyID6
	,SL.slPropertyID7
	,skuName
	,SLS.skuID
	,SLS.skuDescription
	,SLS.locationSkuName
	,SLS.bufferSize
	,inventoryNeeded
	,SLS.bpProduction
	,SLS.productionColor
	,SLS.toReplenish
	,SLS.sentToReplenishment
	,SLS.skuPropertyID1
	,SLS.skuPropertyID2
	,SLS.skuPropertyID3
	,SLS.skuPropertyID4
	,SLS.skuPropertyID5
	,SLS.skuPropertyID6
	,SLS.skuPropertyID7
	,SLS.originStockLocation
	--,SLS.originSKU
	,SLS.suggestedReplenishmentAmount
	,SLS.replenishmentQuantity
	,SLS.minimumRequiredBP / 100 AS minimumRequiredBP
	,SLS.minimumReplenishment
	,SLS.multiplications
	,SLS.autoReplenishment
	,SLS.uomID
	,'' AS clientOrderID
	,'Stock' AS replenishType
	,NULL AS productuionDueDate
	,SLS.notes
	,SLS.custom_num1
	,SLS.custom_num2
	,SLS.custom_num3
	,SLS.custom_num4
	,SLS.custom_num5
	,SLS.custom_num6
	,SLS.custom_num7
	,SLS.custom_num8
	,SLS.custom_num9
	,SLS.custom_num10
	,SLS.custom_txt1
	,SLS.custom_txt2
	,SLS.custom_txt3
	,SLS.custom_txt4
	,SLS.custom_txt5
	,SLS.custom_txt6
	,SLS.custom_txt7
	,SLS.custom_txt8
	,SLS.custom_txt9
	,SLS.custom_txt10
	--,NULL AS projectID
	--,NULL AS taskOrder
	,CASE WHEN shipmentMeasure IS NULL THEN NULL ELSE shipmentMeasure * replenishmentQuantity END shipmentMeasure
	,shipmentMeasure as shipmentMeasureOriginal
	--,NULL [istrID]
	,SLS.TVC
	,ISNULL(replenishmentQuantity,0) * ISNULL(SLS.TVC,0) as [orderValue]
FROM Symphony_StockLocationSkus SLS
INNER JOIN Symphony_StockLocations SL ON SLS.stockLocationID = SL.stockLocationID
LEFT JOIN Symphony_StockLocations SL1 ON SL1.stockLocationID = SLS.originStockLocation
INNER JOIN Symphony_SKUs S ON SLS.skuID = S.skuID
WHERE inventoryNeeded > 0
	AND sentToReplenishment = 0
	AND avoidReplenishment = 0
	AND toReplenish <= 2
	AND SLS.isDeleted = 0
	AND SL1.stockLocationType = 1
	AND SL1.stockLocationID = SLS.originStockLocation

UNION ALL

SELECT replinshmentDestination AS stockLocationID
	,SL.stockLocationName
	,OSL.stockLocationName as originStockLocationName
	,SL.stockLocationDescription
	,SL.slPropertyID1
	,SL.slPropertyID2
	,SL.slPropertyID3
	,SL.slPropertyID4
	,SL.slPropertyID5
	,SL.slPropertyID6
	,SL.slPropertyID7
	,skuName
	,CO.skuID
	,SLS.skuDescription
	,S.skuName AS locationSkuName
	,NULL AS bufferSize
	,quantityToReplenish AS inventoryNeeded
	,bufferPenetration AS bpProduction
	,bpColor AS productionColor
	,CO.toReplenish
	,CO.sentToReplenishment
	,SLS.skuPropertyID1
	,SLS.skuPropertyID2
	,SLS.skuPropertyID3
	,SLS.skuPropertyID4
	,SLS.skuPropertyID5
	,SLS.skuPropertyID6
	,SLS.skuPropertyID7
	,replinshmentSource AS originStockLocation
	--,NULL AS originSKU
	,quantityToReplenish AS suggestedReplenishmentAmount
	,quantityToReplenish AS replenishmentQuantity
	,SLS.minimumRequiredBP / 100 AS minimumRequiredBP
	,SLS.minimumReplenishment
	,SLS.multiplications
	,1 AS autoReplenishment
	,SLS.uomID
	,clientOrderID
	,'Order' AS replenishType
	,productuionDueDate
	,CO.notesReplenishment
	,SLS.custom_num1
	,SLS.custom_num2
	,SLS.custom_num3
	,SLS.custom_num4
	,SLS.custom_num5
	,SLS.custom_num6
	,SLS.custom_num7
	,SLS.custom_num8
	,SLS.custom_num9
	,SLS.custom_num10
	,SLS.custom_txt1
	,SLS.custom_txt2
	,SLS.custom_txt3
	,SLS.custom_txt4
	,SLS.custom_txt5
	,SLS.custom_txt6
	,SLS.custom_txt7
	,SLS.custom_txt8
	,SLS.custom_txt9
	,SLS.custom_txt10
	--,NULL AS projectID
	--,NULL AS taskOrder
	,CASE WHEN SLS.shipmentMeasure IS NULL THEN NULL ELSE SLS.shipmentMeasure * quantityToReplenish END shipmentMeasure
	,SLS.shipmentMeasure as shipmentMeasureOriginal
	--,NULL [istrID]
	,SLS.TVC
	,ISNULL(replenishmentQuantity,0) * ISNULL(SLS.TVC,0) as [orderValue]
FROM Symphony_ClientOrder CO
	,Symphony_StockLocationSkus SLS
	,Symphony_StockLocations SL
	,Symphony_SKUs S
	,Symphony_StockLocations OSL
WHERE quantityToReplenish > 0
	AND CO.sentToReplenishment = 0
	AND needToProduceRepOrder = 1
	AND CO.replinshmentDestination = SL.stockLocationID
	AND CO.skuID = S.skuID
	AND CO.replinshmentDestination = SLS.stockLocationID
	AND CO.skuID = SLS.skuID
	AND SLS.isDeleted = 0
	AND OSL.stockLocationID = SLS.originStockLocation

UNION ALL

SELECT replinshmentDestination AS stockLocationID
	,SL.stockLocationName
	,OSL.stockLocationName as originStockLocationName
	,SL.stockLocationDescription
	,SL.slPropertyID1
	,SL.slPropertyID2
	,SL.slPropertyID3
	,SL.slPropertyID4
	,SL.slPropertyID5
	,SL.slPropertyID6
	,SL.slPropertyID7
	,skuName
	,CO.skuID
	,SLS.skuDescription
	,S.skuName AS locationSkuName
	,NULL AS bufferSize
	,quantityToReplenish AS inventoryNeeded
	,bufferPenetration AS bpProduction
	,bpColor AS productionColor
	,CO.toReplenish
	,CO.sentToReplenishment
	,SLS.skuPropertyID1
	,SLS.skuPropertyID2
	,SLS.skuPropertyID3
	,SLS.skuPropertyID4
	,SLS.skuPropertyID5
	,SLS.skuPropertyID6
	,SLS.skuPropertyID7
	,replinshmentSource AS originStockLocation
	--,NULL AS originSKU
	,quantityToReplenish AS suggestedReplenishmentAmount
	,quantityToReplenish AS replenishmentQuantity
	,NULL AS minimumRequiredBP
	,NULL AS minimumReplenishment
	,NULL AS multiplications
	,1 AS autoReplenishment
	,SLS.uomID
	,clientOrderID
	,'Order' AS replenishType
	,productuionDueDate
	,CO.notesReplenishment
	,NULL AS custom_num1
	,NULL AS custom_num2
	,NULL AS custom_num3
	,NULL AS custom_num4
	,NULL AS custom_num5
	,NULL AS custom_num6
	,NULL AS custom_num7
	,NULL AS custom_num8
	,NULL AS custom_num9
	,NULL AS custom_num10
	,NULL AS custom_txt1
	,NULL AS custom_txt2
	,NULL AS custom_txt3
	,NULL AS custom_txt4
	,NULL AS custom_txt5
	,NULL AS custom_txt6
	,NULL AS custom_txt7
	,NULL AS custom_txt8
	,NULL AS custom_txt9
	,NULL AS custom_txt10
	--,NULL AS projectID
	--,NULL AS taskOrder
	,NULL AS shipmentMeasure
	,NULL as shipmentMeasureOriginal
	--,NULL [istrID]
	,SLS.TVC
	,ISNULL(quantityToReplenish,0) * ISNULL(SLS.TVC,0) as [orderValue]
FROM Symphony_ClientOrder CO
	,Symphony_MTOSkus SLS
	,Symphony_StockLocations SL
	,Symphony_SKUs S
	,Symphony_StockLocations OSL
WHERE quantityToReplenish > 0
	AND CO.sentToReplenishment = 0
	AND needToProduceRepOrder = 1
	AND CO.replinshmentDestination = SL.stockLocationID
	AND CO.skuID = S.skuID
	AND CO.replinshmentDestination = SLS.stockLocationID
	AND CO.skuID = SLS.skuID
	AND SLS.isDeleted = 0
	AND OSL.stockLocationID = SLS.originStockLocation

--UNION

--SELECT W.plantID AS stockLocationID
--	,SL.stockLocationName
--	,OSL.stockLocationName as originStockLocationName
--	,SL.stockLocationDescription
--	,SL.slPropertyID1
--	,SL.slPropertyID2
--	,SL.slPropertyID3
--	,SL.slPropertyID4
--	,SL.slPropertyID5
--	,SL.slPropertyID6
--	,SL.slPropertyID7
--	,skuName
--	,W.skuID
--	,M.skuDescription
--	,S.skuName AS locationSkuName
--	,NULL AS bufferSize
--	,W.quantity AS inventoryNeeded
--	,bufferPenetration AS bpProduction
--	,bufferColor AS productionColor
--	,M.autoReplenishment AS toReplenish
--	,W.sentToReplenishment
--	,NULL AS skuPropertyID1
--	,NULL AS skuPropertyID2
--	,NULL AS skuPropertyID3
--	,NULL AS skuPropertyID4
--	,NULL AS skuPropertyID5
--	,NULL AS skuPropertyID6
--	,NULL AS skuPropertyID7
--	,W.plantID AS originStockLocation
--	,NULL AS originSKU
--	,W.quantity AS suggestedReplenishmentAmount
--	,W.quantity AS replenishmentQuantity
--	,NULL AS minimumRequiredBP
--	,NULL AS minimumReplenishment
--	,NULL AS multiplications
--	,M.autoReplenishment
--	,M.uomID
--	,NULL AS clientOrderID
--	,'Order' AS replenishType
--	,W.dueDate AS productuionDueDate
--	,NULL AS notesReplenishment
--	,NULL AS custom_num1
--	,NULL AS custom_num2
--	,NULL AS custom_num3
--	,NULL AS custom_num4
--	,NULL AS custom_num5
--	,NULL AS custom_num6
--	,NULL AS custom_num7
--	,NULL AS custom_num8
--	,NULL AS custom_num9
--	,NULL AS custom_num10
--	,NULL AS custom_txt1
--	,NULL AS custom_txt2
--	,NULL AS custom_txt3
--	,NULL AS custom_txt4
--	,NULL AS custom_txt5
--	,NULL AS custom_txt6
--	,NULL AS custom_txt7
--	,NULL AS custom_txt8
--	,NULL AS custom_txt9
--	,NULL AS custom_txt10
--	,W.projectID
--	,W.taskOrder
--	,NULL AS shipmentMeasure
--	,NULL as shipmentMeasureOriginal
--	--,NULL [istrID]
--	,M.TVC
--	,ISNULL(W.quantity,0) * ISNULL(M.TVC,0) as [orderValue]
--FROM Symphony_workOrders4Projects W
--	,Symphony_MTOSkus M
--	,Symphony_StockLocations SL
--	,Symphony_SKUs S
--	,Symphony_StockLocations OSL
--WHERE W.sentToReplenishment = 0
--	AND W.releaseToFloor = 0
--	AND W.plantID = SL.stockLocationID
--	AND W.skuID = S.skuID
--	AND M.stockLocationID = SL.stockLocationID
--	AND M.skuID = S.skuID
--	AND M.isDeleted = 0
--	AND W.plantID = M.stockLocationID
--	AND W.skuID = M.skuID
--	AND OSL.stockLocationID = M.originStockLocation

GO
/****** Object:  View [dbo].[ProductionReplenishmentLog]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ProductionReplenishmentLog] AS
	SELECT RDL.*
		,SL.stockLocationName
		,OSLS.stockLocationName as originStockLocationName
		,SL.stockLocationDescription
		,SLS.skuDescription
		,SLS.locationSkuName
		,SLS.uomID
		,S.skuName
		,SL.slPropertyID1
		,SL.slPropertyID2
		,SL.slPropertyID3
		,SL.slPropertyID4
		,SL.slPropertyID5
		,SL.slPropertyID6
		,SL.slPropertyID7
		,SLS.skuPropertyID1
		,SLS.skuPropertyID2
		,SLS.skuPropertyID3
		,SLS.skuPropertyID4
		,SLS.skuPropertyID5
		,SLS.skuPropertyID6
		,SLS.skuPropertyID7
		,SLS.custom_txt1
		,SLS.custom_txt2
		,SLS.custom_txt3
		,SLS.custom_txt4
		,SLS.custom_txt5
		,SLS.custom_txt6
		,SLS.custom_txt7
		,SLS.custom_txt8
		,SLS.custom_txt9
		,SLS.custom_txt10
		,SLS.custom_num1
		,SLS.custom_num2
		,SLS.custom_num3
		,SLS.custom_num4
		,SLS.custom_num5
		,SLS.custom_num6
		,SLS.custom_num7
		,SLS.custom_num8
		,SLS.custom_num9
		,SLS.custom_num10
	FROM Symphony_ReplenishmentProductionLog RDL
		,Symphony_StockLocationSkus SLS
		,Symphony_StockLocations OSLS
		,Symphony_StockLocations SL
		,Symphony_SKUs S
	WHERE RDL.stockLocationID = SLS.stockLocationID
		AND OSLS.stockLocationID = RDL.originStockLocation
		AND RDL.skuID = SLS.skuID
		AND SLS.stockLocationID = SL.stockLocationID
		AND SLS.skuID = S.skuID
		AND SLS.isDeleted = 0
	
	UNION
	
	SELECT RDL.*
	    ,SL.stockLocationName
		,OSLS.stockLocationName as originStockLocationName
		,SL.stockLocationDescription
		,SLS.skuDescription
		,SLS.locationSkuName
		,SLS.uomID
		,S.skuName
		,SL.slPropertyID1
		,SL.slPropertyID2
		,SL.slPropertyID3
		,SL.slPropertyID4
		,SL.slPropertyID5
		,SL.slPropertyID6
		,SL.slPropertyID7
		,SLS.skuPropertyID1
		,SLS.skuPropertyID2
		,SLS.skuPropertyID3
		,SLS.skuPropertyID4
		,SLS.skuPropertyID5
		,SLS.skuPropertyID6
		,SLS.skuPropertyID7
		,SLS.custom_txt1
		,SLS.custom_txt2
		,SLS.custom_txt3
		,SLS.custom_txt4
		,SLS.custom_txt5
		,SLS.custom_txt6
		,SLS.custom_txt7
		,SLS.custom_txt8
		,SLS.custom_txt9
		,SLS.custom_txt10
		,SLS.custom_num1
		,SLS.custom_num2
		,SLS.custom_num3
		,SLS.custom_num4
		,SLS.custom_num5
		,SLS.custom_num6
		,SLS.custom_num7
		,SLS.custom_num8
		,SLS.custom_num9
		,SLS.custom_num10
	FROM Symphony_ReplenishmentProductionLog RDL
		,Symphony_MTOSkus SLS
		,Symphony_StockLocations OSLS
		,Symphony_StockLocations SL
		,Symphony_SKUs S
	WHERE RDL.stockLocationID = SLS.stockLocationID
		AND OSLS.stockLocationID = RDL.originStockLocation
		AND RDL.skuID = SLS.skuID
		AND SLS.stockLocationID = SL.stockLocationID
		AND SLS.skuID = S.skuID
		AND SLS.isDeleted = 0

GO
/****** Object:  View [dbo].[ProductionShippingBuffer]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ProductionShippingBuffer]  
AS
SELECT 
	[WO].[ID]
	,[WO].[woid]
	,[SLC].[stockLocationID]
	,[WO].[stockLocationName]
	,[WO].[skuID]
	,SK.[skuName]
	,[WO].[componentID]
	,[WO].[PlantID]
	,[SL].[stockLocationName] AS [plantName]
	,[isToOrder]
	,CONVERT (int, [quantity]) AS [quantity]
	,[dueDate] = CASE isToOrder WHEN 1 THEN [dueDate] 
		ELSE null 
	END
	,[materialReleaseScheduledDate]
	,[materialReleaseActualDate]
	,[bufferPenetration]
	,[bufferColor]
	,[WO].[bufferSize]
	,[ropeViolation]
	,[virtualStockLevel]
	,[isRopeViolationReasonNeeded]
	,[isFinished]
	,[workCenter]
	,[description]
	,[saleOrderID]
	,[sellingPrice]
	,[woPropertyID1]
	,[woPropertyID2]
	,[woPropertyID3]
	,[woPropertyID4]
	,[woPropertyID5]
	,[woPropertyID6]
	,[woPropertyID7]
	,[woPropertyID8]
	,[woPropertyID9]
	,[woPropertyID10]
	,[woPropertyID11]
	,[woPropertyID12]
	,[woPropertyID13]
	,[woPropertyID14]
	,[woPropertyID15]
	,[woPropertyID16]
	,[woPropertyID17]
	,[woPropertyID18]
	,[woPropertyID19]
	,[woPropertyID20]
	,[WO].[stockLocationDesc]
	,ISNULL([SkuDesc],mtoSk.skuDescription) as SkuDesc
	,[bufferSlack]
	,[orderType]
	,[inputSuspicion]
	,[WO].[lastReasonDate]
	,[WO].[lastReason]	
	,[WO].[notes]
	,[WO].[newRedBlack]
	,[WO].[considered]
	,[percentDone]
	,CAST(ISNULL(percentDone,0)/0.20 AS int) AS [percentDoneLevel]
	,ISNULL([PF].[percentTouchTime],0) AS [percentTouchTime] 
	,[initialBufferPenetration]
	,[initialBPAtCurrentWC]
	,[WO].[uomID]
	,[woCustom_num1]
	,[woCustom_num2]
	,[woCustom_num3]
	,[woCustom_num4]
	,[woCustom_num5]
	,[woCustom_num6]
	,[woCustom_num7]
	,[woCustom_num8]
	,[woCustom_num9]
	,[woCustom_num10]
	,[woCustom_txt1]
	,[woCustom_txt2]
	,[woCustom_txt3]
	,[woCustom_txt4]
	,[woCustom_txt5]
	,[woCustom_txt6]
	,[woCustom_txt7]
	,[woCustom_txt8]
	,[woCustom_txt9]
	,[woCustom_txt10]
	,[WO].[productionFamily]
	,[WO].[clientOrderID]
	,[WO].[orderScale]

	--,quantityLeftBefore2
	--,quantityLeftBefore1
	--,quantityLeftBefore3
	--,quantityLeftBefore4
FROM Symphony_WorkOrders WO 
	INNER JOIN Symphony_StockLocations SL 
		ON [SL].[stockLocationID] = [WO].[PlantID] 
	INNER JOIN [dbo].[Symphony_SKUs] AS SK
	   ON SK.[skuID] = WO.[skuID] 
	LEFT JOIN Symphony_StockLocations SLC 
		ON [SLC].[stockLocationName] = [WO].[stockLocationName] 
	LEFT JOIN Symphony_MTOSkus mtoSk 
		ON [mtoSk].[skuID]=[WO].[skuID] AND [mtoSk].[stockLocationID] = [WO].[PlantID] 
	LEFT JOIN Symphony_StockLocationSkus MTS 
		ON [MTS].[skuID] = [WO].[skuID] AND [MTS].[stockLocationID] = [WO].[PlantID] 
	LEFT JOIN [Symphony_ProductionFamilies] PF 
		ON [WO].[productionFamily] = [PF].[ID] 
	WHERE [WO].[isFinished] = 0 AND [WO].[isPhantom] = 0 

GO
/****** Object:  View [dbo].[PurchasingOrdersAll]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PurchasingOrdersAll]
AS
SELECT 	CASE PO.isToOrder 	WHEN 1 THEN 0 WHEN 0 THEN         
					CASE WHEN PO.promisedDueDate is NULL THEN 1  ELSE 2  END 
		END AS orderType,   
		CASE  WHEN PO.promisedDueDate IS NULL THEN 0      
		ELSE        DATEDIFF(d,convert(datetime, convert(varchar,getdate(), 112)), PO.promisedDueDate)    
		END AS daysLate,    
		PO.[stockLocationID]
	  ,SL.stockLocationName
      ,PO.[skuDescription]
	  ,PO.[ID] as UniqueId
      ,[quantity]
	  ,followUpDate
      ,[orderID]
      ,[clientOrderID]
	  ,SUP.stockLocationID as supplierID
	  ,SUP.stockLocationName as supplierName
	  ,SUP.stockLocationDescription as supplierDescription
      ,PO.[bufferSize]
      ,[orderPrice]
      ,[orderDate]
      ,[promisedDueDate]
      ,[bufferPenetration]
      ,[bufferColor]
      ,[inputSuspicion]
      ,[virtualStockLevel]
      ,[bufferDueDate]
      ,PO.[considered]
      ,PO.[newRedBlack]
      ,[calculateDueDate]
      ,[oldBufferColor]
      ,[neededDate]
      ,[isShipped]
      ,[supplierSkuName]
      ,[note] as notes
      ,[needsMatch]
      ,[purchasingPropertyID1]
      ,[purchasingPropertyID2]
      ,[purchasingPropertyID3]
      ,[purchasingPropertyID4]
      ,[purchasingPropertyID5]
      ,[purchasingPropertyID6]
      ,[purchasingPropertyID7]
	  ,PO.[poCustom_num1]
      ,PO.[poCustom_num2]
      ,PO.[poCustom_num3]
      ,PO.[poCustom_num4]
      ,PO.[poCustom_num5]
      ,PO.[poCustom_num6]
      ,PO.[poCustom_num7]
      ,PO.[poCustom_num8]
      ,PO.[poCustom_num9]
      ,PO.[poCustom_num10]
      ,PO.[poCustom_txt1]
      ,PO.[poCustom_txt2]
      ,PO.[poCustom_txt3]
      ,PO.[poCustom_txt4]
      ,PO.[poCustom_txt5]
      ,PO.[poCustom_txt6]
      ,PO.[poCustom_txt7]
      ,PO.[poCustom_txt8]
      ,PO.[poCustom_txt9]
      ,PO.[poCustom_txt10]
      ,[isISTOrder],
	    SKUs.skuID,
		SKUs.skuName,
		SL.stockLocationDescription,
		SLS.skuPropertyID1, SLS.skuPropertyID2, SLS.skuPropertyID3, SLS.skuPropertyID4,SLS.skuPropertyID5, SLS.skuPropertyID6, SLS.skuPropertyID7,		  
		SLS.custom_txt1, SLS.custom_txt2, SLS.custom_txt3, SLS.custom_txt4, SLS.custom_txt5,SLS.custom_txt6, SLS.custom_txt7, SLS.custom_txt8, SLS.custom_txt9, SLS.custom_txt10,  
		SLS.custom_num1, SLS.custom_num2, SLS.custom_num3, SLS.custom_num4, SLS.custom_num5,SLS.custom_num6, SLS.custom_num7, SLS.custom_num8, SLS.custom_num9, SLS.custom_num10,
		SL.slPropertyID1, SL.slPropertyID2, SL.slPropertyID3, SL.slPropertyID4,SL.slPropertyID5,SL.slPropertyID6, SL.slPropertyID7 
		
FROM    Symphony_PurchasingOrder PO,    
		Symphony_StockLocationSkus SLS,   
		Symphony_StockLocations SL,
		Symphony_SKUs SKUs ,
		Symphony_StockLocations SUP

WHERE    PO.stockLocationID = SL.stockLocationID AND    PO.skuID = SLS.skuID AND    SUP.stockLocationID = [supplierID]
AND    SLS.isDeleted = 0 AND    SLS.stockLocationID = SL.stockLocationID  AND SKUs.skuID = SLS.skuID 

UNION 
SELECT 	CASE PO.isToOrder 	WHEN 1 THEN 0 WHEN 0 THEN
			        CASE WHEN PO.promisedDueDate is NULL THEN 1 ELSE 2	END 
		END AS orderType,    
		CASE WHEN PO.promisedDueDate IS NULL THEN 0      
		ELSE        DATEDIFF(d,convert(datetime, convert(varchar,getdate(), 112)), PO.promisedDueDate)    
		END AS daysLate,    
		PO.[stockLocationID],
		SL.stockLocationName,
      PO.[skuDescription]
	  ,PO.[ID] as UniqueId
      ,[quantity]
	  ,followUpDate
      ,[orderID]
      ,[clientOrderID]
	  ,SUP.stockLocationID as supplierID
   	  ,SUP.stockLocationName as supplierName
	  ,SUP.stockLocationDescription as supplierDescription
      ,[bufferSize]
      ,[orderPrice]
      ,[orderDate]
      ,[promisedDueDate]
      ,[bufferPenetration]
      ,[bufferColor]
      ,[inputSuspicion]
      ,[virtualStockLevel]
      ,[bufferDueDate]
      ,[considered]
      ,[newRedBlack]
      ,[calculateDueDate]
      ,[oldBufferColor]
      ,[neededDate]
      ,[isShipped]
      ,[supplierSkuName]
      ,[note] as notes
      ,[needsMatch]
      ,[purchasingPropertyID1]
      ,[purchasingPropertyID2]
      ,[purchasingPropertyID3]
      ,[purchasingPropertyID4]
      ,[purchasingPropertyID5]
      ,[purchasingPropertyID6]
      ,[purchasingPropertyID7]
	  ,PO.[poCustom_num1]
      ,PO.[poCustom_num2]
      ,PO.[poCustom_num3]
      ,PO.[poCustom_num4]
      ,PO.[poCustom_num5]
      ,PO.[poCustom_num6]
      ,PO.[poCustom_num7]
      ,PO.[poCustom_num8]
      ,PO.[poCustom_num9]
      ,PO.[poCustom_num10]
      ,PO.[poCustom_txt1]
      ,PO.[poCustom_txt2]
      ,PO.[poCustom_txt3]
      ,PO.[poCustom_txt4]
      ,PO.[poCustom_txt5]
      ,PO.[poCustom_txt6]
      ,PO.[poCustom_txt7]
      ,PO.[poCustom_txt8]
      ,PO.[poCustom_txt9]
      ,PO.[poCustom_txt10]
      ,[isISTOrder],
	    SKUs.skuID,
		SKUs.skuName,
		SL.stockLocationDescription,
		SLS.skuPropertyID1, SLS.skuPropertyID2, SLS.skuPropertyID3, SLS.skuPropertyID4,    
		SLS.skuPropertyID5, SLS.skuPropertyID6, SLS.skuPropertyID7, 
		NULL AS custom_txt1, NULL AS custom_txt2, NULL AS custom_txt3,NULL AS custom_txt4 ,
		NULL AS custom_txt5,NULL AS custom_txt6, NULL AS custom_txt7, NULL AS custom_txt8,
		NULL AS custom_txt9 ,NULL AS custom_txt10,NULL AS custom_num1, NULL AS custom_num2, 
		NULL AS custom_num3, NULL AS custom_num4, NULL AS custom_num5,NULL AS custom_num6, 
		NULL AS custom_num7, NULL AS custom_num8, NULL AS custom_num9, NULL AS custom_num10,   
		SL.slPropertyID1, SL.slPropertyID2, SL.slPropertyID3, SL.slPropertyID4,    
		SL.slPropertyID5, SL.slPropertyID6, SL.slPropertyID7 

FROM    Symphony_PurchasingOrder PO,    
		Symphony_MTOSkus SLS,    
		Symphony_StockLocations SL ,
		Symphony_SKUs SKUs ,
		Symphony_StockLocations SUP

WHERE    PO.stockLocationID = SL.stockLocationID AND    PO.skuID = SLS.skuID AND    SUP.stockLocationID = [supplierID]
AND    SLS.isDeleted = 0 AND    SLS.stockLocationID = SL.stockLocationID  AND SKUs.skuID = SLS.skuID


GO
/****** Object:  View [dbo].[Qry_AnnualsList]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



--**************************************
--**  Creating Views
--**************************************
CREATE VIEW [dbo].[Qry_AnnualsList] 
AS
SELECT TOP 100 PERCENT
DATEPART(mm,annually_date) AS month_number,
DATENAME(mm,annually_date) AS month_name,
DATEPART(dd,annually_date) AS month_day
FROM Symphony_AnnuallyDates
ORDER BY month_number,month_day

GO
/****** Object:  View [dbo].[Retail_Location_AG]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--**********************************


CREATE VIEW [dbo].[Retail_Location_AG] AS
select SF.name [Family],
AG.name [AG Name],
case when LAG.gapMode=0 then 'Variety'
		when LAG.gapMode=1 then 'Space Over Variety'
		when LAG.gapMode=2 then 'Variety Over Space'
End [Gap Mode],
LAG.maxTarget [AG Max Variety],
LAG.minTarget [AG Min Variety],
LAG.varietyTarget [AG Variety Target],
convert(decimal(18,2),round(LAG.spaceBP*100,1)) [AG Buffer Penetration (Space)],
convert(decimal(18,2),round(LAG.varietyBP*100,1)) [AG Buffer Penetration (Variety)],
LAG.spaceTarget [AG Space Target],
LAG.validFamiliesNum [Valid Families],
LAG.notValidFamiliesNum [Invalid Familes],
LAG.notValidFamiliesOverThresholdNum [Expired Families],
(LAG.notValidFamiliesNum - LAG.notValidFamiliesOverThresholdNum) [Newly Invalid Families],
SL.stockLocationName [SL Name],
sku.skuName [SKU Name],
RNK.salesEstimation [Sales Estimation],
RNK.decile [Sales Decile],
LAG.totalSpace [AG's Total Space],
( Select sum(SLSB.bufferSize)
	from Symphony_MasterSkus MSB
	join Symphony_LocationAssortmentGroups LAGB on LAGB.assortmentGroupID=MSB.assortmentGroupID 
	join Symphony_StockLocationSkus SLSB on MS.skuID=SLSB.skuID and LAGB.stockLocationID=SLSB.stockLocationID 
	where LAGB.assortmentGroupID=LAG.assortmentGroupID and LAGB.stockLocationID=LAG.stockLocationID
	group by LAGB.assortmentGroupID,LAGB.stockLocationID
	)	
[AG's Total Buffer],
			    
case when LAG.spaceManaged=0 then 'No'
		when LAG.spaceManaged=1 then 'Yes'
End [Space Managed],
AGS.familyCount [Total Families],
AGS.inventoryAtSite [AG's Total Inv (Site)],
AGS.totalInventory [AG's Total Inv (Pipe)],
AGCS.averageConsumptionAG [AG Average Consumption],
DG.name [DG Name],
AGCS.averageConsumptionDG [DG Average Consumption]
					 		
from Symphony_MasterSkus MS
join Symphony_LocationAssortmentGroups LAG on LAG.assortmentGroupID=MS.assortmentGroupID
join  Symphony_StockLocationSkus sls on MS.skuID=sls.skuID and sls.stockLocationID=LAG.stocklocationid 
join Symphony_SkuFamilies SF on SF.id=MS.familyID
join Symphony_AssortmentGroups AG on AG.id=LAG.assortmentGroupID
join Symphony_StockLocations SL on SL.stockLocationID=LAG.stockLocationID
join Symphony_SKUs SKU on SKU.skuID=MS.skuID
left join Symphony_RetailFamilySalesRanking RNK on RNK.familyID=MS.familyID and RNK.propertyItemID is null
left join Symphony_AssortmentGroupSummaryData AGS on AGS.assortmentGroupID=LAG.assortmentGroupID and AGS.stockLocationID=LAG.stockLocationID
left join Symphony_AssortmentGroupConsumptionSummaryData AGCS on AGCS.assortmentGroupID=LAG.assortmentGroupID and AGCS.stockLocationID=LAG.stockLocationID
left join Symphony_RetailAgDgConnection AGDG on AGDG.assortmentGroupID=LAG.assortmentGroupID
left join Symphony_DisplayGroups DG on DG.id = AGDG.displayGroupID
where sl.isDeleted=0


GO
/****** Object:  View [dbo].[Retail_SKU_Location_AG]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--**********************************


CREATE VIEW [dbo].[Retail_SKU_Location_AG] AS
select sls.stockLocationID [Stock Location ID],
sls.skuID [SKU ID],
sku.skuName [SKU Name], 
sls.skuDescription [SKU Description],
sl.stockLocationName [Stock Location Name],
sl.stocklocationdescription [SL Description],
convert(decimal(18,0),sls.bufferSize) [Buffer Size],
convert(decimal(18,0),sls.coolingInv) [Cooling Inventory],
convert(decimal(18,0),sls.inventoryAtSite) [Inventory At Site],
convert(decimal(18,0),sls.inventoryAtTransit) [Inventory At Transit],
convert(decimal(18,0),sls.inventoryAtProduction) [Inventory At Production],
convert(decimal(18,0),sls.consumption) [Consumption],
convert(decimal(18,0),sls.noconsumptiondays) [No Consumption Days],
convert(datetime, convert(int, convert(float, sls.lastConsumptionDate))) [Last Consumption Date],
convert(datetime, convert(int, convert(float, sls.previousConsumptionDate))) [Previous Consumption Date],
sls.totalin [Total In (Inventory)],
convert(datetime, convert(int, convert(float, sls.updateDate))) [SKU's Update Date],
sls.replenishmentTime [Replenishment Time],
convert(decimal(18,2),round(bpSite*100,1)) [Buffer Penetration (Site)],
convert(decimal(18,2),round(bpTransit*100,1)) [Buffer Penetration (Transit)],
convert(decimal(18,2),round(bpProduction*100,1)) [Buffer Penetration (Production)],
case when sitecolor=0 then 'Cyan'
		when siteColor=1 then 'Green'
		when siteColor=2 then 'Yellow'
		When siteColor=3 then 'Red'
		when siteColor=4 then 'Black'
End [Buffer Penetration Color (Site)],
case when transitColor=0 then 'Cyan'
		when transitColor=1 then 'Green'
		when transitColor=2 then 'Yellow'
		When transitColor=3 then 'Red'
		when transitColor=4 then 'Black'
End [Buffer Penetration Color (Transit)],
case when productionColor=0 then 'Cyan'
		when productionColor=1 then 'Green'
		when productionColor=2 then 'Yellow'
		When productionColor=3 then 'Red'
		when productionColor=4 then 'Black'
End [Buffer Penetration Color (Production)],
convert(decimal(18,0),sls.unitPrice) [Unit Price],
Itm1.skuItemName [SKU Property 1],
Itm2.skuItemName [SKU Property 2],
Itm3.skuItemName [SKU Property 3],
Itm4.skuItemName [SKU Property 4],
Itm5.skuItemName [SKU Property 5],
Itm6.skuItemName [SKU Property 6],
Itm7.skuItemName [SKU Property 7],		
SLitm1.slItemName [SL Property 1],
SLitm2.slItemName [SL Property 2],
SLitm3.slItemName [SL Property 3],
SLitm4.slItemName [SL Property 4],
SLitm5.slItemName [SL Property 5],
SLitm6.slItemName [SL Property 6],
SLitm7.slItemName [SL Property 7],
case 
	when SL.stockLocationType=1 then 'Plant'
	when SL.stockLocationType=2 then 'Supplier'
	when SL.stockLocationType=3 then 'Point of Sale'
	when SL.stockLocationType=4 then 'Transparent'
	when SL.stockLocationType=5 then 'Warehouse'
End [Stock location Type],
case 
		When ((sls.nextGreenCheckDate>sls.updateDate) or (sls.nextGreenOverstockCheckDate>sls.updateDate)) then 'Yes'
		Else 'No'
End	[Green Cooling Period?],
convert(decimal(18,0),sls.minimumBufferSize) [Minimum Buffer Size],
originsl.stockLocationName [Origin Stock Location],
convert(decimal(18,0),sls.saftyStock) [Safety Stock],
convert(decimal(18,0),sls.minimumReplenishment) [Minimum Replenishment],
convert(decimal(18,0),sls.multiplications) [Multipications],
case 
	when SLS.avoidSeasonality=1 then 'Yes'
	when SLS.avoidSeasonality=0 then 'No'
	End [Avoid Seasonality?],
				
Case when sls.autoReplenishment=1 then 'Yes'
		when sls.autoReplenishment=0 then 'No'
		End [Auto Replenish?],
uom.uomName [Unit of Measurement],
convert(decimal(18,0),SLS.Throughput) [Throughput],
convert(decimal(18,0),SLS.TVC) [Total Variable Cost],
convert(datetime, convert(int, convert(float, startDate))) [SKU's Start Date],
dbm.name [DBM Policy],
case
	when sls.inSeasonality=1 then 'Yes'
	when sls.inSeasonality=0 then 'No' 
End[In Seasonality?],
sls.custom_num1 [Custom Number 1],
sls.custom_num2 [Custom Number 2],
sls.custom_num3 [Custom Number 3],
sls.custom_num4 [Custom Number 4],
sls.custom_num5 [Custom Number 5],
sls.custom_num6 [Custom Number 6],
sls.custom_num7 [Custom Number 7],
sls.custom_num8 [Custom Number 8],
sls.custom_num9 [Custom Number 9],
sls.custom_num10 [Custom Number 10],
sls.custom_txt1 [Custom Text 1],
sls.custom_txt2 [Custom Text 2],
sls.custom_txt3 [Custom Text 3],
sls.custom_txt4 [Custom Text 4],
sls.custom_txt5 [Custom Text 5],
sls.custom_txt6 [Custom Text 6],
sls.custom_txt7 [Custom Text 7],
sls.custom_txt8 [Custom Text 8],
sls.custom_txt9 [Custom Text 9],
sls.custom_txt10 [Custom Text 10],
SF.name [Family],
AG.name [AG Name],
case when LAG.gapMode=0 then 'Variety'
		when LAG.gapMode=1 then 'Space Over Variety'
		when LAG.gapMode=2 then 'Variety Over Space'
End [Gap Mode],
LAG.maxTarget [AG Max Variety],
LAG.minTarget [AG Min Variety],
LAG.varietyTarget [AG Variety Target],
LAG.spaceTarget [AG Space Target],
LAG.validFamiliesNum [Valid Families],
LAG.notValidFamiliesNum [Invalid Familes],
LAG.notValidFamiliesOverThresholdNum [Expired Families],
(LAG.notValidFamiliesNum - LAG.notValidFamiliesOverThresholdNum) [Newly Invalid Families],
RNK.salesEstimation [Sales Estimation],
RNK.decile [Sales Decile],
case when LAG.spaceManaged=0 then 'No'
		when LAG.spaceManaged=1 then 'Yes'
End [Space Managed],
AGS.familyCount [Total Families],
AGCS.averageConsumptionAG [AG Average Consumption],
DG.name [DG Name],
AGCS.averageConsumptionDG [DG Average Consumption]
							
from Symphony_MasterSkus MS
join Symphony_LocationAssortmentGroups LAG on LAG.assortmentGroupID=MS.assortmentGroupID
join  Symphony_StockLocationSkus sls on MS.skuID=sls.skuID and sls.stockLocationID=LAG.stocklocationid 
join Symphony_SkuFamilies SF on SF.id=MS.familyID
join Symphony_AssortmentGroups AG on AG.id=LAG.assortmentGroupID
join Symphony_StockLocations SL on SL.stockLocationID=LAG.stockLocationID
left join Symphony_SKUsPropertyItems Itm1 on sls.skuPropertyID1=Itm1.skuItemID
left join Symphony_SKUsPropertyItems Itm2 on sls.skuPropertyID2=Itm2.skuItemID
left join Symphony_SKUsPropertyItems Itm3 on sls.skuPropertyID3=Itm3.skuItemID
left join Symphony_SKUsPropertyItems Itm4 on sls.skuPropertyID4=Itm4.skuItemID
left join Symphony_SKUsPropertyItems Itm5 on sls.skuPropertyID5=Itm5.skuItemID
left join Symphony_SKUsPropertyItems Itm6 on sls.skuPropertyID6=Itm6.skuItemID
left join Symphony_SKUsPropertyItems Itm7 on sls.skuPropertyID7=Itm7.skuItemID
left join Symphony_StockLocationPropertyItems SLitm1 on sl.slPropertyID1=slitm1.slItemID
left join Symphony_StockLocationPropertyItems SLitm2 on sl.slPropertyID2=slitm2.slItemID
left join Symphony_StockLocationPropertyItems SLitm3 on sl.slPropertyID3=slitm3.slItemID	
left join Symphony_StockLocationPropertyItems SLitm4 on sl.slPropertyID4=slitm4.slItemID
left join Symphony_StockLocationPropertyItems SLitm5 on sl.slPropertyID5=slitm5.slItemID
left join Symphony_StockLocationPropertyItems SLitm6 on sl.slPropertyID6=slitm6.slItemID	
left join Symphony_StockLocationPropertyItems SLitm7 on sl.slPropertyID7=slitm7.slItemID	
left join Symphony_stocklocations Originsl on originsl.stockLocationID=sls.originStockLocation
join Symphony_SKUs SKU on SKU.skuID=MS.skuID
left join Symphony_RetailFamilySalesRanking RNK on RNK.familyID=MS.familyID and RNK.propertyItemID is null
left join Symphony_AssortmentGroupSummaryData AGS on AGS.assortmentGroupID=LAG.assortmentGroupID and AGS.stockLocationID=LAG.stockLocationID
left join Symphony_AssortmentGroupConsumptionSummaryData AGCS on AGCS.assortmentGroupID=LAG.assortmentGroupID and AGCS.stockLocationID=LAG.stockLocationID
left join Symphony_RetailAgDgConnection AGDG on AGDG.assortmentGroupID=LAG.assortmentGroupID
left join Symphony_DisplayGroups DG on DG.id = AGDG.displayGroupID
left join Symphony_UOM UOM on uom.uomID=sls.uomID 
left join Symphony_DBMChangePolicies dbm on dbm.ID=sls.bufferManagementPolicy 
where sl.isDeleted=0



GO
/****** Object:  View [dbo].[RetailBPLevels]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[RetailBPLevels] AS

SELECT (
		SELECT CONVERT(DECIMAL, flag_value) / 100
		FROM Symphony_Globals
		WHERE flag_name = 'RetailSettings.VarietyPenetrationColorsBlack'
		) blackLevel
	,(
		SELECT CONVERT(DECIMAL, flag_value) / 100
		FROM Symphony_Globals
		WHERE flag_name = 'RetailSettings.VarietyPenetrationColorsRed'
		) redLevel
	,(
		SELECT CONVERT(DECIMAL, flag_value) / 100
		FROM Symphony_Globals
		WHERE flag_name = 'RetailSettings.VarietyPenetrationColorsYellow'
		) yellowLevel
	,(
		SELECT CONVERT(DECIMAL, flag_value) / 100
		FROM Symphony_Globals
		WHERE flag_name = 'RetailSettings.VarietyPenetrationColorsGreen'
		) greenLevel


GO
/****** Object:  View [dbo].[SeasonalityEventsDefinitions]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  CREATE VIEW [dbo].[SeasonalityEventsDefinitions] AS
  SELECT [seasonalityID]
        ,[itemID]
        ,[eventGroup]
      --  ,[eventType]
        ,[eventState]
        ,[name]
        ,[stockLocationID]
        ,[status]
        ,[startDate]
        ,[endDate]
        ,[resizeMethod]
        ,[resizeValue]
        ,[updateSteps]
        ,[currentStep]
        ,[recurrence]
        ,[targetBuffer]
        ,[extraAmount]
        ,[originalBuffer]
        ,[isHandled]
        ,[nextChangeDate]
        ,[DataFilterDisplayString]
        ,[DataFilterSerialized]
        ,[autoAccept]
		,[revertOnEndDate]
    FROM [dbo].[Symphony_Seasonality]
    WHERE [eventState] <> 5 AND [eventType] = 0  -- 5 = EventState.Deleted. eventType = 0 is bufferSize

GO
/****** Object:  View [dbo].[SeasonalitySummaryCalcView]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[SeasonalitySummaryCalcView]
AS

SELECT
		SLS.stockLocationID,
		SLS.originStockLocation,
		SLS.skuID,
		SLS.bufferSize,
		SLS.skuPropertyID1,
		SLS.skuPropertyID2,
		SLS.skuPropertyID3,
		SLS.skuPropertyID4,
		SLS.skuPropertyID5,
		SLS.skuPropertyID6,
		SLS.skuPropertyID7,
		SL.slPropertyID1,
		SL.slPropertyID2,
		SL.slPropertyID3,
		SL.slPropertyID4,
		SL.slPropertyID5,
		SL.slPropertyID6,
		SL.slPropertyID7,
		SLS.custom_txt1,
		SLS.custom_txt2,
		SLS.custom_txt3,
		SLS.custom_txt4,
		SLS.custom_txt5,
		SLS.custom_txt6,
		SLS.custom_txt7,
		SLS.custom_txt8,
		SLS.custom_txt9,
		SLS.custom_txt10,
		SLS.custom_num1,
		SLS.custom_num2,
		SLS.custom_num3,
		SLS.custom_num4,
		SLS.custom_num5,
		SLS.custom_num6,
		SLS.custom_num7,
		SLS.custom_num8,
		SLS.custom_num9,
		SLS.custom_num10,
		MSKU.[familyID],
		MSKU.[assortmentGroupID],
		LDG.[displayGroupID]
		FROM [dbo].[Symphony_StockLocationSkus] SLS
		INNER JOIN[dbo].[Symphony_StockLocations] SL
		ON SL.[stockLocationID] = SLS.[stockLocationID]
LEFT JOIN (
SELECT
	  	MSKU.[skuID],
		MSKU.[familyID],
		LAG.[assortmentGroupID],
		LAG.[stockLocationID]
		FROM [dbo].[Symphony_MasterSkus] MSKU
		INNER JOIN[dbo].[Symphony_RetailFamilyAgConnection] FAG
		ON FAG.[familyID] = MSKU.[familyID]
		INNER JOIN [dbo].[Symphony_LocationAssortmentGroups] LAG
		ON LAG.assortmentGroupID = FAG.assortmentGroupID
) MSKU
ON MSKU.[skuID] = SLS.[skuID] AND MSKU.[stockLocationID] = SLS.[stockLocationID]                                                         
LEFT JOIN[dbo].[Symphony_RetailAgDgConnection] AGDG
ON AGDG.[assortmentGroupID] = MSKU.[assortmentGroupID]
LEFT JOIN[dbo].[Symphony_LocationDisplayGroups]  LDG
ON LDG.[displayGroupID] = AGDG.[displayGroupID] AND LDG.stockLocationID = SLS.stockLocationID
WHERE avoidSeasonality = 0 AND SLS.isDeleted = 0 AND SL.isDeleted = 0


GO
/****** Object:  View [dbo].[ShipmentPolicyDetailsView]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[ShipmentPolicyDetailsView]  as
SELECT 
SL.[stockLocationID]
,SL.[stockLocationName]
,SL.[stockLocationType]
,SL.[stockLocationDescription]
,SL.[shipmentPolicyID]
,SP.[policyName]
,SP.[policyDescription]
,SP.[minConstraint]
,SP.[maxConstraint]
,SP.[multiplication]
,SP.[lastBatch]
FROM [dbo].[Symphony_StockLocations] SL
INNER JOIN [dbo].[Symphony_ShipmentPolicies] SP
ON SP.ID = SL.[shipmentPolicyID]
		

GO
/****** Object:  View [dbo].[SRVL_AGSizeGrids]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SRVL_AGSizeGrids] AS 

SELECT RG.gridName AS grid ,AG.name AS assortmentGroup,AG.id AS assortmentGroupID, RADC.displayGroupID
FROM Symphony_RetailAssortmentGroupGrids AS RAGG
JOIN Symphony_AssortmentGroups AS AG
ON AG.id = RAGG.assortmentGroupID
JOIN Symphony_RetailGrids AS RG
ON RG.id = RAGG.gridID
JOIN Symphony_RetailAgDgConnection AS RADC
ON RADC.assortmentGroupID = AG.id

GO
/****** Object:  View [dbo].[SRVL_FamilySizeGrid]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SRVL_FamilySizeGrid] AS 
SELECT RADC.displayGroupID, RFAC.assortmentGroupID, AG.name as assortmentGroup, SF.name as family, RG.gridName as grid , modeID, RFG.warningID
FROM Symphony_RetailFamilyGrids AS RFG
JOIN Symphony_RetailFamilyAgConnection AS RFAC
ON RFG.familyID = RFAC.familyID
JOIN Symphony_RetailAgDgConnection AS RADC
ON RFAC.assortmentGroupID = RADC.assortmentGroupID
JOIN Symphony_AssortmentGroups AS AG
ON AG.id = RADC.assortmentGroupID
LEFT JOIN Symphony_RetailGrids AS RG
ON RG.id = RFG.gridID
JOIN Symphony_SkuFamilies AS SF
ON SF.id = RFG.familyID


GO
/****** Object:  View [dbo].[SRVL_Rules]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SRVL_Rules] AS 
SELECT RC.id as clusterID ,RC.clusterName,RG.gridName as grid ,RADC.displayGroupID ,AG.id as assortmentGroupID ,AG.name as assortmentGroup, minimumInventory,minimumServiceLevel
FROM Symphony_RetailServiceLevelRules AS RSLR
JOIN Symphony_AssortmentGroups AS AG
ON AG.id = RSLR.assortmentGroupID
JOIN Symphony_RetailGrids AS RG
ON RG.id = RSLR.gridID
JOIN Symphony_RetailClusters AS RC
ON RC.id = RSLR.clusterID
JOIN Symphony_RetailAgDgConnection AS RADC
ON RADC.assortmentGroupID = AG.id

GO
/****** Object:  View [dbo].[SRVL_SizeGrids]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SRVL_SizeGrids] AS 
SELECT RG.gridname as grid , SFM.name as member
FROM Symphony_RetailSizeGrids AS RSG
JOIN Symphony_RetailGrids AS RG
ON RSG.gridID = RG.id
JOIN Symphony_SkuFamilyMembers AS SFM
ON SFM.id = RSG.[memberID]


GO
/****** Object:  View [dbo].[SRVL_SRVLDistribution]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SRVL_SRVLDistribution] AS 
SELECT RSLD.assortmentGroupID, AG.name as assortmentGroup, RADC.displayGroupID, RSLD.clusterID ,RC.clusterName,RG.gridName as grid,SFM.name as size,serviceLevel
FROM Symphony_RetailServiceLevelDistributions AS RSLD
JOIN Symphony_AssortmentGroups AS AG
ON AG.id = RSLD.assortmentGroupID
JOIN Symphony_RetailGrids AS RG
ON RG.id = RSLD.gridID
JOIN Symphony_RetailAgDgConnection AS RADC
ON RSLD.assortmentGroupID = RADC.assortmentGroupID
JOIN Symphony_SkuFamilyMembers AS SFM
ON SFM.id = RSLD.[memberID]
JOIN Symphony_RetailClusters AS RC
ON RC.id = RSLD.clusterID

GO
/****** Object:  View [dbo].[SupplyChainDownstream]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SupplyChainDownstream]
AS
SELECT SLS.skuID
	,SLS.stockLocationID
	,SL1.stockLocationName
	,SLS.originStockLocation AS originID
	,SL2.stockLocationName AS originName
	,SLS.inventoryAtSite
	,SLS.bpSite
	,SLS.inventoryAtTransit
	,SLS.bpTransit
	,SLS.inventoryAtProduction
	,SLS.bpProduction
	,SLS.uomID
	,SLS.siteColor
	,SLS.transitColor
	,SLS.productionColor
	,UOM.uomName AS uomID_display
FROM dbo.Symphony_StockLocationSkus AS SLS
LEFT JOIN dbo.Symphony_StockLocations AS SL1
	ON SLS.stockLocationID = SL1.stockLocationID
LEFT JOIN dbo.Symphony_StockLocations AS SL2
	ON SLS.originStockLocation = SL2.stockLocationID
LEFT JOIN dbo.Symphony_UOM AS UOM
	ON SLS.uomID = UOM.uomID


GO
/****** Object:  View [dbo].[Symphony_DisplayGroup]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Symphony_DisplayGroup]
AS
SELECT 
id as displayGroupID,
name as displayGroupName,
[description]
FROM [dbo].[Symphony_DisplayGroups]

GO
/****** Object:  View [dbo].[Symphony_DPLM_Policies_lookup]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Symphony_DPLM_Policies_lookup]
AS
SELECT 
	 [ID]
    ,[policyName]
  FROM [dbo].[Symphony_DPLM_Policies]


GO
/****** Object:  View [dbo].[Symphony_SkuFamily]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Symphony_SkuFamily]
AS
SELECT 
id as familyID,
name as familyName,
creationDate,
familyDescription
FROM [dbo].[Symphony_SkuFamilies]


GO
/****** Object:  View [dbo].[TEMPVIEWBA4557A3-8C30-4705-8EB3-2BCB9C72A02B]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[TEMPVIEWBA4557A3-8C30-4705-8EB3-2BCB9C72A02B] as (SELECT ''+cast(min(case ordinal_position when 1 then column_name end) as varchar)+'' as [Stock Location (WW)], ''+cast(min(case ordinal_position when 2 then column_name end) as varchar)+'' as [SKU Name (WW)], ''+cast(min(case ordinal_position when 3 then column_name end) as varchar)+'' as [SKU Description (WW)], ''+cast(min(case ordinal_position when 4 then column_name end) as varchar)+'' as [Sap Site Code], ''+cast(min(case ordinal_position when 5 then column_name end) as varchar)+'' as [Sap SKU Code], ''+cast(min(case ordinal_position when 6 then column_name end) as varchar)+'' as [SLM Status], ''+cast(min(case ordinal_position when 7 then column_name end) as varchar)+'' as [Current Year], ''+cast(min(case ordinal_position when 8 then column_name end) as varchar)+'' as [Current Month], ''+cast(min(case ordinal_position when 9 then column_name end) as varchar)+'' as [Current Day], ''+cast(min(case ordinal_position when 10 then column_name end) as varchar)+'' as [No Consumption Days], ''+cast(min(case ordinal_position when 11 then column_name end) as varchar)+'' as [Class Code], ''+cast(min(case ordinal_position when 12 then column_name end) as varchar)+'' as [Class Description], ''+cast(min(case ordinal_position when 13 then column_name end) as varchar)+'' as [Category Description], ''+cast(min(case ordinal_position when 14 then column_name end) as varchar)+'' as [Category Code], ''+cast(min(case ordinal_position when 15 then column_name end) as varchar)+'' as [Group Description], ''+cast(min(case ordinal_position when 16 then column_name end) as varchar)+'' as [Group Code], ''+cast(min(case ordinal_position when 17 then column_name end) as varchar)+'' as [Inv. At Site], ''+cast(min(case ordinal_position when 18 then column_name end) as varchar)+'' as [Article Status], ''+ cast(min(case ordinal_position when 19 then column_name end) as varchar)+'' as [Origin Stock Location]  from [SymphonyInfiniti].information_schema.columns where UPPER(table_name) = Upper('SYMPHONY_EXPORTDATA')  union all  select  ''+CASE when isnumeric([Stock Location (WW)]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='STOCK LOCATION (WW)') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Stock Location (WW)] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Stock Location (WW)] = '' THEN NULL ELSE [Stock Location (WW)] END as varchar(max)) END+'' as [Stock Location (WW)], ''+CASE when isnumeric([SKU Name (WW)]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='SKU NAME (WW)') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([SKU Name (WW)] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [SKU Name (WW)] = '' THEN NULL ELSE [SKU Name (WW)] END as varchar(max)) END+'' as [SKU Name (WW)], ''+CASE when isnumeric([SKU Description (WW)]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='SKU DESCRIPTION (WW)') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([SKU Description (WW)] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [SKU Description (WW)] = '' THEN NULL ELSE [SKU Description (WW)] END as varchar(max)) END+'' as [SKU Description (WW)], ''+CASE when isnumeric([Sap Site Code]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='SAP SITE CODE') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Sap Site Code] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Sap Site Code] = '' THEN NULL ELSE [Sap Site Code] END as varchar(max)) END+'' as [Sap Site Code], ''+CASE when isnumeric([Sap SKU Code]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='SAP SKU CODE') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Sap SKU Code] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Sap SKU Code] = '' THEN NULL ELSE [Sap SKU Code] END as varchar(max)) END+'' as [Sap SKU Code], ''+CASE when isnumeric([SLM Status]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='SLM STATUS') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([SLM Status] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [SLM Status] = '' THEN NULL ELSE [SLM Status] END as varchar(max)) END+'' as [SLM Status], ''+CASE when isnumeric([Current Year]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='CURRENT YEAR') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Current Year] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Current Year] = '' THEN NULL ELSE [Current Year] END as varchar(max)) END+'' as [Current Year], ''+CASE when isnumeric([Current Month]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='CURRENT MONTH') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Current Month] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Current Month] = '' THEN NULL ELSE [Current Month] END as varchar(max)) END+'' as [Current Month], ''+CASE when isnumeric([Current Day]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='CURRENT DAY') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Current Day] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Current Day] = '' THEN NULL ELSE [Current Day] END as varchar(max)) END+'' as [Current Day], ''+CASE when isnumeric([No Consumption Days]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='NO CONSUMPTION DAYS') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([No Consumption Days] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [No Consumption Days] = '' THEN NULL ELSE [No Consumption Days] END as varchar(max)) END+'' as [No Consumption Days], ''+CASE when isnumeric([Class Code]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='CLASS CODE') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Class Code] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Class Code] = '' THEN NULL ELSE [Class Code] END as varchar(max)) END+'' as [Class Code], ''+CASE when isnumeric([Class Description]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='CLASS DESCRIPTION') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Class Description] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Class Description] = '' THEN NULL ELSE [Class Description] END as varchar(max)) END+'' as [Class Description], ''+CASE when isnumeric([Category Description]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='CATEGORY DESCRIPTION') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Category Description] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Category Description] = '' THEN NULL ELSE [Category Description] END as varchar(max)) END+'' as [Category Description], ''+CASE when isnumeric([Category Code]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='CATEGORY CODE') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Category Code] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Category Code] = '' THEN NULL ELSE [Category Code] END as varchar(max)) END+'' as [Category Code], ''+CASE when isnumeric([Group Description]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='GROUP DESCRIPTION') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Group Description] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Group Description] = '' THEN NULL ELSE [Group Description] END as varchar(max)) END+'' as [Group Description], ''+CASE when isnumeric([Group Code]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='GROUP CODE') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Group Code] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Group Code] = '' THEN NULL ELSE [Group Code] END as varchar(max)) END+'' as [Group Code], ''+CASE when isnumeric([Inv. At Site]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='INV. AT SITE') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Inv. At Site] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Inv. At Site] = '' THEN NULL ELSE [Inv. At Site] END as varchar(max)) END+'' as [Inv. At Site], ''+CASE when isnumeric([Article Status]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='ARTICLE STATUS') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Article Status] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Article Status] = '' THEN NULL ELSE [Article Status] END as varchar(max)) END+'' as [Article Status], ''+CASE when isnumeric([Origin Stock Location]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='ORIGIN STOCK LOCATION') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Origin Stock Location] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Origin Stock Location] = '' THEN NULL ELSE [Origin Stock Location] END as varchar(max)) END+'' as [Origin Stock Location] FROM [SymphonyInfiniti]..[SYMPHONY_EXPORTDATA])
GO
/****** Object:  View [dbo].[TEMPVIEWF9AA8803-F0DE-4C90-AF64-AA2AC46B403E]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[TEMPVIEWF9AA8803-F0DE-4C90-AF64-AA2AC46B403E] as (SELECT ''+cast(min(case ordinal_position when 1 then column_name end) as varchar)+'' as [Stock Location], ''+cast(min(case ordinal_position when 2 then column_name end) as varchar)+'' as [Stock Location Desc], ''+cast(min(case ordinal_position when 3 then column_name end) as varchar)+'' as [SKU Code], ''+cast(min(case ordinal_position when 4 then column_name end) as varchar)+'' as [SKU Desc], ''+cast(min(case ordinal_position when 5 then column_name end) as varchar)+'' as [Current SLM status], ''+cast(min(case ordinal_position when 6 then column_name end) as varchar)+'' as [Change Date], ''+cast(min(case ordinal_position when 7 then column_name end) as varchar)+'' as [Class Code], ''+cast(min(case ordinal_position when 8 then column_name end) as varchar)+'' as [Class Desc], ''+cast(min(case ordinal_position when 9 then column_name end) as varchar)+'' as [Category Code], ''+cast(min(case ordinal_position when 10 then column_name end) as varchar)+'' as [Cat Desc], ''+cast(min(case ordinal_position when 11 then column_name end) as varchar)+'' as [Group Code], ''+ cast(min(case ordinal_position when 12 then column_name end) as varchar)+'' as [Group Desc]  from [SymphonyInfiniti].information_schema.columns where UPPER(table_name) = Upper('SYMPHONY_EXPORTDATA')  union all  select  ''+CASE when isnumeric([Stock Location]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='STOCK LOCATION') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Stock Location] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Stock Location] = '' THEN NULL ELSE [Stock Location] END as varchar(max)) END+'' as [Stock Location], ''+CASE when isnumeric([Stock Location Desc]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='STOCK LOCATION DESC') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Stock Location Desc] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Stock Location Desc] = '' THEN NULL ELSE [Stock Location Desc] END as varchar(max)) END+'' as [Stock Location Desc], ''+CASE when isnumeric([SKU Code]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='SKU CODE') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([SKU Code] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [SKU Code] = '' THEN NULL ELSE [SKU Code] END as varchar(max)) END+'' as [SKU Code], ''+CASE when isnumeric([SKU Desc]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='SKU DESC') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([SKU Desc] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [SKU Desc] = '' THEN NULL ELSE [SKU Desc] END as varchar(max)) END+'' as [SKU Desc], ''+CASE when isnumeric([Current SLM status]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='CURRENT SLM STATUS') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Current SLM status] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Current SLM status] = '' THEN NULL ELSE [Current SLM status] END as varchar(max)) END+'' as [Current SLM status], ''+CASE when isnumeric([Change Date]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='CHANGE DATE') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Change Date] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Change Date] = '' THEN NULL ELSE [Change Date] END as varchar(max)) END+'' as [Change Date], ''+CASE when isnumeric([Class Code]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='CLASS CODE') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Class Code] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Class Code] = '' THEN NULL ELSE [Class Code] END as varchar(max)) END+'' as [Class Code], ''+CASE when isnumeric([Class Desc]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='CLASS DESC') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Class Desc] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Class Desc] = '' THEN NULL ELSE [Class Desc] END as varchar(max)) END+'' as [Class Desc], ''+CASE when isnumeric([Category Code]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='CATEGORY CODE') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Category Code] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Category Code] = '' THEN NULL ELSE [Category Code] END as varchar(max)) END+'' as [Category Code], ''+CASE when isnumeric([Cat Desc]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='CAT DESC') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Cat Desc] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Cat Desc] = '' THEN NULL ELSE [Cat Desc] END as varchar(max)) END+'' as [Cat Desc], ''+CASE when isnumeric([Group Code]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='GROUP CODE') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Group Code] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Group Code] = '' THEN NULL ELSE [Group Code] END as varchar(max)) END+'' as [Group Code], ''+CASE when isnumeric([Group Desc]) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = 'SYMPHONY_EXPORTDATA' 
		and (UPPER(data_type) <> 'VARCHAR' OR UPPER(data_type) <> 'NVARCHAR' OR UPPER(data_type) <> 'CHAR' OR UPPER(data_type) <>'NCHAR') 
		and Upper(column_name)='GROUP DESC') THEN -1 ELSE 0
		END = 0
		THEN cast(cast([Group Desc] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when [Group Desc] = '' THEN NULL ELSE [Group Desc] END as varchar(max)) END+'' as [Group Desc] FROM [SymphonyInfiniti]..[SYMPHONY_EXPORTDATA])
GO
/****** Object:  View [dbo].[UserViewDefaults]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[UserViewDefaults]
AS
	SELECT 
		 UVI.viewID
		,NULL [userID]
		,UV.viewName
		,UV.formName
		,UVI.itemName
		,UVI.itemState
		,UVI.id [itemID]
		,UV.[isSystemDefault]
		,CONVERT(bit, 0) [isUserDefault]
	FROM [dbo].[Symphony_UserViews] UV
	INNER JOIN [dbo].[Symphony_UserViewItems] UVI
		ON UVI.[viewID] = UV.[id]
	WHERE UV.[isSystemDefault] = 1
	UNION ALL
	SELECT 
		 UVI.viewID
		,UVA.userID
		,UV.viewName
		,UV.formName
		,UVI.itemName
		,UVI.itemState
		,UVI.id [itemID]
		,UV.[isSystemDefault]
		,UVA.[isUserDefault]
	FROM [dbo].[Symphony_UserViews] UV
	INNER JOIN [dbo].[Symphony_UserViewItems] UVI
		ON UVI.[viewID] = UV.[id]
	INNER JOIN [dbo].[Symphony_UserViewsAssignment] UVA
		ON UVA.[viewID] = UV.[id]
	WHERE UVA.[isUserDefault] = 1


GO
/****** Object:  View [dbo].[UserViewItems]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[UserViewItems]
AS
SELECT 
	 UVA .[userID]
	,UV.[viewName]
	,UV.[formName]
	,UVI.[itemState]
	,UVI.[itemName]
	,UVI.[id] [itemID]
FROM [dbo].[Symphony_UserViewsAssignment] UVA
INNER JOIN [dbo].[Symphony_UserViews] UV
ON UV.[id] = UVA.[viewID]
INNER JOIN [dbo].[Symphony_UserViewItems] UVI
	ON UV.[id] = UVI.[viewID]
UNION
SELECT 
	-1 [userID]
	,UV.[viewName]
	,UV.[formName]
	,UVI.[itemState]
	,UVI.[itemName]
	,UVI.[id] [itemID]
FROM [dbo].[Symphony_UserViews] UV
INNER JOIN [dbo].[Symphony_UserViewItems] UVI
	ON UV.[id] = UVI.[viewID]
WHERE UV.isSystemDefault = 1

GO
/****** Object:  View [dbo].[UserViews]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[UserViews]
AS
(
		SELECT UV.[id]
			,UV.[userID]
			,[viewName]
			,[formName]
			,[createdBy]
			,[createdDate]
			,[isPublic]
			,[viewState]
			,[isSystemDefault]
			,ISNULL(UVA.isUserDefault, 0) [isUserDefault]
			,ISNULL(CONVERT(BIT, ISNULL(UVA.userID, 0)), 0) [assignToMe]
		FROM (
			SELECT CONVERT(int, UP.[userPasswordID]) [userID]
				,UV.*
			FROM Symphony_UserViews UV
			CROSS JOIN Symphony_UserPassword UP
			WHERE UP.userPasswordID = UV.createdBy
				OR UV.isPublic = 1
				OR UV.isSystemDefault = 1
		) UV
		LEFT JOIN Symphony_UserViewsAssignment UVA
			ON UVA.viewID = UV.id
				AND UVA.userID = UV.userID
		)

GO
/****** Object:  View [dbo].[UserViewsReport]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[UserViewsReport] AS

WITH viewValidity AS(
SELECT 
 viewID
,CONVERT(bit,MIN(CONVERT(tinyint, dbo.IsItemStateValid(UVI.itemState)))) isValid
FROM Symphony_UserViewItems UVI
GROUP BY viewID
)
,userCounts AS(
SELECT [viewID]
	,COUNT([userID])  userCount
	,SUM(CONVERT(int, [isUserDefault])) userDefaultCount
FROM [dbo].[Symphony_UserViewsAssignment]
GROUP BY [viewID]
)

SELECT 
 UV.[formName]
,UV.id [viewID]
,UV.[viewName]
,UV.[createdBy] [ownerID]
,UP.[userName] [ownerName]
,UV.[createdDate]
,VV.[isValid]
,UV.[isPublic]
,UV.[isSystemDefault]
, UC.userCount
, UC.userDefaultCount
FROM [dbo].[Symphony_UserViews] UV
INNER JOIN viewValidity VV
ON VV.viewID = UV.id
LEFT JOIN userCounts UC
ON UC.viewID = UV.id
LEFT JOIN [dbo].[Symphony_UserPassword] UP
ON UP.[userPasswordID] = UV.createdBy


GO
/****** Object:  View [dbo].[WorkOrderColorChanges]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[WorkOrderColorChanges] AS

SELECT 
	WO.ID 
	,woid
	,description as woDescription
	,WO.skuID
	, skus.skuName
	,ISNULL([SkuDesc], mtoSk.skuDescription) AS SkuDesc
	,PlantID
	,sl.stockLocationName as PlantName
	,componentID
	,workCenter
	,saleOrderID
	,WO.stockLocationName
	,WO.stockLocationDesc
	,quantity
	,orderType
	,dueDate = CASE isToOrder
		WHEN 1
			THEN dueDate
		ELSE NULL
		END
	,bufferPenetration
	,bufferColor
	,prevColor
	,woPropertyID1
	,woPropertyID2
	,woPropertyID3
	,woPropertyID4
	,woPropertyID5
	,woPropertyID6
	,woPropertyID7
	,woPropertyID8
	,woPropertyID9
	,woPropertyID10
	,woPropertyID11
	,woPropertyID12
	,woPropertyID13
	,woPropertyID14
	,woPropertyID15
	,woPropertyID16
	,woPropertyID17
	,woPropertyID18
	,woPropertyID19
	,woPropertyID20
	,woCustom_txt1
	,woCustom_txt2
	,woCustom_txt3
	,woCustom_txt4
	,woCustom_txt5
	,woCustom_txt6
	,woCustom_txt7
	,woCustom_txt8
	,woCustom_txt9
	,woCustom_txt10
	,woCustom_num1
	,woCustom_num2
	,woCustom_num3
	,woCustom_num4
	,woCustom_num5
	,woCustom_num6
	,woCustom_num7
	,woCustom_num8
	,woCustom_num9
	,woCustom_num10
	,WO.notes
	,WO.uomID
	,WO.clientOrderID
	,WO.considered
	,sl.slPropertyID1
	,sl.slPropertyID2
	,sl.slPropertyID3
	,sl.slPropertyID4
	,sl.slPropertyID5
	,sl.slPropertyID6
	,sl.slPropertyID7
	,Sk.skuPropertyID1
	,Sk.skuPropertyID2
	,Sk.skuPropertyID3
	,Sk.skuPropertyID4
	,Sk.skuPropertyID5
	,Sk.skuPropertyID6
	,Sk.skuPropertyID7
FROM Symphony_WorkOrders WO
LEFT JOIN Symphony_StockLocations sl 
ON sl.stockLocationID = WO.PlantID
LEFT JOIN Symphony_MTOSkus mtoSk 
ON 	mtoSk.skuID = WO.skuID	AND mtoSk.stockLocationID = WO.PlantID		
LEFT JOIN Symphony_Skus skus
ON mtoSk.skuID = skus.skuID
LEFT JOIN Symphony_StockLocationSkus Sk 
ON 	Sk.skuID = WO.skuID AND Sk.stockLocationID = WO.PlantID		
LEFT JOIN [Symphony_ProductionFamilies] PF 
ON [WO].[productionFamily] = [PF].[ID]
WHERE WO.isFinished = 0
	AND isPhantom = 0
	AND WO.newRedBlack = 1
	AND WO.considered = 0

GO
/****** Object:  StoredProcedure [dbo].[AfterCreate]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AfterCreate] 
	@objectType sysname,
	@objectName sysname
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF OBJECT_ID(@objectName) IS NOT NULL
		PRINT '<<< CREATED ' + @objectType + ' ' + @objectName + ' >>>'
	ELSE
		PRINT '<<< FAILED CREATING ' + @objectType + ' ' + @objectName + ' >>>'

END

GO
/****** Object:  StoredProcedure [dbo].[BeforeCreate]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BeforeCreate] 
	-- Add the parameters for the stored procedure here
	@objectType sysname,
	@objectName sysname
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF OBJECT_ID(@objectName) IS NOT NULL
	BEGIN
		EXEC ('DROP ' + @objectType + ' ' + @objectName)
		IF OBJECT_ID(@objectName) IS NOT NULL
			PRINT '<<< FAILED DROPPING ' + @objectType + ' ' + @objectName + ' >>>'
		ELSE
			PRINT '<<< DROPPED ' + @objectType + ' ' + @objectName + ' >>>'
	END

END

GO
/****** Object:  StoredProcedure [dbo].[CleanInputTableData]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ================================================
-- Author: Reuven Jackson
-- Create date: December 1, 2015
-- Description:
--		Remove leading and trailing spaces for all
--		table columns of type nvarchar
-- ================================================

CREATE PROCEDURE [dbo].[CleanInputTableData] 
	-- Add the parameters for the stored procedure here
	@inputTableName nvarchar(128)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @cmd nvarchar(max);
				
	DECLARE 
		 @count int
		,@index int
		,@columns dbo.StringList
		,@columnNames nvarchar(max)
		
	INSERT INTO @columns
		SELECT [name] FROM sys.columns
		WHERE [object_id] = OBJECT_ID(@inputTableName)
		AND [system_type_id] = 231
		
	SELECT @cmd = N'UPDATE ' + @inputTableName + ' SET ' + dbo.TrimAndAssign(',', @columns)	

	EXEC (@cmd)
END



GO
/****** Object:  StoredProcedure [dbo].[Client_SP_Daily_Replenishment_Output]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Client_SP_Daily_Replenishment_Output]
AS
BEGIN


drop table client_temp_replenishment_table

select * into client_temp_replenishment_table from

(SELECT sl.stockLocationName as [Stock Location]
         ,ss.skuName as SKU
		 ,CAST(sls.replenishmentQuantity AS decimal(20,0)) as repl_ori

		 ,case when (sls.bufferSize+sls.saftyStock - (sls.inventoryAtSite+sls.inventoryAtTransit))<=0 then 0 else  CAST(sls.replenishmentQuantity AS decimal(20,0)) end as [Replenishment Quantity]
		 ,sl1.stockLocationName as [Origin Stock Location]
		 ,spi6.skuItemName as Range_flag
		 ,sls.custom_txt3 as [Group code]
		 ,case when productionColor=0 then 'Cyan' 
       when productionColor=1 then 'Green' 
	when productionColor=2 then 'yellow' 	
   	when productionColor=3 then 'Red' 	
	when productionColor=4 then 'Black' end	[BP Color]
		 ,cast(sls.bpProduction as decimal (20,2)) as [Virtual pipe Penetration]
		 ,sls.inventoryNeeded as [Inventory Needed]
         ,cast(sls.bufferSize as decimal(20,0)) as [Buffer Size]
		 ,sls.inventoryAtSite+sls.inventoryAtTransit as Pipe
		 ,0 as front_end_gap
		 --,a.g as front_end_gap
         
		 --,isnull(a.g,0) as FE_Gap
         --,sls.inventoryatsite+sls.inventoryattransit+sls.inventoryatproduction as pipe
		 --,isnull((sls.bufferSize+isnull(a.g,0))-(sls.inventoryatsite+sls.inventoryattransit+sls.inventoryatproduction),0) as total_gap
		 
  	 FROM [SymphonyInfiniti].[dbo].[Symphony_StockLocationSkus] sls
  join Symphony_StockLocations sl
on sls.stockLocationID=sl.stockLocationID
join Symphony_StockLocations sl1
on sls.originStockLocation=sl1.stockLocationID
join Symphony_SKUs ss
on sls.skuid=ss.skuID
left join Symphony_SKUsPropertyItems spi6 on sls.skuPropertyID6=spi6.skuItemID
/*
left join 
(SELECT sl1.stockLocationName as [Stock Location]
         ,ss.skuName as SKU
		 ,sum(sls.replenishmentQuantity) as [Replenishment Quantity]
		 ,sum(sls.inventoryNeeded) as inveneed
		 ,ISNULL(sum(sls.inventoryNeeded-sls.replenishmentQuantity),0) as g
		 ,sum(cast(sls.bufferSize as decimal(20,0))) as [Buffer Size]
		 FROM [SymphonyInfiniti].[dbo].[Symphony_StockLocationSkus] sls
  join Symphony_StockLocations sl
on sls.stockLocationID=sl.stockLocationID
 join Symphony_StockLocations sl1
on sls.originStockLocation=sl1.stockLocationID
join Symphony_SKUs ss
on sls.skuid=ss.skuID
left join Symphony_SKUsPropertyItems spi6 on sls.skuPropertyID6=spi6.skuItemID
where /*sls.inventoryNeeded-sls.replenishmentQuantity>0 and */ sl.stockLocationType=3 and spi6.skuItemName='Y'
group by sl1.stockLocationName,ss.skuName)a on a.[Stock Location]=sl.stockLocationName and a.SKU=ss.skuName 
*/
where /*sls.replenishmentQuantity>0 and*/ --(sls.bufferSize+isnull(a.g,0) - (sls.inventoryAtSite+sls.inventoryAtTransit))>0

(sls.replenishmentQuantity>0) 
and sls.bufferSize>0 and sl1.stockLocationName like 'D%'
and spi6.skuItemName='Y' --and ss.skuName='162323'
--and sl.stockLocationName='COR GOLD' and 
--AND ss.skuName='GCHACHA000086_W_0008_000'
--and ((sls.bufferSize+a.g)-(sls.inventoryatsite+sls.inventoryattransit+sls.inventoryatproduction))>0
)#erf


select [Stock Location],SKU,[Replenishment Quantity],[Origin Stock Location],[Group code],[BP Color],
[Virtual pipe Penetration],[Inventory Needed],[Buffer Size] from client_temp_replenishment_table
where [Replenishment Quantity]>0


end
GO
/****** Object:  StoredProcedure [dbo].[Client_SP_Daily_Replenishment_Output_Wednesday]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Client_SP_Daily_Replenishment_Output_Wednesday]
AS
BEGIN

drop table client_temp_replenishment_table

select * into client_temp_replenishment_table from

(SELECT sl.stockLocationName as [Stock Location]
         ,ss.skuName as SKU
		 ,CAST(sls.replenishmentQuantity AS decimal(20,0)) as repl_ori

		 ,case when (sls.bufferSize+sls.saftyStock - (sls.inventoryAtSite+sls.inventoryAtTransit))<=0 then 0 else  CAST(sls.replenishmentQuantity AS decimal(20,0)) end as [Replenishment Quantity]
		 ,sl1.stockLocationName as [Origin Stock Location]
		 ,spi6.skuItemName as Range_flag
		 ,sls.custom_txt3 as [Group code]
		 ,case when productionColor=0 then 'Cyan' 
       when productionColor=1 then 'Green' 
	when productionColor=2 then 'yellow' 	
   	when productionColor=3 then 'Red' 	
	when productionColor=4 then 'Black' end	[BP Color]
		 ,cast(sls.bpProduction as decimal (20,2)) as [Virtual pipe Penetration]
		 ,sls.inventoryNeeded as [Inventory Needed]
         ,cast(sls.bufferSize as decimal(20,0)) as [Buffer Size]
		 ,sls.inventoryAtSite+sls.inventoryAtTransit as Pipe
		 ,0 as front_end_gap
		 --,a.g as front_end_gap
         
		 --,isnull(a.g,0) as FE_Gap
         --,sls.inventoryatsite+sls.inventoryattransit+sls.inventoryatproduction as pipe
		 --,isnull((sls.bufferSize+isnull(a.g,0))-(sls.inventoryatsite+sls.inventoryattransit+sls.inventoryatproduction),0) as total_gap
		 
  	 FROM [SymphonyInfiniti].[dbo].[Symphony_StockLocationSkus] sls
  join Symphony_StockLocations sl
on sls.stockLocationID=sl.stockLocationID
join Symphony_StockLocations sl1
on sls.originStockLocation=sl1.stockLocationID
join Symphony_SKUs ss
on sls.skuid=ss.skuID
left join Symphony_SKUsPropertyItems spi6 on sls.skuPropertyID6=spi6.skuItemID
/*
left join 
(SELECT sl1.stockLocationName as [Stock Location]
         ,ss.skuName as SKU
		 ,sum(sls.replenishmentQuantity) as [Replenishment Quantity]
		 ,sum(sls.inventoryNeeded) as inveneed
		 ,ISNULL(sum(sls.inventoryNeeded-sls.replenishmentQuantity),0) as g
		 ,sum(cast(sls.bufferSize as decimal(20,0))) as [Buffer Size]
		 FROM [SymphonyInfiniti].[dbo].[Symphony_StockLocationSkus] sls
  join Symphony_StockLocations sl
on sls.stockLocationID=sl.stockLocationID
 join Symphony_StockLocations sl1
on sls.originStockLocation=sl1.stockLocationID
join Symphony_SKUs ss
on sls.skuid=ss.skuID
left join Symphony_SKUsPropertyItems spi6 on sls.skuPropertyID6=spi6.skuItemID
where /*sls.inventoryNeeded-sls.replenishmentQuantity>0 and */ sl.stockLocationType=3 and spi6.skuItemName='Y'
group by sl1.stockLocationName,ss.skuName)a on a.[Stock Location]=sl.stockLocationName and a.SKU=ss.skuName 
*/
where /*sls.replenishmentQuantity>0 and*/ --(sls.bufferSize+isnull(a.g,0) - (sls.inventoryAtSite+sls.inventoryAtTransit))>0

(sls.replenishmentQuantity>0) 
and sls.bufferSize>0 and sl1.stockLocationName like 'D%'
and spi6.skuItemName='Y' --and ss.skuName='162323'
--and sl.stockLocationName='COR GOLD' and 
--AND ss.skuName='GCHACHA000086_W_0008_000'
--and ((sls.bufferSize+a.g)-(sls.inventoryatsite+sls.inventoryattransit+sls.inventoryatproduction))>0
union

SELECT sl1.stockLocationName as [Stock Location]
         ,ss.skuName as SKU
		 ,CAST(sls.replenishmentQuantity AS decimal(20,0)) as repl_ori

		 ,case when spi6.skuItemName='Y' and ((sls.inventoryAtSite+sls.inventoryAtTransit)-(sls.bufferSize+sls.saftyStock))>0 then 
                   cast ( ((sls.inventoryAtSite+sls.inventoryAtTransit)-(sls.bufferSize+sls.saftyStock)) as decimal(20,0))  else 
case when spi6.skuItemName='N' and (sls.inventoryAtSite+sls.inventoryAtTransit)>0 then  cast ((sls.inventoryAtSite+sls.inventoryAtTransit) as decimal(20,0))  else 0

   end end as [Replenishment Quantity]
		 ,sl.stockLocationName  as [Origin Stock Location]
		 ,spi6.skuItemName as Range_flag
		 ,sls.custom_txt3 as [Group code]
		 ,case when productionColor=0 then 'Cyan' 
       when productionColor=1 then 'Green' 
	when productionColor=2 then 'yellow' 	
   	when productionColor=3 then 'Red' 	
	when productionColor=4 then 'Black' end	[BP Color]
		 ,cast(sls.bpProduction as decimal (20,2)) as [Virtual pipe Penetration]
		 ,sls.inventoryNeeded as [Inventory Needed]
         ,cast(sls.bufferSize as decimal(20,0)) as [Buffer Size]
		 ,sls.inventoryAtSite+sls.inventoryAtTransit as Pipe
		 ,0 as front_end_gap
		 		 
  	 FROM Symphony_StockLocationSkus sls
 join Symphony_StockLocations sl on sls.stockLocationID=sl.stockLocationID
join Symphony_StockLocations sl1 on sls.originStockLocation=sl1.stockLocationID
join Symphony_SKUs ss on sls.skuid=ss.skuID
left join Symphony_SKUsPropertyItems spi6 on sls.skuPropertyID6=spi6.skuItemID

where
sl.stockLocationName in ( 'D024','D045','D046','D047','D048')
and sls.inventoryAtSite+sls.inventoryAtTransit>0






)#erf


select [Stock Location],SKU,[Replenishment Quantity],[Origin Stock Location],[Group code],[BP Color],
[Virtual pipe Penetration],[Inventory Needed],[Buffer Size] from client_temp_replenishment_table
where [Replenishment Quantity]>0


end
GO
/****** Object:  StoredProcedure [dbo].[Client_SP_Daily_Updatee]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Client_SP_Daily_Updatee]
AS
BEGIN


 update Symphony_StockLocationSkus set inventoryAtTransit = 0 
  where inventoryAtTransit<0  

  update Symphony_StockLocationSkuHistory set inventoryAtTransit = 0 
  where inventoryAtTransit<0 

 
  update [SymphonyInfiniti].[dbo].[Symphony_MasterSkus] 
  set npiQuantity=1 where npiQuantity=0  

   
   update SLS set sls.skuDescription=ms.skuDescription 
    from [SymphonyInfiniti].[dbo].[Symphony_StockLocationSkus] sls   join Symphony_MasterSkus ms on ms.skuID=sls.skuID  
	 where (sls.skuDescription is null or sls.skuDescription='')  

	  update SLS set sls.minimumBufferSize=0  
	  from [SymphonyInfiniti].[dbo].[Symphony_StockLocationSkus] sls  
	   join Symphony_StockLocations sl on sl.stockLocationID=sls.stockLocationID  
	    where skuPropertyID6=422 and skuPropertyID4 in (9,44,157) and bufferSize>0  
		 AND custom_txt10 NOT in ('SLM2','SLM3') and sl.stockLocationType=3   

		  update SLS set sls.saftyStock=0   from [SymphonyInfiniti].[dbo].[Symphony_StockLocationSkus] sls  
		   join Symphony_StockLocations sl on sl.stockLocationID=sls.stockLocationID  
		    where skuPropertyID6=422 and skuPropertyID4 in (9,44,157) and bufferSize>0  
			 AND custom_txt10 NOT in ('SLM2','SLM3') and sl.stockLocationType=3 
			     
			  update SLS set sls.bufferSize=0   from [SymphonyInfiniti].[dbo].[Symphony_StockLocationSkus] sls  
			   join Symphony_StockLocations sl on sl.stockLocationID=sls.stockLocationID   where skuPropertyID6=422 
			   and skuPropertyID4 in (9,44,157) and bufferSize>0   AND custom_txt10 NOT in ('SLM2','SLM3') 
			   and sl.stockLocationType=3   
			   
			   update ms  set ms.custom_txt8 = skf.name 
			    FROM [SymphonyInfiniti].[dbo].[Symphony_MasterSkus] ms  
				 JOIN [SymphonyInfiniti].[dbo].[Symphony_SkuFamilies] skf on ms.familyID=skf.id 
				  where ms.custom_txt8 is null or ms.custom_txt8=''     

				  
update sl2 set sl2.slPropertyID3=246
from Symphony_StockLocations sl2
where stockLocationType=3 and isDeleted=0
and  slPropertyID3 is null



update sl set sl.defaultOriginID=sls2.OSL
from Symphony_StockLocations sl
left join (
select  distinct sls.stockLocationID ,max ( sls.originStockLocation) as OSL from Symphony_StockLocationSkus sls
left join Symphony_StockLocations sl on sls.stockLocationID=sl.stockLocationID
--left join Symphony_StockLocations sl1 on sl1.stockLocationID=sls.originStockLocation
where  sl.stockLocationType=3 and sl.isDeleted=0 and sls.isDeleted=0
group by sls.stockLocationID) sls2 on sls2.stockLocationID=sl.stockLocationID
where sl.defaultOriginID is null and sl.stockLocationType=3 and sl.isDeleted=0 and sls2.osl is not null

end
GO
/****** Object:  StoredProcedure [dbo].[Client_SP_DC_Buffer_Calculation]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[Client_SP_DC_Buffer_Calculation]
AS
BEGIN



Drop table client_temp_days_cover
CREATE TABLE client_temp_days_cover
(
DC nvarchar(100),
CLASS_CODE nvarchar(100),
BRAND_CODE nvarchar(100),
DAYS_COVER_BEST_SELLER nvarchar(100),
DAYS_COVER_NON_BEST_SELLER nvarchar(100),
)

BULK INSERT client_temp_days_cover
FROM 'D:\symphonydata\CustomQuery\Days_Cover\Days_cover.csv'
WITH
(
FIRSTROW = 2, --ignores first row (header row)
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)

drop table dc_buffer_temp1 

select * into dc_buffer_temp1 from (

select sl.stockLocationName as DC,
      sls.locationSkuName as SKU,
	  sls.skuDescription,
	  cast(sls.bufferSize as decimal(10,0)) as Current_Buffer,
	  osl.stockLocationName as Origin_Stock_Location,
	    spi2.skuItemName as Category_Description,
	   sls.custom_txt5 as Brand_Description,
	   spi1.skuItemName as Class_Description,
	     spi3.skuItemName as Group_Description,
		 sls.custom_txt1 as Class_Code,
		 sls.custom_txt6 as Brand_Code,
		 spi4.skuItemName as Status ,
	  spi6.skuItemName as Ranging ,
	  sls.custom_txt4 as Stocking_Policy ,
	  spi7.skuitemname as Best_Seller ,
	  cast (sls.custom_num2 as decimal(10,0)) as GRN_Status ,
	   
	  cast (sls.unitPrice as decimal(10,2)) as MAP ,
	  sls.custom_num3 as Weekly_Sales ,
	  cast(sls.custom_num3/7 as decimal(10,3)) as Daily_Sales ,
         dy.DAYS_COVER_BEST_SELLER ,
		 dy.DAYS_COVER_NON_BEST_SELLER ,
    case when sls.custom_num2=0 then cast(sls.bufferSize as decimal(10,0)) else 
	case when spi7.skuItemName='BestSeller' and dy.days_cover_best_seller is not null then cast(round((sls.custom_num3/7)*dy.days_cover_best_seller,0,0) as decimal(10,0)) else
    case when spi7.skuItemName is null  and dy.days_cover_non_best_seller is not null then cast(round((sls.custom_num3/7)*dy.days_cover_non_best_seller,0,0) as decimal(10,0))
 else	0  end end end as DC_Calculated_Buffer,

 cast(sls.unitprice as decimal(10,2)) * case when sls.custom_num2=0 then cast(sls.bufferSize as decimal(10,0)) else 
	case when spi7.skuItemName='BestSeller' and dy.days_cover_best_seller is not null then cast(round((sls.custom_num3/7)*dy.days_cover_best_seller,0,0) as decimal(10,0)) else
    case when spi7.skuItemName is null  and dy.days_cover_non_best_seller is not null then cast(round((sls.custom_num3/7)*dy.days_cover_non_best_seller,0,0) as decimal(10,0))
 else	0  end end end as DC_Calculated_Buffer_Value 


from Symphony_StockLocationSkus sls
left join Symphony_StockLocations sl on sl.stockLocationID=sls.stockLocationID
left join Symphony_StockLocations osl on osl.stockLocationID=sls.originStockLocation
left join Symphony_SKUsPropertyItems spi1 on spi1.skuItemID=sls.skuPropertyID1
left join Symphony_SKUsPropertyItems spi2 on spi2.skuItemID=sls.skuPropertyID2
left join Symphony_SKUsPropertyItems spi3 on spi3.skuItemID=sls.skuPropertyID3
left join Symphony_SKUsPropertyItems spi4 on spi4.skuItemID=sls.skuPropertyID4
left join Symphony_SKUsPropertyItems spi6 on spi6.skuItemID=sls.skuPropertyID6
left join Symphony_SKUsPropertyItems spi7 on spi7.skuItemID=sls.skuPropertyID7
left join [SymphonyInfiniti].[dbo].[client_temp_days_cover] dy on dy.dc=sl.stockLocationName 
and RIGHT('000'+CAST(dy.CLASS_CODE AS VARCHAR(4)),4)=sls.custom_txt1 and  RIGHT('000'+CAST(dy.BRAND_CODE AS VARCHAR(4)),4)=sls.custom_txt6
where sls.isDeleted=0 and sl.isDeleted=0 and sl.stockLocationType=5 and
sls.custom_txt4='S' and spi6.skuItemName='Y' and spi4.skuItemName in ('ZA','ZN','ZT')
-- and sl.stockLocationName='D001'
)#sxc


select * from dc_buffer_temp1

end
GO
/****** Object:  StoredProcedure [dbo].[Client_SP_Excessstk]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Client_SP_Excessstk]
AS
BEGIN


drop table client_temp_slmstk

select * into client_temp_slmstk from (select sl.stockLocationName
       ,sl.stockLocationDescription
       ,s.skuName
	   ,sls.skuDescription
	   ,osl.stockLocationName as Origin_SL
	   ,sls.bufferSize
	   ,sls.saftyStock
	   ,sls.minimumBufferSize
	   ,sls.inventoryAtSite
	   ,sls.inventoryAtTransit
	   ,sls.bufferSize+sls.saftyStock as Total_req
	   ,sls.inventoryAtSite as Total_available
	   ,sls.custom_txt5 as Brand_Description
	   ,sls.custom_txt6 as Brand_code
	   ,sls.custom_txt1 as Class_code
	   ,spi1.skuItemName as Class_Description
	   ,sls.custom_txt2 as Category_code
	   ,spi2.skuItemName as Category_Description
	   ,spi3.skuItemName as Group_Description
	   ,sls.custom_txt10 as SLM_Type
	   ,spi4.skuItemName as Status
	   ,spi6.skuItemName as Ranging_flag
	   
	   , case when spi6.skuItemName='N' and sls.saftyStock>0 and sls.minimumBufferSize=0 then (case when ((sls.inventoryAtSite)-(sls.saftyStock))<0 then 0 else (sls.inventoryAtSite)-(sls.saftyStock) end )
 	    when spi6.skuItemName='N' and sls.saftyStock=0 and sls.minimumBufferSize>0 then (case when ((sls.inventoryAtSite))<0 then 0 else (sls.inventoryAtSite) end )
		when spi6.skuItemName='N' and sls.saftyStock=0 and sls.minimumBufferSize=0 then (case when ((sls.inventoryAtSite))<0 then 0 else (sls.inventoryAtSite) end )
		when spi6.skuItemName='N' and sls.saftyStock>0 and sls.minimumBufferSize>0 then (case when ((sls.inventoryAtSite))<0 then 0 else (sls.inventoryAtSite)-(sls.saftyStock) end )
		when spi6.skuItemName='Y' and sls.bufferSize=0 and sls.saftyStock>0 and sls.minimumBufferSize=0 then (case when ((sls.inventoryAtSite)-(sls.saftyStock))<0 then 0 else (sls.inventoryAtSite)-(sls.saftyStock) end )
		when spi6.skuItemName='Y' and sls.bufferSize=0 and sls.saftyStock=0 and sls.minimumBufferSize>0 then (case when ((sls.inventoryAtSite))<0 then 0 else (sls.inventoryAtSite) end )
		when spi6.skuItemName='Y' and sls.bufferSize=0 and sls.saftyStock=0 and sls.minimumBufferSize=0 then (case when ((sls.inventoryAtSite))<0 then 0 else (sls.inventoryAtSite) end )
		when spi6.skuItemName='Y' and sls.bufferSize=0 and sls.saftyStock>0 and sls.minimumBufferSize>0 then (case when ((sls.inventoryAtSite))<0 then 0 else (sls.inventoryAtSite) - (sls.saftyStock+sls.bufferSize)  end )
		when spi6.skuItemName='Y' and sls.bufferSize>0 and sls.saftyStock>0 and sls.minimumBufferSize=0 then (case when ((sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize))<0 then 0 else (sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize) end )
		when spi6.skuItemName='Y' and sls.bufferSize>0 and sls.saftyStock=0 and sls.minimumBufferSize>0 then (case when ((sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize))<0 then 0 else (sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize) end )
		when spi6.skuItemName='Y' and sls.bufferSize>0 and sls.saftyStock=0 and sls.minimumBufferSize=0 then (case when ((sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize))<0 then 0 else (sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize) end )
		when spi6.skuItemName='Y' and sls.bufferSize>0 and sls.saftyStock>0 and sls.minimumBufferSize>0 then (case when ((sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize))<0 then 0 else (sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize) end )
		end   as Excess
from Symphony_StockLocationSkus sls
join Symphony_StockLocations sl on sl.stockLocationID=sls.stockLocationID
join Symphony_StockLocations osl on osl.stockLocationID=sls.originStockLocation
join Symphony_SKUs s on s.skuID=sls.skuID
left join Symphony_SKUsPropertyItems spi1 on spi1.skuItemID=sls.skuPropertyID1
left join Symphony_SKUsPropertyItems spi2 on spi2.skuItemID=sls.skuPropertyID2
left join Symphony_SKUsPropertyItems spi3 on spi3.skuItemID=sls.skuPropertyID3
left join Symphony_SKUsPropertyItems spi4 on spi4.skuItemID=sls.skuPropertyID4
left join Symphony_SKUsPropertyItems spi6 on spi6.skuItemID=sls.skuPropertyID6
left join Symphony_StockLocationPropertyItems slpi on slpi.slItemID=sl.slPropertyID5
where sl.stockLocationType=3 and inventoryAtSite>0)#a 
--and sls.custom_txt1 in ('0490') --sls.locationSkuName in ('169313','195629')



SELECT [stockLocationName]
      ,[stockLocationDescription]
      ,[skuName]
      ,[skuDescription]
      ,[Origin_SL]
      ,[bufferSize]
      ,[saftyStock]
      ,[minimumBufferSize]
      ,[inventoryAtSite]
      ,[inventoryAtTransit]
      ,[Total_req]
      ,[Total_available]
      ,[Brand_Description]
      ,[Brand_code]
      ,[Class_code]
      ,[Class_Description]
      ,[Category_code]
      ,[Category_Description]
	  ,[Group_Description]
      ,[SLM_Type]
      ,[Status]
      ,[Ranging_flag]
	  
      ,case when class_description like '%inch%tablet%' and brand_description like '%APPLE%' and
	   Ranging_flag='N' /*and saftyStock>0 and minimumBufferSize=0*/ then (case when ((inventoryAtSite))<0 then 0 else (inventoryAtSite) end )

	   else case when class_description like '%inch%tablet%' and brand_description like '%APPLE%' and
	   Ranging_flag='Y' and buffersize=0 /*and saftyStock>0 and minimumBufferSize=0*/ then (case when ((inventoryAtSite)-(saftyStock+bufferSize))<0 then 0 else (inventoryAtSite)-(saftyStock+bufferSize) end )
	   
	   else case when category_description like '%TV%LCD%'  and
	   Ranging_flag='N' /*and saftyStock>0 and minimumBufferSize=0*/ then (case when ((inventoryAtSite)-1)<0 then 0 else (inventoryAtSite)-1 end )

	   else case when category_description like '%TV%LCD%'  and
	   Ranging_flag='Y' and buffersize=0 /*and saftyStock>0 and minimumBufferSize=0*/ then (case when ((inventoryAtSite)-(saftyStock+bufferSize))<0 then 0 else (inventoryAtSite)-(saftyStock+bufferSize) end )


	   else case when group_description like '%LARGE%APPLIANCE%'  and
	   Ranging_flag='N' /*and saftyStock>0 and minimumBufferSize=0*/ then (case when ((inventoryAtSite)-1)<0 then 0 else (inventoryAtSite)-1 end )


	   else case when group_description like '%LARGE%APPLIANCE%'  and
	   Ranging_flag='Y' and buffersize=0 /*and saftyStock>0 and minimumBufferSize=0*/ then (case when ((inventoryAtSite)-(saftyStock+bufferSize))<0 then 0 else (inventoryAtSite)-(saftyStock+bufferSize) end )

	   else Excess end end end end end end Excess_Stock_Qty 
  
  FROM [SymphonyInfiniti].[dbo].[client_temp_slmstk]

  --where class_description like '%inch%tablet%' and brand_description like '%APPLE%'

  end


GO
/****** Object:  StoredProcedure [dbo].[Client_SP_Hubnspoke]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Client_SP_Hubnspoke]
AS
BEGIN

drop table hubnspokesku

CREATE TABLE hubnspokesku
(
SKU nvarchar(100),
)

BULK INSERT hubnspokesku
FROM 'D:\symphonydata\CustomQuery\HubnSpoke\HubandSpokeSKU.csv'
WITH
(
FIRSTROW = 2, --ignores first row (header row)
FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n'
)


update sls set skuPropertyID5=810
from Symphony_StockLocationSkus sls
left join Symphony_SKUs s on s.skuID=sls.skuID
--left join [SymphonyInfiniti].[dbo].[hubnspokesku]hnb on hnb.sku=s.skuName
where s.skuName  in (select sku from [SymphonyInfiniti].[dbo].[hubnspokesku])


update sls set skuPropertyID5=null
from Symphony_StockLocationSkus sls
left join Symphony_SKUs s on s.skuID=sls.skuID
--left join [SymphonyInfiniti].[dbo].[hubnspokesku]hnb on hnb.sku=s.skuName
where s.skuName not  in (select sku from [SymphonyInfiniti].[dbo].[hubnspokesku])


end

GO
/****** Object:  StoredProcedure [dbo].[Client_SP_OneFL_2AG]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Client_SP_OneFL_2AG]
AS
BEGIN


  
  drop table client_temp_flexing_family

  select * into client_temp_flexing_family from (SELECT   sf.name as FL
                  
    FROM [SymphonyInfiniti].[dbo].[Symphony_RetailFamilyAgConnection] rfac
  join Symphony_SkuFamilies sf on sf.id=rfac.familyID
  join Symphony_AssortmentGroups sa on sa.id=rfac.assortmentGroupID 
   group by sf.name having count(sf.name)>1)#a


   select ff.FL,ag.Name from
   client_temp_flexing_family ff
   join Symphony_SkuFamilies sf on sf.name=ff.FL
   join Symphony_RetailFamilyAgConnection rfac on rfac.familyID=sf.id
   join Symphony_AssortmentGroups ag on ag.id=rfac.assortmentGroupID
   order by ff.FL,ag.Name

   end
GO
/****** Object:  StoredProcedure [dbo].[Client_SP_Origin_Missing_Report]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Client_SP_Origin_Missing_Report]
AS
BEGIN


select distinct sl2.stockLocationName [Origin SL],sls2.locationskuname[SKU Name] ,sls2.skuDescription as sku_description,
spi1.skuItemName as Class_Description
	  
	   ,spi2.skuItemName as Category_Description
	   ,spi3.skuItemName as Group_Description
	   ,sls2.custom_txt10 as SLM_Type
	   ,spi4.skuItemName as Status
	   ,spi6.skuItemName as Ranging_flag
	   
	   ,count(sl2.stockLocationName) as Stores_Count
	   ,sum(sls2.buffersize) as Sum_of_Buffer
      ,sum(case when sls2.buffersize>0 then 1 else 0 end)  as Stores_Count_with_Buffer
	  ,sum(case when sls2.buffersize=0 then 1 else 0 end)  as Stors_Count_without_Buffer
from Symphony_StockLocationSkus sls2 join symphony_stocklocations sl1 on sl1.stocklocationid=sls2.stockLocationID 
join symphony_stocklocations sl2 on sl2.stocklocationid=sls2.originStockLocation 
left join Symphony_SKUsPropertyItems spi1 on spi1.skuItemID=sls2.skuPropertyID1
left join Symphony_SKUsPropertyItems spi2 on spi2.skuItemID=sls2.skuPropertyID2
left join Symphony_SKUsPropertyItems spi3 on spi3.skuItemID=sls2.skuPropertyID3 
left join Symphony_SKUsPropertyItems spi6 on spi6.skuItemID=sls2.skuPropertyID6
left join Symphony_SKUsPropertyItems spi4 on spi4.skuItemID=sls2.skuPropertyID4
where sl2.stockLocationName like 'D%' 
and sls2.isDeleted=0
and not exists (select distinct sls.skuID ,sls.stockLocationID 
from Symphony_stocklocationskus sls join symphony_stocklocations sl on sl.stocklocationid=sls.stockLocationID 
where sls2.skuID=sls.skuID and  sls.stockLocationID=sls2.originStockLocation and sls.isDeleted=0 
 )
group by 
sl2.stockLocationName,sls2.locationskuname,sls2.skuDescription ,spi1.skuItemName,spi2.skuItemName,spi3.skuItemName,sls2.custom_txt10 ,spi4.skuItemName,spi6.skuItemName



  end


GO
/****** Object:  StoredProcedure [dbo].[Client_SP_Purchasing_MOD_V6_New_1]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Client_SP_Purchasing_MOD_V6_New_1]
AS
BEGIN


drop table c_temp_storeneeded
drop table c_temp_neededSum

select
		 sls.locationSkuName sku		 
		,sls.originStockLocation
		,(slo.stocklocationname) Origin
		,sl.stockLocationName Store
		,(sls.buffersize+sls.saftystock-sls.inventoryatsite-sls.inventoryattransit-sls.replenishmentQuantity) Needed@store
	into c_temp_storeneeded	
		
from Symphony_StockLocationSkus sls

	 join Symphony_StockLocations sl on sls.stockLocationID=sl.stockLocationID
	 join Symphony_StockLocations slo on sls.originStockLocation=slo.stockLocationID	
where sls.stockLocationID = sl.stockLocationID 
		and sls.bufferSize>0
		and sl.stockLocationName not like 'D%'
		and sls.autoReplenishment = 1 
		and (sls.buffersize+sls.saftystock-sls.inventoryatsite-sls.inventoryattransit-sls.replenishmentQuantity)>0
		
select  sn.Origin [origin]
		,sn.originStockLocation OriginSL
		,sn.sku [sku]
		,isnull(SUM(sn.needed@store),0) [NeedStore]
into  c_temp_neededSum
from c_temp_storeneeded	 sn
group by sn.Origin,sn.sku,sn.originStockLocation

drop table DC_purchase_Temp1

select * into DC_purchase_Temp1 from (

select 
	  SLL.stockLocationName [Stock Location] 
	 ,sls1.locationSkuName [SKU] 
	 ,case	when cast(bufferSize+saftyStock+isnull(stn.NeedStore,0)-inventoryAtSite-inventoryAtTransit as    int)>minimumReplenishment  then cast(ceiling((bufferSize+saftyStock+isnull(stn.NeedStore,0)-inventoryAtSite-     inventoryAtTransit)/multiplications)*multiplications as int)
  else cast(minimumReplenishment as int)  end [Quantity To Purchase] 

	 /* ,cast(bufferSize+saftyStock-inventoryAtSite-inventoryAtTransit as int) calQty
	  ,isnull(stn.NeedStore,0) Storeneeded
	  ,isnull(cast(bufferSize+saftyStock+isnull(stn.NeedStore,0)-inventoryAtSite-inventoryAtTransit as int),0)  qtywithStore*/

	 ,slo.stockLocationname [Supplier Code] 
	 ,sls1.custom_txt2 [Category Code] 
	 ,sls1.custom_txt6 [Brand Code] 
     ,case	when sls1.transitColor =0 then 'Cyan' 
			when sls1.transitColor =1 then 'Green' 
			when sls1.transitColor =2 then 'Yellow' 
			when sls1.transitColor =3 then 'Red' 
			when sls1.transitColor =4 then 'Black' 
       end [BP Color] 
	
 ,cast(sls1.bpTransit as decimal(10,2)) [Virtual Pipe Penetration]

	 ,cast(bufferSize+saftyStock+isnull(stn.NeedStore,0)-inventoryAtSite-inventoryAtTransit as int) [Inventory Needed]

	,'Stock' [Order Type]
	 

	/* ,cast(bufferSize as int)DCBufferSize
	 ,cast(sls1.saftyStock as int)DCSafetyStock
	 ,cast(inventoryAtSite as int) DCInvAtSIite
	 ,cast(inventoryAtTransit as int) DCInvAtTransit

	,sls1.minimumReplenishment [Min Repl]
	,sls1.multiplications [Lot Size]*/
	
from Symphony_StockLocationSkus sls1
	 join Symphony_StockLocations sll on sls1.stockLocationID=sll.stockLocationID
	 join Symphony_StockLocations slo on sls1.originStockLocation=slo.stockLocationID
	 join Symphony_SKUsPropertyItems skp4 on skp4.skuItemID=sls1.skuPropertyID4	 
	 Left outer join c_temp_neededSum stn on stn.sku=sls1.locationSkuName and stn.OriginSL=sls1.stockLocationID 

where 
		sls1.avoidReplenishment=0 and sls1.bufferSize>0
		and sls1.autoReplenishment=1 and skp4.skuItemName in ('ZA','ZT')
		and sls1.custom_txt4 like 'S' 
		and sll.stockLocationName like 'D%'
		and sls1.bufferSize+sls1.saftyStock+isnull(stn.NeedStore,0)-sls1.inventoryAtSite-sls1.inventoryAtTransit>0
                and slo.stockLocationName not like 'D%'   ---added on 17thDec'19 for DC to DC replenishment process
)#fgv

select * from DC_purchase_Temp1 --order by [Stock Location],[SKU] 



end
GO
/****** Object:  StoredProcedure [dbo].[Client_SP_Purchasing_MOD_V7]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Client_SP_Purchasing_MOD_V7]
AS
BEGIN


drop table Store_Excess

drop table client_temp_slmstk

select * into client_temp_slmstk from (select sl.stockLocationName
       ,sl.stockLocationDescription
       ,s.skuName
	   ,sls.skuDescription
	   ,osl.stockLocationName as Origin_SL
	   ,sls.bufferSize
	   ,sls.saftyStock
	   ,sls.minimumBufferSize
	   ,sls.inventoryAtSite
	   ,sls.inventoryAtTransit
	   ,sls.bufferSize+sls.saftyStock as Total_req
	   ,sls.inventoryAtSite as Total_available
	   ,sls.custom_txt5 as Brand_Description
	   ,sls.custom_txt6 as Brand_code
	   ,sls.custom_txt1 as Class_code
	   ,spi1.skuItemName as Class_Description
	   ,sls.custom_txt2 as Category_code
	   ,spi2.skuItemName as Category_Description
	   ,spi3.skuItemName as Group_Description
	   ,sls.custom_txt10 as SLM_Type
	   ,spi4.skuItemName as Status
	   ,spi6.skuItemName as Ranging_flag
	   
	   , case when spi6.skuItemName='N' and sls.saftyStock>0 and sls.minimumBufferSize=0 then (case when ((sls.inventoryAtSite)-(sls.saftyStock))<0 then 0 else (sls.inventoryAtSite)-(sls.saftyStock) end )
 	    when spi6.skuItemName='N' and sls.saftyStock=0 and sls.minimumBufferSize>0 then (case when ((sls.inventoryAtSite))<0 then 0 else (sls.inventoryAtSite) end )
		when spi6.skuItemName='N' and sls.saftyStock=0 and sls.minimumBufferSize=0 then (case when ((sls.inventoryAtSite))<0 then 0 else (sls.inventoryAtSite) end )
		when spi6.skuItemName='N' and sls.saftyStock>0 and sls.minimumBufferSize>0 then (case when ((sls.inventoryAtSite))<0 then 0 else (sls.inventoryAtSite)-(sls.saftyStock) end )
		when spi6.skuItemName='Y' and sls.bufferSize=0 and sls.saftyStock>0 and sls.minimumBufferSize=0 then (case when ((sls.inventoryAtSite)-(sls.saftyStock))<0 then 0 else (sls.inventoryAtSite)-(sls.saftyStock) end )
		when spi6.skuItemName='Y' and sls.bufferSize=0 and sls.saftyStock=0 and sls.minimumBufferSize>0 then (case when ((sls.inventoryAtSite))<0 then 0 else (sls.inventoryAtSite) end )
		when spi6.skuItemName='Y' and sls.bufferSize=0 and sls.saftyStock=0 and sls.minimumBufferSize=0 then (case when ((sls.inventoryAtSite))<0 then 0 else (sls.inventoryAtSite) end )
		when spi6.skuItemName='Y' and sls.bufferSize=0 and sls.saftyStock>0 and sls.minimumBufferSize>0 then (case when ((sls.inventoryAtSite))<0 then 0 else (sls.inventoryAtSite) - (sls.saftyStock+sls.bufferSize)  end )
		when spi6.skuItemName='Y' and sls.bufferSize>0 and sls.saftyStock>0 and sls.minimumBufferSize=0 then (case when ((sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize))<0 then 0 else (sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize) end )
		when spi6.skuItemName='Y' and sls.bufferSize>0 and sls.saftyStock=0 and sls.minimumBufferSize>0 then (case when ((sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize))<0 then 0 else (sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize) end )
		when spi6.skuItemName='Y' and sls.bufferSize>0 and sls.saftyStock=0 and sls.minimumBufferSize=0 then (case when ((sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize))<0 then 0 else (sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize) end )
		when spi6.skuItemName='Y' and sls.bufferSize>0 and sls.saftyStock>0 and sls.minimumBufferSize>0 then (case when ((sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize))<0 then 0 else (sls.inventoryAtSite)-(sls.saftyStock+sls.bufferSize) end )
		end   as Excess
from Symphony_StockLocationSkus sls
join Symphony_StockLocations sl on sl.stockLocationID=sls.stockLocationID
join Symphony_StockLocations osl on osl.stockLocationID=sls.originStockLocation
join Symphony_SKUs s on s.skuID=sls.skuID
left join Symphony_SKUsPropertyItems spi1 on spi1.skuItemID=sls.skuPropertyID1
left join Symphony_SKUsPropertyItems spi2 on spi2.skuItemID=sls.skuPropertyID2
left join Symphony_SKUsPropertyItems spi3 on spi3.skuItemID=sls.skuPropertyID3
left join Symphony_SKUsPropertyItems spi4 on spi4.skuItemID=sls.skuPropertyID4
left join Symphony_SKUsPropertyItems spi6 on spi6.skuItemID=sls.skuPropertyID6
left join Symphony_StockLocationPropertyItems slpi on slpi.slItemID=sl.slPropertyID5
where sl.stockLocationType=3 and inventoryAtSite>0)#a 
--and sls.custom_txt1 in ('0490') --sls.locationSkuName in ('169313','195629')


select [Origin_SL],[skuName],sum(Excess_Stock_Qty) as Excess into Store_Excess from (
SELECT [stockLocationName]
      ,[stockLocationDescription]
      ,[skuName]
      ,[skuDescription]
      ,[Origin_SL]
      ,[bufferSize]
      ,[saftyStock]
      ,[minimumBufferSize]
      ,[inventoryAtSite]
      ,[inventoryAtTransit]
      ,[Total_req]
      ,[Total_available]
      ,[Brand_Description]
      ,[Brand_code]
      ,[Class_code]
      ,[Class_Description]
      ,[Category_code]
      ,[Category_Description]
	  ,[Group_Description]
      ,[SLM_Type]
      ,[Status]
      ,[Ranging_flag]
	  
      ,case when class_description like '%inch%tablet%' and brand_description like '%APPLE%' and
	   Ranging_flag='N' /*and saftyStock>0 and minimumBufferSize=0*/ then (case when ((inventoryAtSite))<0 then 0 else (inventoryAtSite) end )

	   else case when class_description like '%inch%tablet%' and brand_description like '%APPLE%' and
	   Ranging_flag='Y' and buffersize=0 /*and saftyStock>0 and minimumBufferSize=0*/ then (case when ((inventoryAtSite)-(saftyStock+bufferSize))<0 then 0 else (inventoryAtSite)-(saftyStock+bufferSize) end )
	   
	   else case when category_description like '%TV%LCD%'  and
	   Ranging_flag='N' /*and saftyStock>0 and minimumBufferSize=0*/ then (case when ((inventoryAtSite)-1)<0 then 0 else (inventoryAtSite)-1 end )

	   else case when category_description like '%TV%LCD%'  and
	   Ranging_flag='Y' and buffersize=0 /*and saftyStock>0 and minimumBufferSize=0*/ then (case when ((inventoryAtSite)-(saftyStock+bufferSize))<0 then 0 else (inventoryAtSite)-(saftyStock+bufferSize) end )


	   else case when group_description like '%LARGE%APPLIANCE%'  and
	   Ranging_flag='N' /*and saftyStock>0 and minimumBufferSize=0*/ then (case when ((inventoryAtSite)-1)<0 then 0 else (inventoryAtSite)-1 end )


	   else case when group_description like '%LARGE%APPLIANCE%'  and
	   Ranging_flag='Y' and buffersize=0 /*and saftyStock>0 and minimumBufferSize=0*/ then (case when ((inventoryAtSite)-(saftyStock+bufferSize))<0 then 0 else (inventoryAtSite)-(saftyStock+bufferSize) end )

	   else Excess end end end end end end Excess_Stock_Qty
  
  FROM [SymphonyInfiniti].[dbo].[client_temp_slmstk]
  

  --where class_description like '%inch%tablet%' and brand_description like '%APPLE%'
  ) #ex1

  group by [Origin_SL],[skuName]

  --select * from Store_Excess where Excess>0
  





 select    sls.locationSkuName sku      ,sls.originStockLocation   ,(slo.stocklocationname) Origin   
 ,sl.stockLocationName Store   
 ,(sls.buffersize+sls.saftystock-sls.inventoryatsite-sls.inventoryattransit-sls.replenishmentQuantity) Needed@store  
 into #storeneeded     
 from Symphony_StockLocationSkus sls    
 join Symphony_StockLocations sl on sls.stockLocationID=sl.stockLocationID   
 join Symphony_StockLocations slo on sls.originStockLocation=slo.stockLocationID  
 where sls.stockLocationID = sl.stockLocationID    and sls.bufferSize>0   
 --and sl.stockLocationName  like 'D%'  
 and slo.stockLocationName like 'D%' -- to combine POS and Secondary DC
 and sls.autoReplenishment = 1 and sls.skuPropertyID6=423   
 and (sls.buffersize+sls.saftystock-sls.inventoryatsite-sls.inventoryattransit-sls.replenishmentQuantity)>0 
    
 select  sn.Origin [origin]   ,sn.originStockLocation OriginSL   ,sn.sku [sku]   ,isnull(SUM(sn.needed@store),0) [NeedStore] 
 into #neededSum 
 from #storeneeded sn group by sn.Origin,sn.sku,sn.originStockLocation  

 select     SLL.stockLocationName [Stock Location]    ,sls1.locationSkuName [SKU]    
 ,case when cast(bufferSize+saftyStock+isnull(stn.NeedStore,0)-inventoryAtSite-inventoryAtTransit-isnull(exx.Excess,0) as    int)>minimumReplenishment 
  then cast(ceiling((bufferSize+saftyStock+isnull(stn.NeedStore,0)-inventoryAtSite-     inventoryAtTransit-isnull(exx.Excess,0))/multiplications)*multiplications as int)   
  else cast(minimumReplenishment as int)  end [Quantity To Purchase]     
  /* ,cast(bufferSize+saftyStock-inventoryAtSite-inventoryAtTransit as int) calQty    ,isnull(stn.NeedStore,0) Storeneeded    ,isnull(cast(bufferSize+saftyStock+isnull(stn.NeedStore,0)-inventoryAtSite-inventoryAtTransit as int),0)  qtywithStore*/    
  ,slo.stockLocationname [Supplier Code]    ,sls1.custom_txt2 [Category Code]    ,sls1.custom_txt6 [Brand Code]      
   ,case when sls1.transitColor =0 then 'Cyan'     when sls1.transitColor =1 then 'Green'     
   when sls1.transitColor =2 then 'Yellow'     when sls1.transitColor =3 then 'Red'    
    when sls1.transitColor =4 then 'Black'         end [BP Color]     
	,cast(sls1.bpTransit as decimal(10,2)) [Virtual Pipe Penetration]    
	,cast(bufferSize+saftyStock+isnull(stn.NeedStore,0)-inventoryAtSite-inventoryAtTransit-isnull(exx.Excess,0) as int) [Inventory Needed]   
	,'Stock' [Order Type]      
	/* ,cast(bufferSize as int)DCBufferSize   ,cast(sls1.saftyStock as int)DCSafetyStock   ,cast(inventoryAtSite as int) DCInvAtSIite   ,cast(inventoryAtTransit as int) DCInvAtTransit   ,sls1.minimumReplenishment [Min Repl]  ,sls1.multiplications [Lot Size]*/   
	from Symphony_StockLocationSkus sls1   
	join Symphony_StockLocations sll on sls1.stockLocationID=sll.stockLocationID   
	join Symphony_StockLocations slo on sls1.originStockLocation=slo.stockLocationID   
	join Symphony_SKUsPropertyItems skp4 on skp4.skuItemID=sls1.skuPropertyID4     
	Left outer join #neededSum stn on stn.sku=sls1.locationSkuName and stn.OriginSL=sls1.stockLocationID  
	left join (select * from store_excess where Excess>0) exx on exx.Origin_SL=sll.stockLocationName and exx.skuName=sls1.locationSkuName
	where    sls1.avoidReplenishment=0 and sls1.bufferSize>0   and sls1.autoReplenishment=1 and skp4.skuItemName in ('ZA','ZT')   
	and sls1.custom_txt4 like 'S'    and sll.stockLocationName like 'D%'   and sls1.bufferSize+sls1.saftyStock+isnull(stn.NeedStore,0)-sls1.inventoryAtSite-sls1.inventoryAtTransit>0                 
	and slo.stockLocationName not like 'D%'   ---added on 17thDec'19 for DC to DC replenishment process 
	order by sll.stockLocationname, sls1.locationSkuName  

	drop table #storeneeded 
	drop table #neededSum

  end


GO
/****** Object:  StoredProcedure [dbo].[Client_SP_WH_Buffer]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Client_SP_WH_Buffer]
AS
BEGIN


drop table Client_temp_WH_Buffer

select * into Client_temp_WH_Buffer 
from (
SELECT [originID]
      ,[destinationID]
	  ,osl.stockLocationName as Origin
	  ,sl.stockLocationName
      ,rar.[familyID]
	  ,sf.name as Family
	  ,slso.skuID
	  ,s.skuName
	  ,m.skuDescription as SKU_Description
	  ,ag.name as AG
	  ,ab.[Average Sales] as Average_sales
	  ,slso.bufferSize
      ,[requestStatus]
      ,rar.[sentToReplenishment]
      ,[bySystem]
      ,[totalNPI]
      ,rar.[groupID]
      ,[optionalRequest]
      ,[allocationRecommendationType]
      ,[userSelection]
  FROM [SymphonyInfiniti].[dbo].[Symphony_RetailAllocationRequest] rar
  join Symphony_SkuFamilies sf on sf.id=rar.familyID
    join Symphony_StockLocations sl on sl.stockLocationID=rar.destinationID
  join Symphony_StockLocations osl on osl.stockLocationID=rar.originID
  join Symphony_MasterSkus m on m.familyID=rar.familyID
  join Symphony_SKUs s on s.skuID=m.skuID
  left join Symphony_StockLocationSkus slso on slso.stockLocationID=rar.originID and slso.skuID=s.skuID
  left join Symphony_RetailFamilyAgConnection rfac on rfac.familyID=m.familyID
  left join Symphony_AssortmentGroups ag on ag.id=rfac.assortmentGroupID
  
  left join (select sl.stocklocationname [Stock location] 
       ,s.stockLocationName as DC	  
       ,sl.stockLocationDescription 	  
	   ,dg.name [Display Group] 	  
	   ,ag.name [Assortment Group] 	 
       ,lag.varietyTarget [Current range target]  	   
	   ,AGS.validFamilyCount [Current # of valid families] 	   
 ,(case lag.varietyTarget  when '0' then '0' else convert(numeric(18,0),100*(1-convert(numeric(18,2),convert(numeric(18,2),
 AGS.validFamilyCount)/convert(numeric(18,2),lag.varietyTarget)))) 	    end) [Variety Penetration (Percentage)] 	     	     	    
 ,cast( (select avg(sls.custom_num3) 			
from Symphony_StockLocationSkus sls 			
join Symphony_MasterSkus Ms on MS.skuID=sls.skuID  			
JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG on MS.familyID=FAG.familyID AND FAG.assortmentGroupID = LAG.assortmentGroupID 			
join Symphony_LocationAssortmentGroups LAG2 on LAG.assortmentGroupID=LAG2.assortmentGroupID and LAG2.stockLocationID=LAG.stockLocationID 			
where LAG2.assortmentGroupID=FAG.assortmentGroupID 	AND sls.stockLocationID=LAG2.stockLocationID AND sls.custom_num3>0 			
group by LAG2.assortmentGroupID,LAG2.stockLocationID 		) as numeric(18,2))	[Average Sales]	,
 		
( select count(1) 			
from Symphony_StockLocationSkus sls 			
join Symphony_MasterSkus Ms on MS.skuID=sls.skuID  			
JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG on MS.familyID=FAG.familyID AND FAG.assortmentGroupID = LAG.assortmentGroupID 			
join Symphony_LocationAssortmentGroups LAG2 on LAG.assortmentGroupID=LAG2.assortmentGroupID and LAG2.stockLocationID=LAG.stockLocationID 			
where LAG2.assortmentGroupID=FAG.assortmentGroupID 		AND sls.stockLocationID=LAG2.stockLocationID 	AND sls.custom_num3>0 			
group by LAG2.assortmentGroupID,LAG2.stockLocationID )	[Number of SKUs with positive Sales]	     	 
 
 from Symphony_LocationAssortmentGroups lag  	  
 
 join Symphony_AssortmentGroupSummaryData AGS on AGS.stockLocationID=lag.stockLocationID and AGS.assortmentGroupID=lag.assortmentGroupID 	  
 join symphony_stocklocations sl on sl.stocklocationid=lag.stocklocationid 
 left join Symphony_StockLocations s on s.stockLocationID=sl.defaultOriginID	 
 join Symphony_AssortmentGroups ag on ag.id=lag.assortmentGroupID 	  
 join Symphony_RetailAgDgConnection agdg on agdg.assortmentGroupID=lag.assortmentGroupID 	 
 join Symphony_DisplayGroups dg on dg.id=agdg.displayGroupID 	 
where sl.isDeleted=0 )ab on ab.[Stock location]=sl.stockLocationName and ab.[Assortment Group]=ag.name
--left join Symphony_StockLocationSkus osls on osls.stockLocationID=sls.originStockLocation and osls.skuID=sls.skuID
--where osl.stockLocationName='D001' and sls.skuPropertyID6=422
--group by sls.locationSkuName ,osl.stockLocationName) aab on aab.sku=sls.locationSkuName and aab.DC=sl.stockLocationName

  where userSelection=1)#sxb


  select skuName,
       SKU_Description,
         Origin as DC,
		 ag as AG_Name,
		 buffersize as Current_DC_Buffer,
		 count(stocklocationname) as [No of Stores Ranged],
		 sum(Average_sales) as [Sum of Average sales/DC buffer]

   from Client_temp_WH_Buffer
   group by skuname,SKU_Description, origin,ag,bufferSize
   order  by skuName,Origin 
   end
GO
/****** Object:  StoredProcedure [dbo].[CompleteDataImport]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Reuven Jackson
-- Create date: December 1, 2015
-- Description:
--		Inserts all data as is from input table to table
-- =============================================
CREATE PROCEDURE [dbo].[CompleteDataImport] 
	-- Add the parameters for the stored procedure here
	@tableName nvarchar(128),
	@inputTableName nvarchar(128)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @cmd nvarchar(max)
		DECLARE 
		 @count int
		,@index int
		,@columns dbo.StringList
		,@columnNames nvarchar(max)
		
	INSERT INTO @columns
		SELECT [name] FROM sys.columns
		WHERE [object_id] = OBJECT_ID(@inputTableName)
		
	SELECT @columnNames = dbo.StringJoin(',', @columns)

	EXEC @cmd = dbo.StringFormat N'INSERT INTO %0 (%1) SELECT %1 FROM %2', @tableName, @columnNames, @inputTableName
	EXEC (@cmd)
				
END


GO
/****** Object:  StoredProcedure [dbo].[CreateAfterChangeTriggers]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CreateAfterChangeTriggers]
	@tableName sysname = NULL
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--Get trigger/table name pairs
	DECLARE @PARAMETERS AS TABLE([ID] [int] IDENTITY (0,1),[tableName] [nvarchar](100), [triggerName] [nvarchar](150))
	
	INSERT INTO @PARAMETERS
		SELECT [tableName], [triggerName] 
		FROM [dbo].[Symphony_DataChanged]
		WHERE [type] = 0 
		AND [tableName] LIKE ISNULL(@tableName, '%')
		
	DECLARE
		 @COUNT int
		,@INDEX int
		,@TABLE_NAME NVARCHAR(100)
		,@TRIGGER_NAME NVARCHAR(150)
		
	SELECT @COUNT = COUNT(1), @INDEX = 0 FROM @PARAMETERS;
	SELECT @COUNT
	WHILE @INDEX < @COUNT
	BEGIN
	
		SELECT @TABLE_NAME = [tableName], @TRIGGER_NAME = [triggerName] 
		FROM @PARAMETERS
		WHERE [ID] = @INDEX
		
		EXECUTE('IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N''[dbo].[' + @TRIGGER_NAME + ']''))
						DROP TRIGGER [dbo].[' + @TRIGGER_NAME + ']'
				) 

					
		EXECUTE('CREATE TRIGGER [dbo].[' + @TRIGGER_NAME + '] ON [dbo].[' + @TABLE_NAME +']
					   AFTER INSERT,DELETE,UPDATE
					AS
					BEGIN
						UPDATE [dbo].[Symphony_DataChanged]
						SET [lastDataChange] = GETDATE()
						WHERE [tableName] = ''' + @TABLE_NAME + ''';
					END'
				)
												
		SET @INDEX = @INDEX + 1;
		
	END
	
END

GO
/****** Object:  StoredProcedure [dbo].[CreateAfterInsertDeleteTriggers]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CreateAfterInsertDeleteTriggers]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Get trigger/table name pairs
	DECLARE @PARAMETERS AS TABLE([ID] [int] IDENTITY (0,1),[tableName] [nvarchar](100), [triggerName] [nvarchar](150))
	
	INSERT INTO @PARAMETERS
		SELECT [tableName], [triggerName] 
		FROM [dbo].[Symphony_DataChanged]
		WHERE [type] = 1;
		
	DECLARE
		 @COUNT int
		,@INDEX int
		,@TABLE_NAME NVARCHAR(100)
		,@TRIGGER_NAME NVARCHAR(150)
		
	SELECT @COUNT = COUNT(1), @INDEX = 0 FROM @PARAMETERS;
	
	WHILE @INDEX < @COUNT
	BEGIN
	
		SELECT @TABLE_NAME = [tableName], @TRIGGER_NAME = [triggerName] 
		FROM @PARAMETERS
		WHERE [ID] = @INDEX
		
		EXECUTE('IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N''[dbo].[' + @TRIGGER_NAME + ']''))
					DROP TRIGGER [dbo].[' + @TRIGGER_NAME + ']'
				)
					
		EXECUTE('CREATE TRIGGER [dbo].[' + @TRIGGER_NAME + '] ON [dbo].[' + @TABLE_NAME +']
					   AFTER INSERT,DELETE
					AS
					BEGIN
						UPDATE [dbo].[Symphony_DataChanged]
						SET [lastDataChange] = GETDATE()
						WHERE [tableName] = ''' + @TABLE_NAME + ''';
					END' 
				)
										
		SET @INDEX = @INDEX + 1;
		
	END
END

GO
/****** Object:  StoredProcedure [dbo].[CreateCustomChangeTriggers]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CreateCustomChangeTriggers]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	EXECUTE (
		'IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N''[dbo].[AfterUpdate_StockLocationSkus]''))
			DROP TRIGGER [dbo].[AfterUpdate_StockLocationSkus]'
	)
					
	EXECUTE (
		'CREATE TRIGGER [dbo].[AfterUpdate_StockLocationSkus] 
		   ON  [dbo].[Symphony_StockLocationSkus] 
		   AFTER UPDATE
		AS 
		BEGIN
			IF UPDATE([isDeleted])	BEGIN
			
				DECLARE @isChanged bit = 0
				
				SELECT TOP 1
					@isChanged = CONVERT(bit, 1)
				FROM deleted 
				INNER JOIN inserted 
					ON inserted.skuID =deleted.skuID
					AND inserted.stockLocationID = deleted.stockLocationID
					AND inserted.[isDeleted] <> deleted.[isDeleted]
				
				IF @isChanged = 1
					UPDATE [dbo].[Symphony_DataChanged]
					SET [lastDataChange] = GETDATE()
					WHERE [tableName] = ''Symphony_StockLocationSkus''
					OR [tableName] = ''Symphony_SKUs'';
				
			END
			ELSE IF UPDATE([originStockLocation])
			BEGIN
				UPDATE [dbo].[Symphony_DataChanged]
				SET [lastDataChange] = GETDATE()
				WHERE [tableName] = ''Symphony_StockLocationSkus'' AND [type] = 2;
			END
		END'
	)

	EXECUTE (
		'IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N''[dbo].[AfterUpdate_MTOSkus]''))
			DROP TRIGGER [dbo].[AfterUpdate_MTOSkus]'
	)
					
	EXECUTE (
		'CREATE TRIGGER [dbo].[AfterUpdate_MTOSkus] 
		   ON  [dbo].[Symphony_MTOSkus] 
		   AFTER UPDATE
		AS 
		BEGIN
			IF UPDATE([isDeleted])
			BEGIN
				UPDATE [dbo].[Symphony_DataChanged]
				SET [lastDataChange] = GETDATE()
				WHERE [tableName] = ''Symphony_MTOSkus''
				OR [tableName] = ''Symphony_MTOSkus'';
			END
		END'
	)

END

GO
/****** Object:  StoredProcedure [dbo].[CreateInputQuarantineTable]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CreateInputQuarantineTable]
	-- Add the parameters for the stored procedure here
	@inputTableName sysname
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
    DECLARE @quarantineTableName sysname;
	SELECT @quarantineTableName = OBJECT_NAME(OBJECT_ID(@inputTableName)) + N'Quarantine';
	EXEC [dbo].[BeforeCreate] 'TABLE', @quarantineTableName

	EXEC ('SELECT TOP(0) * INTO ' + @quarantineTableName + ' FROM ' + @inputTableName)
	EXEC ('ALTER TABLE ' + @quarantineTableName + ' ADD id bigint IDENTITY')
	EXEC ('ALTER TABLE ' + @quarantineTableName + ' ADD [type] nvarchar(50)')
	EXEC ('ALTER TABLE ' + @quarantineTableName + ' ADD loadingDate datetime')
	EXEC ('ALTER TABLE ' + @quarantineTableName + ' ADD quarantineReason nvarchar(500)')
	EXEC ('ALTER TABLE ' + @quarantineTableName + ' ADD actualLineContent nvarchar(1000)')
	
	EXEC [dbo].[AfterCreate] 'TABLE', @quarantineTableName

END

GO
/****** Object:  StoredProcedure [dbo].[DatabaseGrowth]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 

CREATE PROC [dbo].[DatabaseGrowth] @pDBName sysname = NULL

AS

BEGIN

/*********************************************************************************

Description: Procedure to calulate the file growth %ages for a given database and

show the growth rate so that we can plan ahead for future storage needs.

 

How to use:

--------------

Example 1: To see the file growth of the current database:

EXEC dbo.DatabaseGrowth

 

Example 2: To see the file growth for [Test] database:

EXEC dbo.DatabaseGrowth 'test'

 

--------------------------------------------------------------------------------

Ramzan Ali

********************************************************************************/

SET NOCOUNT ON;

DECLARE @DatabaseName SYSNAME

 

-- Use current database, if a database name is not specified in input parameter

SET @DatabaseName = ISNULL(@pDBName, DB_NAME())

SELECT  backup_start_date AS StartTime

        ,@DatabaseName AS DatabaseName

        ,filegroup_name AS FilegroupName

        ,logical_name AS LogicalFilename

        ,physical_name AS PhysicalFilename

        ,CONVERT(NUMERIC(9,2), file_size/1048576) AS FileSizeInMB

        ,Growth AS PercentageGrowth

FROM (

     SELECT b.backup_start_date

           ,a.backup_set_id

           ,a.file_size

           ,a.logical_name

           ,a.[filegroup_name]

           ,a.physical_name

           ,(SELECT CONVERT(numeric(5,2),((a.file_size * 100.00)/i1.file_size)-100)

             FROM msdb.dbo.backupfile i1

             WHERE i1.backup_set_id =

              (

              SELECT MAX(i2.backup_set_id)

              FROM msdb.dbo.backupfile i2 JOIN msdb.dbo.backupset i3

              ON i2.backup_set_id = i3.backup_set_id

              WHERE i2.backup_set_id < a.backup_set_id

              AND i2.file_type='D'

              AND i3.database_name = @DatabaseName

              AND i2.logical_name = a.logical_name

              AND i2.logical_name = i1.logical_name

              AND i3.type = 'D'

              )

              AND i1.file_type = 'D'

) AS Growth

FROM msdb.dbo.backupfile a

JOIN msdb.dbo.backupset b

ON a.backup_set_id = b.backup_set_id

WHERE b.database_name = @DatabaseName

AND a.file_type = 'D'

AND b.type = 'D'

) AS Derived

WHERE   ISNULL(Growth, 0.0) <> 0.0

ORDER BY  StartTime desc

END

 


GO
/****** Object:  StoredProcedure [dbo].[DeleteUserView]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteUserView]
	@viewID int
AS
BEGIN
	SET NOCOUNT ON;

	DELETE [dbo].[Symphony_UserViews]
	WHERE id = @viewID;

	DELETE [dbo].[Symphony_UserViewItems]
	WHERE viewID = @viewID;

	DELETE [dbo].Symphony_UserViewsAssignment
		WHERE viewID = @viewID

END

GO
/****** Object:  StoredProcedure [dbo].[DropDefaultConstraint]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DropDefaultConstraint] 
	-- Add the parameters for the stored procedure here
	@tableName sysname, 
	@columnName sysname
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @constraintName sysname;
	
	SELECT
		@constraintName = DC.name
	FROM sys.default_constraints DC
	INNER JOIN sys.tables T
		ON DC.parent_object_id = T.object_id
	INNER JOIN sys.columns C
		ON C.object_id = T.object_id
		AND DC.parent_column_id = C.column_id
	WHERE T.name = @tableName
		AND C.name = @columnName
		

	IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(@constraintName) AND type = 'D')
	BEGIN
		EXEC ('ALTER TABLE ' + @tableName + ' DROP CONSTRAINT ' + @constraintName)
	END
END

GO
/****** Object:  StoredProcedure [dbo].[DropDefaultConstraints]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DropDefaultConstraints] 
	@tableName sysname
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @cmd nvarchar(max);
	
	SELECT
		@cmd = CASE
			WHEN @cmd IS NULL THEN 'ALTER TABLE ' + @tableName + ' DROP CONSTRAINT ' + DC.name
			ELSE @cmd + CHAR(13) + 'ALTER TABLE ' + @tableName + ' DROP CONSTRAINT ' + DC.name
		END
	FROM sys.default_constraints DC
	INNER JOIN sys.tables T
		ON DC.parent_object_id = T.object_id
	WHERE T.name = REPLACE(REPLACE(@tableName,'[',''),']','');
		
	EXEC (@cmd);
END

GO
/****** Object:  StoredProcedure [dbo].[DropForeignKeyConstraints]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DropForeignKeyConstraints]
	@tableName sysname
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE
		 @charIndex int
		,@cmd nvarchar(max);

	SELECT 
		 @charIndex = CHARINDEX('.', REVERSE(@tableName), 1)
		,@tableName = CASE 
			WHEN @charIndex > 0 THEN  LTRIM(RTRIM(REPLACE(REPLACE(RIGHT(@tableName, @charIndex - 1),'[',''),']','')))
			ELSE LTRIM(RTRIM(REPLACE(REPLACE(@tableName,'[',''),']','')))
			END

	SELECT 
		@cmd = CASE	
			WHEN @cmd IS NULL THEN 'ALTER TABLE ' + @tableName + ' DROP CONSTRAINT ' + FK.name 
			ELSE @cmd + CHAR(13) +  'ALTER TABLE ' + @tableName + ' DROP CONSTRAINT ' + FK.name 
			END
	FROM sys.foreign_keys FK
	INNER JOIN sys.tables TBL
		ON TBL.object_id = FK.parent_object_id
	WHERE TBL.name = @tableName
	
	EXEC (@cmd)
	
END

GO
/****** Object:  StoredProcedure [dbo].[ExportDelimitedData]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ExportDelimitedData]
	-- Add the parameters for the stored procedure here
	 @fileName nvarchar(128)
	,@sourceTableName nvarchar(128)
	,@columns dbo.StringList READONLY
	,@separator nvarchar(20) = ','
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE
		 @bcpCmd varchar(8000)
		,@dbName nvarchar(128) 
	
	SELECT @dbName = DB_NAME();
	EXEC @bcpCmd = dbo.StringFormat N'bcp %0..%1 out %2 -b5000 -c -t %3 -T -S %4', @dbName, @sourceTableName, @fileName, @separator, @@SERVERNAME
	
	DECLARE
		 @prevAdvancedOptions int
		,@prevXpCmdshell int

	EXEC dbo.SetXpCmdShellOption 1, 1, @prevAdvancedOptions, @prevXpCmdshell
	
	EXEC xp_cmdshell @bcpCmd
			
	EXEC dbo.SetXpCmdShellOption @prevAdvancedOptions, @prevXpCmdshell
END


GO
/****** Object:  StoredProcedure [dbo].[ExportDelimitedDataWithHeaders]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ExportDelimitedDataWithHeaders]
	-- Add the parameters for the stored procedure here
	 @fileName nvarchar(260)
	,@sourceTableName nvarchar(128)
	,@headers dbo.StringList READONLY
	,@columns dbo.StringList READONLY
	,@separator nvarchar(20) = ','
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE
			 @cmd nvarchar(max)
			,@params dbo.StringList
			,@headerNames dbo.StringList
			,@columnDefinitions dbo.StringList
			,@inputTableName nvarchar(128)
			,@headersTableName nvarchar(128)
			
		SELECT
			 @inputTableName = 'T' + REPLACE(NEWID(), '-', '')
			,@headersTableName = 'T' + REPLACE(NEWID(), '-', '')

		-- Create table for headers
		DECLARE @columnNames TABLE
		(
			 [colNumber]int IDENTITY(1,1)
			,[colNamePrefix] nvarchar(100)
		)
		
		INSERT INTO @columnNames
			SELECT 'C' FROM @headers 

		INSERT INTO @columnDefinitions 
			SELECT [colNamePrefix] + CONVERT(nvarchar(10), [colNumber]) + ' nvarchar(255)' FROM @columnNames
			
				
		DECLARE @columnDefinitionsString nvarchar(max) 
		SELECT @columnDefinitionsString = dbo.StringJoin(',', @columnDefinitions)
		EXEC @cmd = dbo.StringFormat N'CREATE TABLE %0 (%1)', @headersTableName, @columnDefinitionsString
		EXEC (@cmd)

		--Insert headers into headers table		
		DECLARE @headersString nvarchar(max)
		SELECT @headersString = dbo.StringJoin(''',''',@headers)
		EXEC @cmd = dbo.StringFormat N'INSERT INTO %0 VALUES (''%1'')', @headersTableName, @headersString
		EXEC (@cmd)

	DECLARE
		 @xpCmd varchar(8000)
		,@bcpCmd varchar(8000)
		,@prevAdvancedOptions int
		,@prevXpCmdshell int
		
	DECLARE
		 @pos int
		,@path nvarchar(255)
		,@fileExtension nvarchar(50)
		,@dataFileName nvarchar(255)
		,@headersFileName nvarchar(255)
		
	SELECT 
		 @pos = CHARINDEX('.', REVERSE(@fileName), 1)
		,@fileExtension = RIGHT(@fileName, @pos)
		,@pos = CHARINDEX('\', REVERSE(@fileName), 1)
		,@path = LEFT(@fileName, LEN(@fileName) - @pos + 1)
		,@dataFileName = @path + @inputTableName + @fileExtension
		,@headersFileName = @path + @headersTableName + @fileExtension
		
	EXEC dbo.SetXpCmdShellOption 1, 1, @prevAdvancedOptions, @prevXpCmdshell
	
	DECLARE @dbName nvarchar(128)
	SELECT @dbName = DB_NAME()

		EXEC @bcpCmd = dbo.StringFormat N'bcp %0..%1 out %2 -b5000 -c -t %3 -T -S %4', @dbName, @sourceTableName, @dataFileName, @separator, @@SERVERNAME
		EXEC xp_cmdshell @bcpCmd

		EXEC @bcpCmd = dbo.StringFormat N'bcp %0..%1 out %2 -b5000 -c -t %3 -T -S %4', @dbName, @headersTableName, @headersFileName, @separator, @@SERVERNAME
		EXEC xp_cmdshell @bcpCmd

		EXEC @xpCmd = dbo.StringFormat N'copy /b %0 +%1 %2', @headersFileName, @dataFileName, @fileName
		EXEC xp_cmdshell @xpCmd

		EXEC @xpCmd = dbo.StringFormat N'DEL %0 %1 ', @headersFileName, @dataFileName 
		EXEC xp_cmdshell @xpCmd
				
	EXEC dbo.SetXpCmdShellOption @prevAdvancedOptions, @prevXpCmdshell
	
	-- Create temporary input table	
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@inputTableName) AND type in (N'U'))
	EXEC ('DROP TABLE ' + @inputTableName)

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@headersTableName) AND type in (N'U'))
	EXEC ('DROP TABLE ' + @headersTableName)
END



GO
/****** Object:  StoredProcedure [dbo].[fs_FileExists]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[fs_FileExists] 
	 @fileName nvarchar(260)
	,@fileExists bit = 0 OUTPUT
AS
BEGIN

	DECLARE
		 @cmd varchar(500)
		,@prevAdvancedOptions int
		,@prevXpCmdshell int

	DECLARE @outputTable TABLE
	(
		 [id] int IDENTITY(1,1)
		,[output] nvarchar(260)
	)

	EXEC dbo.SetXpCmdShellOption 1, 1, @prevAdvancedOptions, @prevXpCmdshell
	
	SELECT 
		 @fileExists = 0
		,@cmd = 'IF EXIST ' + @fileName + ' (ECHO 1) ELSE (ECHO 0)'			
	
	INSERT INTO @outputTable
		EXECUTE sys.xp_cmdshell @cmd
	
	SELECT @fileExists = CONVERT(bit, [output]) 
	FROM @outputTable WHERE [id] = 1 
			
	EXEC dbo.SetXpCmdShellOption @prevAdvancedOptions, @prevXpCmdshell
	
END


GO
/****** Object:  StoredProcedure [dbo].[fs_FolderExists]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[fs_FolderExists] 
	 @path nvarchar(260)
	,@folderExists bit = 0 OUTPUT
AS
BEGIN

	DECLARE
		 @cmd varchar(500)
		,@prevAdvancedOptions int
		,@prevXpCmdshell int

	DECLARE @outputTable TABLE
	(
		 [id] int IDENTITY(1,1)
		,[output] nvarchar(512)
	)

	SELECT @folderExists = 0
	IF LEN(@path) > 0 AND SUBSTRING(@path, LEN(@path), 1) <> '\'
		SELECT @path = @path + '\'

	EXEC dbo.SetXpCmdShellOption 1, 1, @prevAdvancedOptions, @prevXpCmdshell
	
	SELECT 
		 @folderExists = 0
		,@cmd = 'IF EXIST ' + @path + ' (ECHO 1) ELSE (ECHO 0)'			
	
	INSERT INTO @outputTable
		EXECUTE sys.xp_cmdshell @cmd
	
	SELECT @folderExists = CONVERT(bit, [output]) 
	FROM @outputTable WHERE [id] = 1 
			
	EXEC dbo.SetXpCmdShellOption @prevAdvancedOptions, @prevXpCmdshell
	
END


GO
/****** Object:  StoredProcedure [dbo].[fs_GetFileName]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[fs_GetFileName] 
(
	-- Add the parameters for the function here
	 @path nvarchar(260)
	,@name nvarchar(260) OUTPUT
)
AS
BEGIN
	DECLARE
		@patIndex int

	SELECT 
		 @path = REVERSE(@path)
		,@patIndex = PATINDEX('%\%', @path)
	
	IF @patIndex = 1
		SELECT @path = SUBSTRING(@path, 2, LEN(@path) - 1), @patIndex = PATINDEX('%\%', @path)

	IF @patIndex = 0 BEGIN
		SELECT @path = REVERSE(@path)
		RAISERROR('%s is a root folder', 16, 1, @path)
	END
		
	SELECT @name = REVERSE(SUBSTRING(@path, 1, @patIndex - 1))
	
END


GO
/****** Object:  StoredProcedure [dbo].[fs_MoveFiles]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[fs_MoveFiles] 
	 @sourceFolder nvarchar(260)
	,@destinationFolder nvarchar(260)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE
		 @cmd varchar(1028)
		,@prevAdvancedOptions int
		,@prevXpCmdshell int

	EXEC dbo.SetXpCmdShellOption 1, 1, @prevAdvancedOptions, @prevXpCmdshell
	BEGIN
	
		IF SUBSTRING(@sourceFolder, LEN(@sourceFolder), 1) <> '\'
			SELECT @sourceFolder = @sourceFolder + '\'
			
		IF SUBSTRING(@destinationFolder, LEN(@destinationFolder), 1) <> '\'
			SELECT @destinationFolder = @destinationFolder + '\'
			
		SELECT @cmd = 'MOVE /Y ' + @sourceFolder + '* ' + @destinationFolder 			
		EXECUTE sys.xp_cmdshell @cmd
		
	END	
	EXEC dbo.SetXpCmdShellOption @prevAdvancedOptions, @prevXpCmdshell
END


GO
/****** Object:  StoredProcedure [dbo].[ImportDelimitedDataFiles]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Reuven Jackson
-- Create date: December 1, 2015
-- Description:
--		Import delimited data files. Import all files whose name
--		begins with fileNamePrefix located in inputFolder.
--			* Make sure the file locations exist
--			* Make sure the inputTable and table exist
--			* Load files into inputTable
--			* Remove leading and trailing spaces on all nvarchar fields
--			* Copy data from input table to table
--			* Remove duplicate rows from table
-- VERSION 2:
-- Author: Maria Grekov
-- Change Date: July 12, 2018
-- Change Description:
--			* Add new parameter @quarantineDuplicates bit default value = 1
--          * make quarantine duplicates optional
-- =============================================
CREATE PROCEDURE [dbo].[ImportDelimitedDataFiles] 
	 @fileNamePrefix nvarchar(260)
	,@inputFolder nvarchar(260)
	,@outputFolder nvarchar(260)
	,@tableName nvarchar(128)
	,@inputTableName nvarchar(128)
	,@keyColumns dbo.StringList READONLY
	,@ignoreFirstLine bit = 0
	,@separator nvarchar(20) = ','
	,@errorFileName nvarchar(260) = ''
	,@quarantineDuplicates bit = 1
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE 
		 @exists bit	
		,@cmd varchar(1028)
		,@prevXpCmdshell int
		,@prevAdvancedOptions int
		
	
	DECLARE @outputTable TABLE
	(
		 [id] int IDENTITY(0,1)
		,[output] nvarchar(255)
	)
	
	DECLARE @fileNames TABLE
	(
		 [id] int IDENTITY(0,1)
		,[fileName] nvarchar(255)
	)

	--Insure that the folder name ends with \
	IF SUBSTRING(@inputFolder, LEN(@inputFolder), 1) <> '\'
		SELECT @inputFolder = @inputFolder + '\'
		
	EXEC dbo.fs_FolderExists @inputFolder, @exists OUTPUT
	IF @exists = 0
		RAISERROR('Could not find the folder %s', 16, 1, @inputFolder)

	IF SUBSTRING(@outputFolder, LEN(@outputFolder), 1) <> '\'
		SELECT @outputFolder = @outputFolder + '\'
		
	EXEC dbo.fs_FolderExists @outputFolder, @exists OUTPUT
	IF @exists = 0
		RAISERROR('Could not find the folder %s', 16, 1, @outputFolder)

	IF (SELECT OBJECT_ID(@tableName)) IS NULL
		RAISERROR('Table %s does not exist', 16, 1, @tableName)
				
	IF (SELECT OBJECT_ID(@inputTableName)) IS NULL
		RAISERROR('Table %s does not exist', 16, 1, @inputTableName)
		
	--Enable xp_cmdshell option
	EXEC dbo.SetXpCmdShellOption 1, 1, @prevAdvancedOptions, @prevXpCmdshell
	BEGIN

		--Get file names by prefix
		SELECT @cmd = 'DIR /B ' + @inputFolder + @fileNamePrefix + '* '	
			
		INSERT INTO @outputTable
			EXECUTE sys.xp_cmdshell @cmd
			
	END	
	--Restore original xp_cmdshell option
	EXEC dbo.SetXpCmdShellOption @prevAdvancedOptions, @prevXpCmdshell

	--Get full file names
	INSERT INTO @fileNames
		SELECT 
			CONVERT(nvarchar(516),@inputFolder + [output])[fileName]
		FROM @outputTable
		WHERE [output] LIKE @fileNamePrefix + '%'
		
	DECLARE 
		 @index int
		,@fileCount int
		,@fileName nvarchar(516)	
		,@tmpErrorFileName nvarchar(max)

	SELECT
		 @index = 0
		,@fileCount = COUNT(1) 
		,@tmpErrorFileName = @errorFileName
	FROM @fileNames
	

	EXEC ('TRUNCATE TABLE ' + @inputTableName)
	
	WHILE @index < @fileCount
	BEGIN	
					
		SELECT @fileName = fileName FROM @fileNames WHERE [id] = @index
		
		IF LEN(@errorFileName) > 0
		BEGIN
			DECLARE @patIndex int			
			SELECT @patIndex = PATINDEX('%.%', REVERSE(@fileName))
			SELECT @tmpErrorFileName = LEFT(@fileName,LEN(@fileName) - @patIndex) + '_' + @errorFileName;
		END
				
		EXEC dbo.LoadDelimitedDataFile  @fileName, @inputTableName, @separator, @ignoreFirstLine, @tmpErrorFileName
		
		SELECT @index = @index + 1
	END
		
	DECLARE 
		 @nvcCmd nvarchar(512)
		,@rowCount int

	SELECT @nvcCmd = 'SELECT @rowCount = COUNT(1) FROM ' + @inputTableName
	EXEC sp_executesql @nvcCmd, N'@rowCount int OUTPUT', @rowCount = @rowCount OUTPUT
	
	IF @rowCount > 0 BEGIN
		EXEC ('TRUNCATE TABLE ' + @tableName)
		EXEC dbo.CleanInputTableData @inputTableName
		EXEC dbo.CompleteDataImport @tableName, @inputTableName
		if(@quarantineDuplicates =1)
			EXEC dbo.QuarantineDuplicates @fileName, @tableName, @inputTableName, @outputFolder, @keyColumns 
	END
	
END


GO
/****** Object:  StoredProcedure [dbo].[InitProgress]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[InitProgress] 
	@maxValue int
AS
BEGIN
	RAISERROR (N'%d', 11, 11, @maxValue)WITH NOWAIT;
END

GO
/****** Object:  StoredProcedure [dbo].[InitSubProgress]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[InitSubProgress] 
	@maxValue int
AS
BEGIN
	RAISERROR (N'%d', 11, 12, @maxValue)WITH NOWAIT;
END

GO
/****** Object:  StoredProcedure [dbo].[LoadDelimitedDataFile]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Reuven Jackson
-- Create date: December 1, 2015
-- Description:
--		Load a single delimited file into input table
--		using Bulk Insert
-- =============================================

CREATE PROCEDURE [dbo].[LoadDelimitedDataFile] 
	-- Add the parameters for the stored procedure here
	 @fileName nvarchar(260)
	,@inputTableName nvarchar(128)
	,@separator nvarchar(20) = ','
	,@ignoreFirstLine bit = 0
	,@errorFileName nvarchar(260) = ''
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE 
		 @cmd nvarchar(max)
		,@firstRow nvarchar(1)
		
	IF LEN(@errorFileName) > 0
		SELECT 
			 @errorFileName = ', ERRORFILE = ''' + @errorFileName + ''''
			,@firstRow = CONVERT(varchar(1), CONVERT(int,@ignoreFirstLine) + 1)
	ELSE
		SELECT @firstRow = CONVERT(varchar(1), CONVERT(int,@ignoreFirstLine) + 1)		
		
	EXEC @cmd = dbo.StringFormat
		N'BULK INSERT %0 FROM ''%1'' WITH (MAXERRORS = 10, FIELDTERMINATOR = ''%2'', FIRSTROW = %3 %4)',
		@inputTableName, @fileName, @separator, @firstRow, @errorFileName
									
	EXEC (@cmd)		
END



GO
/****** Object:  StoredProcedure [dbo].[NDQ report]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NDQ report]
AS
BEGIN


select sl.stockLocationName
       ,sl.stockLocationDescription
       ,s.skuName
	   ,sls.skuDescription
	   ,spi4.skuItemName as Status
	   ,spi6.skuItemName as Ranging_flag

	   ,osl.stockLocationName as Origin_SL
	   ,sls.bufferSize
	   ,sls.saftyStock
	   ,sls.minimumBufferSize
	   ,sls.inventoryAtSite
	   ,sls.inventoryAtTransit
	   ,sls.custom_txt6 as Brand_code
	   ,sls.custom_txt5 as Brand_Description
	   ,sls.custom_txt1 as Class_code
	   ,spi1.skuItemName as Class_Description
	   ,sls.custom_txt2 as Category_code
	   ,spi2.skuItemName as Category_Description
	   ,spi3.skuItemName as Group_Description
	   ,sls.custom_txt10 as SLM_Type
	   ,sls.custom_txt9 as SLM_Date

	   from Symphony_StockLocationSkus sls
join Symphony_StockLocations sl on sl.stockLocationID=sls.stockLocationID
join Symphony_StockLocations osl on osl.stockLocationID=sls.originStockLocation
join Symphony_SKUs s on s.skuID=sls.skuID
left join Symphony_SKUsPropertyItems spi1 on spi1.skuItemID=sls.skuPropertyID1
left join Symphony_SKUsPropertyItems spi2 on spi2.skuItemID=sls.skuPropertyID2
left join Symphony_SKUsPropertyItems spi3 on spi3.skuItemID=sls.skuPropertyID3
left join Symphony_SKUsPropertyItems spi4 on spi4.skuItemID=sls.skuPropertyID4
left join Symphony_SKUsPropertyItems spi6 on spi6.skuItemID=sls.skuPropertyID6
left join Symphony_StockLocationPropertyItems slpi on slpi.slItemID=sl.slPropertyID5

where  sls.inventoryAtSite+sls.inventoryAtTransit>0 and sl.stockLocationType=3

end
GO
/****** Object:  StoredProcedure [dbo].[Procedure_MTSSKUSLM]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[Procedure_MTSSKUSLM] as

declare @Reportname varchar(1000);
declare @sqlcmd varchar(1000);

begin
set @Reportname = 'E:\SymphonyData\SLMOutputFolder\' + 'SLM_MTSSKUS_' + Convert(varchar(8), GETDATE(), 112) + '.csv'
set @sqlcmd = 'SQLCMD.EXE -d SymphonyInfiniti -Q " select * from MTSSKU_Nidhi" -o ' +
				@Reportname + '  -s"," -W -h 500000'
--Print @sqlcmd;
EXEC xp_cmdshell @sqlcmd,no_output;
end







GO
/****** Object:  StoredProcedure [dbo].[QuarantineDuplicates]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author:		Reuven Jackson
-- Create date: 
-- Description:	Export duplicate input data to a specified file
-- ================================================
CREATE PROCEDURE [dbo].[QuarantineDuplicates] 
	-- Add the parameters for the stored procedure here
	 @fileName varchar(512)
	,@tableName varchar(512)
	,@inputTableName varchar(512)
	,@outputFolder varchar(512)
	,@keyColumns dbo.StringList READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	DECLARE
		 @cmd nvarchar(max)
		,@duplicatesCount int
		,@columns dbo.StringList
		,@columnNames varchar(8000)
		,@keyColumnNames varchar(8000)
		
	INSERT INTO @columns
		SELECT name FROM sys.columns
		WHERE [object_id] = OBJECT_ID(@tableName)
	
	SELECT 
		 @columnNames = dbo.StringJoin(',',@columns)
		,@keyColumnNames = dbo.StringJoin(',',@keyColumns)
				
	DECLARE @params dbo.StringList
	INSERT INTO @params
		SELECT @columnNames
		UNION ALL SELECT @keyColumnNames
		UNION ALL SELECT @tableName
	
	SELECT @cmd = dbo.StringFormatEx(
		'WITH keyValues AS (SELECT %s ,ROW_NUMBER() OVER (PARTITION BY %s ORDER BY [id])[count] FROM %s)SELECT @duplicatesCount = COUNT(1) FROM keyValues WHERE [count] > 1'
		,@params)
	
	EXEC sp_executesql @cmd, N'@duplicatesCount int OUTPUT', @duplicatesCount = @duplicatesCount OUTPUT
	
	IF @duplicatesCount > 0
	BEGIN
		DECLARE
			 @patIndex int
			,@extension nvarchar(32)
			,@tmpColumnNames varchar(8000)
			,@deletedColumnNames varchar(8000)
		
		EXEC fs_GetFileName @fileName, @fileName OUTPUT

		SELECT @fileName = REVERSE(@fileName), @patIndex = PATINDEX('%.%', @fileName)
		
		IF @patIndex > 0
			SELECT
				 @extension = REVERSE(LEFT(@fileName, @patIndex))
				,@fileName = @outputFolder + REVERSE(RIGHT(@fileName,LEN(@fileName) - @patIndex)) + '_quarantine' + @extension
				
		DELETE @columns
		
		INSERT INTO @columns
			SELECT name FROM sys.columns
			WHERE [object_id] = OBJECT_ID(@inputTableName)
	
		SELECT @tmpColumnNames = dbo.StringJoin(',', @columns)
		SELECT @deletedColumnNames = dbo.StringJoin(',deleted.', @columns)

		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TMP_DUPLICATES]') AND type in (N'U'))
		DROP TABLE [dbo].[TMP_DUPLICATES]

		--Create tmp table for duplicates
		DELETE @params	
		INSERT INTO @params ([item]) VALUES (@tmpColumnNames),(@tmpColumnNames),(@tableName)
		SELECT @cmd = dbo.StringFormatEx('SELECT TOP(0) %s INTO TMP_DUPLICATES FROM (SELECT %s FROM %s) TMP',@params)
		EXEC (@cmd)
		
		--Get Duplicates
		DELETE @params	
		INSERT INTO @params ([item]) VALUES (@columnNames),(@keyColumnNames),(@tableName),(@deletedColumnNames)
		SELECT @cmd = dbo.StringFormatEx('WITH keyValues AS (SELECT %s ,ROW_NUMBER() OVER (PARTITION BY %s ORDER BY [id])[count] FROM %s)DELETE FROM keyValues OUTPUT deleted.%s INTO TMP_DUPLICATES WHERE [count] > 1',@params)
		EXEC (@cmd)
		
		--Get bcp command to output duplicates
		DELETE @params	
		DECLARE @bcpCmd varchar(8000)
		INSERT INTO @params ([item]) VALUES (DB_NAME()),(@fileName)
		SELECT @bcpCmd = dbo.StringFormatEx('bcp %s..TMP_DUPLICATES out %s -c -t, -T',@params)
			
		--Output duplicates with bcp
		DECLARE
			 @prevAdvancedOptions int
			,@prevXpCmdshell int

		EXEC dbo.SetXpCmdShellOption 1, 1, @prevAdvancedOptions, @prevXpCmdshell
		
		EXEC xp_cmdshell @bcpCmd
				
		EXEC dbo.SetXpCmdShellOption @prevAdvancedOptions, @prevXpCmdshell
		
		--Remove duplicates table
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TMP_DUPLICATES]') AND type in (N'U'))
		DROP TABLE [dbo].[TMP_DUPLICATES]
END
END




GO
/****** Object:  StoredProcedure [dbo].[ReportProgress]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ReportProgress] 
	@message nvarchar(max) = ''
AS
BEGIN
	RAISERROR (N'%s', 11, 13, @message)WITH NOWAIT;
END

GO
/****** Object:  StoredProcedure [dbo].[ReportSubProgress]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ReportSubProgress] 
	@message nvarchar(max) = ''
AS
BEGIN
	RAISERROR (N'%s', 11, 14, @message) WITH NOWAIT;
END

GO
/****** Object:  StoredProcedure [dbo].[ResetDefaultViewFlag]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ResetDefaultViewFlag]
@viewID int
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE UVA
		SET UVA.isUserDefault = 0
	FROM [dbo].[Symphony_UserViewsAssignment] UVA
	WHERE UVA.viewID = @viewID

END

GO
/****** Object:  StoredProcedure [dbo].[ResetUserViewAssignments]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ResetUserViewAssignments]
@viewID int
AS
BEGIN
	SET NOCOUNT ON;

	DELETE UVA
	FROM [dbo].[Symphony_UserViewsAssignment] UVA
	WHERE UVA.viewID = @viewID

END

GO
/****** Object:  StoredProcedure [dbo].[SetViewOwner]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SetViewOwner] @viewID INT
	,@newOwnerID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		 @userID INT
		,@isUserDeleted BIT

	SELECT 
		 @userID = UV.createdBy
		,@isUserDeleted = CONVERT(BIT, ISNULL(UP.userPasswordID, 0))
	FROM [dbo].[Symphony_UserViews] UV
	LEFT JOIN [dbo].[Symphony_UserPassword] UP
		ON UP.userPasswordID = UV.createdBy

	--Change createdBy to new user
	UPDATE UV
	SET UV.createdBy = @newOwnerID
	FROM [dbo].[Symphony_UserViews] UV
	WHERE UV.id = @viewID

	IF @isUserDeleted = 1
		DELETE UVA
		FROM [dbo].[Symphony_UserViewsAssignment] UVA
		WHERE UVA.viewID = @viewID
			AND UVA.userID = @userID;
END

GO
/****** Object:  StoredProcedure [dbo].[SetXpCmdShellOption]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SetXpCmdShellOption] 
	-- Add the parameters for the stored procedure here
	 @allowAdvancedOptions int
	,@allowXpCmdShell int
	,@prevAdvancedOptions int = NULL OUTPUT
	,@prevXpCmdshell int = NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT @prevAdvancedOptions = CONVERT(int, value_in_use) 
	FROM sys.configurations 
	WHERE name = 'show advanced options'

	SELECT @prevXpCmdshell = CONVERT(int, value_in_use) 
	FROM sys.configurations 
	WHERE name = 'xp_cmdshell'
			
			
	IF @allowAdvancedOptions = 0 AND @prevAdvancedOptions = 1
	BEGIN
		IF (@prevXpCmdshell <> @allowXpCmdShell)
		BEGIN
			EXEC sp_configure 'xp_cmdshell', @allowAdvancedOptions
			RECONFIGURE
		END
		IF (@prevAdvancedOptions <> @allowAdvancedOptions)
		BEGIN
			EXEC sp_configure 'show advanced options', @allowAdvancedOptions
			RECONFIGURE
		END
	END
	ELSE
	BEGIN
		IF (@prevAdvancedOptions <> @allowAdvancedOptions)
		BEGIN
			EXEC sp_configure 'show advanced options', @allowAdvancedOptions
			RECONFIGURE
		END

		IF (@prevXpCmdshell <> @allowXpCmdShell)
		BEGIN
			EXEC sp_configure 'xp_cmdshell', @allowAdvancedOptions
			RECONFIGURE
		END
	END
END



GO
/****** Object:  StoredProcedure [dbo].[sp_CreateDelimitedTextFile]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CreateDelimitedTextFile] 
(
@Source varchar(max),
@DestinationFile varchar(max),
@ColumnList varchar(max) = '',
@Delimiter varchar(256) = ',',
@Qualifier varchar(256) = '"',
@Criteria varchar(max) = '',
@FirstRow int = 0,
@LastRow int = 0,
@Username varchar(256) = '',
@Password varchar(256) = '',
@Server varchar(256) = '',
@SourceType varchar(100) = '',
@SourceTableName varchar(128) = '',
@OtherConnection varchar(max) = '',
@useExcelTextFields int = 0,
@ExcelTextIdn varchar(256) = '='
)
AS
BEGIN

-- Declare variable
DECLARE @HeaderCount int
DECLARE @Header varchar(max)
DECLARE @SQL varchar(max)
DECLARE @COLNAME varchar(max)
DECLARE @SUBSQL varchar(max)
DECLARE @TEMPVIEWNAME varchar(max)
DECLARE @counter int

-- If TAB is specified as the delimiter, switch to the tab character
IF @Delimiter = 'TAB'
SET @Delimiter = CHAR(9)

-- If useExcelTextFields is specified as True (1), then add '=' before values in the exported file
IF @useExcelTextFields = 1
SET @ExcelTextIdn = '='
ElSE
SET @ExcelTextIdn = ''

-- Otherconnection is not used but kept for future development
SET @OtherConnection = ''

-- Set the name of the temporary view
SET @TEMPVIEWNAME = 'TEMPVIEW'+convert(varchar(max),newid())

begin try

-- Try to figure out the source type in case one is not given and it appears something other than SQL may be given
begin try
IF (charindex('\',@SOURCE) > 0 AND charindex('.', reverse(@SOURCE)) = 4 AND @SourceType='')
BEGIN
	SET @SourceType = SUBSTRING(UPPER(@SOURCE),LEN(@SOURCE)-2,3)
END
ELSE
	SET @SourceType = 'SQL'
end try
begin catch
-- If an error occurs during this time, ignore it and assume SQL source type
	SET @SourceType = 'SQL'
end catch


IF (UPPER(@SourceType) <> 'SQL')
BEGIN
	IF (@OtherConnection <> '')
		-- This will be used in the future but disabled for now from previous set statement (I left this in here because I have a horrible memory!)
		exec ('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset('+@OtherConnection+'))')
	ELSE
	BEGIN
		-- If the source is a delimited file, create a view to the file
		DECLARE @filepath varchar(256)
		DECLARE @filename varchar(256)
		DECLARE @OtherViewSQL varchar(max)

		-- Get the file path and filename
		select @filepath=reverse(substring(reverse(@Source), charindex('\', reverse(@Source))+1, len(@Source) - charindex('\', reverse(@Source)) ))
		select @filename=reverse(substring(reverse(@Source), 0, charindex('\', reverse(@Source)) ))
		-- Create view to the file using its connector
		If(UPPER(@SourceType) = 'DELIMITED' OR UPPER(@SourceType) = 'CSV' OR Upper(@SourceType) = 'TEXT' OR Upper(@SourceType) = 'TXT')
		exec('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset(''MSDASQL'', ''Driver={Microsoft Text Driver (*.txt; *.csv)};DefaultDir='+@filepath+';'',''select * from ['+@filename+']''))')
		else if(UPPER(@SourceType) = 'DBF' OR UPPER(@SourceType) = 'DBASE' OR UPPER(@SourceType) = 'DBASE3' OR UPPER(@SourceType) = 'DBASEIII' OR UPPER(@SourceType) = 'DBASE 3' OR UPPER(@SourceType) = 'DBASE III' OR UPPER(@SourceType) = 'FOXPRO')
		exec('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset(''MSDASQL'', ''Driver={Microsoft dBase Driver (*.dbf)};DBQ='+@filepath+';'',''select * from ['+@filename+']''))')
		else IF(UPPER(@SourceType) = 'ACCESS' OR UPPER(@SourceType) = 'MDB')
		exec('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset(''MICROSOFT.JET.OLEDB.4.0'', '''+@filepath+'\'+@filename+''' ;;,['+@SourceTableName+']))')
		else IF(UPPER(@SourceType) = 'EXCEL' OR UPPER(@SourceType) = 'XLS')
		exec('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset(''MICROSOFT.JET.OLEDB.4.0'', ''Excel 8.0;DATABASE='+@filepath+'\'+@filename+''',''select * from ['+@SourceTableName+'$]''))')
	END


-- Set the source table to the new view
SET @Source = @TEMPVIEWNAME+'-other'

END
ELSE
	SET @SourceTableName = @Source

-- Check to see if columnlist is provided
IF (@ColumnList <> '')
	BEGIN
		-- Get header count from columnlist
		SELECT @HeaderCount = ((LEN(RTRIM(LTRIM(@ColumnList))) - LEN(REPLACE(RTRIM(LTRIM(@ColumnList)), ',', '')))+1)

		-- Build delimited file header row
		SELECT @Header = COALESCE(@Header  + ',', '') + 
	    CASE WHEN @Qualifier = '' THEN ' ''' + @ExcelTextIdn + @Qualifier+'''+CASE when isnumeric(['+column_name+']) = 1 AND
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = '''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''' 
		and (UPPER(data_type) <> ''VARCHAR'' OR UPPER(data_type) <> ''NVARCHAR'' OR UPPER(data_type) <> ''CHAR'' OR UPPER(data_type) <>''NCHAR'') 
		and Upper(column_name)='''+UPPER(column_name)+''') THEN -1 ELSE 0
		END = 0
		THEN cast(cast(['+column_name+'] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when ['+column_name+'] = '''' THEN NULL ELSE ['+column_name+'] END as varchar(max)) END+'''+@Qualifier+''' as ['+column_name+']'
		ELSE ' '''+ @ExcelTextIdn + @Qualifier+'''+ISNULL(CASE when isnumeric(['+column_name+']) = 1 AND
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = '''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''' 
		and (UPPER(data_type) <> ''VARCHAR'' OR UPPER(data_type) <> ''NVARCHAR'' OR UPPER(data_type) <> ''CHAR'' OR UPPER(data_type) <>''NCHAR'') 
		and Upper(column_name)='''+UPPER(column_name)+''') THEN -1 ELSE 0
		END = 0
		THEN cast(cast(['+column_name+'] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when ['+column_name+'] = '''' THEN NULL ELSE ['+column_name+'] END as varchar(max)) END,'''')+'''+@Qualifier+''' as ['+column_name+']'
				END
		FROM ( SELECT column_name, rank() OVER (ORDER BY ordinal_position) as rank
		FROM INFORMATION_SCHEMA.columns
		where UPPER(table_name) = Upper((REPLACE(REPLACE(@Source,'[',''),']',''))) AND charindex(','+column_name+',',RTRIM(LTRIM(','+@ColumnList+','))) > 0
		) t ORDER BY t.rank ASC 

		-- Initialize main view query
		SET @SQL = 'SELECT '

		-- Build main view query
		set @counter = 0
		while @counter < @HeaderCount
			begin
				-- Increase counter
				set @counter = @counter + 1
				-- Get column name
				SELECT TOP 1 @colname = column_name FROM ( SELECT TOP (@counter) column_name, rank() OVER (ORDER BY ordinal_position) as rank
				FROM INFORMATION_SCHEMA.columns
				where UPPER(table_name) = ((Upper((REPLACE(REPLACE(@Source,'[',''),']',''))))) AND charindex(','+column_name+',',RTRIM(LTRIM(','+@ColumnList+','))) > 0
				ORDER BY rank ASC ) as t ORDER BY rank DESC
				-- Add to main view query
				IF @counter = @HeaderCount
					BEGIN
						SET @SQL = @SQL + ''''+ @ExcelTextIdn + @Qualifier+'''+ SUBSTRING(RTRIM(LTRIM('''+@ColumnList+''')),charindex('''+@colname+''',RTRIM(LTRIM('''+@ColumnList+'''))), LEN('''+@colname+'''))+'''+@Qualifier+''' as ['+@colname+'] '
					END
				ELSE
					BEGIN
						SET @SQL = @SQL + ''''+ @ExcelTextIdn + @Qualifier+'''+ SUBSTRING(RTRIM(LTRIM('''+@ColumnList+''')),charindex('''+@colname+''',RTRIM(LTRIM('''+@ColumnList+'''))), LEN('''+@colname+'''))+'''+@Qualifier+''' as ['+@colname+@Delimiter+'], '
					END
			end
	END
ELSE
	BEGIN
		-- Get header count from columnlist
		SELECT @HeaderCount = count(column_name)
		FROM INFORMATION_SCHEMA.columns
		where UPPER(table_name) = Upper((REPLACE(REPLACE(@Source,'[',''),']','')))

		-- Build delimited file header row
		SELECT @Header = COALESCE(@Header  + ',', '') + 
	    CASE WHEN @Qualifier = '' THEN ' ''' + @ExcelTextIdn + @Qualifier+'''+CASE when isnumeric(['+column_name+']) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = '''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''' 
		and (UPPER(data_type) <> ''VARCHAR'' OR UPPER(data_type) <> ''NVARCHAR'' OR UPPER(data_type) <> ''CHAR'' OR UPPER(data_type) <>''NCHAR'') 
		and Upper(column_name)='''+UPPER(column_name)+''') THEN -1 ELSE 0
		END = 0
		THEN cast(cast(['+column_name+'] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when ['+column_name+'] = '''' THEN NULL ELSE ['+column_name+'] END as varchar(max)) END+'''+@Qualifier+''' as ['+column_name+']'
		ELSE ' ''' + @ExcelTextIdn + @Qualifier+'''+ISNULL(CASE when isnumeric(['+column_name+']) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = '''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''' 
		and (UPPER(data_type) <> ''VARCHAR'' OR UPPER(data_type) <> ''NVARCHAR'' OR UPPER(data_type) <> ''CHAR'' OR UPPER(data_type) <>''NCHAR'') 
		and Upper(column_name)='''+UPPER(column_name)+''') THEN -1 ELSE 0
		END = 0
		THEN cast(cast(['+column_name+'] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when cast(['+column_name+'] as varchar(max)) = '''' THEN NULL ELSE ['+column_name+'] END as varchar(max)) END,'''')+'''+@Qualifier+''' as ['+column_name+']'
		END
		FROM ( SELECT column_name, rank() OVER (ORDER BY ordinal_position) as rank
		FROM INFORMATION_SCHEMA.columns
		where UPPER(table_name) = Upper((REPLACE(REPLACE(@Source,'[',''),']','')))
		) t ORDER BY t.rank ASC 
		-- Initialize main view query
		SET @SQL = 'SELECT '

		-- Build main view query
		set @counter = 0

		while @counter < @HeaderCount
			begin
				-- Increase counter
				set @counter = @counter + 1
				-- Get column name
				SELECT TOP 1 @colname = column_name FROM ( SELECT TOP (@counter) column_name, rank() OVER (ORDER BY ordinal_position) as rank
				FROM INFORMATION_SCHEMA.columns
				where UPPER(table_name) = Upper((REPLACE(REPLACE(@Source,'[',''),']','')))
				ORDER BY rank ASC ) as t ORDER BY rank DESC

				-- Add to main view query
				IF @counter = @HeaderCount
					BEGIN
						SET @SQL = @SQL + ''''+ @ExcelTextIdn + @Qualifier+'''+ cast(min(case ordinal_position when '+cast(@counter as varchar)+' then column_name end) as varchar)+'''+@Qualifier+''' as ['+@colname+'] '
					END
				ELSE
					BEGIN
						SET @SQL = @SQL + ''''+ @ExcelTextIdn + @Qualifier+'''+cast(min(case ordinal_position when '+cast(@counter as varchar)+' then column_name end) as varchar)+'''+@Qualifier+''' as ['+@colname+'], '
					END
			end

		SET @SQL = @SQL + ' from ['+db_name()+'].information_schema.columns where UPPER(table_name) = Upper('''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''') '

	END
-- Finish up the main view query
SET @SQL = @SQL + ' union all '
SET @SQL = @SQL + ' select '
SET @SQL = @SQL + @Header + ' FROM ['+db_name()+']..['+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+']'

-- Add criteria if exists
IF (@Criteria <> '')
BEGIN
	SET @SQL = @SQL + ' WHERE '+@Criteria+' '
END

-- Create temporary view
exec('create view ['+@TEMPVIEWNAME+'] as ('+@SQL+')')

-- Execute bcp on temporary view
DECLARE @bcpcmd varchar(8000)
SET @bcpcmd = 'bcp ["'+db_name()+']..['+@TEMPVIEWNAME+']" out "'+@DestinationFile+'" -k -c -t "'+@Delimiter+'"'
-- Add first row and last row arguments to bcp command
IF (@FirstRow > 0)
SET @bcpcmd = @bcpcmd + ' -F '+cast(@FirstRow as varchar)
IF (@LastRow > 0)
SET @bcpcmd = @bcpcmd + ' -L '+cast(@LastRow as varchar)

-- Add server login information
IF (@Username <> '')
BEGIN
	SET @bcpcmd = @bcpcmd + ' -U '+@Username
	IF (@Password <> '')
	SET @bcpcmd = @bcpcmd + ' -P '+@Password
END
ELSE
BEGIN
	SET @bcpcmd = @bcpcmd + ' -T '
END

IF (@Server <> '')
SET @bcpcmd = @bcpcmd + ' -S '+@Server

exec master..xp_cmdshell @bcpcmd

-- Drop temporary view

exec('IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'''+@TEMPVIEWNAME+''')) DROP View ['+@TEMPVIEWNAME+']')
exec('IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'''+@TEMPVIEWNAME+'-other'')) DROP VIEW ['+@TEMPVIEWNAME+'-other]')
end try
begin catch
	-- show error if one occurs
	SELECT 'ERROR: UNABLE TO CREATE DELIMITED TEXT FILE (Reason:' + error_message() + ')'
	begin try
		-- Drop view if an error occurs
		exec('IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'''+@TEMPVIEWNAME+''')) DROP View ['+@TEMPVIEWNAME+']')
		exec('IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'''+@TEMPVIEWNAME+'-other'')) DROP VIEW ['+@TEMPVIEWNAME+'-other]')
	end try
	begin catch
	end catch
end catch
END
-- sp_CreateDelimitedTextFile:Version: 1.6	 http://www.attobase.com
-- Delimited Text File Stored Procedure by:	 Joseph Biggert   03/19/2009	
----------------------------------------------------------------------------

GO
/****** Object:  StoredProcedure [dbo].[sp_CreateNoConsumptionFile]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CreateNoConsumptionFile] 
(
@Source varchar(max),
@DestinationFile varchar(max),
@ColumnList varchar(max) = '',
@Delimiter varchar(256) = ',',
@Qualifier varchar(256) = '"',
@Criteria varchar(max) = '',
@FirstRow int = 0,
@LastRow int = 0,
@Username varchar(256) = '',
@Password varchar(256) = '',
@Server varchar(256) = '',
@SourceType varchar(100) = '',
@SourceTableName varchar(128) = '',
@OtherConnection varchar(max) = '',
@useExcelTextFields int = 0,
@ExcelTextIdn varchar(256) = '='
)
AS
BEGIN

-- Declare variable
DECLARE @HeaderCount int
DECLARE @Header varchar(max)
DECLARE @SQL varchar(max)
DECLARE @COLNAME varchar(max)
DECLARE @SUBSQL varchar(max)
DECLARE @TEMPVIEWNAME varchar(max)
DECLARE @counter int

-- If TAB is specified as the delimiter, switch to the tab character
IF @Delimiter = 'TAB'
SET @Delimiter = CHAR(9)

-- If useExcelTextFields is specified as True (1), then add '=' before values in the exported file
IF @useExcelTextFields = 1
SET @ExcelTextIdn = '='
ElSE
SET @ExcelTextIdn = ''

-- Otherconnection is not used but kept for future development
SET @OtherConnection = ''

-- Set the name of the temporary view
SET @TEMPVIEWNAME = 'TEMPVIEW'+convert(varchar(max),newid())

begin try

-- Try to figure out the source type in case one is not given and it appears something other than SQL may be given
begin try
IF (charindex('\',@SOURCE) > 0 AND charindex('.', reverse(@SOURCE)) = 4 AND @SourceType='')
BEGIN
	SET @SourceType = SUBSTRING(UPPER(@SOURCE),LEN(@SOURCE)-2,3)
END
ELSE
	SET @SourceType = 'SQL'
end try
begin catch
-- If an error occurs during this time, ignore it and assume SQL source type
	SET @SourceType = 'SQL'
end catch


IF (UPPER(@SourceType) <> 'SQL')
BEGIN
	IF (@OtherConnection <> '')
		-- This will be used in the future but disabled for now from previous set statement (I left this in here because I have a horrible memory!)
		exec ('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset('+@OtherConnection+'))')
	ELSE
	BEGIN
		-- If the source is a delimited file, create a view to the file
		DECLARE @filepath varchar(256)
		DECLARE @filename varchar(256)
		DECLARE @OtherViewSQL varchar(max)

		-- Get the file path and filename
		select @filepath=reverse(substring(reverse(@Source), charindex('\', reverse(@Source))+1, len(@Source) - charindex('\', reverse(@Source)) ))
		select @filename=reverse(substring(reverse(@Source), 0, charindex('\', reverse(@Source)) ))
		-- Create view to the file using its connector
		If(UPPER(@SourceType) = 'DELIMITED' OR UPPER(@SourceType) = 'CSV' OR Upper(@SourceType) = 'TEXT' OR Upper(@SourceType) = 'TXT')
		exec('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset(''MSDASQL'', ''Driver={Microsoft Text Driver (*.txt; *.csv)};DefaultDir='+@filepath+';'',''select * from ['+@filename+']''))')
		else if(UPPER(@SourceType) = 'DBF' OR UPPER(@SourceType) = 'DBASE' OR UPPER(@SourceType) = 'DBASE3' OR UPPER(@SourceType) = 'DBASEIII' OR UPPER(@SourceType) = 'DBASE 3' OR UPPER(@SourceType) = 'DBASE III' OR UPPER(@SourceType) = 'FOXPRO')
		exec('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset(''MSDASQL'', ''Driver={Microsoft dBase Driver (*.dbf)};DBQ='+@filepath+';'',''select * from ['+@filename+']''))')
		else IF(UPPER(@SourceType) = 'ACCESS' OR UPPER(@SourceType) = 'MDB')
		exec('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset(''MICROSOFT.JET.OLEDB.4.0'', '''+@filepath+'\'+@filename+''' ;;,['+@SourceTableName+']))')
		else IF(UPPER(@SourceType) = 'EXCEL' OR UPPER(@SourceType) = 'XLS')
		exec('create view ['+@TEMPVIEWNAME+'-other] as (select * from OpenRowset(''MICROSOFT.JET.OLEDB.4.0'', ''Excel 8.0;DATABASE='+@filepath+'\'+@filename+''',''select * from ['+@SourceTableName+'$]''))')
	END


-- Set the source table to the new view
SET @Source = @TEMPVIEWNAME+'-other'

END
ELSE
	SET @SourceTableName = @Source

-- Check to see if columnlist is provided
IF (@ColumnList <> '')
	BEGIN
		-- Get header count from columnlist
		SELECT @HeaderCount = ((LEN(RTRIM(LTRIM(@ColumnList))) - LEN(REPLACE(RTRIM(LTRIM(@ColumnList)), ',', '')))+1)

		-- Build delimited file header row
		SELECT @Header = COALESCE(@Header  + ',', '') + 
	    CASE WHEN @Qualifier = '' THEN ' ''' + @ExcelTextIdn + @Qualifier+'''+CASE when isnumeric(['+column_name+']) = 1 AND
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = '''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''' 
		and (UPPER(data_type) <> ''VARCHAR'' OR UPPER(data_type) <> ''NVARCHAR'' OR UPPER(data_type) <> ''CHAR'' OR UPPER(data_type) <>''NCHAR'') 
		and Upper(column_name)='''+UPPER(column_name)+''') THEN -1 ELSE 0
		END = 0
		THEN cast(cast(['+column_name+'] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when ['+column_name+'] = '''' THEN NULL ELSE ['+column_name+'] END as varchar(max)) END+'''+@Qualifier+''' as ['+column_name+']'
		ELSE ' '''+ @ExcelTextIdn + @Qualifier+'''+ISNULL(CASE when isnumeric(['+column_name+']) = 1 AND
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = '''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''' 
		and (UPPER(data_type) <> ''VARCHAR'' OR UPPER(data_type) <> ''NVARCHAR'' OR UPPER(data_type) <> ''CHAR'' OR UPPER(data_type) <>''NCHAR'') 
		and Upper(column_name)='''+UPPER(column_name)+''') THEN -1 ELSE 0
		END = 0
		THEN cast(cast(['+column_name+'] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when ['+column_name+'] = '''' THEN NULL ELSE ['+column_name+'] END as varchar(max)) END,'''')+'''+@Qualifier+''' as ['+column_name+']'
				END
		FROM ( SELECT column_name, rank() OVER (ORDER BY ordinal_position) as rank
		FROM INFORMATION_SCHEMA.columns
		where UPPER(table_name) = Upper((REPLACE(REPLACE(@Source,'[',''),']',''))) AND charindex(','+column_name+',',RTRIM(LTRIM(','+@ColumnList+','))) > 0
		) t ORDER BY t.rank ASC 

		-- Initialize main view query
		SET @SQL = 'SELECT '

		-- Build main view query
		set @counter = 0
		while @counter < @HeaderCount
			begin
				-- Increase counter
				set @counter = @counter + 1
				-- Get column name
				SELECT TOP 1 @colname = column_name FROM ( SELECT TOP (@counter) column_name, rank() OVER (ORDER BY ordinal_position) as rank
				FROM INFORMATION_SCHEMA.columns
				where UPPER(table_name) = ((Upper((REPLACE(REPLACE(@Source,'[',''),']',''))))) AND charindex(','+column_name+',',RTRIM(LTRIM(','+@ColumnList+','))) > 0
				ORDER BY rank ASC ) as t ORDER BY rank DESC
				-- Add to main view query
				IF @counter = @HeaderCount
					BEGIN
						SET @SQL = @SQL + ''''+ @ExcelTextIdn + @Qualifier+'''+ SUBSTRING(RTRIM(LTRIM('''+@ColumnList+''')),charindex('''+@colname+''',RTRIM(LTRIM('''+@ColumnList+'''))), LEN('''+@colname+'''))+'''+@Qualifier+''' as ['+@colname+'] '
					END
				ELSE
					BEGIN
						SET @SQL = @SQL + ''''+ @ExcelTextIdn + @Qualifier+'''+ SUBSTRING(RTRIM(LTRIM('''+@ColumnList+''')),charindex('''+@colname+''',RTRIM(LTRIM('''+@ColumnList+'''))), LEN('''+@colname+'''))+'''+@Qualifier+''' as ['+@colname+@Delimiter+'], '
					END
			end
	END
ELSE
	BEGIN
		-- Get header count from columnlist
		SELECT @HeaderCount = count(column_name)
		FROM INFORMATION_SCHEMA.columns
		where UPPER(table_name) = Upper((REPLACE(REPLACE(@Source,'[',''),']','')))

		-- Build delimited file header row
		SELECT @Header = COALESCE(@Header  + ',', '') + 
	    CASE WHEN @Qualifier = '' THEN ' ''' + @ExcelTextIdn + @Qualifier+'''+CASE when isnumeric(['+column_name+']) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = '''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''' 
		and (UPPER(data_type) <> ''VARCHAR'' OR UPPER(data_type) <> ''NVARCHAR'' OR UPPER(data_type) <> ''CHAR'' OR UPPER(data_type) <>''NCHAR'') 
		and Upper(column_name)='''+UPPER(column_name)+''') THEN -1 ELSE 0
		END = 0
		THEN cast(cast(['+column_name+'] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when ['+column_name+'] = '''' THEN NULL ELSE ['+column_name+'] END as varchar(max)) END+'''+@Qualifier+''' as ['+column_name+']'
		ELSE ' ''' + @ExcelTextIdn + @Qualifier+'''+ISNULL(CASE when isnumeric(['+column_name+']) = 1 AND 
		case when exists(select ordinal_position from 
		INFORMATION_SCHEMA.COLUMNS where Upper(table_name) = '''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''' 
		and (UPPER(data_type) <> ''VARCHAR'' OR UPPER(data_type) <> ''NVARCHAR'' OR UPPER(data_type) <> ''CHAR'' OR UPPER(data_type) <>''NCHAR'') 
		and Upper(column_name)='''+UPPER(column_name)+''') THEN -1 ELSE 0
		END = 0
		THEN cast(cast(['+column_name+'] as decimal(38, 38)) as varchar(max)) ELSE cast(CASE when cast(['+column_name+'] as varchar(max)) = '''' THEN NULL ELSE ['+column_name+'] END as varchar(max)) END,'''')+'''+@Qualifier+''' as ['+column_name+']'
		END
		FROM ( SELECT column_name, rank() OVER (ORDER BY ordinal_position) as rank
		FROM INFORMATION_SCHEMA.columns
		where UPPER(table_name) = Upper((REPLACE(REPLACE(@Source,'[',''),']','')))
		) t ORDER BY t.rank ASC 
		-- Initialize main view query
		SET @SQL = 'SELECT '

		-- Build main view query
		set @counter = 0

		while @counter < @HeaderCount
			begin
				-- Increase counter
				set @counter = @counter + 1
				-- Get column name
				SELECT TOP 1 @colname = column_name FROM ( SELECT TOP (@counter) column_name, rank() OVER (ORDER BY ordinal_position) as rank
				FROM INFORMATION_SCHEMA.columns
				where UPPER(table_name) = Upper((REPLACE(REPLACE(@Source,'[',''),']','')))
				ORDER BY rank ASC ) as t ORDER BY rank DESC

				-- Add to main view query
				IF @counter = @HeaderCount
					BEGIN
						SET @SQL = @SQL + ''''+ @ExcelTextIdn + @Qualifier+'''+ cast(min(case ordinal_position when '+cast(@counter as varchar)+' then column_name end) as varchar)+'''+@Qualifier+''' as ['+@colname+'] '
					END
				ELSE
					BEGIN
						SET @SQL = @SQL + ''''+ @ExcelTextIdn + @Qualifier+'''+cast(min(case ordinal_position when '+cast(@counter as varchar)+' then column_name end) as varchar)+'''+@Qualifier+''' as ['+@colname+'], '
					END
			end

		SET @SQL = @SQL + ' from ['+db_name()+'].information_schema.columns where UPPER(table_name) = Upper('''+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+''') '

	END
-- Finish up the main view query
SET @SQL = @SQL + ' union all '
SET @SQL = @SQL + ' select '
SET @SQL = @SQL + @Header + ' FROM ['+db_name()+']..['+Upper((REPLACE(REPLACE(@Source,'[',''),']','')))+']'

-- Add criteria if exists
IF (@Criteria <> '')
BEGIN
	SET @SQL = @SQL + ' WHERE '+@Criteria+' '
END

-- Create temporary view
exec('create view ['+@TEMPVIEWNAME+'] as ('+@SQL+')')

-- Execute bcp on temporary view
DECLARE @bcpcmd varchar(8000)
SET @bcpcmd = 'bcp ["'+db_name()+']..['+@TEMPVIEWNAME+']" out "'+@DestinationFile+'" -k -c -t "'+@Delimiter+'"'
-- Add first row and last row arguments to bcp command
IF (@FirstRow > 0)
SET @bcpcmd = @bcpcmd + ' -F '+cast(@FirstRow as varchar)
IF (@LastRow > 0)
SET @bcpcmd = @bcpcmd + ' -L '+cast(@LastRow as varchar)

-- Add server login information
IF (@Username <> '')
BEGIN
	SET @bcpcmd = @bcpcmd + ' -U '+@Username
	IF (@Password <> '')
	SET @bcpcmd = @bcpcmd + ' -P '+@Password
END
ELSE
BEGIN
	SET @bcpcmd = @bcpcmd + ' -T '
END

IF (@Server <> '')
SET @bcpcmd = @bcpcmd + ' -S '+@Server

exec master..xp_cmdshell @bcpcmd

-- Drop temporary view

exec('IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'''+@TEMPVIEWNAME+''')) DROP View ['+@TEMPVIEWNAME+']')
exec('IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'''+@TEMPVIEWNAME+'-other'')) DROP VIEW ['+@TEMPVIEWNAME+'-other]')
end try
begin catch
	-- show error if one occurs
	SELECT 'ERROR: UNABLE TO CREATE DELIMITED TEXT FILE (Reason:' + error_message() + ')'
	begin try
		-- Drop view if an error occurs
		exec('IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'''+@TEMPVIEWNAME+''')) DROP View ['+@TEMPVIEWNAME+']')
		exec('IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'''+@TEMPVIEWNAME+'-other'')) DROP VIEW ['+@TEMPVIEWNAME+'-other]')
	end try
	begin catch
	end catch
end catch
END
-- sp_CreateDelimitedTextFile:Version: 1.6	 http://www.attobase.com
-- Delimited Text File Stored Procedure by:	 Joseph Biggert   03/19/2009	
----------------------------------------------------------------------------

GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteFamilyAGConnection]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_DeleteFamilyAGConnection]
 	@folderPath nvarchar(max) = N'D:\symphonydata\InputFolder',
	@outputPath nvarchar(max) = 'D:\symphonydata\InputFolder',
	@trace int = 0
AS
BEGIN

DROP TABLE A_DELETE_FAMILY_AG_Export;
DROP TABLE ##TempHeaderNames;
drop table ##Tmp_DeleteFamilyAG

  IF NOT EXISTS(SELECT * FROM sys.tables
         WHERE Name = N'ClientTable_NewFamilyAG' AND Type = N'U')
		 BEGIN
				CREATE TABLE ClientTable_NewFamilyAG
				(
					assortmentGroupID int,
					familyID int,
					reportedYear int,
					reportedMonth int,
					reportedDay int
				)
	     END
 ELSE
		 BEGIN
				TRUNCATE TABLE ClientTable_NewFamilyAG
		 END

IF OBJECT_ID('tempdb..##Tmp_DeleteFamilyAG') IS NOT NULL
BEGIN
		DROP TABLE ##Tmp_DeleteFamilyAG
END

/********************************************/
-- input process should be here
--CREATE INPUT TABLES DYNAMICALLY ACCORDING TO FILE_STRUCTURE 'SKUFAMILY'

DECLARE @structCMD nvarchar(max)


IF OBJECT_ID('TMP_DELETE_FAMILY_AG_INPUT') IS NOT NULL
	DROP TABLE TMP_DELETE_FAMILY_AG_INPUT

  SELECT @structCMD  = 'CREATE TABLE TMP_DELETE_FAMILY_AG_INPUT ('

  SELECT @structCMD = @structCMD + field_name + ' nvarchar(200), '
  FROM Symphony_FileStructure
  WHERE file_name = 'SKUFAMILY' and participate = 1
  ORDER BY field_position ASC

  select @structCMD = Left(@structCMD, len(@structCMD) - 1) + ')'

 EXEC(@structCMD)

IF OBJECT_ID('TMP_DELETE_FAMILY_AG_INPUTDATA') IS NOT NULL
BEGIN
	DROP TABLE TMP_DELETE_FAMILY_AG_INPUTDATA
END

  SELECT @structCMD  = 'CREATE TABLE TMP_DELETE_FAMILY_AG_INPUTDATA ('

  SELECT @structCMD = @structCMD + field_name + ' nvarchar(200), '
  FROM Symphony_FileStructure
  WHERE file_name = 'SKUFAMILY' and participate = 1
  ORDER BY field_position ASC

  select @structCMD = @structCMD + ' rowNum int IDENTITY(1,1), 
									familyID int,
									assortmentGroupID int,
									reportedYearNumber int,
									reportedMonthNumber int,
									reportedDayNumber int)'

 EXEC(@structCMD)

IF OBJECT_ID('CLIENT_DELETE_FAMILY_AG_QUARANTINE_ROWS') IS NULL
BEGIN
CREATE TABLE CLIENT_DELETE_FAMILY_AG_QUARANTINE_ROWS
(
	Family nvarchar(200),
	AG nvarchar(200),
	ReportedYear nvarchar(10),
	ReportedMonth nvarchar(10),
	ReportedDay nvarchar(10),
	familyID int,
	assortmentGroupID int,
	reportedYearNumber int,
	reportedMonthNumber int,
	reportedDayNumber int,
	quarantineReason nvarchar(1000)
)
END

TRUNCATE TABLE CLIENT_DELETE_FAMILY_AG_QUARANTINE_ROWS

--IMPORT THE DATA TO THE INPUT TABLE

DECLARE @myKeyColumns dbo.StringList
DECLARE @separator nvarchar(5)

SELECT @separator = CASE WHEN separator = '' THEN ',' ELSE separator END
FROM Symphony_FileStructureGlobal
WHERE file_name = 'SKUFAMILY'


exec ImportDelimitedDataFiles @fileNamePrefix = 'SKUFAMILY',@inputFolder = @FolderPath, @outputFolder = 'D:\symphonydata\InputFolder',@tableName = 'TMP_DELETE_FAMILY_AG_INPUTDATA', @inputTableName ='TMP_DELETE_FAMILY_AG_INPUT',@keyColumns = @myKeyColumns,
	@ignoreFirstLine = 1,@quarantineDuplicates = 0, @separator = @separator


--VALIDATE DATA
-- Quaranine missing mandatory data
INSERT INTO CLIENT_DELETE_FAMILY_AG_QUARANTINE_ROWS (Family, AG, ReportedYear, ReportedMonth,ReportedDay,quarantineReason)
SELECT familyName, assortmentGroupName, reportedYear, reportedMonth,reportedDay,'Mandatory data is missing'
FROM TMP_DELETE_FAMILY_AG_INPUTDATA
WHERE familyName IS NULL OR assortmentGroupName IS NULL OR reportedYear IS NULL OR reportedMonth IS NULL OR reportedDay IS NULL

DELETE TMP_DELETE_FAMILY_AG_INPUTDATA
WHERE familyName IS NULL OR assortmentGroupName IS NULL OR ReportedYear IS NULL OR ReportedMonth IS NULL OR ReportedDay IS NULL

--QUARANTINE DUPLICATED ROWS
IF OBJECT_ID('#DUPLICATE_ROWS') IS NOT NULL
	DROP TABLE #DUPLICATE_ROWS

CREATE TABLE #DUPLICATE_ROWS
(
		minRowNum int,
		Family nvarchar(200),
		AG nvarchar(200)
)

INSERT INTO #DUPLICATE_ROWS (Family, AG,minRowNum)
SELECT familyName, assortmentGroupName, MIN(rowNum)
FROM TMP_DELETE_FAMILY_AG_INPUTDATA
GROUP BY familyName, assortmentGroupName
HAVING COUNT(1) > 1


INSERT INTO CLIENT_DELETE_FAMILY_AG_QUARANTINE_ROWS (Family, AG, ReportedYear, ReportedMonth,ReportedDay,quarantineReason)
SELECT T.familyName, T.assortmentGroupName, ReportedYear, ReportedMonth,ReportedDay,'DUPLICATE ROW'
FROM TMP_DELETE_FAMILY_AG_INPUTDATA T INNER JOIN #DUPLICATE_ROWS D ON T.familyName = D.Family AND T.assortmentGroupName = D.AG
WHERE T.rowNum <> D.minRowNum

DELETE T
FROM TMP_DELETE_FAMILY_AG_INPUTDATA T INNER JOIN #DUPLICATE_ROWS D ON T.familyName = D.Family AND T.assortmentGroupName = D.AG
WHERE T.rowNum <> D.minRowNum

--CONVERT family, ag to ids
UPDATE T set familyID = F.id, assortmentGroupID = AG.id
FROM TMP_DELETE_FAMILY_AG_INPUTDATA T
	LEFT JOIN Symphony_SkuFamilies F ON F.name = T.familyName
	LEFT JOIN Symphony_AssortmentGroups AG ON AG.name = T.assortmentGroupName

--QUARANTINE INVALID ENTITIES
INSERT INTO CLIENT_DELETE_FAMILY_AG_QUARANTINE_ROWS (Family, AG, ReportedYear, ReportedMonth,ReportedDay,quarantineReason)
SELECT familyName, assortmentGroupName, ReportedYear, ReportedMonth,ReportedDay,'Invalid Entity'
FROM TMP_DELETE_FAMILY_AG_INPUTDATA 
WHERE assortmentGroupID IS NULL OR familyID IS NULL

DELETE TMP_DELETE_FAMILY_AG_INPUTDATA 
WHERE assortmentGroupID IS NULL OR familyID IS NULL

-- VALIDATE DATES 
--CONVERT VALID INTEGERS AND SET INVALID TO NULL
UPDATE T SET reportedYearNumber = CASE WHEN isnumeric(T.ReportedYear)=1 THEN CASE WHEN charindex('.',T.ReportedYear) > 0 THEN NULL ELSE cast(T.ReportedYear as int) END ELSE NULL END
,reportedMonthNumber = CASE WHEN isnumeric(T.ReportedMonth)=1 THEN CASE WHEN charindex('.',T.ReportedMonth) > 0 THEN NULL ELSE cast(T.ReportedMonth as int) END ELSE NULL END
,reportedDayNumber = CASE WHEN isnumeric(T.ReportedDay)=1 THEN CASE WHEN charindex('.',T.ReportedDay) > 0 THEN NULL ELSE cast(T.ReportedDay as int) END ELSE NULL END
FROM TMP_DELETE_FAMILY_AG_INPUTDATA T 

--QUARANTINE INVALID REPORTED DATE
INSERT INTO CLIENT_DELETE_FAMILY_AG_QUARANTINE_ROWS (Family, AG, ReportedYear, ReportedMonth,ReportedDay,quarantineReason)
SELECT familyName, assortmentGroupName, reportedYear, reportedMonth,reportedDay,'Invalid reported date'
FROM TMP_DELETE_FAMILY_AG_INPUTDATA
WHERE reportedYearNumber IS NULL OR reportedMonthNumber IS NULL OR reportedDayNumber IS NULL 
OR reportedYearNumber <2002 OR reportedYearNumber>3000 OR reportedMonthNumber < 1 OR reportedMonthNumber > 12 OR reportedDayNumber <1 OR reportedDayNumber > 31
OR ISDATE(ReportedYear+'-'+ReportedMonth+'-'+ReportedDay) = 0 OR CAST( ReportedYear+'-'+ReportedMonth+'-'+ReportedDay as date) > getDate()

DELETE TMP_DELETE_FAMILY_AG_INPUTDATA 
WHERE reportedYearNumber IS NULL OR reportedMonthNumber IS NULL OR reportedDayNumber IS NULL 
OR reportedYearNumber <2002 OR reportedYearNumber>3000 OR reportedMonthNumber < 1 OR reportedMonthNumber > 12 OR reportedDayNumber <1 OR reportedDayNumber > 31
OR ISDATE(ReportedYear+'-'+ReportedMonth+'-'+ReportedDay) = 0 OR CAST( ReportedYear+'-'+ReportedMonth+'-'+ReportedDay as date) > getDate()


--INSERT FILE DATA INTO TABLE
TRUNCATE TABLE ClientTable_NewFamilyAG

INSERT INTO ClientTable_NewFamilyAG (assortmentGroupID, familyID, reportedYear, reportedMonth, reportedDay)
SELECT assortmentGroupID, familyID, reportedYearNumber, reportedMonthNumber, reportedDayNumber
FROM TMP_DELETE_FAMILY_AG_INPUTDATA


if @trace = 0
BEGIN 
	DROP TABLE TMP_DELETE_FAMILY_AG_INPUT
	DROP TABLE TMP_DELETE_FAMILY_AG_INPUTDATA
END

DROP TABLE #DUPLICATE_ROWS


/********************************************/

--Logic starting from 4.5:
SELECT NFA.familyID, NFA.assortmentGroupID, NFA.reportedYear, NFA.reportedMonth, NFA.reportedDay
INTO ##Tmp_DeleteFamilyAG
FROM ClientTable_NewFamilyAG AS NFA
JOIN Symphony_RetailFamilyAgConnection AS RFAC
ON NFA.familyID = RFAC.familyID
WHERE RFAC.assortmentGroupID <> NFA.assortmentGroupID

/********************************************/
-- export process should be here
-- ##Tmp_DeleteFamilyAG
DECLARE 
		 @columnname varchar(100)
		,@getid CURSOR
		,@cmdSql varchar(max)
		,@baseName varchar(200)
		,@outFileName varchar(max)
		,@headerNames dbo.StringList

		,@reportedYear nvarchar(10)
		,@reportedMonth nvarchar(10)
		,@reportedDay nvarchar(10)
		,@reportedDayInto nvarchar(10)
		,@hour nvarchar(10)
		,@Min nvarchar(10)
		,@Sec nvarchar(10)

		select
		@reportedYear = CONVERT(nvarchar(10), YEAR(DATEADD(day, -0, GETDATE())))
		,@reportedMonth = CONVERT(nvarchar(10), MONTH(DATEADD(day, -0, GETDATE())))
		,@reportedDay = CONVERT(nvarchar(10), DAY(DATEADD(day, -0, GETDATE())))
		,@reportedDayInto = CONVERT(nvarchar(10), DAY(DATEADD(day, -0, GETDATE())))
		,@hour = CONVERT(nvarchar(10), DATEPART(hh,GETDATE()))
		,@Min = CONVERT(nvarchar(10), DATEPART(mi,GETDATE()))
		,@Sec = CONVERT(nvarchar(10), DATEPART(ss,GETDATE()))

		
	SET @cmdSql = 'SELECT '
		
	SET @getid = CURSOR FOR
				SELECT
					display_name
				FROM Symphony_FileStructure
				WHERE file_name = 'DELETE_FAMILY_AG' AND participate = 1
				ORDER BY field_position ASC

		OPEN @getid
		FETCH NEXT
		FROM @getid INTO @columnname
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @cmdSql = @cmdSql + 'null as ''' + @columnname + ''','
			FETCH NEXT
			FROM @getid INTO @columnname
		
		END

		CLOSE @getid
		DEALLOCATE @getid
	
		SET	@cmdSql = LEFT(@cmdSql, LEN(@cmdSql) - 1) -- remove last charcter ,
		SET @cmdSql = @cmdSql + ' INTO A_DELETE_FAMILY_AG_Export'

	
		EXEC( @cmdSql)

		TRUNCATE TABLE A_DELETE_FAMILY_AG_Export

		IF COL_LENGTH('A_DELETE_FAMILY_AG_Export', 'Family Name') IS NOT NULL
			ALTER TABLE A_DELETE_FAMILY_AG_Export ALTER COLUMN [Family Name] nvarchar(250)

		IF COL_LENGTH('A_DELETE_FAMILY_AG_Export', 'AG Name') IS NOT NULL
			ALTER TABLE A_DELETE_FAMILY_AG_Export ALTER COLUMN [AG Name] nvarchar(250)

		IF COL_LENGTH('A_DELETE_FAMILY_AG_Export', 'Reported Year') IS NOT NULL
			ALTER TABLE A_DELETE_FAMILY_AG_Export ALTER COLUMN [Reported Year] INT

		IF COL_LENGTH('A_DELETE_FAMILY_AG_Export', 'Reported Month') IS NOT NULL
			ALTER TABLE A_DELETE_FAMILY_AG_Export ALTER COLUMN [Reported Month] INT

		IF COL_LENGTH('A_DELETE_FAMILY_AG_Export', 'Reported Day') IS NOT NULL
			ALTER TABLE A_DELETE_FAMILY_AG_Export ALTER COLUMN [Reported Day] INT

	INSERT INTO  A_DELETE_FAMILY_AG_Export
				([Family Name]
				,[AG Name]
				,[Reported Year]
				,[Reported Month]
				,[Reported Day])
	
		SELECT 
			SF.[name]
			,AG.[name]
			,@reportedYear AS [Reported Year]
			,@reportedMonth AS [Reported Month]
			,@reportedDayInto AS [Reported Day]
		FROM ##Tmp_DeleteFamilyAG DAG
		INNER JOIN [dbo].[Symphony_SkuFamilies] SF
			ON DAG.[familyID] = SF.[id]
		INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] AS RFAC
			ON RFAC.familyID = SF.[id]
		INNER JOIN [dbo].[Symphony_AssortmentGroups] AG
			ON AG.[id] = RFAC.assortmentGroupID


SET @baseName = 'DELETE_FAMILY_AG_update_connections_' + @reportedYear + '_' + @reportedMonth + '_' + @reportedDay + '_' + @hour + '_' + @Min + '_'  + @Sec + '.txt'
SET @outFileName = @outputPath + '\' + @baseName

SELECT display_name,ID=IDENTITY (int, 1, 1)
INTO ##TempHeaderNames
	FROM Symphony_FileStructure 
		WHERE file_name = 'DELETE_FAMILY_AG' AND participate = 1
		ORDER BY field_position ASC

INSERT INTO @headerNames 
SELECT TOP 100 display_name
FROM ##TempHeaderNames

exec ExportDelimitedDataWithHeaders 
	@fileName= @outFileName,
	@sourceTableName = 'A_DELETE_FAMILY_AG_Export', 
	@headers=@headerNames, 
	@columns = @headerNames,
	@separator = @separator

DROP TABLE A_DELETE_FAMILY_AG_Export;
DROP TABLE ##TempHeaderNames;
/********************************************/

	IF @trace = 0
	BEGIN
		IF OBJECT_ID('tempdb..##Tmp_DeleteFamilyAG') IS NOT NULL
		BEGIN
			 DROP TABLE ##Tmp_DeleteFamilyAG
	    END
	END

END


GO
/****** Object:  StoredProcedure [dbo].[Symphony_AddShipmentsLastBatchToFileStructure]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Symphony_AddShipmentsLastBatchToFileStructure]
AS
BEGIN
	
	IF NOT EXISTS (SELECT * FROM dbo.Symphony_FileStructure WHERE file_name = 'SHIPMENT_POLICIES' AND field_name = 'ShipmentsLastBatch')
	BEGIN
		UPDATE FS
		SET FS.field_position = FS.field_position + 1
		FROM dbo.Symphony_FileStructure FS
		CROSS JOIN dbo.Symphony_FileStructure LBR
		WHERE LBR.file_name = 'SHIPMENT_POLICIES'
		AND FS.file_name = 'SHIPMENT_POLICIES'
		AND LBR.field_name = 'ShipmentsMultiplication'
		AND FS.field_position > LBR.field_position

		UPDATE FS
		SET FS.defaultPosition = FS.defaultPosition + 1
		FROM dbo.Symphony_FileStructure FS
		CROSS JOIN dbo.Symphony_FileStructure LBR
		WHERE LBR.file_name = 'SHIPMENT_POLICIES'
		AND FS.file_name = 'SHIPMENT_POLICIES'
		AND LBR.field_name = 'ShipmentsMultiplication'
		AND FS.defaultPosition > LBR.defaultPosition

		INSERT INTO [dbo].[Symphony_FileStructure](file_name,field_name,display_name,field_position,defaultPosition,field_type,participate,default_value,mandatory,groupingName,groupFieldName,groupDisplayName,isDummy,defaultValueField,avoidWhenUpdate,isKeyForInsert,idType,idLicense,symFieldType,stopInputOnError)
		VALUES('SHIPMENT_POLICIES','ShipmentsLastBatch','Shipments Last Batch',4,4,'deny',1,'',0,'','','',0,'',0,0,0,0,7,1);

		UPDATE FS
		SET FS.field_position = LBR.field_position + 1
		FROM dbo.Symphony_FileStructure FS
		CROSS JOIN dbo.Symphony_FileStructure LBR
		WHERE LBR.file_name = 'SHIPMENT_POLICIES'
		AND LBR.field_name = 'ShipmentsMultiplication'
		AND FS.file_name = 'SHIPMENT_POLICIES'
		AND FS.field_name = 'ShipmentsLastBatch'

		UPDATE FS
		SET FS.defaultPosition = LBR.defaultPosition + 1
		FROM dbo.Symphony_FileStructure FS
		CROSS JOIN dbo.Symphony_FileStructure LBR
		WHERE LBR.file_name = 'SHIPMENT_POLICIES'
		AND LBR.field_name = 'ShipmentsMultiplication'
		AND FS.defaultPosition > LBR.defaultPosition
		AND FS.file_name = 'SHIPMENT_POLICIES'
		AND FS.field_name = 'ShipmentsLastBatch'
	END
END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_ChangeCardViewCardsPerRow]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Symphony_ChangeCardViewCardsPerRow]
	 @columnCount int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @sqlVersion INT;
	SELECT @sqlVersion = CONVERT(INT, SUBSTRING(CONVERT(NVARCHAR(128), SERVERPROPERTY('ProductVersion')), 0, CHARINDEX('.', CONVERT(NVARCHAR(128), SERVERPROPERTY('ProductVersion')))))

	IF @sqlVersion >= 13
	BEGIN
		DECLARE @cmd nvarchar(max);
		SELECT @cmd = N'
			WITH candidates AS (
				SELECT id
					,JSON_VALUE(itemState, ''$.model.Pager.SettingsTableLayout.ColumnCount'') columnCount
				FROM [dbo].[Symphony_UserViewItems]
				)
			UPDATE UVI
				SET itemState = JSON_MODIFY(itemState, ''$.model.Pager.SettingsTableLayout.ColumnCount'', @columnCount)
			FROM candidates C
			INNER JOIN [dbo].[Symphony_UserViewItems] UVI ON C.id = UVI.id
			WHERE C.columnCount IS NOT NULL'
		EXEC sp_executesql @cmd, N'@columnCount int', @columnCount = @columnCount
	END
	ELSE
	BEGIN
		DECLARE @path NVARCHAR(100) = N'%"Pager":{"PageIndex":%,"SettingsTableLayout":{"ColumnCount":%'
			,@path2 NVARCHAR(100) = N'%"Pager":{"PageIndex":%,"SettingsTableLayout":{"ColumnCount":%,"RowsPerPage%'
		DECLARE @revPath NVARCHAR(100) = REVERSE(@path)
			,@revPath2 NVARCHAR(100) = REVERSE(@path2)

		UPDATE UVI
		SET itemState = STUFF(itemState, LEN(itemState) - patindex(@revPath, REVERSE(itemState)) + 2, patindex(@revPath, REVERSE(itemState)) - patindex(@revPath2, REVERSE(itemState)) - LEN(',"RowsPerPage'), CONVERT(NVARCHAR(10), @columnCount))
		FROM [dbo].[Symphony_UserViewItems] UVI
		WHERE itemState LIKE @path;
	END
END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_CustomReport_Data]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Symphony_CustomReport_Data]
	 @reportID int
	,@skip int = null
	,@take int = null
	,@select nvarchar(max) = null
	,@where nvarchar(max) = null
	,@orderby nvarchar(max) = null
	,@paramValues nvarchar(max) = null
	,@paramDefinitions nvarchar(max) = null
AS
BEGIN
	
	SET NOCOUNT ON;

	--Get the query text
	DECLARE 			 
		 @sql nvarchar(max)
		,@guid nvarchar(36)
		,@queryText nvarchar(max)
		,@procedure nvarchar(max)
		,@pageRange nvarchar(max)
		,@tableDefinition nvarchar(max);

	DECLARE @columnDefinitions TABLE(
			name nvarchar(128)
		,system_Type_Name nvarchar(128)
	)

	SELECT 			 
		 @guid = 'TMP_' + REPLACE( newid(),'-','')
		,@queryText = RTRIM(LTRIM([query])) FROM [dbo].[Symphony_CustomReports] WHERE [id] = @reportID;

	DECLARE @isProcedure bit = CONVERT(bit, CHARINDEX('EXEC', @queryText));

	--Create Tmp table with uniqueId field
	--The uniqueId field is necessary for the grid view
	--Note: The custom report definition should be modified add a mandatory order by clause

	--Get column definitions
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF @isProcedure = 1 BEGIN
		SELECT @procedure = LTRIM(SUBSTRING(@queryText, CHARINDEX(' ', @queryText), LEN(@queryText)));
		IF (CHARINDEX(' ', @procedure) > 0)
			SELECT @procedure = LEFT(@procedure, CHARINDEX(' ', @procedure) - 1)
		INSERT INTO @columnDefinitions
			SELECT QUOTENAME(name,'[') [name], [system_type_name] FROM sys.dm_exec_describe_first_result_set_for_object(OBJECT_ID(@procedure), null);
	END
	ELSE BEGIN

		INSERT INTO @columnDefinitions
			SELECT QUOTENAME(name,'[') [name], [system_type_name] FROM sys.dm_exec_describe_first_result_set(@queryText,NULL,NULL);
	END
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- Create tmp table
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT
		@tableDefinition = CASE 
			WHEN @tableDefinition IS NULL THEN 'uniqueId int IDENTITY(1, 1), ' + [name] + ' ' + [system_type_name]
			ELSE @tableDefinition + ', ' + [name] + ' ' + [system_type_name]
		END
	FROM(
		SELECT [name], [system_type_name]
		FROM @columnDefinitions
	) tmp

	SELECT 
			@tableDefinition = @tableDefinition + ', CONSTRAINT PK_' + @guid + ' PRIMARY KEY CLUSTERED  (uniqueId)'
		,@sql = '	CREATE TABLE ' + @guid + '(' + @tableDefinition + ')';

	EXEC (@sql);
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	IF @isProcedure = 1 BEGIN
		SELECT @sql = 'INSERT INTO ' + @guid + ' EXEC ' + @procedure;
		EXEC (@sql);

		SELECT @queryText = 'SELECT * FROM ' + @guid + ' ' + + ISNULL(@where, '');
	END
	ELSE BEGIN
		SELECT @sql = 'INSERT  INTO ' + @guid + ' SELECT * FROM (' + @queryText +  ') TMP ' + ISNULL(@where, '') ;

		IF @paramDefinitions IS NOT NULL AND @paramValues IS NOT NULL
			SELECT @sql = 'sp_executesql N''' + REPLACE( @sql,'''','''''') + ''', N''' + @paramDefinitions + ''', ' + @paramValues
		EXEC (@sql);

		SELECT @queryText = 'SELECT * FROM ' + @guid;
	END

	IF @skip + @take IS  NULL
		SELECT @sql = ISNULL(@select, 'SELECT * ') + ' FROM (' + @queryText + ') TMP ' + ISNULL(@orderby, 'ORDER BY uniqueId')
	ELSE
		SELECT @sql = ISNULL(@select, 'SELECT * ') + ' FROM (' + @queryText + ') TMP ' + ISNULL(@orderby, 'ORDER BY uniqueId') + ' OFFSET ' + CONVERT(nvarchar(10), @skip) + ' ROWS FETCH NEXT ' + CONVERT(nvarchar(10), @take) + ' ROWS ONLY';

	IF @isProcedure = 1 AND @paramDefinitions IS NOT NULL AND @paramValues IS NOT NULL
		SELECT @sql = 'sp_executesql N''' +  @sql + ''', N''' + @paramDefinitions + ''',' + @paramValues 

	EXEC (@sql);

	IF OBJECT_ID(@guid) IS NOT NULL BEGIN
		SELECT @sql = 'DROP TABLE ' + @guid;
		EXEC (@sql);
	END

END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_CustomReport_DataTable]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Symphony_CustomReport_DataTable]
	@reportID int
AS
BEGIN
	
	SET NOCOUNT ON;

	--Get the query text
	DECLARE @queryText nvarchar(max);
	SELECT @queryText = RTRIM(LTRIM([query])) FROM [dbo].[Symphony_CustomReports] WHERE [id] = @reportID

	--Differentiate between queries and procedures
	DECLARE 
		 @guid nvarchar(36)
		,@sql nvarchar(max)

	DECLARE @columnDefinitions TABLE(
		 name nvarchar(128)
		,system_Type_Name nvarchar(128)
	)

	SELECT @guid = 'TMP_' + REPLACE( newid(),'-','');

	IF CHARINDEX('EXEC', @queryText) = 1 BEGIN
		DECLARE @procedure nvarchar(max);
		-- LTRIM MAY NOT WORK HERE, USER SHOULD NOT INSERT MORE THAN 1 SPACE BETWEEN EXEC AND THE PROCEDURE NAME
		SELECT @procedure = LTRIM(SUBSTRING(@queryText, CHARINDEX(' ', @queryText), LEN(@queryText)));
		IF (CHARINDEX(' ', @procedure) > 0)
			SELECT @procedure = LEFT(@procedure, CHARINDEX(' ', @procedure) - 1)
		INSERT INTO @columnDefinitions
			SELECT QUOTENAME(name,'[') [name], [system_type_name] FROM sys.dm_exec_describe_first_result_set_for_object(OBJECT_ID(@procedure), null);
	END
	ELSE BEGIN
		INSERT INTO @columnDefinitions
			SELECT QUOTENAME(name,'[') [name], [system_type_name] FROM sys.dm_exec_describe_first_result_set(@queryText,NULL,NULL);
	END

	EXEC (@sql);

	DECLARE 
	 @tableDefinition nvarchar(max)
	,@separator nvarchar(1) = ','
	
	SELECT
		@tableDefinition = CASE 
			WHEN @tableDefinition IS NULL THEN [name] + ' ' + [system_type_name]
			ELSE @tableDefinition + @separator + [name] + ' ' + [system_type_name]
		END
	FROM(
		SELECT [name], [system_type_name]
		FROM @columnDefinitions
	) tmp

	SELECT @sql = '	CREATE TABLE ' + @guid + '(' + @tableDefinition + ')';
	EXEC (@sql);

	SELECT @sql = '	SELECT * FROM ' + @guid;
	EXEC (@sql);

	SELECT @sql = 'DROP TABLE ' + @guid;
	EXEC (@sql);

END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_CustomReport_RowCount]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Symphony_CustomReport_RowCount]
	 @reportID int
	,@where nvarchar(max) = null
	,@paramValues nvarchar(max) = null
	,@paramDefinitions nvarchar(max) = null
AS
BEGIN
	
	SET NOCOUNT ON;

	--Get the query text
	DECLARE 			 
		 @sql nvarchar(max)
		,@queryText nvarchar(max);

	SELECT @queryText = RTRIM(LTRIM([query])) FROM [dbo].[Symphony_CustomReports] WHERE [id] = @reportID

	IF @queryText IS NULL BEGIN
		SELECT 0;
		RETURN 1;
	END

	--Differentiate between queries and procedures
	IF CHARINDEX('EXEC', @queryText) = 1 BEGIN

		DECLARE 
			 @guid nvarchar(36)
			,@procedure nvarchar(max)
			,@tableDefinition nvarchar(max)

		DECLARE @columnDefinitions TABLE(
			 name nvarchar(128)
			,system_Type_Name nvarchar(128)
		)
		-- LTRIM MAY NOT WORK HERE, USER SHOULD NOT INSERT MORE THAN 1 SPACE BETWEEN EXEC AND THE PROCEDURE NAME
		SELECT 
			 @guid = 'TMP_' + REPLACE( newid(),'-','')
			,@procedure = LTRIM(SUBSTRING(@queryText, CHARINDEX(' ', @queryText), LEN(@queryText)));
			IF (CHARINDEX(' ', @procedure) > 0)
				SELECT @procedure = LEFT(@procedure, CHARINDEX(' ', @procedure) - 1)
			INSERT INTO @columnDefinitions
				SELECT QUOTENAME(name,'[') [name], [system_type_name] FROM sys.dm_exec_describe_first_result_set_for_object(OBJECT_ID(@procedure), null);

		SELECT
			@tableDefinition = CASE 
				--WHEN @tableDefinition IS NULL THEN 'uniqueId int IDENTITY(1, 1), ' + [name] + ' ' + [system_type_name]
				WHEN @tableDefinition IS NULL THEN [name] + ' ' + [system_type_name]
				ELSE @tableDefinition + ', ' + [name] + ' ' + [system_type_name]
			END
		FROM(
			SELECT [name], [system_type_name]
			FROM @columnDefinitions
		) tmp

		SELECT 
			 --@tableDefinition = @tableDefinition + ', CONSTRAINT PK_' + @guid + ' PRIMARY KEY CLUSTERED  (uniqueId)'
			 @sql = '	CREATE TABLE ' + @guid + '(' + @tableDefinition + ')';

		EXEC (@sql);

		SELECT @sql = 'INSERT INTO ' + @guid + ' EXEC ' + @procedure;
		EXEC (@sql);

		SELECT @sql = 'SELECT COUNT(1) FROM ' + @guid + ' ' + ISNULL(@where, '');

		IF @paramDefinitions IS NOT NULL AND @paramValues IS NOT NULL
			SELECT @sql = 'sp_executesql N''' + @sql + ''', N''' + @paramDefinitions + ''',' + @paramValues 

		EXEC (@sql);

		SELECT @sql = 'DROP TABLE ' + @guid;
		EXEC (@sql);

	END
	ELSE BEGIN

		SELECT @sql = 'SELECT COUNT(1) FROM (' + @queryText  + ') TMP' + ' ' + ISNULL(@where, '');

		IF @paramDefinitions IS NOT NULL AND @paramValues IS NOT NULL 
			SELECT @sql = 'sp_executesql N''' + REPLACE( @sql,'''','''''') + ''', N''' + @paramDefinitions + ''',' + @paramValues 
	
		EXEC (@sql);
	END
END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_CustomReport_SQLColumns]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Symphony_CustomReport_SQLColumns]
	@reportID int
AS
BEGIN
	
	SET NOCOUNT ON;

	--Get the query text
	DECLARE @queryText nvarchar(max);
	SELECT @queryText = RTRIM(LTRIM([query])) FROM [dbo].[Symphony_CustomReports] WHERE [id] = @reportID

	--Differentiate between queries and procedures
	IF CHARINDEX('EXEC', @queryText) = 1 BEGIN
		DECLARE @procedure nvarchar(max);
		SELECT @procedure = LTRIM(SUBSTRING(@queryText, CHARINDEX(' ', @queryText), LEN(@queryText)))
		SELECT QUOTENAME(name,'[') [name], system_type_name [type] FROM sys.dm_exec_describe_first_result_set_for_object(OBJECT_ID(@procedure), null);
	END
	ELSE BEGIN
		SELECT QUOTENAME(name,'[') [name], system_type_name [type] FROM sys.dm_exec_describe_first_result_set(@queryText,NULL,NULL);
	END

END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_CustomReport_Summary]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Symphony_CustomReport_Summary]
	 @reportID int
	,@operation nvarchar(max) = null
	,@columnName nvarchar(max) = null
	,@where nvarchar(max) = null
	,@paramValues nvarchar(max) = null
	,@paramDefinitions nvarchar(max) = null
AS
BEGIN
	
	SET NOCOUNT ON;

	

	--Get the query text
	DECLARE 			 
		 @sql nvarchar(max)
		,@guid nvarchar(36)
		,@queryText nvarchar(max)
		,@procedure nvarchar(max)
		,@pageRange nvarchar(max)
		,@tableDefinition nvarchar(max);

	DECLARE @columnDefinitions TABLE(
			name nvarchar(128)
		,system_Type_Name nvarchar(128)
	)

	SELECT 			 
		 @guid = 'TMP_' + REPLACE( newid(),'-','')
		,@queryText = RTRIM(LTRIM([query])) FROM [dbo].[Symphony_CustomReports] WHERE [id] = @reportID;

	DECLARE @isProcedure bit = CONVERT(bit, CHARINDEX('EXEC', @queryText));

	--Create Tmp table with uniqueId field
	--The uniqueId field is necessary for the grid view
	--Note: The custom report definition should be modified add a mandatory order by clause

	--Get column definitions
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF @isProcedure = 1 BEGIN
		SELECT @procedure = LTRIM(SUBSTRING(@queryText, CHARINDEX(' ', @queryText), LEN(@queryText)));
		IF (CHARINDEX(' ', @procedure) > 0)
			SELECT @procedure = LEFT(@procedure, CHARINDEX(' ', @procedure) - 1)
		INSERT INTO @columnDefinitions
			SELECT QUOTENAME(name,'[') [name], [system_type_name] FROM sys.dm_exec_describe_first_result_set_for_object(OBJECT_ID(@procedure), null);
	END
	ELSE BEGIN

		INSERT INTO @columnDefinitions
			SELECT QUOTENAME(name,'[') [name], [system_type_name] FROM sys.dm_exec_describe_first_result_set(@queryText,NULL,NULL);
	END
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- Create tmp table
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT
		@tableDefinition = CASE 
			WHEN @tableDefinition IS NULL THEN 'uniqueId int IDENTITY(1, 1), ' + [name] + ' ' + [system_type_name]
			ELSE @tableDefinition + ', ' + [name] + ' ' + [system_type_name]
		END
	FROM(
		SELECT [name], [system_type_name]
		FROM @columnDefinitions
	) tmp

	SELECT 
			@tableDefinition = @tableDefinition + ', CONSTRAINT PK_' + @guid + ' PRIMARY KEY CLUSTERED  (uniqueId)'
		,@sql = '	CREATE TABLE ' + @guid + '(' + @tableDefinition + ')';

	EXEC (@sql);
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	IF @isProcedure = 1 BEGIN
		SELECT @sql = 'INSERT INTO ' + @guid + ' EXEC ' + @procedure;
		EXEC (@sql);

		SELECT @queryText = 'SELECT * FROM ' + @guid + ' ' + + ISNULL(@where, '');
	END
	ELSE BEGIN
		SELECT @sql = 'INSERT  INTO ' + @guid + ' SELECT * FROM (' + @queryText +  ') TMP ' + ISNULL(@where, '') ;

		IF @paramDefinitions IS NOT NULL AND @paramValues IS NOT NULL
			SELECT @sql = 'sp_executesql N''' + REPLACE( @sql,'''','''''') + ''', N''' + @paramDefinitions + ''', ' + @paramValues
		EXEC (@sql);

		SELECT @queryText = 'SELECT * FROM ' + @guid;
	END
	IF @operation = 'AVG'	BEGIN

		DECLARE @scale int
		DECLARE @cmd nvarchar(max) =
		N'SELECT @scale = CASE WHEN COL.system_type_id IN (48, 52, 56, 127) THEN 2 ELSE NULL END
		FROM sys.columns COL
		INNER JOIN sys.tables TBL
			ON TBL.object_id = COL.object_id
		WHERE TBL.NAME = ''' + @guid + '''
			AND COL.NAME = ''' + @columnName + ''''


		EXEC sp_executesql @cmd
			,N'@scale int OUTPUT'
			,@scale = @scale OUTPUT

		SELECT @columnName = QUOTENAME(@columnName);

		IF @scale IS NULL
			SELECT @sql =  'SELECT ' + @operation + '(' + @columnName + ')' + ' FROM (' + @queryText + ') TMP '
		ELSE
			SELECT @sql =  'SELECT ' + @operation + '(CONVERT(decimal(18, ' + CONVERT(nvarchar(10),@scale) + '),' + @columnName + '))' + ' FROM (' + @queryText + ') TMP '
	END
	ELSE BEGIN
		SELECT @sql =  'SELECT ' + @operation + '(' + @columnName + ')' + ' FROM (' + @queryText + ') TMP '
	END

	IF @isProcedure = 1 AND @paramDefinitions IS NOT NULL AND @paramValues IS NOT NULL
		SELECT @sql = 'sp_executesql N''' +  @sql + ''', N''' + @paramDefinitions + ''',' + @paramValues 

	EXEC (@sql);

	IF OBJECT_ID(@guid) IS NOT NULL BEGIN
		SELECT @sql = 'DROP TABLE ' + @guid;
		EXEC (@sql);
	END

END


GO
/****** Object:  StoredProcedure [dbo].[Symphony_ExpandStoreClosures]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Symphony_ExpandStoreClosures]
		 @fromDate date
		,@toDate date
AS
BEGIN
	SET NOCOUNT ON;

	IF @fromDate >= @toDate
		return;

	TRUNCATE TABLE [dbo].[Symphony_StoreClosuresExpanded];
	WITH stockLocations AS(
		SELECT DISTINCT 
			[stockLocationID]
		FROM [dbo].[Symphony_StoreClosures]
	)
	INSERT INTO [dbo].[Symphony_StoreClosuresExpanded](stockLocationID, updateDate, isClosed)
	SELECT 
		 SL.stockLocationID
		,DT.date 
		,CONVERT(bit, ISNULL( SC.stockLocationID + 5, 0)) [isClosed]
	FROM stockLocations SL
	CROSS JOIN [dbo].[Symphony_DatesTable](@fromDate, @toDate) DT
	INNER JOIN [dbo].[Symphony_StoreClosures] SC
	ON SC.stockLocationID = SL.stockLocationID
	AND DT.date >= SC.closingDate AND DT.date < ISNULL(SC.openingDate, DATEADD(DAY,1,DT.date))
END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_FillAuxFamilyDiscounts]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Symphony_FillAuxFamilyDiscounts]
	@calculationDate date = null,
	@defaultCoverageValue int = 180
AS
BEGIN
	SET NOCOUNT ON;

	--=========================================================================================================
	-- [dbo].[Symphony_Aux_LocationFamilyInventory]
	--=========================================================================================================
	IF EXISTS (SELECT 1 FROM sys.objects 
	WHERE object_id = OBJECT_ID(N'[dbo].[Symphony_Aux_LocationFamilyInventory]') AND type in (N'U'))
		DROP TABLE [dbo].[Symphony_Aux_LocationFamilyInventory]

		SELECT MSKU.[familyID]
			,SL.[stockLocationID]
			,SL.[stockLocationType]
			,SLS.[inventoryAtSite] + SLS.[inventoryAtTransit] [inventory]
		INTO [dbo].[Symphony_Aux_LocationFamilyInventory]
		FROM [dbo].[Symphony_StockLocationSkus] SLS
		INNER JOIN [dbo].[Symphony_StockLocations] SL
			ON SL.stockLocationID = SLS.stockLocationID
		INNER JOIN [dbo].[Symphony_MasterSkus] MSKU
			ON MSKU.skuID = SLS.skuID
		WHERE SL.isDeleted = 0
		AND SLS.isDeleted = 0
		AND SL.stockLocationType IN (3, 5) 
	--=========================================================================================================
	-- [dbo].[Symphony_FillFamilyInventory]
	--=========================================================================================================
		IF EXISTS (SELECT 1 FROM sys.objects
		WHERE object_id = OBJECT_ID(N'[dbo].[Symphony_Aux_FamilyInventory]') AND type in (N'U'))
			DROP TABLE [dbo].[Symphony_Aux_FamilyInventory]

		SELECT 
			LFI.[familyID]
			--Count distinct stores - COUNT doesn't count NULL
			,COUNT(DISTINCT CASE WHEN [stockLocationType] = 3 AND [inventory] > 0 THEN [stockLocationID] ELSE NULL END) [storeCount]
			--Multiply inventory by 0 to exclude the inventory by stockLocationType. 3/5 = 0
			,SUM([inventory]) [totalInventory]
			,SUM(([stockLocationType]/5) * [inventory]) [totalInventoryWarehouses]
			,MAX(CASE [stockLocationType] WHEN 5 THEN [stockLocationID] ELSE NULL END) [warehouseID]
			,MAX(FAG.assortmentGroupID) [assortmentGroupID]
		INTO [dbo].[Symphony_Aux_FamilyInventory]
		FROM [dbo].[Symphony_Aux_LocationFamilyInventory] LFI
		INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG
		ON FAG.familyID = LFI.familyID
		GROUP BY LFI.[familyID]
	--=========================================================================================================
	-- [dbo].[Symphony_FillParticipatingFamilies]
	--=========================================================================================================
	IF EXISTS (SELECT 1 FROM sys.objects 
	WHERE object_id = OBJECT_ID(N'[dbo].[Symphony_Aux_ParticipatingFamilies]') AND type in (N'U'))
		DROP TABLE [dbo].[Symphony_Aux_ParticipatingFamilies]

	SELECT [familyID]
			,[storeCount]
			,[totalInventory]
			,[totalInventory] - [totalInventoryWarehouses] [totalInventoryStores]
			,[totalInventoryWarehouses]
			,[warehouseID]
			,[assortmentGroupID]
		INTO [dbo].[Symphony_Aux_ParticipatingFamilies]
		FROM [dbo].[Symphony_Aux_FamilyInventory] FI
		WHERE FI.totalInventory > 0
	--=========================================================================================================
	-- [dbo].[Symphony_Aux_FamilyDiscounts]
	--=========================================================================================================

	TRUNCATE TABLE [dbo].[Symphony_Aux_FamilyDiscounts];

	WITH familyTree AS (
		SELECT DISTINCT PF.[familyID]
			,SF.NAME [familyName]
			,PF.[assortmentGroupID]
			,AGDG.[displayGroupID]
			,AG.NAME [assortmentGroupName]
			,DG.NAME [displayGroupName]
		FROM [dbo].[Symphony_Aux_ParticipatingFamilies] PF
		INNER JOIN [dbo].[Symphony_SkuFamilies] SF
			ON SF.id = PF.familyID
		INNER JOIN [dbo].[Symphony_AssortmentGroups] AG
			ON AG.id = PF.assortmentGroupID
		LEFT JOIN [dbo].[Symphony_RetailAgDgConnection] AGDG
			ON AGDG.assortmentGroupID = PF.assortmentGroupID
		LEFT JOIN [dbo].[Symphony_DisplayGroups] DG
			ON DG.id = AGDG.displayGroupID
	)
	INSERT INTO [dbo].[Symphony_Aux_FamilyDiscounts] (
		 familyID
		,totalInventory
		,totalInventoryStores
		,totalInventoryWarehouses
		,storeCount
		,familyName
		,assortmentGroupID
		,displayGroupID
		,assortmentGroupName
		,displayGroupName
		)
		SELECT PF.familyID
		,PF.totalInventory
		,PF.totalInventoryStores
		,PF.totalInventoryWarehouses
		,PF.storeCount 
		,FT.familyName
		,FT.assortmentGroupID
		,FT.displayGroupID
		,FT.assortmentGroupName
		,FT.displayGroupName
		FROM [dbo].[Symphony_Aux_ParticipatingFamilies] PF
	INNER JOIN familyTree FT
	ON FT.familyID = PF.familyID


	UPDATE FD 
		SET unitPrice = TMP.unitPrice
			,throughput = TMP.throughput
			,custom_num1 = TMP.custom_num1
			,custom_num2 = TMP.custom_num2
			,custom_num3 = TMP.custom_num3
			,custom_num4 = TMP.custom_num4
			,custom_num5 = TMP.custom_num5
			,custom_num6 = TMP.custom_num6
			,custom_num7 = TMP.custom_num7
			,custom_num8 = TMP.custom_num8
			,custom_num9 = TMP.custom_num9
			,custom_num10 = TMP.custom_num10
			,custom_txt1 = TMP.custom_txt1
			,custom_txt2 = TMP.custom_txt2
			,custom_txt3 = TMP.custom_txt3
			,custom_txt4 = TMP.custom_txt4
			,custom_txt5 = TMP.custom_txt5
			,custom_txt6 = TMP.custom_txt6
			,custom_txt7 = TMP.custom_txt7
			,custom_txt8 = TMP.custom_txt8
			,custom_txt9 = TMP.custom_txt9
			,custom_txt10 = TMP.custom_txt10
			,skuPropertyID1 = TMP.skuPropertyID1
			,skuPropertyID2 = TMP.skuPropertyID2
			,skuPropertyID3 = TMP.skuPropertyID3
			,skuPropertyID4 = TMP.skuPropertyID4
			,skuPropertyID5 = TMP.skuPropertyID5
			,skuPropertyID6 = TMP.skuPropertyID6
			,skuPropertyID7 = TMP.skuPropertyID7
		FROM [Symphony_Aux_FamilyDiscounts] FD
		INNER JOIN (
		SELECT MSKU.familyID
			,MAX(MSKU.unitPrice) unitPrice
			,MAX(MSKU.throughput) throughput
			,MAX(MSKU.custom_num1) custom_num1
			,MAX(MSKU.custom_num2) custom_num2
			,MAX(MSKU.custom_num3) custom_num3
			,MAX(MSKU.custom_num4) custom_num4
			,MAX(MSKU.custom_num5) custom_num5
			,MAX(MSKU.custom_num6) custom_num6
			,MAX(MSKU.custom_num7) custom_num7
			,MAX(MSKU.custom_num8) custom_num8
			,MAX(MSKU.custom_num9) custom_num9
			,MAX(MSKU.custom_num10) custom_num10
			,MAX(MSKU.custom_txt1) custom_txt1
			,MAX(MSKU.custom_txt2) custom_txt2
			,MAX(MSKU.custom_txt3) custom_txt3
			,MAX(MSKU.custom_txt4) custom_txt4
			,MAX(MSKU.custom_txt5) custom_txt5
			,MAX(MSKU.custom_txt6) custom_txt6
			,MAX(MSKU.custom_txt7) custom_txt7
			,MAX(MSKU.custom_txt8) custom_txt8
			,MAX(MSKU.custom_txt9) custom_txt9
			,MAX(MSKU.custom_txt10) custom_txt10
			,MAX(MSKU.skuPropertyID1) skuPropertyID1
			,MAX(MSKU.skuPropertyID2) skuPropertyID2
			,MAX(MSKU.skuPropertyID3) skuPropertyID3
			,MAX(MSKU.skuPropertyID4) skuPropertyID4
			,MAX(MSKU.skuPropertyID5) skuPropertyID5
			,MAX(MSKU.skuPropertyID6) skuPropertyID6
			,MAX(MSKU.skuPropertyID7) skuPropertyID7
		FROM [dbo].[Symphony_Aux_ParticipatingFamilies] PF
			INNER JOIN [dbo].[Symphony_MasterSkus] MSKU ON MSKU.familyID = PF.familyID
		GROUP BY MSKU.familyID
			) TMP ON TMP.familyID = FD.familyID

	UPDATE FD
		SET [totalConsumption] = TMP.[totalConsumption]
		FROM [dbo].[Symphony_Aux_FamilyDiscounts] FD
		INNER JOIN (		
	SELECT PF.familyID
				,SUM(ISNULL(STC.[consumption], 0)) [totalConsumption]
	FROM [dbo].[Symphony_Aux_ParticipatingFamilies] PF
			INNER JOIN [Symphony_MasterSkus] MSKU
				ON MSKU.familyID = PF.familyID
			LEFT JOIN  [dbo].[Symphony_SkusTotalConsumption] STC
				ON STC.skuID = MSKU.skuID
			GROUP BY PF.familyID	
		)TMP
			ON TMP.familyID = FD.familyID

	 ;WITH storeSalesRates AS(
			SELECT
				 SRF.familyID
				,SRF.saleRate			
			FROM [dbo].[Symphony_SalesRateFamily] SRF
			INNER JOIN [dbo].[Symphony_StockLocations] SL
				ON SL.stockLocationID = SRF.stockLocationID
			WHERE SL.isDeleted = 0
				AND SL.stockLocationType = 3
		)
		, totals AS(
			SELECT PF.familyID
			,SUM(SSR.saleRate) familySalesRate
			,7 * SUM(SSR.saleRate) weeklyFamilySalesRate
		FROM [dbo].[Symphony_Aux_FamilyDiscounts] AFD
		INNER JOIN [dbo].[Symphony_Aux_ParticipatingFamilies] PF
			ON PF.familyID = AFD.familyID
		INNER JOIN storeSalesRates SSR
			ON SSR.familyID = PF.familyID
		GROUP BY PF.familyID
		)

		UPDATE AFD
			SET AFD.[weeklyFamilySalesRate] =  T.weeklyFamilySalesRate
			,AFD.[coverage] = CASE WHEN ISNULL(T.weeklyFamilySalesRate, 0) = 0 THEN @defaultCoverageValue ELSE PF.totalInventory/T.weeklyFamilySalesRate END
			,AFD.[percentSalesRateChange] = CASE 
				WHEN FDH.salesRate = 0 THEN NULL
				WHEN FDH.salesRate IS NULL THEN NULL 
				ELSE (T.familySalesRate - FDH.salesRate)/FDH.salesRate 
			END

		FROM [dbo].[Symphony_Aux_FamilyDiscounts] AFD
		INNER JOIN [dbo].[Symphony_Aux_ParticipatingFamilies] PF
			ON PF.familyID = AFD.familyID
		INNER JOIN totals T
			ON T.familyID = PF.familyID
		LEFT JOIN [dbo].[Symphony_FamilyDiscounts] FD
			ON FD.familyID = PF.familyID
		LEFT JOIN [dbo].[Symphony_FamilyDiscountsHistory] FDH
			ON FDH.familyID = FD.familyID
			AND FDH.updateDate = FD.updateDate 

	UPDATE FD
		SET  [assortmentGroupHBT] = HBT.HBTSegmentID_AG
		FROM [dbo].[Symphony_Aux_FamilyDiscounts] FD
		INNER JOIN [dbo].[Symphony_Aux_ParticipatingFamilies] PF
		ON PF.familyID = FD.familyID
		LEFT JOIN [dbo].[Symphony_HBTGradation] HBT
		ON HBT.familyID = PF.familyID
		AND HBT.assortmentGroupID = PF.assortmentGroupID

	UPDATE FD
		SET  percentValidity = CASE WHEN TMP.[storeCount] IS NULL THEN NULL 
			WHEN TMP.[storeCount] = 0 THEN NULL
			ELSE CONVERT(decimal,TMP.[validStoreCount])/TMP.[storeCount] * 100 
END

		FROM [dbo].[Symphony_Aux_FamilyDiscounts] FD
		INNER JOIN (		
			SELECT PF.familyID
				,COUNT(TMP.stockLocationID) [storeCount]
				,COUNT(CASE 	WHEN TMP.isValid = 1 OR (	TMP.isValid = 0 AND TMP.isInvalidOverThreshold = 0	) THEN TMP.[stockLocationID]	ELSE NULL	END) [validStoreCount]
			FROM [dbo].[Symphony_Aux_ParticipatingFamilies] PF
			LEFT JOIN (
				SELECT FVR.stockLocationID
					,FVR.isValid
					,FVR.isInvalidOverThreshold
					,FVR.familyID
					,FVR.assortmentGroupID
				FROM [dbo].[Symphony_FamilyValidationResults] FVR
				INNER JOIN [dbo].[Symphony_StockLocations] SL
					ON SL.stockLocationID = FVR.stockLocationID
						AND SL.stockLocationType = 3
				) TMP
			ON TMP.familyID = PF.familyID
				AND TMP.assortmentGroupID = PF.assortmentGroupID
			GROUP BY PF.familyID
		)TMP
			ON TMP.familyID = FD.familyID

		UPDATE FD
			SET [daysSinceIntroduction]  = DATEDIFF(day, TMP.startDate, ISNULL( @calculationDate,GETDATE()))
		FROM [dbo].[Symphony_Aux_FamilyDiscounts] FD
		INNER JOIN (		
			SELECT 
				 PF.familyID
				,CONVERT(date, MIN(startDate)) startDate
			FROM [dbo].[Symphony_Aux_ParticipatingFamilies] PF
			LEFT JOIN [dbo].[Symphony_RetailFamilyStockLocations] RFS
			ON RFS.familyID = PF.familyID
			GROUP BY PF.familyID
		)TMP
			ON TMP.familyID = FD.familyID
END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_RemoveShipmentsLastBatchFromFileStructure]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Symphony_RemoveShipmentsLastBatchFromFileStructure]
AS
BEGIN
	IF EXISTS (SELECT * FROM dbo.Symphony_FileStructure WHERE file_name = 'SHIPMENT_POLICIES' AND field_name = 'ShipmentsLastBatch')
	BEGIN
		UPDATE FS
		SET FS.field_position = FS.field_position - 1
		FROM dbo.Symphony_FileStructure FS
		CROSS JOIN dbo.Symphony_FileStructure LBR
		WHERE LBR.file_name = 'SHIPMENT_POLICIES'
		AND FS.file_name = 'SHIPMENT_POLICIES'
		AND LBR.field_name = 'ShipmentsLastBatch'
		AND FS.field_position > LBR.field_position

		UPDATE FS
		SET FS.defaultPosition = FS.defaultPosition - 1
		FROM dbo.Symphony_FileStructure FS
		CROSS JOIN dbo.Symphony_FileStructure LBR
		WHERE LBR.file_name = 'SHIPMENT_POLICIES'
		AND FS.file_name = 'SHIPMENT_POLICIES'
		AND LBR.field_name = 'ShipmentsLastBatch'
		AND FS.defaultPosition > LBR.defaultPosition

		DELETE dbo.Symphony_FileStructure
		WHERE file_name = 'SHIPMENT_POLICIES'
		AND field_name = 'ShipmentsLastBatch'
	END
END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_SetShipmentAllowOverAllocation]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Symphony_SetShipmentAllowOverAllocation]
	 @allowOverAllocation nvarchar(200)
AS
BEGIN
	IF @allowOverAllocation <> 'true' AND @allowOverAllocation <> 'false'
	BEGIN
		PRINT N'@allowOverAllocation must be true or false'
		RETURN
	END

	-- allow over allocation only if policyMode is origin
	DECLARE @policyMode nvarchar(20);
	SELECT @policyMode = flag_value
	FROM [dbo].[Symphony_Globals]
	WHERE flag_name = 'shippingPolicy.policyMode';

	IF @allowOverAllocation = 'true' AND @policyMode <> 'Origin'
	BEGIN
		PRINT N'Operation failed: Over allocation is allowed only when Policy Mode is Origin';
		return;
	END

	UPDATE [dbo].[Symphony_Globals]
	SET flag_value = @allowOverAllocation
	WHERE flag_name = 'shippingPolicy.allowOverAllocation'

	IF @allowOverAllocation = 'true'
		EXEC [dbo].[Symphony_AddShipmentsLastBatchToFileStructure]
	ELSE
		EXEC [dbo].[Symphony_RemoveShipmentsLastBatchFromFileStructure]

END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_spCopyExistingPurchasingOrders]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Symphony_spCopyExistingPurchasingOrders]
AS
BEGIN

	TRUNCATE TABLE Symphony_PurchasingOrderPrev
	INSERT INTO [dbo].[Symphony_PurchasingOrderPrev] (
		ID
		,stockLocationID
		,skuID
		,skuDescription
		,quantity
		,orderID
		,clientOrderID
		,supplierID
		,bufferSize
		,isToOrder
		,orderPrice
		,orderDate
		,promisedDueDate
		,bufferPenetration
		,bufferColor
		,inputSuspicion
		,virtualStockLevel
		,bufferDueDate
		,considered
		,newRedBlack
		,calculateDueDate
		,oldBufferColor
		,neededDate
		,isShipped
		,supplierSkuName
		,note
		,needsMatch
		,purchasingPropertyID1
		,purchasingPropertyID2
		,purchasingPropertyID3
		,purchasingPropertyID4
		,purchasingPropertyID5
		,purchasingPropertyID6
		,purchasingPropertyID7
		,isISTOrder
		)
	SELECT ID
		,stockLocationID
		,skuID
		,skuDescription
		,quantity
		,orderID
		,clientOrderID
		,supplierID
		,bufferSize
		,isToOrder
		,orderPrice
		,orderDate
		,promisedDueDate
		,bufferPenetration
		,bufferColor
		,inputSuspicion
		,virtualStockLevel
		,bufferDueDate
		,considered
		,newRedBlack
		,calculateDueDate
		,oldBufferColor
		,neededDate
		,isShipped
		,supplierSkuName
		,note
		,needsMatch
		,purchasingPropertyID1
		,purchasingPropertyID2
		,purchasingPropertyID3
		,purchasingPropertyID4
		,purchasingPropertyID5
		,purchasingPropertyID6
		,purchasingPropertyID7
		,isISTOrder
	FROM [dbo].[Symphony_PurchasingOrder]
END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_spFillSkusTotalConsumptionFromHistory]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Symphony_spFillSkusTotalConsumptionFromHistory]
AS
BEGIN
	SET NOCOUNT ON;

	TRUNCATE TABLE [dbo].[Symphony_SkusTotalConsumption]
	TRUNCATE TABLE [dbo].[Symphony_SkusTotalConsumptionTemp]

	INSERT INTO [dbo].[Symphony_SkusTotalConsumption] (skuId, consumption)
	SELECT 
	   SLSH.skuID, 
	   SUM(SLSH.[consumption]) consumption
	FROM 
	   [dbo].[Symphony_StockLocationSkuHistory] SLSH
	   INNER JOIN [dbo].[Symphony_StockLocations] SL ON SL.stockLocationID = SLSH.stockLocationID
	WHERE 
	   SL.[stockLocationType] = 3  
	GROUP BY SLSH.skuID	 
END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_spGenerateReducedRules]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Symphony_spGenerateReducedRules]
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE [dbo].[Symphony_familyTreeReducedRules];
	  TRUNCATE TABLE [dbo].[Symphony_familyTreeReducedRulesPrepare];

    INSERT INTO [dbo].[Symphony_familyTreeReducedRules]
       SELECT 
            FAG.[familyID]
           ,FAG.[assortmentGroupID]
           ,AGDG.[displayGroupID]
           ,NULL
       FROM [dbo].[Symphony_SkuFamilies] F
       INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG
           ON F.[id] = FAG.[familyID]
       LEFT JOIN [dbo].[Symphony_RetailAgDgConnection] AGDG
           ON AGDG.[assortmentGroupID] = FAG.[assortmentGroupID]

    INSERT INTO [dbo].[Symphony_familyTreeReducedRules]
       SELECT 
            FAG.[familyID]
           ,FAG.[assortmentGroupID]
           ,AGDG.[displayGroupID]
           ,MSKU.[familyMemberID]
       FROM [dbo].[Symphony_SkuFamilies] F
       INNER JOIN [dbo].[Symphony_RetailFamilyAgConnection] FAG
           ON F.[id] = FAG.[familyID]
       LEFT JOIN [dbo].[Symphony_RetailAgDgConnection] AGDG
           ON AGDG.[assortmentGroupID] = FAG.[assortmentGroupID]
       INNER JOIN [dbo].[Symphony_MasterSkus] MSKU
           ON MSKU.[familyID] = FAG.[familyID]

   EXECUTE [dbo].[Symphony_spGetReducedRulesCommon]   
   EXECUTE [dbo].[Symphony_spGetReducedRulesSL]   
   EXECUTE [dbo].[Symphony_spGetReducedRulesFamilyMember]   
   EXECUTE [dbo].[Symphony_spGetReducedRulesSLFamilyMember]   
END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_spGetReducedRulesCommon]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Symphony_spGetReducedRulesCommon]
AS
BEGIN
    SET NOCOUNT ON;

    --**********************************************************
    -- Get common rules					
    --**********************************************************
    INSERT INTO [dbo].[Symphony_familyTreeReducedRulesPrepare]  
    --1
    SELECT
          FT.[familyID]
         ,FT.[assortmentGroupID]
         ,-1 [familyMemberID]
         ,-1 [stockLocationID]
         ,MAX([minimumMembersCount])[minimumMembersCount]
         ,MAX([minimumPreferredCount])[minimumPreferredCount]
         ,MAX([minimumInventory])[minimumInventory]
         ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
         ,1
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
         ON FT.[familyID] = VR.[familyID]
         AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
         AND FT.[displayGroupID] = VR.[displayGroupID]
    WHERE
          VR.[familyMemberID] IS NULL
          AND VR.[stockLocationID] IS NULL
    GROUP BY 
		 FT.[familyID]
		,FT.[assortmentGroupID]
    UNION
    --2
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,-1 [familyMemberID]
        ,-1 [stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,1
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON VR.[familyID] is NULL
        AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
        AND FT.[displayGroupID] = VR.[displayGroupID]
    WHERE
         VR.[familyMemberID] IS NULL
         AND VR.[stockLocationID] IS NULL
    GROUP BY 
		 FT.[familyID]
		,FT.[assortmentGroupID]
    UNION
    --3
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,-1 [familyMemberID]
        ,-1 [stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,1
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON VR.[familyID] is null
        AND VR.[assortmentGroupID] is null
        AND FT.[displayGroupID] = VR.[displayGroupID]
    WHERE
         VR.[familyMemberID] IS NULL
         AND VR.[stockLocationID] IS NULL
    GROUP BY 
		 FT.[familyID]
		,FT.[assortmentGroupID]
    UNION
    --4
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,-1 [familyMemberID]
        ,-1 [stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,1
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON FT.[familyID] = VR.[familyID] 
        AND VR.[assortmentGroupID] is null
        AND VR.[displayGroupID]  is null
    WHERE
         VR.[familyMemberID] IS NULL
         AND VR.[stockLocationID] IS NULL
    GROUP BY 
		 FT.[familyID]
		,FT.[assortmentGroupID]
    UNION
    --5
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,-1 [familyMemberID]
        ,-1 [stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,1
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON FT.[familyID] = VR.[familyID] 
        AND VR.[assortmentGroupID] is null
        AND FT.[displayGroupID] = VR.[displayGroupID]
    WHERE
         VR.[familyMemberID] IS NULL
         AND VR.[stockLocationID] IS NULL
    GROUP BY 
		 FT.[familyID]
		,FT.[assortmentGroupID]
  UNION
  --6
    SELECT
           FT.[familyID]
          ,FT.[assortmentGroupID]
          ,-1 [familyMemberID]
          ,-1 [stockLocationID]
          ,MAX([minimumMembersCount])[minimumMembersCount]
          ,MAX([minimumPreferredCount])[minimumPreferredCount]
          ,MAX([minimumInventory])[minimumInventory]
          ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
          ,1
      FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
      INNER JOIN Symphony_familyTreeReducedRules FT  
          ON FT.[familyID] = VR.[familyID] 
          AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
          AND VR.[displayGroupID] IS NULL
      WHERE
           VR.[familyMemberID] IS NULL
           AND VR.[stockLocationID] IS NULL
      GROUP BY 
	  	 FT.[familyID]
	  	,FT.[assortmentGroupID]
    UNION
    --7
    SELECT
           FT.[familyID]
          ,FT.[assortmentGroupID]
          ,-1 [familyMemberID]
          ,-1 [stockLocationID]
          ,MAX([minimumMembersCount])[minimumMembersCount]
          ,MAX([minimumPreferredCount])[minimumPreferredCount]
          ,MAX([minimumInventory])[minimumInventory]
          ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
          ,1
      FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
      INNER JOIN Symphony_familyTreeReducedRules FT  
          ON VR.[familyID] is null
          AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
          AND VR.[displayGroupID] IS NULL
      WHERE
           VR.[familyMemberID] IS NULL
           AND VR.[stockLocationID] IS NULL
      GROUP BY 
	  	 FT.[familyID]
	  	,FT.[assortmentGroupID]
    UNION
    --8
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,-1 [familyMemberID]
        ,-1 [stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,1
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON VR.[familyID] is null
        AND VR.[assortmentGroupID] is null
        AND VR.[displayGroupID]  is null
    WHERE
         VR.[familyMemberID] IS NULL
         AND VR.[stockLocationID] IS NULL
    GROUP BY 
		 FT.[familyID]
		,FT.[assortmentGroupID]
END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_spGetReducedRulesFamilyMember]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Symphony_spGetReducedRulesFamilyMember]
AS
BEGIN
    SET NOCOUNT ON;

    --**********************************************************
    --Get familyMember rules
    --**********************************************************
    INSERT INTO [dbo].[Symphony_familyTreeReducedRulesPrepare]  
    SELECT
          FT.[familyID]
         ,FT.[assortmentGroupID]
         ,FT.[familyMemberID]
         ,-1 [stockLocationID]
         ,MAX([minimumMembersCount])[minimumMembersCount]
         ,MAX([minimumPreferredCount])[minimumPreferredCount]
         ,MAX([minimumInventory])[minimumInventory]
         ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
         ,3
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
         ON FT.[familyID] = VR.[familyID]
         AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
         AND FT.[displayGroupID] = VR.[displayGroupID]
	    AND FT.[familyMemberID] = VR.[familyMemberID]
    WHERE
           VR.[stockLocationID] IS NULL
    GROUP BY 
		FT.[familyID]
	     ,FT.[assortmentGroupID]
          ,FT.[familyMemberID]
    UNION
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,FT.[familyMemberID]
        ,-1 [stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,3
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON VR.[familyID] is NULL
        AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
        AND FT.[displayGroupID] = VR.[displayGroupID]
	   AND FT.[familyMemberID] = VR.[familyMemberID]
    WHERE
          VR.[stockLocationID] IS NULL
    GROUP BY 
		 FT.[familyID]
	     ,FT.[assortmentGroupID]
          ,FT.[familyMemberID]
    UNION
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,FT.[familyMemberID]
        ,-1 [stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,3
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON VR.[familyID] is null
        AND VR.[assortmentGroupID] is null
        AND FT.[displayGroupID] = VR.[displayGroupID]
	      AND FT.[familyMemberID] = VR.[familyMemberID]
    WHERE
          VR.[stockLocationID] IS NULL
    GROUP BY 
		 FT.[familyID]
	     ,FT.[assortmentGroupID]
          ,FT.[familyMemberID]
    UNION
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,FT.[familyMemberID]
        ,-1 [stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,3
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON FT.[familyID] = VR.[familyID] 
        AND VR.[assortmentGroupID] is null
        AND VR.[displayGroupID]  is null
	   AND FT.[familyMemberID] = VR.[familyMemberID]
    WHERE
          VR.[stockLocationID] IS NULL
    GROUP BY 
		 FT.[familyID]
	     ,FT.[assortmentGroupID]
          ,FT.[familyMemberID]
    UNION
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,FT.[familyMemberID]
        ,-1 [stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,3
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON FT.[familyID] = VR.[familyID] 
        AND VR.[assortmentGroupID] is null
        AND FT.[displayGroupID] = VR.[displayGroupID]
	   AND FT.[familyMemberID] = VR.[familyMemberID]
    WHERE
          VR.[stockLocationID] IS NULL
    GROUP BY 
		 FT.[familyID]
	     ,FT.[assortmentGroupID]
          ,FT.[familyMemberID]
    UNION
    SELECT
           FT.[familyID]
          ,FT.[assortmentGroupID]
          ,FT.[familyMemberID]
          ,-1 [stockLocationID]
          ,MAX([minimumMembersCount])[minimumMembersCount]
          ,MAX([minimumPreferredCount])[minimumPreferredCount]
          ,MAX([minimumInventory])[minimumInventory]
          ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
          ,3
      FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
      INNER JOIN Symphony_familyTreeReducedRules FT  
          ON FT.[familyID] = VR.[familyID] 
          AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
          AND VR.[displayGroupID] IS NULL
	      	AND FT.[familyMemberID] = VR.[familyMemberID]
      WHERE
           VR.[stockLocationID] IS NULL
      GROUP BY 
	  	 FT.[familyID]
	     ,FT.[assortmentGroupID]
          ,FT.[familyMemberID]
    UNION
    SELECT
           FT.[familyID]
          ,FT.[assortmentGroupID]
          ,FT.[familyMemberID]
          ,-1 [stockLocationID]
          ,MAX([minimumMembersCount])[minimumMembersCount]
          ,MAX([minimumPreferredCount])[minimumPreferredCount]
          ,MAX([minimumInventory])[minimumInventory]
          ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
          ,3
      FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
      INNER JOIN Symphony_familyTreeReducedRules FT  
          ON VR.[familyID] IS NULL
          AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
          AND VR.[displayGroupID] IS NULL
	      	AND FT.[familyMemberID] = VR.[familyMemberID]
      WHERE
           VR.[stockLocationID] IS NULL
      GROUP BY 
	  	 FT.[familyID]
	     ,FT.[assortmentGroupID]
          ,FT.[familyMemberID]
    UNION
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,FT.[familyMemberID]
        ,-1 [stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,3
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON VR.[familyID] is null
        AND VR.[assortmentGroupID] is null
        AND VR.[displayGroupID]  is null
	   AND FT.[familyMemberID] = VR.[familyMemberID]
    WHERE
         VR.[stockLocationID] IS NULL
    GROUP BY 
		 FT.[familyID]
	     ,FT.[assortmentGroupID]
          ,FT.[familyMemberID]
END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_spGetReducedRulesResults]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Symphony_spGetReducedRulesResults]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  
       [familyID],
       [assortmentGroupID],
       null [familyMemberID],
       null [stockLocationID],
       MAX([minimumMembersCount])[minimumMembersCount],
       MAX([minimumPreferredCount])[minimumPreferredCount],
       MAX([minimumInventory])[minimumInventory],
       MAX([minimumPercentBufferSize])[minimumPercentBufferSize] 
    FROM 
       [dbo].[Symphony_familyTreeReducedRulesPrepare]  
    WHERE
	  [familyMemberID] = -1 AND
	  [stockLocationID] = -1
    GROUP BY 
	  [familyID],
	  [assortmentGroupID]
UNION 
    SELECT
        [familyID]
       ,[assortmentGroupID]
       ,null [familyMemberID]
       ,[stockLocationID]
       ,MAX([minimumMembersCount])[minimumMembersCount]
       ,MAX([minimumPreferredCount])[minimumPreferredCount]
       ,MAX([minimumInventory])[minimumInventory]
       ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
	FROM 
       [dbo].[Symphony_familyTreeReducedRulesPrepare]  
	WHERE
        [familyMemberID] != -1 AND
        [stockLocationID] != -1  
     GROUP BY 
        [familyID]
	  ,[assortmentGroupID]
       ,[stockLocationID]
UNION 
    SELECT
          [familyID]
         ,[assortmentGroupID]
         ,[familyMemberID]
         ,null [stockLocationID]
         ,MAX([minimumMembersCount])[minimumMembersCount]
         ,MAX([minimumPreferredCount])[minimumPreferredCount]
         ,MAX([minimumInventory])[minimumInventory]
         ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
	FROM 
       [dbo].[Symphony_familyTreeReducedRulesPrepare]  
	WHERE
           [stockLocationID] !=-1
     GROUP BY 
		[familyID]
	     ,[assortmentGroupID]
          ,[familyMemberID]
UNION 
    SELECT
          [familyID]
         ,[assortmentGroupID]
         ,[familyMemberID]
         ,[stockLocationID]
         ,MAX([minimumMembersCount])[minimumMembersCount]
         ,MAX([minimumPreferredCount])[minimumPreferredCount]
         ,MAX([minimumInventory])[minimumInventory]
         ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
	FROM 
       [dbo].[Symphony_familyTreeReducedRulesPrepare]  
	WHERE 
        [stockLocationID] !=-1
      GROUP BY
          [familyID]
	    ,[assortmentGroupID]
         ,[familyMemberID]
         ,[stockLocationID]
END 

GO
/****** Object:  StoredProcedure [dbo].[Symphony_spGetReducedRulesSL]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Symphony_spGetReducedRulesSL]
AS
BEGIN
    SET NOCOUNT ON;

    --**********************************************************
    --Get stockLocation specific rules
    --**********************************************************
    INSERT INTO [dbo].[Symphony_familyTreeReducedRulesPrepare]  
    SELECT
             FT.[familyID]
            ,FT.[assortmentGroupID]
            ,-1 [familyMemberID]
            ,[stockLocationID]
            ,MAX([minimumMembersCount])[minimumMembersCount]
            ,MAX([minimumPreferredCount])[minimumPreferredCount]
            ,MAX([minimumInventory])[minimumInventory]
            ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
            ,2
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT
            ON FT.[familyID] = VR.[familyID]
            AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
            AND FT.[displayGroupID] = VR.[displayGroupID]
     WHERE
            VR.[familyMemberID] IS NULL
            AND VR.[stockLocationID] IS NOT NULL
     GROUP BY 
             FT.[familyID]
	       ,FT.[assortmentGroupID]
            ,VR.[stockLocationID]
  UNION
	SELECT
             FT.[familyID]
            ,FT.[assortmentGroupID]
            ,-1 [familyMemberID]
            ,[stockLocationID]
            ,MAX([minimumMembersCount])[minimumMembersCount]
            ,MAX([minimumPreferredCount])[minimumPreferredCount]
            ,MAX([minimumInventory])[minimumInventory]
            ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
            ,2
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT
            ON VR.[familyID] is NULL
            AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
            AND FT.[displayGroupID] = VR.[displayGroupID]
     WHERE
            VR.[familyMemberID] IS NULL
            AND VR.[stockLocationID] IS NOT NULL
     GROUP BY 
             FT.[familyID]
	       ,FT.[assortmentGroupID]
            ,VR.[stockLocationID]
  UNION
	SELECT
             FT.[familyID]
            ,FT.[assortmentGroupID]
            ,-1 [familyMemberID]
            ,[stockLocationID]
            ,MAX([minimumMembersCount])[minimumMembersCount]
            ,MAX([minimumPreferredCount])[minimumPreferredCount]
            ,MAX([minimumInventory])[minimumInventory]
            ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
            ,2
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT
            ON VR.[familyID] is null
            AND VR.[assortmentGroupID] is null
            AND FT.[displayGroupID] = VR.[displayGroupID]
     WHERE
            VR.[familyMemberID] IS NULL
            AND VR.[stockLocationID] IS NOT NULL
     GROUP BY 
             FT.[familyID]
	       ,FT.[assortmentGroupID]
            ,VR.[stockLocationID]
  UNION
	SELECT
             FT.[familyID]
            ,FT.[assortmentGroupID]
            ,-1 [familyMemberID]
            ,[stockLocationID]
            ,MAX([minimumMembersCount])[minimumMembersCount]
            ,MAX([minimumPreferredCount])[minimumPreferredCount]
            ,MAX([minimumInventory])[minimumInventory]
            ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
            ,2
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT
            ON FT.[familyID] = VR.[familyID] 
            AND VR.[assortmentGroupID] is null
            AND VR.[displayGroupID]  is null
     WHERE
            VR.[familyMemberID] IS NULL
            AND VR.[stockLocationID] IS NOT NULL
     GROUP BY 
             FT.[familyID]
	       ,FT.[assortmentGroupID]
            ,VR.[stockLocationID]
  UNION
	SELECT
             FT.[familyID]
            ,FT.[assortmentGroupID]
            ,-1 [familyMemberID]
            ,[stockLocationID]
            ,MAX([minimumMembersCount])[minimumMembersCount]
            ,MAX([minimumPreferredCount])[minimumPreferredCount]
            ,MAX([minimumInventory])[minimumInventory]
            ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
            ,2
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT
             ON FT.[familyID] = VR.[familyID] 
             AND VR.[assortmentGroupID] is null
             AND FT.[displayGroupID] = VR.[displayGroupID]
     WHERE
            VR.[familyMemberID] IS NULL
            AND VR.[stockLocationID] IS NOT NULL
     GROUP BY 
             FT.[familyID]
	       ,FT.[assortmentGroupID]
            ,VR.[stockLocationID]
  UNION
	SELECT
             FT.[familyID]
            ,FT.[assortmentGroupID]
            ,-1 [familyMemberID]
            ,[stockLocationID]
            ,MAX([minimumMembersCount])[minimumMembersCount]
            ,MAX([minimumPreferredCount])[minimumPreferredCount]
            ,MAX([minimumInventory])[minimumInventory]
            ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
            ,2
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT
             ON FT.[familyID] = VR.[familyID] 
             AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
             AND VR.[displayGroupID] IS NULL
     WHERE
            VR.[familyMemberID] IS NULL
            AND VR.[stockLocationID] IS NOT NULL
     GROUP BY 
             FT.[familyID]
	       ,FT.[assortmentGroupID]
            ,VR.[stockLocationID]
  UNION
  SELECT
             FT.[familyID]
            ,FT.[assortmentGroupID]
            ,-1 [familyMemberID]
            ,[stockLocationID]
            ,MAX([minimumMembersCount])[minimumMembersCount]
            ,MAX([minimumPreferredCount])[minimumPreferredCount]
            ,MAX([minimumInventory])[minimumInventory]
            ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
            ,2
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT
             ON VR.[familyID] IS NULL
             AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
             AND VR.[displayGroupID] IS NULL
     WHERE
            VR.[familyMemberID] IS NULL
            AND VR.[stockLocationID] IS NOT NULL
     GROUP BY 
             FT.[familyID]
	       ,FT.[assortmentGroupID]
            ,VR.[stockLocationID]
  UNION
	SELECT
             FT.[familyID]
            ,FT.[assortmentGroupID]
            ,-1 [familyMemberID]
            ,[stockLocationID]
            ,MAX([minimumMembersCount])[minimumMembersCount]
            ,MAX([minimumPreferredCount])[minimumPreferredCount]
            ,MAX([minimumInventory])[minimumInventory]
            ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
            ,2
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT
             ON VR.[familyID] is null
             AND VR.[assortmentGroupID] is null
             AND VR.[displayGroupID]  is null
     WHERE
            VR.[familyMemberID] IS NULL
            AND VR.[stockLocationID] IS NOT NULL
     GROUP BY 
             FT.[familyID]
	       ,FT.[assortmentGroupID]
            ,VR.[stockLocationID]
END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_spGetReducedRulesSLFamilyMember]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Symphony_spGetReducedRulesSLFamilyMember]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[Symphony_familyTreeReducedRulesPrepare]  
    --1
    SELECT
          FT.[familyID]
         ,FT.[assortmentGroupID]
         ,FT.[familyMemberID]
         ,[stockLocationID]
         ,MAX([minimumMembersCount])[minimumMembersCount]
         ,MAX([minimumPreferredCount])[minimumPreferredCount]
         ,MAX([minimumInventory])[minimumInventory]
         ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
         ,4
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
         ON FT.[familyID] = VR.[familyID]
         AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
         AND FT.[displayGroupID] = VR.[displayGroupID]
	    AND FT.[familyMemberID] = VR.[familyMemberID]
    WHERE 
        VR.[stockLocationID] IS NOT NULL
      GROUP BY
          FT.[familyID]
	    ,FT.[assortmentGroupID]
         ,FT.[familyMemberID]
         ,VR.[stockLocationID]
    UNION
    --2
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,FT.[familyMemberID]
        ,[stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,4
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON VR.[familyID] is NULL
        AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
        AND FT.[displayGroupID] = VR.[displayGroupID]
	   AND FT.[familyMemberID] = VR.[familyMemberID]
    WHERE 
        VR.[stockLocationID] IS NOT NULL
      GROUP BY
          FT.[familyID]
	    ,FT.[assortmentGroupID]
         ,FT.[familyMemberID]
         ,VR.[stockLocationID]
    UNION
    --3
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,FT.[familyMemberID]
        ,[stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,4
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON VR.[familyID] is null
        AND VR.[assortmentGroupID] is null
        AND FT.[displayGroupID] = VR.[displayGroupID]
	   AND FT.[familyMemberID] = VR.[familyMemberID]
    WHERE 
        VR.[stockLocationID] IS NOT NULL
      GROUP BY
          FT.[familyID]
	    ,FT.[assortmentGroupID]
         ,FT.[familyMemberID]
         ,VR.[stockLocationID]
    UNION
    --4
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,FT.[familyMemberID]
        ,[stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,4
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON FT.[familyID] = VR.[familyID] 
        AND VR.[assortmentGroupID] is null
        AND VR.[displayGroupID]  is null
	   AND FT.[familyMemberID] = VR.[familyMemberID]
    WHERE 
        VR.[stockLocationID] IS NOT NULL
      GROUP BY
          FT.[familyID]
	    ,FT.[assortmentGroupID]
         ,FT.[familyMemberID]
         ,VR.[stockLocationID]
    UNION
    --5
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,FT.[familyMemberID]
        ,[stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,4
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON FT.[familyID] = VR.[familyID] 
        AND VR.[assortmentGroupID] is null
        AND FT.[displayGroupID] = VR.[displayGroupID]
	   AND FT.[familyMemberID] = VR.[familyMemberID]
    WHERE 
        VR.[stockLocationID] IS NOT NULL
      GROUP BY
          FT.[familyID]
	    ,FT.[assortmentGroupID]
         ,FT.[familyMemberID]
         ,VR.[stockLocationID]
  UNION
  --6
    SELECT
           FT.[familyID]
          ,FT.[assortmentGroupID]
          ,FT.[familyMemberID]
          ,[stockLocationID]
          ,MAX([minimumMembersCount])[minimumMembersCount]
          ,MAX([minimumPreferredCount])[minimumPreferredCount]
          ,MAX([minimumInventory])[minimumInventory]
          ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
          ,4
      FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
      INNER JOIN Symphony_familyTreeReducedRules FT  
          ON FT.[familyID] = VR.[familyID] 
          AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
          AND VR.[displayGroupID] IS NULL
		AND FT.[familyMemberID] = VR.[familyMemberID]
      WHERE 
        VR.[stockLocationID] IS NOT NULL
      GROUP BY
          FT.[familyID]
	    ,FT.[assortmentGroupID]
         ,FT.[familyMemberID]
         ,VR.[stockLocationID]
    UNION
    --7
    SELECT
           FT.[familyID]
          ,FT.[assortmentGroupID]
          ,FT.[familyMemberID]
          ,[stockLocationID]
          ,MAX([minimumMembersCount])[minimumMembersCount]
          ,MAX([minimumPreferredCount])[minimumPreferredCount]
          ,MAX([minimumInventory])[minimumInventory]
          ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
          ,4
      FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
      INNER JOIN Symphony_familyTreeReducedRules FT  
          ON VR.[familyID] IS NULL
          AND FT.[assortmentGroupID] = VR.[assortmentGroupID]
          AND VR.[displayGroupID] IS NULL
		      AND FT.[familyMemberID] = VR.[familyMemberID]
      WHERE 
        VR.[stockLocationID] IS NOT NULL
      GROUP BY
          FT.[familyID]
	    ,FT.[assortmentGroupID]
         ,FT.[familyMemberID]
         ,VR.[stockLocationID]
    UNION
    --8
    SELECT
         FT.[familyID]
        ,FT.[assortmentGroupID]
        ,FT.[familyMemberID]
        ,[stockLocationID]
        ,MAX([minimumMembersCount])[minimumMembersCount]
        ,MAX([minimumPreferredCount])[minimumPreferredCount]
        ,MAX([minimumInventory])[minimumInventory]
        ,MAX([minimumPercentBufferSize])[minimumPercentBufferSize]
        ,4
    FROM [dbo].[Symphony_SkuFamiliesValidationRules] VR
    INNER JOIN Symphony_familyTreeReducedRules FT  
        ON VR.[familyID] is null
        AND VR.[assortmentGroupID] is null
        AND VR.[displayGroupID]  is null
	   AND FT.[familyMemberID] = VR.[familyMemberID]
    WHERE 
        VR.[stockLocationID] IS NOT NULL
    GROUP BY
          FT.[familyID]
	       ,FT.[assortmentGroupID]
         ,FT.[familyMemberID]
         ,VR.[stockLocationID]
END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_spHandleISTComplianceHistory]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Symphony_spHandleISTComplianceHistory]
AS
BEGIN
	INSERT INTO [Symphony_ISTComplianceHistory](
		   [orderID]
		  ,[stockLocationID]
		  ,[supplierID]
		  ,[skuID]
		  ,[quantity]
		  ,[orderPrice]
		  ,[orderDate]
		  ,[promisedDueDate]
		  ,[purchasingPropertyID1]
		  ,[purchasingPropertyID2]
		  ,[purchasingPropertyID3]
		  ,[purchasingPropertyID4]
		  ,[purchasingPropertyID5]
		  ,[purchasingPropertyID6]
		  ,[purchasingPropertyID7]
		  ,[closeDate]
		  ,[completionDate]
		  ,[unitsReceived]
		  ,[statusCode])
	SELECT OLD.orderID, 
		   OLD.stockLocationID, 
		   OLD.supplierID,
		   OLD.skuID,
		   OLD.quantity,
		   OLD.orderPrice,
		   OLD.orderDate,
		   OLD.promisedDueDate,
		   OLD.purchasingPropertyID1,
		   OLD.purchasingPropertyID2,
		   OLD.purchasingPropertyID3,
		   OLD.purchasingPropertyID4,
		   OLD.purchasingPropertyID5,
		   OLD.purchasingPropertyID6,
		   OLD.purchasingPropertyID7,
		   datediff(d, 0, getdate()),
		   NULL,
		   0,
		   NULL 
	FROM 
	Symphony_PurchasingOrderPrev OLD Left Join Symphony_PurchasingOrder NEW
	ON OLD.orderID = NEW.orderID
	WHERE OLD.isISTOrder = 1 AND NEW.orderID IS NULL

END


GO
/****** Object:  StoredProcedure [dbo].[Symphony_spMtoSkuHistory]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Symphony_spMtoSkuHistory]
				@stockLocationID INT=-1,
				@updateDate smalldatetime=null, 
				@yesterday smalldatetime=null,
				@doUpdateSkuTable bit=0
			AS
			BEGIN

				IF (@stockLocationID = -1 or @updateDate is null)
					return

				INSERT INTO Symphony_MTOSkusHistory(skuID, stockLocationID, 
				inventoryAtSite, totalIn, consumption, updateDate, inventoryAtTransit, inventoryAtProduction,
				unitPrice, throughput, tvc, tempInventoryAtSite,
				worstInventoryAtSite, avgInventoryAtSite, inventoryAtSiteUpdatesNum, isDuplicatedRow)
		        
				SELECT skuID, @stockLocationID, inventoryAtSite, 0  as totalIn, 0 as consumption, @updateDate,
				inventoryAtTransit, inventoryAtProduction, unitPrice, throughput, tvc, inventoryAtSite as tempInventoryAtSite,
				inventoryAtSite as WorstInventoryAtSite, inventoryAtSite as avgInventoryAtSite ,1, 1
		        
				FROM Symphony_MTOSkusHistory S WITH(NOLOCK)
				WHERE S.isDeleted = 0
				AND S.stockLocationID=@stockLocationID
				AND updateDate = @yesterday
				AND not exists (select 1 from Symphony_MTOSkusHistory
										where skuID = S.skuID and
										stockLocationID = S.stockLocationID and
										updateDate = @updateDate)

			IF (@doUpdateSkuTable = 1)
			BEGIN
				update Symphony_MTOSkus set updateDate = @updateDate, totalIN = 0, consumption = 0
				 WHERE Symphony_MTOSkus.stockLocationID=@stockLocationID
						and Symphony_MTOSkus.updateDate < @updateDate
			END
		END
GO
/****** Object:  StoredProcedure [dbo].[Symphony_spMTOSkusToPurchaseData]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[Symphony_spMTOSkusToPurchaseData] 
AS
BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;

   
        DECLARE @WOEXTENDED TABLE (woID nvarchar(100) NOT NULL
				,clientOrderID nvarchar(50)
                ,skuID INT NOT NULL
                ,plantID INT NOT NULL
                ,dueDate smalldatetime
                ,quantity decimal(18,5)
                ,bufferSize decimal(18,5)
                ,tractionHorizon int NULL
                ,materialReleaseActualDate smalldatetime
                ,materialReleaseScheduledDate smalldatetime)

        INSERT INTO @WOEXTENDED
                        SELECT 
                                WO.woid
                                ,WO.clientOrderID
                                ,WO.skuID
                                ,WO.plantID
                                ,WO.dueDate
                                ,WO.quantity
                                ,ISNULL(WO.bufferSize,CAST(PF.bufferSize as decimal(18,5))) AS bufferSize
                                ,CCR.tractionHorizon
                                ,WO.materialReleaseActualDate
                                ,WO.materialReleaseScheduledDate

                        FROM 
                          Symphony_WorkOrders WO
                          INNER JOIN Symphony_SKUs MSKU ON WO.componentID = '' 
                                                                                                AND WO.isPhantom = 0 
                                                                                                AND WO.orderType != 1 
                                                                                                AND WO.materialReleaseActualDate IS NULL 
                                                                                                AND MSKU.skuID = WO.skuID
                          LEFT JOIN Symphony_StockLocationSkusProductionData SLSPD ON SLSPD.stockLocationID = WO.plantID AND SLSPD.skuID = MSKU.skuID
                          LEFT JOIN Symphony_ProductionFamilies PF ON PF.ID = SLSPD.productionFamily
                          LEFT JOIN Symphony_CCRs CCR ON CCR.plantID = WO.plantID AND CCR.ID = PF.flowDictatorID

        DECLARE @CANDIDATES TABLE (
                ID int IDENTITY(1,1)
                ,woID nvarchar(100) NOT NULL
                ,clientOrderID nvarchar(50)
                ,plantID INT NOT NULL
                ,dueDate smalldatetime
                ,bufferSize decimal(18,5) NULL
                ,tractionHorizon int NULL
                ,materialReleaseActualDate smalldatetime
                ,materialReleaseScheduledDate smalldatetime
                ,quantityNeeded decimal(18,5)
                ,skuID INT NOT NULL
                ,skuName nvarchar(100) NOT NULL
                ,supplierID INT
                ,stockLocationID INT
                ,supplierLeadTime int NOT NULL
                ,timeProtection int NOT NULL
                ,quantityProtection decimal(18,5) NOT NULL
                ,minimumOrderQuantity decimal(18,5) NOT NULL
                ,orderMultiplications decimal(18,5) NOT NULL
                ,lastBatchReplenishment decimal(18,5) NOT NULL
                ,additionalTimeTillArrival int NOT NULL
                ,supplierSKUName nvarchar(100)
                ,mlSlID INT NOT NULL)

        -- Fill temporary table
        INSERT INTO @CANDIDATES
                SELECT 
                        WO.woid
                        ,WO.clientOrderID
                        ,WO.plantID
                        ,WO.dueDate
                        ,WO.bufferSize
                        ,WO.tractionHorizon
                        ,WO.materialReleaseActualDate
                        ,WO.materialReleaseScheduledDate
                        ,BOM.quantity * WO.quantity
                        ,BOM.skuID
                        ,PD.skuName
                        ,PD.supplierID
                        ,PD.stockLocationID
                        ,PD.supplierLeadTime
                        ,PD.timeProtection
                        ,PD.quantityProtection
                        ,PD.minimumOrderQuantity
                        ,PD.orderMultiplications
                        ,PD.lastBatchReplenishment
                        ,PD.additionalTimeTillArrival
                        ,PD.supplierSKUName
                        ,ml.stockLocationID
                FROM 
                  @WOEXTENDED WO
                  INNER JOIN Symphony_SkusBom BOM ON WO.plantID = BOM.plantID AND WO.skuID = BOM.masterSkuID
                  INNER JOIN Symphony_MaterialsStockLocations ML ON BOM.plantID = ML.plantID AND (BOM.skuID = ML.skuID OR ML.skuID = -1)
                  INNER JOIN Symphony_SKUs SKU ON BOM.skuID = SKU.skuID
                  INNER JOIN Symphony_SkuProcurementData PD ON SKU.skuName = PD.skuName AND PD.stockLocationID = ML.stockLocationID AND PD.isDefaultSupplier = 1
                --WHERE
                  --NOT EXISTS (SELECT skuID FROM Symphony_StockLocationSkus WHERE isDeleted = 0 AND skuID = BOM.skuID AND stockLocationID = ML.stockLocationID)
                  --AND NOT EXISTS (SELECT ID FROM Symphony_PurchasingRecommendation WHERE woid = WO.woid AND skuID = BOM.skuID AND stockLocationID = ML.stockLocationID AND (isAwaitsConfirmation = 1 OR isConfirmed = 1 OR isDeleted = 1))
                --ORDER BY WO.woid, WO.plantID, SKU.skuName, ML.skuID DESC

        -- Remove duplicates resulting from multiple matches in the MaterialsStockLocations table
        SELECT * FROM @CANDIDATES C1
                WHERE C1.ID = (SELECT TOP 1 C2.ID FROM @CANDIDATES C2 WHERE C1.woID = C2.woID AND C1.plantID = C2.plantID AND C1.skuID = C2.skuID) and
            NOT EXISTS (SELECT skuID FROM Symphony_StockLocationSkus WHERE isDeleted = 0 AND skuID = C1.skuID AND stockLocationID = c1.stockLocationID) and
            NOT EXISTS (SELECT ID FROM Symphony_PurchasingRecommendation WHERE woid = c1.woid AND skuID = c1.skuID AND stockLocationID = c1.mlSlID AND (isAwaitsConfirmation = 1 OR isConfirmed = 1 OR isDeleted = 1))
        ORDER BY c1.woid, c1.plantID, c1.skuName, c1.skuID DESC

END

--Improved Database Restore
IF (SELECT COUNT(1) FROM [dbo].[Symphony_Globals] WHERE [flag_name] = 'databaseRestore.maxAttempts') = 0
	INSERT INTO [dbo].[Symphony_Globals] ([flag_name], [flag_value])
	  SELECT 'databaseRestore.maxAttempts', 3  

IF (SELECT COUNT(1) FROM [dbo].[Symphony_Globals] WHERE [flag_name] = 'databaseRestore.attemptFrequency') = 0
	INSERT INTO [dbo].[Symphony_Globals] ([flag_name], [flag_value])
	  SELECT 'databaseRestore.attemptFrequency', 30000

IF (SELECT COUNT(1) FROM [dbo].[Symphony_Globals] WHERE [flag_name] = 'databaseRestore.allowRestartSQLServerService') = 0
	INSERT INTO [dbo].[Symphony_Globals] ([flag_name], [flag_value])
	  SELECT 'databaseRestore.allowRestartSQLServerService', 'True'   

IF (SELECT COUNT(1) FROM [dbo].[Symphony_Globals] WHERE [flag_name] = 'databaseRestore.allowRestartSQLServerService') = 0
	INSERT INTO [dbo].[Symphony_Globals] ([flag_name], [flag_value])
	  SELECT 'databaseRestore.restartTimeout', 300000   


GO
/****** Object:  StoredProcedure [dbo].[Symphony_spMTOSkuToPurchaseData]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Symphony_spMTOSkuToPurchaseData] 
        @woID NVarChar(50),
        @skuID INT,
        @supplierID INT

AS
BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
        -- Create a temporary table 

        DECLARE @WOEXTENDED TABLE (woID nvarchar(100) NOT NULL
				,clientOrderID nvarchar(50)
                ,skuID INT NOT NULL
                ,plantID INT NOT NULL
                ,dueDate smalldatetime
                ,quantity decimal(18,5)
                ,bufferSize decimal(18,5) NULL
                ,tractionHorizon int NULL
                ,materialReleaseActualDate smalldatetime
                ,materialReleaseScheduledDate smalldatetime)

        INSERT INTO @WOEXTENDED
                        SELECT 
                                WO.woid
								,WO.clientOrderID
                                ,WO.skuID
                                ,WO.plantID
                                ,WO.dueDate
                                ,WO.quantity
                                ,ISNULL(WO.bufferSize,CAST(PF.bufferSize as decimal(18,5))) AS bufferSize
                                ,CCR.tractionHorizon
                                ,WO.materialReleaseActualDate
                                ,WO.materialReleaseScheduledDate

                        FROM 
                          Symphony_WorkOrders WO
                          INNER JOIN Symphony_SKUs MSKU 
                                ON WO.woid = @woId
                                AND WO.componentID = '' 
                                AND WO.isPhantom = 0 
                                AND WO.orderType != 1 
                                AND WO.materialReleaseActualDate IS NULL 
                                AND MSKU.skuID = WO.skuID
                          LEFT JOIN Symphony_StockLocationSkusProductionData SLSPD ON SLSPD.stockLocationID = WO.plantID AND SLSPD.skuID = MSKU.skuID
                          LEFT JOIN Symphony_ProductionFamilies PF ON PF.ID = SLSPD.productionFamily
                          LEFT JOIN Symphony_CCRs CCR ON CCR.plantID = WO.plantID AND CCR.ID = PF.flowDictatorID

        DECLARE @CANDIDATES TABLE (
                ID int IDENTITY(1,1)
                ,woID nvarchar(100) NOT NULL
				,clientOrderID nvarchar(50)
                ,plantID INT NOT NULL
                ,dueDate smalldatetime
                ,bufferSize decimal(18,5) NULL
                ,tractionHorizon int NULL
                ,materialReleaseActualDate smalldatetime
                ,materialReleaseScheduledDate smalldatetime
                ,quantityNeeded decimal(18,5)
                ,skuID INT NOT NULL
                ,skuName nvarchar(100) NOT NULL
                ,supplierID INT
                ,stockLocationID INT
                ,supplierLeadTime int NOT NULL
                ,timeProtection int NOT NULL
                ,quantityProtection decimal(18,5) NOT NULL
                ,minimumOrderQuantity decimal(18,5) NOT NULL
                ,orderMultiplications decimal(18,5) NOT NULL
                ,lastBatchReplenishment decimal(18,5) NOT NULL
                ,additionalTimeTillArrival int NOT NULL
                ,supplierSKUName nvarchar(100))

        -- Fill temporary table
        INSERT INTO @CANDIDATES
                SELECT 
                        WO.woid
						,WO.clientOrderID
                        ,WO.plantID
                        ,WO.dueDate
                        ,WO.bufferSize
                        ,WO.tractionHorizon
                        ,WO.materialReleaseActualDate
                        ,WO.materialReleaseScheduledDate
                        ,BOM.quantity * WO.quantity
                        ,BOM.skuID
                        ,PD.skuName
                        ,PD.supplierID
                        ,PD.stockLocationID
                        ,PD.supplierLeadTime
                        ,PD.timeProtection
                        ,PD.quantityProtection
                        ,PD.minimumOrderQuantity
                        ,PD.orderMultiplications
                        ,PD.lastBatchReplenishment
                        ,PD.additionalTimeTillArrival
                        ,PD.supplierSKUName

                FROM 
                  @WOEXTENDED WO
                  INNER JOIN Symphony_SkusBom BOM ON BOM.skuID = @skuID AND WO.plantID = BOM.plantID AND WO.skuID = BOM.masterSkuID
                  INNER JOIN Symphony_MaterialsStockLocations ML ON BOM.plantID = ML.plantID AND (BOM.skuID = ML.skuID OR ML.skuID = -1)
                  INNER JOIN Symphony_SKUs SKU ON BOM.skuID = SKU.skuID
                  INNER JOIN Symphony_SkuProcurementData PD ON SKU.skuName = PD.skuName AND PD.stockLocationID = ML.stockLocationID AND PD.supplierID = @supplierID
                WHERE
                  NOT EXISTS (SELECT skuID FROM Symphony_StockLocationSkus WHERE isDeleted = 0 AND skuID = BOM.skuID AND stockLocationID = ML.stockLocationID)
                  AND NOT EXISTS (SELECT ID FROM Symphony_PurchasingRecommendation WHERE woid = WO.woid AND skuID = BOM.skuID AND stockLocationID = ML.stockLocationID 
                  AND (isConfirmed = 1 OR isDeleted = 1))
                ORDER BY WO.woid, WO.plantID, SKU.skuName, ML.skuID DESC

        -- Remove duplicates resulting from multiple matches in the MaterialsStockLocations table
        SELECT * FROM @CANDIDATES C1
                WHERE C1.ID = (SELECT TOP 1 C2.ID FROM @CANDIDATES C2 WHERE C1.woID = C2.woID AND C1.plantID = C2.plantID AND C1.skuID = C2.skuID)

END

IF OBJECT_ID('dbo.Symphony_spMTOSkuToPurchaseData') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.Symphony_spMTOSkuToPurchaseData >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.Symphony_spMTOSkuToPurchaseData >>>'

GO
/****** Object:  StoredProcedure [dbo].[Symphony_spProcurementMatching]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Symphony_spProcurementMatching] 
        -- Add the parameters for the stored procedure here
AS
BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;

	DECLARE @AllMatches TABLE(
		 [id] int IDENTITY(1,1)
		,[OrderID] [int]
		,[RecommendationID] [int]
	);

	DECLARE @MatchedRecommendations TABLE
	(
		[RecommendationID] int
	)
	
	DECLARE @Matches as TABLE(
		 [OrderID] [int]
		,[RecommendationID] [int]
	);

	-- orders
	INSERT INTO @AllMatches
	SELECT
		 PO.ID
		,PR.ID 
	FROM [dbo].[Symphony_PurchasingOrder] PO
	INNER JOIN [dbo].[Symphony_PurchasingRecommendation] PR
	ON PO.clientOrderID = PR.clientOrderID

	INSERT INTO @AllMatches
	SELECT
		 PO.ID
		,PR.ID 
	FROM [dbo].[Symphony_PurchasingOrder] PO
	INNER JOIN [dbo].[Symphony_PurchasingRecommendation] PR
	ON	PR.isDeleted = 0
		AND PO.isToOrder = 1  
		AND PO.needsMatch = 1
		AND PO.skuID = PR.skuID
		AND PO.stockLocationID = PR.stockLocationID
		AND DATEDIFF(DAY, PO.neededDate,PR.needDate) = 0
		AND PO.quantity BETWEEN 0.95 * PR.quantity AND 1.05 * PR.quantity
    where not exists (select PO.ID from @AllMatches a where a.[OrderID] = PO.ID)

	--Stock
	INSERT INTO @AllMatches
	SELECT
		 PO.ID
		,PR.ID 
		--,1
	FROM [dbo].[Symphony_PurchasingOrder] PO
		INNER JOIN [dbo].[Symphony_PurchasingRecommendation] PR ON 
		PO.isToOrder = 0  
		AND PO.needsMatch = 1
		AND PO.skuID = PR.skuID
		AND PO.stockLocationID = PR.stockLocationID
   where not exists (select PO.ID from @AllMatches a where a.[OrderID] = PO.ID)
   
	DECLARE 
		 @id int
		,@prID int
		,@poID int
		,@maxID int;
		
	SELECT @id = 1, @maxID = COUNT(1) FROM @AllMatches

	WHILE @id <= @maxID
	BEGIN
		SELECT @poID = [orderID], @prID = [RecommendationID] FROM @AllMatches WHERE [id] = @id;
		IF NOT EXISTS( SELECT [RecommendationID] FROM @MatchedRecommendations WHERE [RecommendationID] = @prID)
			BEGIN
				INSERT INTO @Matches SELECT @poID, @prID
				INSERT INTO @MatchedRecommendations SELECT @prID
			END
		SELECT @id = @id + 1	
	END

	UPDATE PO
		SET needsMatch = 0
    FROM [dbo].[Symphony_PurchasingOrder] PO
    INNER JOIN @Matches MPO 
		ON PO.ID = MPO.OrderID 
    WHERE PO.needsMatch = 1 

	UPDATE PR
		SET isConfirmed = 1
	FROM [dbo].[Symphony_PurchasingRecommendation] PR
	INNER JOIN @Matches MPO 
		ON PR.ID = MPO.RecommendationID 
	WHERE PR.orderType = 0

	DELETE FROM PR
    FROM [dbo].[Symphony_PurchasingRecommendation] PR
    INNER JOIN @Matches MPO
		ON PR.ID = MPO.RecommendationID 
    WHERE PR.orderType = 1
END


GO
/****** Object:  StoredProcedure [dbo].[Symphony_spRebuildIndexes]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[Symphony_spRebuildIndexes]
   @dbName nvarchar(100) 
AS
BEGIN
   SET NOCOUNT ON;
   SET QUOTED_IDENTIFIER OFF;
	  
	 DECLARE @Table NVARCHAR(255)  
	 DECLARE @cmd NVARCHAR(500)  
	 DECLARE @fillfactor INT 
	 
	 DECLARE @frag float = 0
	 DECLARE @buildCMD NVARCHAR(500)
	 DECLARE @buildCMD_online NVARCHAR(500)
	 DECLARE @indexname NVARCHAR(1000)
	 DECLARE @objectid int;  
	 DECLARE @indexid int;  
	  
	 DECLARE @msg NVARCHAR(1000)
	 DECLARE @msgOUT NVARCHAR(1000)
	
	 DECLARE @t1 DATETIME;
	 DECLARE @t2 DATETIME;
	 DECLARE @rebuildONLINE bit;

   SET @fillfactor = 90 
   SET @rebuildONLINE = 0

   IF (object_id( 'tempdb..#ISIndexList' ) IS NOT NULL)
     DROP TABLE ..#ISIndexList
   
   --Create temp indexes table
   SELECT 
      OBJECT_NAME(ind.OBJECT_ID) as tbl, indexstats.object_id AS objectid, indexstats.index_id AS indexid, indexstats.avg_fragmentation_in_percent as frag
   INTO 
      #ISIndexList  
   FROM 
      sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats INNER JOIN 
	    sys.indexes ind ON ind.object_id = indexstats.object_id AND ind.index_id = indexstats.index_id 
   WHERE 
      ind.index_id > 0 and 
	    indexstats.avg_fragmentation_in_percent > 10
  
  DECLARE TableCursor CURSOR FOR SELECT tbl as tableName, objectid, indexid, frag FROM #ISIndexList

  OPEN TableCursor   
  
  FETCH NEXT FROM TableCursor INTO @Table, @objectid, @indexid, @frag   
  WHILE @@FETCH_STATUS = 0   
  BEGIN   
     set @msg = @table
	   set @Table = @dbName + '.dbo.' + @Table

	   SELECT @indexname = QUOTENAME(name) FROM sys.indexes WHERE  object_id = @objectid AND index_id = @indexid;  
	   
	   if (@frag>=30)
	   begin
		    set @msg = @msg + ': REBUILD ' + @indexname
		    set @buildCMD = ' REBUILD WITH (ONLINE = OFF, FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ')'
		    set @buildCMD_online = ' REBUILD WITH (ONLINE = ON, FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ')'
	   end
	   else
	   begin
		    set @msg = @msg + ': REORGANIZE ' + @indexname
		    set @buildCMD_online = ' REORGANIZE WITH ( LOB_COMPACTION = ON )'
	   end

	   SET @t1 = GETDATE();
	   BEGIN TRY 
		   SET @msgOUT = @msg + ' (ONLINE)'
		   if (@rebuildONLINE = 0)
		   begin
		   	   SET @cmd = 'SET QUOTED_IDENTIFIER ON; ALTER INDEX ' + @indexname + ' ON ' + @Table + @buildCMD
		   end
		   else	
		   begin
		      SET @cmd = 'SET QUOTED_IDENTIFIER ON; ALTER INDEX ' + @indexname + ' ON ' + @Table + @buildCMD_online 
		   end
		   EXEC (@cmd)  
	   END TRY
	   BEGIN CATCH
		   SET @msgOUT = @msg + ' (OFFLINE)'
		   SET @cmd = 'SET QUOTED_IDENTIFIER ON; ALTER INDEX ' + @indexname +' ON ' + @Table + @buildCMD
		   EXEC (@cmd)  
	   END CATCH


	   SET @t2 = GETDATE();
	   --print @msgOUT + ' - duration: ' + cast(DATEDIFF(millisecond,@t1,@t2) as nvarchar(200)) + 'ms';
	   
     FETCH NEXT FROM TableCursor INTO @Table, @objectid, @indexid, @frag 
  END   

  CLOSE TableCursor   
  DEALLOCATE TableCursor  

  DROP TABLE #ISIndexList  
  
  SET QUOTED_IDENTIFIER OFF
END


GO
/****** Object:  StoredProcedure [dbo].[Symphony_spRebuildPartitionIndex]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Symphony_spRebuildPartitionIndex]
   @dbName nvarchar(100), 
   @Table nvarchar(255), 
   @indexname nvarchar(1000),
   @partitionID nvarchar(4)
AS
BEGIN
   SET NOCOUNT ON;
   SET QUOTED_IDENTIFIER OFF;
	  
	 DECLARE @cmd NVARCHAR(1500)  
	 DECLARE @fillfactor INT 
	 
	 DECLARE @frag float = 0
	 DECLARE @buildCMD NVARCHAR(500)
	 DECLARE @buildCMD_online NVARCHAR(500)
	 DECLARE @objectid int;  
	 DECLARE @indexid int;  
	  
	 DECLARE @msg NVARCHAR(1000)
	 DECLARE @msgOUT NVARCHAR(2000)
	
	 DECLARE @t1 DATETIME;
	 DECLARE @t2 DATETIME;
	 DECLARE @rebuildONLINE bit;

   SET @fillfactor = 90 
   SET @rebuildONLINE = 0

   --Create temp indexes table
   SELECT 
      @frag = indexstats.avg_fragmentation_in_percent
   FROM 
      sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats INNER JOIN 
	    sys.indexes ind ON ind.object_id = indexstats.object_id AND ind.index_id = indexstats.index_id 
   WHERE 
      ind.name = @indexname and 
	    indexstats.partition_number = @partitionID and
      ind.index_id > 0 and 
	    indexstats.avg_fragmentation_in_percent > 10
  
     set @msg = @table
	   set @Table = @dbName + '.dbo.' + @Table

	   if (@frag>=30)
	   begin
		    set @msg = @msg + ': REBUILD ' + @indexname
		    set @buildCMD = ' REBUILD Partition = ' + @partitionID + ' WITH (ONLINE = OFF)'
		    set @buildCMD_online = ' REBUILD Partition = ' + @partitionID + ' WITH (ONLINE = ON)'
	   end
	   else
	   begin
		    set @msg = @msg + ': REORGANIZE ' + @indexname
		    set @buildCMD_online = ' REORGANIZE Partition = ' + @partitionID + ' WITH ( LOB_COMPACTION = ON )'
		  	set @buildCMD = ' REORGANIZE Partition = ' + @partitionID + ' WITH ( LOB_COMPACTION = ON )'
	   end

	   BEGIN TRY 
		   SET @msgOUT = @msg + ' (ONLINE)'
		   if (@rebuildONLINE = 0)
		   begin
		   	   SET @cmd = 'SET QUOTED_IDENTIFIER ON; ALTER INDEX ' + @indexname + ' ON ' + @Table + @buildCMD
		   end
		   else	
		   begin
		      SET @cmd = 'SET QUOTED_IDENTIFIER ON; ALTER INDEX ' + @indexname + ' ON ' + @Table + @buildCMD_online 
		   end
		    
		   EXEC (@cmd)  
	   END TRY
	   BEGIN CATCH
		   SET @msgOUT = @msg + ' (OFFLINE)'
		   SET @cmd = 'SET QUOTED_IDENTIFIER ON; ALTER INDEX ' + @indexname +' ON ' + @Table + @buildCMD

		   EXEC (@cmd)  
	   END CATCH

     --print @msgOUT 

	   SET QUOTED_IDENTIFIER OFF
END


GO
/****** Object:  StoredProcedure [dbo].[Symphony_spSalesOrderPastDueDate]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[Symphony_spSalesOrderPastDueDate]
AS
    BEGIN

                CREATE TABLE #countSalesOrder(
                        saleOrderID nvarchar(50) COLLATE database_default,
                        counter int)

                INSERT INTO #countSalesOrder
                select saleOrderID,count(*) as counter
                from Symphony_WorkOrders
                where   dueDate <= getdate() AND
                                saleOrderID IS NOT NULL AND
                                (LOWER(saleOrderID) NOT IN ('','0','null')) AND
                                orderType!=1
                group by saleOrderID

                select count(*) from #countSalesOrder

                drop table #countSalesOrder
    END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_spSetChangeTriggersEnabled]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[Symphony_spSetChangeTriggersEnabled]
	 @ENABLED bit
	,@UPDATE_LAST_CHANGE_DATE bit = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--Get trigger/table name pairs
	DECLARE @PARAMETERS AS TABLE([ID] [int] IDENTITY (0,1),[tableName] [nvarchar](100), [triggerName] [nvarchar](150))
	
	INSERT INTO @PARAMETERS
		SELECT [tableName], [triggerName] 
		FROM [dbo].[Symphony_DataChanged]
		
	DECLARE
		 @COUNT int
		,@INDEX int
		,@TABLE_NAME NVARCHAR(100)
		,@TRIGGER_NAME NVARCHAR(150)
		
	SELECT @COUNT = COUNT(1), @INDEX = 0 FROM @PARAMETERS;
	
	WHILE @INDEX < @COUNT
	BEGIN
	
		SELECT @TABLE_NAME = [tableName], @TRIGGER_NAME = [triggerName] 
			FROM @PARAMETERS
			WHERE [ID] = @INDEX
		
		IF @ENABLED = 0
			EXECUTE('DISABLE TRIGGER [dbo].[' + @TRIGGER_NAME + '] ON [dbo].[' + @TABLE_NAME + ']')
		ELSE
			BEGIN
				EXECUTE('ENABLE TRIGGER [dbo].[' + @TRIGGER_NAME + '] ON [dbo].[' + @TABLE_NAME + ']')
				IF @UPDATE_LAST_CHANGE_DATE = 1
					UPDATE [dbo].[Symphony_DataChanged]
					   SET[lastDataChange] = GETDATE()
			END
		SET @INDEX = @INDEX + 1;
		
	END
	
END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_spSetISTComplianceStatuses]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Symphony_spSetISTComplianceStatuses] 
      @threshold1 int = 10,
      @threshold2 int = 30
AS
BEGIN

	DECLARE @statusNonCompliant int
	DECLARE @statusOnTime int 
	DECLARE @statusMissingUnits int
	DECLARE @statusLate int

	SELECT @statusNonCompliant = 0
	SELECT @statusOnTime = 1
	SELECT @statusMissingUnits = 2
	SELECT @statusLate = 3


	UPDATE Symphony_ISTComplianceHistory SET statusCode = @statusNonCompliant
	WHERE DATEDIFF(d, isnull(orderDate,closeDate), getdate()) > @threshold2
	AND statusCode IS NULL


	UPDATE H SET H.unitsReceived = T.quantity,
				 H.statusCode = CASE WHEN T.quantity < H.quantity THEN @statusMissingUnits
									 WHEN DATEDIFF(d, isnull(H.orderDate,H.closeDate),T.reportedDate) > @threshold1 THEN @statusLate
									 ELSE @statusOnTime END,
				H.completionDate = T.reportedDate
			  
	FROM 
	Symphony_ISTComplianceHistory H INNER JOIN 
	Symphony_Transactions T ON H.orderID = T.transactionID
	WHERE H.statusCode IS NULL AND T.transactionType = 1

END


GO
/****** Object:  StoredProcedure [dbo].[Symphony_spSLSkuHistory]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Symphony_spSLSkuHistory]
        @stockLocationID INT=-1,
        @updateDate smalldatetime=null, 
        @yesterday smalldateTime=null,
        @doUpdateSkuTable bit=0
AS
BEGIN

    IF (@stockLocationID = -1 or @updateDate is null)
        return

        INSERT INTO Symphony_StockLocationSkuHistory(skuID, stockLocationID, bufferSize,
        inventoryAtSite, consumption, totalIn, irrConsumption, irrTotalIn,irrInvAtSite,irrInvAtTransit,irrInvAtProduction, updateDate, inventoryAtTransit, inventoryAtProduction,
        unitPrice, throughput, tvc, avgMonthlyConsumption, tempInventoryAtSite, 
        worstInventoryAtSite, avgInventoryAtSite, inventoryAtSiteUpdatesNum, originStockLocation, originSKU, originType,
        bpSite, bpTransit, bpProduction, greenBpLevel, redBpLevel, safetyStock, isDuplicatedRow)

        SELECT skuID, @stockLocationID, bufferSize, inventoryAtSite, 0 as consumption, 0 as totalIn, 0 as irrConsumption, 0 as irrTotalIn, irrInvAtSite, irrInvAtTransit, irrInvAtProduction, @updateDate as updateDate,
        inventoryAtTransit, inventoryAtProduction, unitPrice, throughput, tvc, avgMonthlyConsumption, inventoryAtSite as tempInventoryAtSite,
        inventoryAtSite as worstInventoryAtSite, inventoryAtSite as avgInventoryAtSite ,1, originStockLocation, originSKU,
        originType, bpSite, bpTransit, bpProduction, greenBpLevel, redBpLevel, safetyStock, 1

        FROM Symphony_StockLocationSkuHistory S WITH(NOLOCK)
             
        WHERE S.isDeleted = 0
        AND S.stockLocationID=@stockLocationID
        AND updateDate = @yesterday
        AND not exists (select 1 from Symphony_StockLocationSkuHistory
                                where skuID = S.skuID and
                                stockLocationID = S.stockLocationID and
                                updateDate = @updateDate)

END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_spStockLocationsAdjacent]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[Symphony_spStockLocationsAdjacent]
AS
    BEGIN

        CREATE TABLE #StockLocationsAdjacent(
            stockLocationID1   INT,
            stockLocationID2   INT,
            stockLocationName1 nvarchar(100),
            stockLocationName2 nvarchar(100),
            inD1toD2NotNeeded     bit,
            inD2toD1NotNeeded     bit)

    INSERT INTO     #StockLocationsAdjacent
    SELECT DISTINCT stockLocationID1, stockLocationID2, '', '', inD1toD2NotNeeded, inD2toD1NotNeeded
    FROM            Symphony_StockLocationsAdjacent, Symphony_StockLocations
    WHERE           stockLocationID1=stockLocationID OR stockLocationID2=stockLocationID

    UPDATE      #StockLocationsAdjacent
    SET         stockLocationName1=stockLocationName
    FROM        Symphony_StockLocations
        WHERE   stockLocationID1=stockLocationID

    UPDATE      #StockLocationsAdjacent
    SET         stockLocationName2=stockLocationName
    FROM        Symphony_StockLocations
        WHERE   stockLocationID2=stockLocationID

    SELECT * from #StockLocationsAdjacent

    DROP TABLE #StockLocationsAdjacent

END

GO
/****** Object:  StoredProcedure [dbo].[Symphony_spUpdateSkusTotalConsumption]    Script Date: 4/26/2022 1:32:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Symphony_spUpdateSkusTotalConsumption]
AS
BEGIN
	SET NOCOUNT ON;
	
	MERGE INTO [dbo].[Symphony_SkusTotalConsumption] AS Target  
	USING (SELECT skuID, consumption FROM [Symphony_SkusTotalConsumptionTemp]) AS Source (skuID, consumption)
	ON Target.skuID = Source.skuID 
	WHEN MATCHED THEN  
	UPDATE SET consumption += Source.consumption
	WHEN NOT MATCHED BY TARGET THEN  
	INSERT (skuID, consumption) VALUES (Source.skuID, Source.consumption);
END

GO
