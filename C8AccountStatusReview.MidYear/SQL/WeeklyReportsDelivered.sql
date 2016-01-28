
--SELECT TOP 1000 [alert_type_id]
--      ,[alert_type_description]
--  FROM [C8Data].[dbo].[EF_ALERT_TYPES];
  
  DECLARE @START_DATE DATETIME = '08/01/2015';
  
 WITH 
 BS_INFO AS (
 SELECT	
		A.AccountName,
		LC.AccountId,
		LC.Id as CohortId,
		LC.Name as CohortName,
		S.Id as SchoolId,
		S.Name as SchoolName,
		S.Type as SchoolType,
		UI.LastName as TeacherName
		
  FROM	C8Data.dbo.LogicalContainer LC 
		
		INNER JOIN C8Data.dbo.LogicalContainer P ON
		LC.ParentId = P.Id
		
		INNER JOIN C8Data.dbo.LogicalContainer SC ON
		P.ParentId = SC.Id
		
		INNER JOIN C8Data.dbo.Account A ON
		LC.AccountId = A.Id
		
		INNER JOIN C8Data.dbo.ObjectOwnership OO ON
		LC.Id = OO.ObjectId 
		
		INNER JOIN C8Data.dbo.UserInformation UI ON
		OO.EntityId = UI.UserId
		
		LEFT OUTER JOIN C8Data.dbo.LogicalContainer S ON
		SC.Id = S.Id AND
		0 = S.IsDeleted AND
        1 = S.ContainerStatusId AND
        3 = S.Type AND
        0 = S.ExcludeFromReports
				
 WHERE  LC.IsDeleted = 0 AND
        LC.ContainerStatusId = 1 AND
		LC.ExcludeFromReports = 0 AND
		LC.Type = 5 AND
		
		EXISTS
		(SELECT SG.CohortID
		 FROM	C8Data.dbo.SessionGameInfo SG
		 WHERE	SG.SessionPhase > 1 AND
				SG.CohortId = LC.Id) AND
				
		A.Type = 1  AND
		A.IsDemo = 0 AND
		A.ExcludeFromReports = 0 AND
		A.IsDeleted = 0 AND
		A.AccountStatus = 1 
		
		
		AND S.Id = @SchoolId
		--AND A.Id = '474b399f-7ec9-44c9-ab1a-4cbb624cb672'
		--AND
		--A.Id = '5528310d-a2bf-487d-99a0-2020fba2f6fd' 
		--AND
		--S.Id = 'E407B9CB-1F45-4BB8-A150-50984C26A6AB'
) 

 SELECT	COUNT(SA.alert_token) emails,
		I.AccountId,
		I.AccountName,
		I.SchoolName,
		C.type
 
 FROM	BS_INFO I
 
		CROSS JOIN
		(SELECT 'Weekly' as type
         UNION
         SELECT 'EF' as type) C
 
		LEFT OUTER JOIN C8Data.dbo.EF_SENT_ALERTS SA ON
		I.CohortId = SA.CohortId AND
		I.AccountId = SA.AccountId AND
		(CASE WHEN SA.alert_type IN (5,6,7)
		     THEN 'Weekly'
		     ELSE 'EF'
		 END) = C.type AND
		SA.alert_type IN (5,6,7,8) AND
		SA.alert_time_stamp >= @START_DATE
 	
GROUP BY

		I.AccountId,
		I.AccountName,
		I.SchoolName,
		C.type
		
		


		
		
