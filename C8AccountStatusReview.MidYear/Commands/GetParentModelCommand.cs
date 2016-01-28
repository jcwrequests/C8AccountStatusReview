using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;
using Dapper;
using My = C8AccountStatusReview.MidYear.Properties;

namespace C8AccountStatusReview.MidYear.Commands
{
    public class GetParentModelCommand
    {
        private string connectionString;

        public GetParentModelCommand(string connectionString)
        {
            if (connectionString == null) throw new ArgumentNullException("connectionString");
            this.connectionString = connectionString;
        }

        public Models.ParentModel Execute(Guid SchoolId)
        {
            using (var connection = new SqlConnection(this.connectionString))
            {
                var result =
                    connection.
                    Query(sql: My.Resources.WeeklyReportsDelivered,
                          param: new { @SchoolId = SchoolId },
                          commandType: CommandType.Text).
                    Select(r => new
                    {
                        emailCount = r.emails,
                        emailType = (string)r.type,
                        schoolName = r.SchoolName
                    }).
                    ToList();

                var warnings =
                    connection.
                    Query(sql: My.Resources.CognitiveWeakness,
                          param: new { @SchoolId = SchoolId },
                          commandType: CommandType.Text).
                    Select(r => (int)r.trigger_count).
                    Sum();

                return new Models.ParentModel
                {
                    CurrentSchoolYearTitle = "For School Year 2015 - 2016",
                    EarlyWaringsIssued = warnings,
                    WeeklyReportsDelivered = result.Where(r => r.emailType.Equals("Weekly", StringComparison.InvariantCultureIgnoreCase)).First().emailCount,
                    SchoolName = result.First().schoolName,
                    SchoolId = SchoolId
                };
            }
        }
    }
}
