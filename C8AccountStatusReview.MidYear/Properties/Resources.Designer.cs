﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.42000
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace C8AccountStatusReview.MidYear.Properties {
    using System;
    
    
    /// <summary>
    ///   A strongly-typed resource class, for looking up localized strings, etc.
    /// </summary>
    // This class was auto-generated by the StronglyTypedResourceBuilder
    // class via a tool like ResGen or Visual Studio.
    // To add or remove a member, edit your .ResX file then rerun ResGen
    // with the /str option, or rebuild your VS project.
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("System.Resources.Tools.StronglyTypedResourceBuilder", "4.0.0.0")]
    [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
    [global::System.Runtime.CompilerServices.CompilerGeneratedAttribute()]
    internal class Resources {
        
        private static global::System.Resources.ResourceManager resourceMan;
        
        private static global::System.Globalization.CultureInfo resourceCulture;
        
        [global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode")]
        internal Resources() {
        }
        
        /// <summary>
        ///   Returns the cached ResourceManager instance used by this class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Resources.ResourceManager ResourceManager {
            get {
                if (object.ReferenceEquals(resourceMan, null)) {
                    global::System.Resources.ResourceManager temp = new global::System.Resources.ResourceManager("C8AccountStatusReview.MidYear.Properties.Resources", typeof(Resources).Assembly);
                    resourceMan = temp;
                }
                return resourceMan;
            }
        }
        
        /// <summary>
        ///   Overrides the current thread's CurrentUICulture property for all
        ///   resource lookups using this strongly typed resource class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Globalization.CultureInfo Culture {
            get {
                return resourceCulture;
            }
            set {
                resourceCulture = value;
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to  DECLARE @START_DATE DATETIME = &apos;08/01/2015&apos;;
        /// WITH BS_INFO AS (
        /// SELECT	
        ///		A.AccountName,
        ///		LC.AccountId,
        ///		LC.Id as CohortId,
        ///		LC.Name as CohortName,
        ///		S.Id as SchoolId,
        ///		S.Name as SchoolName,
        ///		S.Type as SchoolType,
        ///		UI.LastName as TeacherName
        ///		
        ///  FROM	C8Data.dbo.LogicalContainer LC 
        ///		
        ///		INNER JOIN C8Data.dbo.LogicalContainer P ON
        ///		LC.ParentId = P.Id
        ///		
        ///		INNER JOIN C8Data.dbo.LogicalContainer SC ON
        ///		P.ParentId = SC.Id
        ///		
        ///		INNER JOIN C8Data.dbo.Account A ON
        ///		LC.AccountId = A [rest of string was truncated]&quot;;.
        /// </summary>
        internal static string CognitiveWeakness {
            get {
                return ResourceManager.GetString("CognitiveWeakness", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to SELECT	DISTINCT
        ///		A.AccountName,
        ///		LC.AccountId,
        ///		S.Id as SchoolId,
        ///		S.Name as SchoolName,
        ///		S.Type as SchoolType
        ///		
        ///  FROM	C8Data.dbo.LogicalContainer LC 
        ///		
        ///		INNER JOIN C8Data.dbo.LogicalContainer P ON
        ///		LC.ParentId = P.Id
        ///		
        ///		INNER JOIN C8Data.dbo.LogicalContainer SC ON
        ///		P.ParentId = SC.Id
        ///		
        ///		INNER JOIN C8Data.dbo.Account A ON
        ///		LC.AccountId = A.Id
        ///		
        ///		LEFT OUTER JOIN C8Data.dbo.LogicalContainer S ON
        ///		SC.Id = S.Id AND
        ///		0 = S.IsDeleted AND
        ///        1 = S.ContainerStatusId AND [rest of string was truncated]&quot;;.
        /// </summary>
        internal static string GetAccounts {
            get {
                return ResourceManager.GetString("GetAccounts", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to WITH BS_INFO AS (
        /// SELECT	
        ///		A.AccountName,
        ///		LC.AccountId,
        ///		LC.Id as CohortId,
        ///		LC.Name as CohortName,
        ///		S.Id as SchoolId,
        ///		S.Name as SchoolName,
        ///		S.Type as SchoolType,
        ///		UI.LastName as TeacherName
        ///		
        ///  FROM	C8Data.dbo.LogicalContainer LC 
        ///		
        ///		INNER JOIN C8Data.dbo.LogicalContainer P ON
        ///		LC.ParentId = P.Id
        ///		
        ///		INNER JOIN C8Data.dbo.LogicalContainer SC ON
        ///		P.ParentId = SC.Id
        ///		
        ///		INNER JOIN C8Data.dbo.Account A ON
        ///		LC.AccountId = A.Id
        ///		
        ///		INNER JOIN C8Data.dbo.ObjectOwnership [rest of string was truncated]&quot;;.
        /// </summary>
        internal static string GetLeadingCohorts {
            get {
                return ResourceManager.GetString("GetLeadingCohorts", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to DECLARE @START_DATE DATETIME = &apos;08/01/2015&apos;;
        ///WITH BS_INFO AS (
        /// SELECT	
        ///		A.AccountName,
        ///		LC.AccountId,
        ///		LC.Id as CohortId,
        ///		LC.Name as CohortName,
        ///		S.Id as SchoolId,
        ///		S.Name as SchoolName,
        ///		S.Type as SchoolType,
        ///		UI.LastName as TeacherName
        ///		
        ///  FROM	C8Data.dbo.LogicalContainer LC 
        ///		
        ///		INNER JOIN C8Data.dbo.LogicalContainer P ON
        ///		LC.ParentId = P.Id
        ///		
        ///		INNER JOIN C8Data.dbo.LogicalContainer SC ON
        ///		P.ParentId = SC.Id
        ///		
        ///		INNER JOIN C8Data.dbo.Account A ON
        ///		LC.AccountId = A.I [rest of string was truncated]&quot;;.
        /// </summary>
        internal static string StatsChart {
            get {
                return ResourceManager.GetString("StatsChart", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to WITH BS_INFO AS (
        /// SELECT	
        ///		A.AccountName,
        ///		LC.AccountId,
        ///		LC.Id as CohortId,
        ///		LC.Name as CohortName,
        ///		S.Id as SchoolId,
        ///		S.Name as SchoolName,
        ///		S.Type as SchoolType,
        ///		UI.LastName as TeacherName
        ///		
        ///  FROM	C8Data.dbo.LogicalContainer LC 
        ///		
        ///		INNER JOIN C8Data.dbo.LogicalContainer P ON
        ///		LC.ParentId = P.Id
        ///		
        ///		INNER JOIN C8Data.dbo.LogicalContainer SC ON
        ///		P.ParentId = SC.Id
        ///		
        ///		INNER JOIN C8Data.dbo.Account A ON
        ///		LC.AccountId = A.Id
        ///		
        ///		INNER JOIN C8Data.dbo.ObjectOwnership [rest of string was truncated]&quot;;.
        /// </summary>
        internal static string StudentsCompleteReports {
            get {
                return ResourceManager.GetString("StudentsCompleteReports", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to DECLARE @START_DATE DATETIME = &apos;08/01/2015&apos;;
        ///
        ///WITH 
        /// BS_INFO AS (
        /// SELECT	
        ///		A.AccountName,
        ///		LC.AccountId,
        ///		LC.Id as CohortId,
        ///		LC.Name as CohortName,
        ///		S.Id as SchoolId,
        ///		S.Name as SchoolName,
        ///		S.Type as SchoolType,
        ///		UI.LastName as TeacherName
        ///		
        ///  FROM	C8Data.dbo.LogicalContainer LC 
        ///		
        ///		INNER JOIN C8Data.dbo.LogicalContainer P ON
        ///		LC.ParentId = P.Id
        ///		
        ///		INNER JOIN C8Data.dbo.LogicalContainer SC ON
        ///		P.ParentId = SC.Id
        ///		
        ///		INNER JOIN C8Data.dbo.Account A ON
        ///		LC.AccountId  [rest of string was truncated]&quot;;.
        /// </summary>
        internal static string StudentsOnPace {
            get {
                return ResourceManager.GetString("StudentsOnPace", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to 
        ///--SELECT TOP 1000 [alert_type_id]
        ///--      ,[alert_type_description]
        ///--  FROM [C8Data].[dbo].[EF_ALERT_TYPES];
        ///  
        ///  DECLARE @START_DATE DATETIME = &apos;08/01/2015&apos;;
        ///  
        /// WITH 
        /// BS_INFO AS (
        /// SELECT	
        ///		A.AccountName,
        ///		LC.AccountId,
        ///		LC.Id as CohortId,
        ///		LC.Name as CohortName,
        ///		S.Id as SchoolId,
        ///		S.Name as SchoolName,
        ///		S.Type as SchoolType,
        ///		UI.LastName as TeacherName
        ///		
        ///  FROM	C8Data.dbo.LogicalContainer LC 
        ///		
        ///		INNER JOIN C8Data.dbo.LogicalContainer P ON
        ///		LC.ParentId = P.Id
        ///		
        ///		I [rest of string was truncated]&quot;;.
        /// </summary>
        internal static string WeeklyReportsDelivered {
            get {
                return ResourceManager.GetString("WeeklyReportsDelivered", resourceCulture);
            }
        }
    }
}