using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace C8AccountStatusReview.MidYear.Models
{
    public class LeadingCohortsModel
    {
        public Guid SchoolId { get; set; }
        public string CohortName { get; set; }
        public string Teacher { get; set; }
        public Decimal AvgSessions { get; set; }
        public Decimal AvgPercentiles { get; set; }
    }
}
