using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using My = C8AccountStatusReview.Runner.Properties;
using C8AccountStatusReview.MidYear;

namespace C8AccountStatusReview.Runner
{
    class Program
    {
        static MidYear.Commands.GetStatsCommand getStats;
        static MidYear.Commands.GetStudentsCompletingReports getStudentsCompletingReports;
        static MidYear.Commands.GetStudentsOnPaceCommand getStudentsOnPace;
        static MidYear.Commands.GetParentModelCommand getParentModel;
        static MidYear.Commands.GetCognitiveWeaknessesCommand getCognitiveWeaknesses;
        static MidYear.Commands.GetLeadingCohortsCommand getLeadingCohorts;

        static void Main(string[] args)
        {
            var getAccounts = new MidYear.Commands.GetAccountsCommand(My.Settings.Default.C8Data);
            var accounts = getAccounts.Execute();
            var definitions = new MidYear.ValueObjects.ReportDefinitions
            {
                CognitiveReportsUnlockedPath = My.Settings.Default.CognitiveReportsUnlockedPath,
                LeadingCohortsPath = My.Settings.Default.LeadingCohortsPath,
                MidYearReportPath =  My.Settings.Default.MidYearReportPath,
                CognitiveWeaknessesPath = My.Settings.Default.CognitiveWeaknessesPath,
                StatsChartPath = My.Settings.Default.StatsChartPath,
                StudentsOnTrackPath = My.Settings.Default.StudentsOnTrackPath
            };

            getStats = new MidYear.Commands.GetStatsCommand(My.Settings.Default.C8Data);
            getStudentsCompletingReports = new MidYear.Commands.GetStudentsCompletingReports(My.Settings.Default.C8Data);
            getStudentsOnPace = new MidYear.Commands.GetStudentsOnPaceCommand(My.Settings.Default.C8Data);
            getParentModel = new MidYear.Commands.GetParentModelCommand(My.Settings.Default.C8Data);
            getCognitiveWeaknesses = new MidYear.Commands.GetCognitiveWeaknessesCommand(My.Settings.Default.C8Data);
            getLeadingCohorts = new MidYear.Commands.GetLeadingCohortsCommand(My.Settings.Default.C8Data);

            var rpt = new MidYear.Services.MidYearSchoolReport(definitions);

            accounts.Where(a => a.Schools.Any(s => s.SchoolId.Equals(Guid.Parse("5a30f70a-c2f6-4e57-b848-b484ce8080d7")))).ToList().
                ForEach(a => a.Schools.
                ForEach(s =>
                {
                    try
                    {
                        var model = GetModel(s.SchoolId);
                        var accountName = a.AccountName.Replace(" ", "");

                        rpt.Generate(model, string.Format(@"./{0}-{1}.pdf", accountName, s.SchoolId.ToString()));
                    }
                    catch (Exception e)
                    {
                        System.Diagnostics.Debug.WriteLine(e.ToString());
                    };

                }
                        )
                );
        }

        private static MidYear.Models.ReportModel GetModel(Guid SchoolId)
        {
            var reportData = new MidYear.Models.ReportModel
            {
                MidYearReportData = new List<MidYear.Models.ParentModel>(new MidYear.Models.ParentModel[]
                {
                    getParentModel.Execute(SchoolId)
                }),
                BasicStats =
                    new List<MidYear.Models.BasicStatsModel>(new MidYear.Models.BasicStatsModel[]
                    {
                        getStats.Execute(SchoolId)
                    }),
                CognitiveWeakness = getCognitiveWeaknesses.Execute(SchoolId),
                LeadingCohorts = getLeadingCohorts.Execute(SchoolId),
                OnTrack = getStudentsOnPace.Execute(SchoolId),
                UnlockedReports = getStudentsCompletingReports.Execute(SchoolId)
            };

            return reportData;
        }
    }
}
