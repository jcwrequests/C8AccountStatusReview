﻿DECLARE @START_DATE DATETIME = '08/01/2015';

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
),
AGE_OF_IMPLEMENTATION AS
(SELECT	A.Id,
		A.AccountName,
		A.AccountCode,
		CASE WHEN DATEDIFF(WK,MIN(FLI.loginDate),GETDATE()) -2 <= 0
			 THEN 0
			 ELSE DATEDIFF(WK,MIN(FLI.loginDate),GETDATE()) -2
		END as age_in_weeks,
		MIN(FLI.loginDate) as start_date,
		A.Type

FROM	C8Data.dbo.aspnet_Membership AM

		INNER JOIN C8Data.dbo.Account A ON
		AM.ApplicationId = A.ApplicationId
		
		INNER JOIN
		(SELECT UserId, 
				MIN(LoginDate) as loginDate
		 FROM	C8Data.dbo.UserLoginHistory
		 GROUP BY
				UserId
		  HAVING MIN(LoginDate) >= @START_DATE) FLI ON
		AM.UserId = FLI.UserId
WHERE	EXISTS (SELECT * 
				FROM C8Data.dbo.StudentInformation SI 
				WHERE SI.UserId = AM.UserId) AND
		A.IsDemo = 0 AND
		A.ExcludeFromReports = 0 AND
		A.IsDeleted = 0 AND
		A.AccountStatus = 1
		
GROUP BY
		A.Id,
		A.AccountName,
		A.AccountCode,
		A.Type),
--ACTIVE COHORTS
ACTIVE_COHORTS AS (
SELECT	
		BS.CohortId as CohortId,
		BS.AccountId
		
		
  FROM	BS_INFO	BS

),
--ACTIVE STUDENTS
ACTIVE_STUDENTS AS(
	SELECT	CFS.CohortId,
			CFS.UserId as StudentId,
			C.AccountId,
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
 SELECT	S.CohortId,
		S.StudentId,
		S.AccountId,
		CASE WHEN (AOI.age_in_weeks * 40) >= SUM(SDH.SessionDayLength)
		     THEN 'On Pace'
		     WHEN SUM(SDH.SessionDayLength) < (AOI.age_in_weeks *40) AND
				  SUM(SDH.SessionDayLength) >= (AOI.age_in_weeks * 30)
		     THEN 'Slightly Behind'
		     ELSE 'Struggling'
		END as pace_category,
		SUM(SDH.SessionDayLength) as total_minutes
		
  FROM	ACTIVE_STUDENTS S
  
		LEFT OUTER JOIN [C8Data].[dbo].[StudentSessionDayHistory] SDH ON
		S.StudentId = SDH.StudentId AND
		S.CohortId = SDH.CohortId AND
		SDH.DateCreated >= @START_DATE
		
		INNER JOIN AGE_OF_IMPLEMENTATION AOI ON
		S.AccountId = AOI.Id
		
 GROUP BY
		
		S.CohortId,
		S.StudentId,
		S.AccountId,
		AOI.age_in_weeks
		)
		
	
	
SELECT	COUNT(*) as number_of_students,
		BS.pace_category,
		BS.AccountId,
		I.SchoolName

FROM	BS

		INNER JOIN BS_INFO I ON
		BS.CohortId = I.CohortId

GROUP BY

		BS.pace_category,
		BS.AccountId,
		I.SchoolName