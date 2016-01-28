 DECLARE @START_DATE DATETIME = '08/01/2015';
 WITH BS_INFO AS (
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
),

BS AS (
SELECT	DISTINCT	
		CASE WHEN C.Description = 'Sustained Attention'
			 THEN 'Attention'
			 WHEN C.Description = 'Category Formation'
			 THEN 'Category Use'
			 WHEN C.Description = 'Response Inhibition'
			 THEN 'Impulse Control'
			 WHEN C.Description = 'Pattern Recognition'
			 THEN 'Pattern Use'
			 WHEN C.Description = 'Speed of Information Processing'
			 THEN 'Processing Speed'
			 ELSE C.Description 
		END as Description,
		A.AccountName,
		A.AccountId,
		A.SchoolId,
		A.SchoolName,
		C.CCCid
      
FROM	[C8Reporting].[dbo].[CoreCognitiveCapacity] C

		CROSS JOIN (SELECT	A.AccountId,
							A.AccountName,
							A.SchoolId,
							A.SchoolName
							
					FROM	BS_INFO A
					) A
							
WHERE	NOT C.CCCId IN (3,4) 							
		
),
ESTATS AS (

SELECT	LC.AccountId,
		S.Id as school_id,
		E.CCCid,
		COUNT(E.trigger_id) as trigger_count

FROM	[C8Data].[dbo].EF_STUDENT_ALERT_EVENTS E

		INNER JOIN C8Data.dbo.LogicalContainer LC ON
		E.CohortId = LC.Id AND
		0 = LC.IsDeleted AND
		1 = LC.ContainerStatusId
	
		LEFT OUTER JOIN C8Data.dbo.ContainerForUser CFU ON
		E.StudentId = CFU.UserId AND
		CFU.TerminationDate IS NULL 
		
		LEFT OUTER JOIN C8Data.dbo.LogicalContainer S ON
		CFU.ContainerId = S.Id AND
		0 = S.IsDeleted AND
        1 = S.ContainerStatusId 

WHERE	E.event_time_stamp >= @START_DATE
 
 GROUP BY

		LC.AccountId,
		S.Id ,
		E.CCCid) 
	

	
SELECT	BS.AccountName,
		BS.AccountId,
		BS.Description,
		BS.SchoolId,
		BS.SchoolName,
		COALESCE(E.trigger_count,0) as trigger_count

FROM	BS 

		LEFT OUTER JOIN ESTATS E ON
		BS.AccountId = E.AccountId AND
		BS.CCCid = E.CCCid AND
		BS.SchoolId = E.school_id

		LEFT OUTER JOIN C8Data.dbo.LogicalContainer LC ON
		E.school_id = LC.Id
		
ORDER BY
	BS.AccountName,
	BS.AccountId,
	BS.SchoolId,
	BS.SchoolName,
	BS.Description