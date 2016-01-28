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
    public class GetLeadingCohortsCommand
    {
        private string connectionString;

        public GetLeadingCohortsCommand(string connectionString)
        {
            if (connectionString == null) throw new ArgumentNullException("connectionString");
            this.connectionString = connectionString;
        }

        public List<Models.LeadingCohortsModel> Execute(Guid SchoolId)
        {
            using (var connection = new SqlConnection(this.connectionString))
            {
                return
                    connection.
                    Query(sql: My.Resources.GetLeadingCohorts,
                          param: new { @SchoolId = SchoolId },
                          commandType: CommandType.Text,
                          commandTimeout: 90).
                    Select(r => new Models.LeadingCohortsModel
                    {
                        AvgPercentiles = Convert.ToDecimal(r.avg_percentile),
                        AvgSessions = Convert.ToDecimal(r.avg_sessions),
                        Teacher = r.TeacherName,
                        CohortName = r.CohortName,
                        SchoolId = SchoolId
                    }).
                    ToList();
            }
        }
    }
}
