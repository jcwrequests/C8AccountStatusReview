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
		 FROM	dbo.SessionGameInfo SG
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
		 FROM	dbo.SessionGameInfo SG
		 WHERE	SG.SessionPhase > 1 AND
				sg.CohortId = CFS.CohortId AND
				SG.StudentId = CFS.UserId) 
),

 NIH_TEST_RESULTS AS(

		SELECT	S.StudentId,
				S.CohortId,
				R.NIHTestType
				
		FROM	ACTIVE_STUDENTS S
		
				INNER JOIN C8Reporting.dbo.NIHResult R ON
				S.CohortId = R.CohortId AND
				S.StudentId = R.StudentId
		
		GROUP BY
				S.StudentId,
				S.CohortId,
				R.NIHTestType
		
),
COMPLETED_NIH AS (

SELECT	CASE WHEN COUNT(N.NIHTestType) >= 3 
			 THEN 1
			 ELSE 0
		END  as nih_completed,
		N.CohortId,
		N.StudentId

FROM	NIH_TEST_RESULTS N

GROUP BY
	N.CohortId,
	N.StudentId),
TIME AS (

	SELECT	S.StudentId,
			S.CohortId,
			CASE WHEN SUM(DH.SessionDayLength) IS NULL
			     THEN DH2.total_time
			     ELSE SUM(DH.SessionDayLength)
			END as total_time,
			COALESCE(N.nih_completed,0) as nih_completed
	
	FROM	ACTIVE_STUDENTS S
	
			LEFT OUTER JOIN COMPLETED_NIH N ON
			S.StudentId = N.StudentId AND
			S.CohortId = N.CohortId
			
			LEFT OUTER JOIN 
			(SELECT	DISTINCT SessionDay as SessionDay,
							 CohortId,
							 StudentId
					FROM	StudentGameSessionHistory)
			 SH ON
			S.CohortId = SH.CohortId AND
			S.StudentId = SH.StudentId
			
			LEFT OUTER JOIN StudentSessionDayHistory DH ON
			SH.SessionDay = DH.SessionDayNumber AND
			SH.CohortId = DH.CohortId AND
			SH.StudentId = DH.StudentId
	
			LEFT OUTER JOIN (SELECT SUM(H.SessionDayLength) as total_time,
								H.CohortId,
								H.StudentId
							   
			FROM	StudentSessionDayHistory H
			GROUP BY
					H.CohortId,
					H.StudentId) AS DH2 ON
			S.CohortId = DH2.CohortId AND
			S.StudentId = DH2.StudentId
			
		GROUP BY
			S.StudentId,
			S.CohortId,
			DH2.total_time,
			N.nih_completed
),
REPORTS_COMPLETED AS (

	SELECT	T.CohortId,
			T.StudentId,
			T.total_time,
			T.nih_completed,
			CASE WHEN T.nih_completed = 0 
				 THEN 0
				 ELSE MAX(COALESCE(RR.ReportNumber,1))
			END	 category
	
	FROM	TIME T
	
			LEFT OUTER JOIN ReportRequirements RR ON
			T.total_time >= RR.MinutesReportAvailable
			
	GROUP BY
			T.CohortId,
			T.StudentId,
			T.total_time,
			T.nih_completed
)
	

SELECT	COUNT(RC.StudentId) as count,
		CASE RC.category 
		WHEN 0 THEN 'With No Reports'
		WHEN 1 THEN 'With Preliminary Report'
		WHEN 2 THEN 'With Preliminary Report'
		WHEN 3 THEN 'With Midterm Report'
		ELSE 'With Final Report'
		END category,
		CASE RC.category
		WHEN 0 THEN 1
		WHEN 1 THEN 2
		WHEN 2 THEN 2
		WHEN 3 THEN 3
		ELSE 4
		END category_order,
		BS.SchoolName,
		BS.AccountName

FROM	REPORTS_COMPLETED RC

		INNER JOIN BS_INFO BS ON
		RC.CohortId = BS.CohortId
		
GROUP BY
		CASE RC.category 
		WHEN 0 THEN 'With No Reports'
		WHEN 1 THEN 'With Preliminary Report'
		WHEN 2 THEN 'With Preliminary Report'
		WHEN 3 THEN 'With Midterm Report'
		ELSE 'With Final Report'
		END,
		BS.SchoolName,
		BS.AccountName,
		CASE RC.category
		WHEN 0 THEN 1
		WHEN 1 THEN 2
		WHEN 2 THEN 2
		WHEN 3 THEN 3
		ELSE 4
		END
		


	