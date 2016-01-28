using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace C8AccountStatusReview.MidYear.Models
{
    public class ParentModel
    {
        public Guid SchoolId { get; set; }
        public string SchoolName { get; set; }
        public int WeeklyReportsDelivered { get; set; }
        public int EarlyWaringsIssued { get; set; }
        public string CurrentSchoolYearTitle { get; set; }
    }
}
