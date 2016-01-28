SELECT	DISTINCT
		A.AccountName,
		LC.AccountId,
		S.Id as SchoolId,
		S.Name as SchoolName,
		S.Type as SchoolType
		
  FROM	C8Data.dbo.LogicalContainer LC 
		
		INNER JOIN C8Data.dbo.LogicalContainer P ON
		LC.ParentId = P.Id
		
		INNER JOIN C8Data.dbo.LogicalContainer SC ON
		P.ParentId = SC.Id
		
		INNER JOIN C8Data.dbo.Account A ON
		LC.AccountId = A.Id
		
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