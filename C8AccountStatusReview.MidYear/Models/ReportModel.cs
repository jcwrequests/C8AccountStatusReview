using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace C8AccountStatusReview.MidYear.Models
{
    public class ReportModel
    {
        public List<ParentModel> MidYearReportData { get; set; }
        public List<LeadingCohortsModel> LeadingCohorts { get; set; }
        public List<BasicStatsModel> BasicStats { get; set; }
        public List<CognitiveReportsUnlockedModel> UnlockedReports { get; set; }
        public List<OnTrackModel> OnTrack { get; set; }
        public List<CognitiveWeaknessFlagModel> CognitiveWeakness { get; set; }
    }
}
