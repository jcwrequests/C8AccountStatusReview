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
    public class GetAccountsCommand
    {
        private string connectionString;

        public GetAccountsCommand(string connectionString)
        {
            if (connectionString == null) throw new ArgumentNullException("connectionString");
            this.connectionString = connectionString;
        }
        public List<Models.AccountsModel> Execute()
        {
            using (var connection = new SqlConnection(this.connectionString))
            {
                return connection.
                    Query(sql: My.Resources.GetAccounts,
                          commandType: CommandType.Text).
                          Select(rs => new
                          {
                              AccountName = rs.AccountName,
                              AccountId = rs.AccountId,
                              SchoolId = rs.SchoolId,
                              SchoolName = rs.SchoolName
                          }).
                          Where(w => w.SchoolId != null).
                          GroupBy(keySelector: ks => Tuple.Create(ks.AccountId, ks.AccountName),
                                  elementSelector: es => es).
                            Select(s =>
                            {
                                return new Models.AccountsModel
                                {
                                    AccountId = s.Key.Item1,
                                    AccountName = s.Key.Item2,
                                    Schools = s.Select(si => new Models.SchoolsModel
                                    {
                                        SchoolId = si.SchoolId,
                                        SchoolName = si.SchoolName
                                    }).
                                        ToList()
                                };
                            }).ToList();

            }


        }
    }
}
