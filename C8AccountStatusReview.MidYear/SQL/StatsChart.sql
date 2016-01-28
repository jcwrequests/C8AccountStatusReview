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
		--AND S.Id = 'CDEFBA68-8AD1-4827-A25E-268004DB5E33'
		--AND A.Id = '474b399f-7ec9-44c9-ab1a-4cbb624cb672'
		--AND
		--A.Id = '5528310d-a2bf-487d-99a0-2020fba2f6fd' 
		--AND
		--S.Id = 'E407B9CB-1F45-4BB8-A150-50984C26A6AB'
),

--ACTIVE COHORTS
ACTIVE_COHORTS AS (
SELECT	
		BS.CohortId as CohortId
		
		
  FROM	BS_INFO	BS
	
),
--ACTIVE STUDENTS
ACTIVE_STUDENTS AS(
	SELECT	CFS.CohortId,
			CFS.UserId as StudentId,
			SI.FirstName + ' ' + SI.LastName as name
			
	
	FROM	ACTIVE_COHORTS C
	
			INNER JOIN C8Data.dbo.CohortForStudent CFS ON
			C.CohortId = CFS.CohortId
			
			INNER JOIN C8Data.dbo.StudentInformation SI ON
			CFS.UserId = SI.UserId
			
	WHERE	CFS.TerminationDate IS NULL AND
			SI.StudentStatusId = 1 AND
			SI.IsDeleted = 0 AND
			EXISTS
		(SELECT SG.CohortID
		 FROM	C8Data.dbo.SessionGameInfo SG
		 WHERE	SG.SessionPhase > 1 AND
				sg.CohortId = CFS.CohortId AND
				SG.StudentId = CFS.UserId) 
),

BS AS (
 SELECT	A.AccountName,
		LC.AccountId,
		SDH.StudentId,
		SDH.CohortId,
		AM.LastLoginDate,
		S.Name as SchoolName,
		S.Id as SchoolId,
		COUNT(SDH.StudentId) as sessions,
		SUM(SDH.SessionDayLength) as total_minutes
		
  FROM	[C8Data].[dbo].[StudentSessionDayHistory] SDH
  
		INNER JOIN C8Data.dbo.LogicalContainer LC ON
		SDH.CohortId = LC.Id
		
		LEFT OUTER JOIN C8Data.dbo.ContainerForUser CFU ON
		SDH.StudentId = CFU.UserId
		
		INNER JOIN C8Data.dbo.Account A ON
		LC.AccountId = A.Id
		
        INNER JOIN C8Data.dbo.StudentInformation SI ON
		SDH.StudentId = SI.UserId
		
		INNER JOIN C8Data.dbo.aspnet_Membership AM ON
		SDH.StudentId = AM.UserId
		
		LEFT OUTER JOIN C8Data.dbo.LogicalContainer S ON
		CFU.ContainerId = S.Id AND
		0 = S.IsDeleted AND
        1 = S.ContainerStatusId
				
 WHERE  A.IsDemo = 0 AND
		A.ExcludeFromReports = 0 AND
		A.IsDeleted = 0 AND
		A.AccountStatus = 1 AND
		LC.IsDeleted = 0 AND
		SI.IsDeleted = 0 AND
        LC.ContainerStatusId = 1 AND
        SDH.DateCreated >= @START_DATE AND
        A.Type = 1 AND
        CFU.TerminationDate IS NULL AND
        EXISTS(	SELECT * 
				FROM	ACTIVE_STUDENTS ST 
				WHERE	ST.CohortId = SDH.CohortId AND 
						ST.StudentId = SDH.StudentId)
        
 GROUP BY
		
        A.AccountName,
		LC.AccountId,
		SDH.StudentId,
		SDH.CohortId,
		S.Name,
		AM.LastLoginDate,
		S.Id
		)


--SELECT	B1.*

--FROM	BS B1

--WHERE	B1.StudentId = 'DEC01546-D60B-45B3-AEC9-0230A8EF96E3'




		
SELECT	COUNT(DISTINCT I.CohortId)  as cohorts,
		SUM(BS.total_minutes)  as total_minutes_played,
		COUNT(DISTINCT S.StudentId)  as active_students,
		COUNT(DISTINCT I.SchoolId) as schools,
		MAX(BS.LastLoginDate) as last_login_date,
		I.AccountName,
		I.SchoolName
		

FROM	ACTIVE_STUDENTS S

		INNER JOIN BS_INFO I ON
		S.CohortId = I.CohortId

		LEFT OUTER JOIN BS ON
		S.CohortId = BS.CohortId AND
		S.StudentId = BS.StudentId

        
GROUP BY
		I.AccountName,
		I.AccountId,
		I.SchoolName
        
--SELECT	E.CohortId,
--		ES.Percentage,
--		ES.DateCreated

--FROM	C8Data.dbo.fnGetCohortsForEntity('474b399f-7ec9-44c9-ab1a-4cbb624cb672', 3, 1, 1) E

--		INNER JOIN	EntityStatus es ON
--		E.CohortId = es.EntityId
			
--	WHERE	es.PercentageType = 12
