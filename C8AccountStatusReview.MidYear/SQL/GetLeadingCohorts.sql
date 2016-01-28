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
--Combine ACTIVE STUDENTS with Game Version, 
--Compare Grade and Over All Progress Time Data
ACTIVE_STUDENTS_OVERALL_PROGRESS_RESULTS AS (
	SELECT	C.OverallProgressTime,
			C.StudentId,
			C.CohortId,
			CONVERT(FLOAT,FLOOR(C.GameVersionPlayed))	as game_version,
			CASE WHEN SGI.Grade < 0 THEN 0
				 WHEN SGI.Grade > 7 THEN 100
				 ELSE SGI.Grade
			END grade
		
	FROM	C8Reporting.dbo.CompareStudentInfo C
	
			INNER JOIN C8Data.dbo.SessionGameInfo SGI ON
			C.StudentId = SGI.StudentId AND
			C.CohortId = SGI.CohortId
			
	WHERE	
		EXISTS(	SELECT * 
					FROM	ACTIVE_STUDENTS S 
					WHERE	S.StudentId = SGI.StudentId AND
							S.CohortId = SGI.CohortId)
			
),
--ADD Overall Progress Rating and artificial id to be
--used to determine the last Overall Progress Rating for
--that Student
ASOPR_WITH_OVERALL_RATING AS (


SELECT	C.OverallProgressRating,
		C.StudentId,
		C.CohortId,
		TP.OverallProgressTime,
		TP.Grade,
		TP.game_version,
		ROW_NUMBER() OVER(PARTITION BY C.StudentId,C.CohortId ORDER BY C.EndScheduleTimePlayed DESC) as id
FROM	C8Reporting.dbo.CompareCCCTable C

		INNER JOIN ACTIVE_STUDENTS_OVERALL_PROGRESS_RESULTS TP ON
		C.StudentId = TP.StudentId AND
		C.CohortId = TP.CohortId
		
WHERE	
		 ( 
				0 = 0  
					OR 
				60000 BETWEEN StartScheduleTimePlayed and EndScheduleTimePlayed
			)
		
) ,
--This is used as an Artificial Key to link the compare students data
--back to the ACTIVE STUDENTS
COMPARE_CRITERIA AS (
	SELECT	DISTINCT
			T.grade,
			T.game_version,
			T.OverallProgressTime AS time_played,
			T.OverallProgressRating
			
	FROM	ASOPR_WITH_OVERALL_RATING T
	WHERE	T.id = 1
),
--COMPARE STUDENTS BASED on the Compare Criteria Defined
--in the COMPARE_CRITERIA SET and the OverallProgress Time
--for those Students at the time of the compare criteria
COMPARE_STUDENTS AS (
SELECT	DISTINCT C.StudentId, 
				 C.CohortId,
				 C.OverallProgressTime,
				 
				 CC.time_played as time_played_criteria,
				 CC.grade as grade_criteria,
				 CC.game_version as game_version_criteria,
				 CC.OverallProgressRating	
				 	
		FROM	C8Reporting.dbo.CompareStudentInfo C
		
				INNER JOIN COMPARE_CRITERIA CC ON
				C.CompareGrade = CC.grade AND
				C.GameVersionPlayed >= CC.game_version AND
				C.OverallProgressTime >= CC.time_played
		
				

),
--COUNT OF THE COMPARE STUDENTS GROUP BY the COMPARE Criteria
--and will be the DENOMINATOR for the final Calculations
COUNT_COMPARE_STUDENTS AS (
	SELECT	COUNT(*) as student_count,
			CS.game_version_criteria,
			CS.time_played_criteria,
			CS.grade_criteria,
			CS.OverallProgressRating
			
	FROM	COMPARE_STUDENTS CS
	
	GROUP BY
			CS.game_version_criteria,
			CS.time_played_criteria,
			CS.grade_criteria,
			CS.OverallProgressRating
			
),
--This SET represents the NUMERATOR of the final Calculation. In
--order to just get distinct student cohort combination records
--it was necessary create an artificial key combining StudentId
--and CohortId to eliminate duplicates caused by OverallProgressRating
COMPARE_DATA AS (

SELECT	DISTINCT
		COUNT(DISTINCT CONVERT(VARCHAR(50),CS.StudentId) + 
					   CONVERT(VARCHAR(50),CS.CohortId)) as rows,
		CS.game_version_criteria,
		CS.grade_criteria,
		CS.time_played_criteria

FROM	COMPARE_STUDENTS CS

		INNER JOIN C8Reporting.dbo.CompareCCCTable CT ON
		CS.CohortId = CT.CohortId AND
		CS.StudentId = CT.StudentId AND
		CS.time_played_criteria BETWEEN CT.StartScheduleTimePlayed AND CT.EndScheduleTimePlayed AND
		CT.OverallProgressRating <= CS.OverallProgressRating
GROUP BY
		CS.game_version_criteria,
		CS.grade_criteria,
		CS.time_played_criteria
		
),
GAME_SESSIONS AS (
			SELECT	COUNT(SDH.Id) as sessions,
					S.StudentId,
					S.CohortId,
					S.name
					
			FROM	C8Data.dbo.StudentSessionDayHistory SDH
			
					INNER JOIN ACTIVE_STUDENTS S ON
					SDH.CohortId = S.CohortId AND
					SDH.StudentId = S.StudentId
					
			GROUP BY
					S.StudentId,
					S.CohortId,
					S.name
					
),
--Combing the ACTIVE STUDENTS with COMPARE DATA which
--contains the NUMERATOR and COUNT COMPARE STUDENTS which 
--contains the DENOMINATOR in order to calculate that students
--percentile. It is necessary to use the artifial key of id in 
--the ASPOR_WITH_OVERALL_RATING to just get the current compare 
--data for the ACTIVE STUDENTS. 
COMBINED AS ( 


SELECT	BS.CohortId,
		BS.StudentId,
		--dbo.fnCalcStudentProgressPercent(BS.StudentId,BS.CohortId,6,0) as per,
		CONVERT(float,CD.rows)  /
		CONVERT(float,CCC.student_count) as percentile,
		CD.rows as DENOMINATOR,
		CCC.student_count as NUMERATOR,
		BS.game_version,
		BS.grade,
		BS.OverallProgressTime,
		BS.OverallProgressRating,
		GS.sessions
		

FROM	(SELECT * FROM ASOPR_WITH_OVERALL_RATING WHERE id = 1) BS

		INNER JOIN COMPARE_DATA CD ON
		BS.OverallProgressTime = CD.time_played_criteria AND
		BS.game_version = CD.game_version_criteria AND
		BS.grade = CD.grade_criteria 
		
		INNER JOIN COUNT_COMPARE_STUDENTS CCC ON 
		BS.OverallProgressTime = CCC.time_played_criteria AND
		BS.game_version = CCC.game_version_criteria AND
		BS.grade = CCC.grade_criteria AND
		BS.OverallProgressRating = CCC.OverallProgressRating
		
		INNER JOIN GAME_SESSIONS GS ON
		BS.StudentId = GS.StudentId AND
		BS.CohortId = GS.CohortId
	
)


		
SELECT	TOP 3
		C.CohortId,
		BS.CohortName,
		BS.SchoolId,
		BS.TeacherName,
		DENSE_RANK() OVER(PARTITION BY BS.SchoolId ORDER BY AVG(C.percentile) DESC) as rank,
		AVG(C.percentile) as avg_percentile,
		AVG(C.sessions) as avg_sessions

		
FROM	COMBINED C
		
		INNER JOIN BS_INFO BS ON
		C.CohortId = BS.CohortId 
		
GROUP BY	C.CohortId,
			BS.CohortName,
			BS.SchoolId,
			BS.TeacherName

ORDER BY
	BS.SchoolId,
	AVG(C.percentile) DESC




