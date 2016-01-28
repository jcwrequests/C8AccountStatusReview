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
    public class GetStatsCommand
    {
        private string connectionString;

        public GetStatsCommand(string connectionString)
        {
            if (connectionString == null) throw new ArgumentNullException("connectionString");
            this.connectionString = connectionString;
        }

        public Models.BasicStatsModel Execute(Guid SchoolId)
        {
            using (var connection = new SqlConnection(this.connectionString))
            {
                return
                connection.
                    Query(sql: My.Resources.StatsChart,
                          param: new { @SchoolId = SchoolId },
                          commandType: CommandType.Text).
                    Select(r => new Models.BasicStatsModel
                    {
                        ActiveStudents = r.active_students,
                        Cohorts = r.cohorts,
                        LastLogingDate = r.last_login_date,
                        SchoolId = SchoolId,
                        TotalMinutesPlayed = r.total_minutes_played
                    }).
                    First();
            }
        }
    }
}
