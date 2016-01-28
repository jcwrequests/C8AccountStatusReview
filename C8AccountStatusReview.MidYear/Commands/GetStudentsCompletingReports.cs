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
    public class GetStudentsCompletingReports
    {
        private string connectionString;

        public GetStudentsCompletingReports(string connectionString)
        {
            if (connectionString == null) throw new ArgumentNullException("connectionString");
            this.connectionString = connectionString;
        }

        public List<Models.CognitiveReportsUnlockedModel> Execute(Guid SchoolId)
        {
            using (var connection = new SqlConnection(this.connectionString))
            {
                return
                    connection.
                    Query(sql: My.Resources.StudentsCompleteReports,
                          param: new { @SchoolId = SchoolId },
                          commandType: CommandType.Text).
                    Select(r => new Models.CognitiveReportsUnlockedModel
                    {
                        Category = r.category,
                        CategoryOrder = r.category_order,
                        ReportCount = r.count,
                        SchoolId = SchoolId
                    }).
                    ToList();
            }
        }
    }
}
