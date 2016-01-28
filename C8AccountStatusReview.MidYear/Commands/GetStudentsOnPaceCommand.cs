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
    public class GetStudentsOnPaceCommand
    {
        private string connectionString;

        public GetStudentsOnPaceCommand(string connectionString)
        {
            if (connectionString == null) throw new ArgumentNullException("connectionString");
            this.connectionString = connectionString;
        }

        public List<Models.OnTrackModel> Execute(Guid SchoolId)
        {
            using (var connection = new SqlConnection(this.connectionString))
            {
                return
                    connection.
                    Query(sql: My.Resources.StudentsOnPace,
                          param: new { @SchoolId = SchoolId },
                          commandType: CommandType.Text).
                    Select(r => new Models.OnTrackModel
                    {
                        Category = r.pace_category,
                        Percentage = r.number_of_students,
                        SchoolId = SchoolId
                    }).
                    ToList();
            }
        }
    }
}
