using Microsoft.Reporting.WinForms;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;


namespace C8AccountStatusReview.MidYear.Services
{
    public class MidYearSchoolReport
    {

        private ValueObjects.ReportDefinitions definitions;
        public MidYearSchoolReport(ValueObjects.ReportDefinitions definitions)
        {
            if (definitions == null) throw new ArgumentNullException("definitions");
            this.definitions = definitions;
        }
        public void Generate(Models.ReportModel reportModel, string destinationPath)
        {
            using (LocalReport localReport = new LocalReport())
            {
                localReport.DataSources.Add(new ReportDataSource("DataSet1", reportModel.MidYearReportData));

                Func<string, System.IO.FileStream> openReadOnlyStream =
                    (file) => System.IO.File.Open(file, System.IO.FileMode.Open, System.IO.FileAccess.Read);

                localReport.LoadSubreportDefinition("StatsChart",
                    System.IO.StringReader.Synchronized(new System.IO.StreamReader(this.definitions.StatsChartPath)));

                localReport.LoadSubreportDefinition("CognitiveReportsUnlocked",
                    System.IO.StringReader.Synchronized(new System.IO.StreamReader(this.definitions.CognitiveReportsUnlockedPath)));

                localReport.LoadSubreportDefinition("StudentsOnTrack",
                    System.IO.StringReader.Synchronized(new System.IO.StreamReader(this.definitions.StudentsOnTrackPath)));

                localReport.LoadSubreportDefinition("CognitiveWeaknesses",
                    System.IO.StringReader.Synchronized(new System.IO.StreamReader(this.definitions.CognitiveWeaknessesPath)));

                localReport.LoadSubreportDefinition("LeadingCohorts",
                    System.IO.StringReader.Synchronized(new System.IO.StreamReader(this.definitions.LeadingCohortsPath)));

                SubreportProcessingEventHandler processSubreport = (s, e) =>
                {
                    if (e.ReportPath == "StatsChart")
                    {
                        e.DataSources.Add(new ReportDataSource("DataSet1", reportModel.BasicStats));
                    }
                    if (e.ReportPath == "CognitiveReportsUnlocked")
                    {
                        e.DataSources.Add(new ReportDataSource("DataSet1", reportModel.UnlockedReports));
                    }

                    if (e.ReportPath == "StudentsOnTrack")
                    {
                        e.DataSources.Add(new ReportDataSource("DataSet1", reportModel.OnTrack));
                    }

                    if (e.ReportPath == "CognitiveWeaknesses")
                    {
                        e.DataSources.Add(new ReportDataSource("DataSet1", reportModel.CognitiveWeakness));
                    }

                    if (e.ReportPath == "LeadingCohorts")
                    {
                        e.DataSources.Add(new ReportDataSource("DataSet1", reportModel.LeadingCohorts));
                    }
                };

                localReport.SubreportProcessing += processSubreport;
                localReport.ReportPath = this.definitions.MidYearReportPath;

                byte[] completedReport = localReport.Render("PDF");

                using (var writer = new System.IO.FileStream(destinationPath, System.IO.FileMode.Create))
                {
                    writer.Write(completedReport, 0, completedReport.Count());
                }
                localReport.SubreportProcessing -= processSubreport;

            }

        }



    }
}
